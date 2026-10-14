describe("catalog.opts.handle_ft_event", function()
	local handle
	local log = { DBG = function() end, WRN = function() end }
	local original_notify = vim.notify

	---Names the fake provider recognizes; the rest resolve to nothing.
	local providable = {
		["lua-language-server"] = true,
		stylua = true,
		luacheck = true,
		["typescript-language-server"] = true,
		["eslint-lsp"] = true,
		prettierd = true,
	}

	before_each(function()
		pcall(vim.api.nvim_del_augroup_by_name, "catalog.handle_ft_event")
		vim.notify = function() end

		package.loaded["catalog.providers"] = nil
		package.loaded["catalog.opts.handle_ft_event"] = nil

		require("catalog.providers"):sub({
			name = "fake",
			try_provide = function(_, name)
				if providable[name] then
					return { name = name, provider_name = "fake" }
				end
			end,
			provide = function(self, name)
				return self:try_provide(name)
			end,
		})

		handle = require("catalog.opts.handle_ft_event")
	end)

	after_each(function()
		pcall(vim.api.nvim_del_augroup_by_name, "catalog.handle_ft_event")
		vim.notify = original_notify
	end)

	---@param ft string
	local function fire(ft)
		-- Scope to our group so the runtime ftplugins (which may need a
		-- treesitter parser that headless runs lack) are not triggered.
		vim.api.nvim_exec_autocmds("FileType", { pattern = ft, group = "catalog.handle_ft_event" })
	end

	---@return integer
	local function registered()
		local ok, autocmds = pcall(vim.api.nvim_get_autocmds, { group = "catalog.handle_ft_event", event = "FileType" })
		return ok and #autocmds or 0
	end

	it("does nothing when the payload is not a function", function()
		handle.setup({ payload = true, log = log })
		assert.equals(0, registered())
	end)

	it("registers a single FileType autocommand for a function payload", function()
		handle.setup({ payload = function() end, log = log })
		assert.equals(1, registered())
	end)

	it("passes the filetype and resolved packages to the callback", function()
		local calls = {}
		handle.setup({
			payload = function(ft, lsps, formatters, linters)
				calls[#calls + 1] = { ft = ft, lsps = lsps, formatters = formatters, linters = linters }
			end,
			log = log,
		})

		fire("lua")

		assert.equals(1, #calls)
		local call = calls[1]
		assert.equals("lua", call.ft)
		assert.is_not_nil(call.lsps["lua-language-server"])
		assert.is_not_nil(call.formatters.stylua)
		assert.is_not_nil(call.linters.luacheck)
	end)

	it("resolves every package listed for a kind", function()
		local resolved
		handle.setup({
			payload = function(_, lsps)
				resolved = lsps
			end,
			log = log,
		})

		fire("typescript")

		assert.is_not_nil(resolved["typescript-language-server"])
		assert.is_not_nil(resolved["eslint-lsp"])
	end)

	it("reports a configured kind that resolved to nothing as an empty map", function()
		local captured
		handle.setup({
			payload = function(_, lsps, formatters, linters)
				captured = { lsps = lsps, formatters = formatters, linters = linters }
			end,
			log = log,
		})

		fire("toml")

		assert.is_not_nil(captured.lsps)
		assert.is_nil(next(captured.lsps))
		assert.is_nil(captured.formatters)
		assert.is_nil(captured.linters)
	end)

	it("runs the callback at most once per filetype", function()
		local count = 0
		handle.setup({
			payload = function()
				count = count + 1
			end,
			log = log,
		})

		fire("lua")
		fire("lua")
		assert.equals(1, count)
	end)

	it("ignores filetypes that are not mapped", function()
		local count = 0
		handle.setup({
			payload = function()
				count = count + 1
			end,
			log = log,
		})

		fire("not_a_filetype")
		assert.equals(0, count)
	end)
end)
