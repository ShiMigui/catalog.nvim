describe("catalog.lsp", function()
	local lsp, provider
	local original_notify
	local notified ---@type {msg: string, level: vim.log.levels}[]

	---Registers a fake provider for `names`, returning Pkg fakes that record
	---install/update/enable calls.
	---@param names table<string, boolean>
	local function register_pkg_provider(names)
		local recorded = { installed = {}, updated = {}, enabled = {} }
		provider.append("fake", function(name)
			if not names[name] then
				return nil
			end
			return {
				name = name,
				provider_name = "fake",
				lsp = {
					update = function(_, cfg)
						recorded.updated[name] = cfg
					end,
					enable = function()
						recorded.enabled[name] = true
					end,
				},
				installed = function()
					return false
				end,
				install = function()
					recorded.installed[name] = true
				end,
			}
		end)
		return recorded
	end

	before_each(function()
		for _, module in ipairs({ "catalog.provider", "catalog.scripts.ensure_installed", "catalog.lsp" }) do
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

	it("merges user defaults over the internal default config", function()
		local capabilities = lsp.default_config.capabilities
		lsp.setup({ default = { flags = { debounce_text_changes = 999 } } })

		assert.equals(999, lsp.default_config.flags.debounce_text_changes)
		assert.equals(capabilities, lsp.default_config.capabilities)
	end)

	it("installs, updates and enables every configured server", function()
		local recorded = register_pkg_provider({ lua_ls = true })
		lsp.setup({ config_by = { lua_ls = { settings = { Lua = { v = "5.4" } } } } })

		assert.equals(true, recorded.installed.lua_ls)
		assert.equals("5.4", recorded.updated.lua_ls.settings.Lua.v)
		assert.equals(true, recorded.enabled.lua_ls)
		assert.not_nil(lsp.configured_lsps.lua_ls)
	end)

	it("ignores configured servers that no provider can resolve", function()
		register_pkg_provider({})
		lsp.setup({ config_by = { ghost = {} } })

		assert.is_nil(next(lsp.configured_lsps))
	end)

	it("logs an error and stops when config_by is not a table", function()
		register_pkg_provider({ lua_ls = true })
		lsp.setup({ config_by = "oops" })

		assert.equals(vim.log.levels.ERROR, notified[1].level)
		assert.is_nil(next(lsp.configured_lsps))
	end)
end)
