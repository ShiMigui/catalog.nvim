describe("catalog.lsp.config", function()
	local original_lsp_api = {
		is_enabled = vim.lsp.is_enabled,
		config = vim.lsp.config,
		enable = vim.lsp.enable,
	}
	local state ---@type {enabled: table<string, boolean>, configured: table<string, vim.lsp.Config>}

	before_each(function()
		state = { enabled = {}, configured = {} }
		vim.lsp.is_enabled = function(name)
			return state.enabled[name] == true
		end
		vim.lsp.config = function(name, cfg)
			state.configured[name] = cfg
		end
		vim.lsp.enable = function(name)
			state.enabled[name] = true
		end
	end)

	after_each(function()
		for fn, original in pairs(original_lsp_api) do
			vim.lsp[fn] = original
		end
	end)

	local function new(name)
		return require("catalog.lsp.config").new(name)
	end

	it("binds an empty configuration to the server name", function()
		local l = new("lua_ls")
		assert.equals("lua_ls", l.name)
		assert.are_same({}, l.config)
	end)

	it("update deep-merges configurations and chains", function()
		local l = new("lua_ls")
		local ret = l:update({ a = { b = 1 } }):update({ a = { c = 2 } })

		assert.equals(l, ret)
		assert.equals(1, l.config.a.b)
		assert.equals(2, l.config.a.c)
	end)

	it("enable registers the merged config and enables the server", function()
		local l = new("lua_ls")
		l:update({ settings = { Lua = { v = "5.4" } } })
		l:enable()

		assert.equals(l.config, state.configured.lua_ls)
		assert.is_true(state.enabled.lua_ls)
	end)

	it("enable skips servers that are already enabled", function()
		state.enabled.lua_ls = true
		new("lua_ls"):enable()

		assert.are_same({}, state.configured)
	end)

	it("is_enabled mirrors the editor state for the bound server", function()
		local l = new("lua_ls")

		assert.is_false(l:is_enabled())
		state.enabled.lua_ls = true
		assert.is_true(l:is_enabled())
	end)
end)
