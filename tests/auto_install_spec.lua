describe("catalog.auto_install", function()
	local lsp, provider
	local original_notify
	local notified ---@type {msg: string, level: vim.log.levels}[]

	before_each(function()
		for _, module in ipairs({
			"catalog.provider",
			"catalog.scripts.ensure_installed",
			"catalog.lsp",
			"catalog.auto_install",
		}) do
			package.loaded[module] = nil
		end

		original_notify = vim.notify
		notified = {}
		vim.notify = function(msg, level)
			table.insert(notified, { msg = msg, level = level })
		end

		provider = require("catalog.provider")
		lsp = require("catalog.lsp")
	end)

	after_each(function()
		vim.notify = original_notify
	end)

	---Registers a fake provider providing `tools`; values are `"lsp"` (package
	---carries an lsp handle) or `"tool"`. Counters record every side effect.
	---@param tools table<string, "lsp"|"tool">
	local function register_tools(tools)
		local state = { installs = {}, updates = {}, enables = {} }
		provider.append({
			name = "fake",
			provide = function(name)
				if not tools[name] then
					return nil
				end
				local pkg = {
					name = name,
					provider_name = "fake",
					installed = function()
						return false
					end,
					install = function()
						state.installs[name] = (state.installs[name] or 0) + 1
					end,
				}
				if tools[name] == "lsp" then
					pkg.lsp = {
						is_enabled = function()
							return false
						end,
						update = function(_, cfg)
							state.updates[name] = cfg
						end,
						enable = function()
							state.enables[name] = (state.enables[name] or 0) + 1
						end,
					}
				end
				return pkg
			end,
			load_installed = function()
				return {}
			end,
		})
		return state
	end

	---Opens a scratch buffer with the given filetype, firing FileType.
	local function trigger_ft(ft)
		local buf = vim.api.nvim_create_buf(false, true)
		vim.bo[buf].filetype = ft
	end

	it("fast-exits without registering autocmds when nothing is enabled", function()
		require("catalog.auto_install").setup({})

		-- the augroup may not exist at all when the fast exit happens
		local ok, autocmds = pcall(vim.api.nvim_get_autocmds, { group = "catalog.auto_install" })
		assert.is_true(not ok or #autocmds == 0)
	end)

	it("installs only the enabled kinds on first filetype open", function()
		local state = register_tools({
			["lua-language-server"] = "lsp",
			stylua = "tool",
			luacheck = "tool",
		})
		require("catalog.auto_install").setup({ lsp = true, formatter = true })
		trigger_ft("lua")

		assert.equals(1, state.installs["lua-language-server"])
		assert.equals(1, state.installs.stylua)
		assert.equals(lsp.default_config, state.updates["lua-language-server"])
		assert.equals(1, state.enables["lua-language-server"])
		assert.is_nil(state.installs.luacheck)
	end)

	it("expands list entries into one install per package", function()
		local state = register_tools({
			pylsp = "lsp",
			["ruff-lsp"] = "lsp",
			black = "tool",
		})
		require("catalog.auto_install").setup({ lsp = true, formatter = true })
		trigger_ft("python")

		assert.equals(1, state.installs.pylsp)
		assert.equals(1, state.installs["ruff-lsp"])
		assert.equals(1, state.installs.black)
	end)

	it("caches filetypes so later events are no-ops", function()
		local state = register_tools({ stylua = "tool" })
		require("catalog.auto_install").setup({ formatter = true })
		trigger_ft("lua")
		trigger_ft("lua")

		assert.equals(1, state.installs.stylua)
	end)

	it("ignores unmapped filetypes", function()
		local state = register_tools({ stylua = "tool" })
		require("catalog.auto_install").setup({ formatter = true, lsp = true, linter = true })
		trigger_ft("not-a-real-ft")

		assert.equals(nil, next(state.installs))
	end)

	it("skips packages without an lspconfig mapping instead of crashing", function()
		local state = register_tools({ marksman = "tool" }) -- provided to the lsp kind, but has no .lsp handle
		require("catalog.auto_install").setup({ lsp = true })
		trigger_ft("markdown")

		assert.equals(vim.log.levels.WARN, notified[1].level)
		assert.equals(nil, next(state.enables))
	end)
end)
