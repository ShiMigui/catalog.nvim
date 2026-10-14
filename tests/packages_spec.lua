describe("catalog.packages", function()
	local entity
	local state
	local original = {
		is_enabled = vim.lsp.is_enabled,
		config = vim.lsp.config,
		enable = vim.lsp.enable,
	}

	local function noop() end

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

		package.loaded["catalog.opts.lsp"] = nil
		package.loaded["catalog.packages"] = nil
		package.loaded["catalog.packages.package"] = nil
		package.loaded["catalog.packages.lsp"] = nil
		package.loaded["catalog.packages.formatter"] = nil
		entity = require("catalog.packages")
	end)

	after_each(function()
		for name, fn in pairs(original) do
			vim.lsp[name] = fn
		end
	end)

	describe("Package", function()
		it("builds the base package fields", function()
			local pkg = entity.Package("mason", "lua-language-server", "lua_ls", noop, noop)
			assert.equals("mason", pkg.provider_name)
			assert.equals("lua-language-server", pkg.name)
			assert.equals("lua_ls", pkg.exec_name)
			assert.are.equal(noop, pkg.install)
			assert.are.equal(noop, pkg.installed)
			assert.is_false(pkg.is_lsp)
			assert.is_false(pkg.is_linter)
			assert.is_false(pkg.is_formatter)
		end)

		it("defaults exec_name to the package name", function()
			local pkg = entity.Package("mason", "stylua", nil, noop, noop)
			assert.equals("stylua", pkg.exec_name)
		end)

		it("returns a fresh table per call", function()
			local a = entity.Package("p", "x", nil, noop, noop)
			local b = entity.Package("p", "x", nil, noop, noop)
			assert.are_not.equal(a, b)
		end)
	end)

	describe("Lsp", function()
		it("specializes the base object in place", function()
			local base = entity.Package("mason", "lua-language-server", "lua_ls", noop, noop)
			local lsp = entity.Lsp(base)
			assert.are.equal(base, lsp)
			assert.is_not_nil(lsp.config)
			assert.equals("function", type(lsp.update))
			assert.equals("function", type(lsp.enable))
			assert.is_true(lsp.is_lsp)
		end)

		it("seeds the configuration from the shared default", function()
			local lsp = entity.Lsp(entity.Package("mason", "x", "x", noop, noop))
			assert.is_not_nil(lsp.config.capabilities)
		end)

		it("gives each server an independent configuration", function()
			local a = entity.Lsp(entity.Package("mason", "a", "a", noop, noop))
			local b = entity.Lsp(entity.Package("mason", "b", "b", noop, noop))
			a.config.capabilities.marker = true
			assert.is_nil(b.config.capabilities.marker)
		end)

		it("deep-merges update fragments into the configuration", function()
			local lsp = entity.Lsp(entity.Package("mason", "lua_ls", "lua_ls", noop, noop))
			lsp:update({ settings = { Lua = { runtime = { version = "LuaJIT" } } } })
			lsp:update({ settings = { Lua = { runtime = { path = { "x" } } } } })
			assert.equals("LuaJIT", lsp.config.settings.Lua.runtime.version)
			assert.are_same({ "x" }, lsp.config.settings.Lua.runtime.path)
		end)

		it("registers the configuration under exec_name and enables it", function()
			local lsp = entity.Lsp(entity.Package("mason", "lua-language-server", "lua_ls", noop, noop))
			lsp:update({ settings = { Lua = { v = "5.4" } } })
			lsp:enable()
			assert.are.equal(lsp.config, state.configured.lua_ls)
			assert.is_true(state.enabled.lua_ls)
		end)

		it("is idempotent for already-enabled servers", function()
			state.enabled.lua_ls = true
			entity.Lsp(entity.Package("mason", "lua-language-server", "lua_ls", noop, noop)):enable()
			assert.are_same({}, state.configured)
		end)
	end)

	describe("Formatter", function()
		local conform

		before_each(function()
			conform = { formatters = {}, formatters_by_ft = {} }
			package.loaded["conform"] = conform
		end)

		after_each(function()
			package.loaded["conform"] = nil
		end)

		---@param name string
		---@param exec string
		---@return catalog.formatter
		local function formatter(name, exec)
			return entity.Formatter(entity.Package("mason", name, exec, noop, noop))
		end

		it("specializes the base object in place", function()
			local base = entity.Package("mason", "stylua", "stylua", noop, noop)
			local fmt = entity.Formatter(base)
			assert.are.equal(base, fmt)
			assert.equals("function", type(fmt.add_to_conform))
			assert.is_true(fmt.is_formatter)
		end)

		it("defines the formatter and files it under the filetype", function()
			formatter("stylua", "stylua"):add_to_conform("lua")
			assert.are_same({ command = "stylua" }, conform.formatters.stylua)
			assert.are_same({ "stylua" }, conform.formatters_by_ft.lua)
		end)

		it("defines the formatter command from its executable", function()
			formatter("some-formatter", "some-fmt"):add_to_conform("lua")
			assert.are_same({ command = "some-fmt" }, conform.formatters["some-formatter"])
			assert.are_same({ "some-formatter" }, conform.formatters_by_ft.lua)
		end)

		it("preserves a formatter definition already configured by the user", function()
			conform.formatters.stylua = { command = "custom", args = { "--check" } }
			formatter("stylua", "stylua"):add_to_conform("lua")
			assert.are_same({ command = "custom", args = { "--check" } }, conform.formatters.stylua)
			assert.are_same({ "stylua" }, conform.formatters_by_ft.lua)
		end)

		it("appends to an existing filetype list without duplicating", function()
			conform.formatters_by_ft.lua = { "other" }
			local fmt = formatter("stylua", "stylua")
			fmt:add_to_conform("lua")
			fmt:add_to_conform("lua")
			assert.are_same({ "other", "stylua" }, conform.formatters_by_ft.lua)
		end)

		it("leaves a non-list filetype entry unchanged", function()
			conform.formatters_by_ft.lua = function()
				return {}
			end
			formatter("stylua", "stylua"):add_to_conform("lua")
			assert.equals("function", type(conform.formatters_by_ft.lua))
		end)

		it("warns and returns when conform is unavailable", function()
			package.loaded["conform"] = nil
			local path, cpath = package.path, package.cpath
			package.path, package.cpath = "", ""

			local original_notify = vim.notify
			local notified = {}
			vim.notify = function(_, level)
				notified[#notified + 1] = level
			end

			local ok = pcall(function()
				formatter("stylua", "stylua"):add_to_conform("lua")
			end)

			vim.notify = original_notify
			package.path, package.cpath = path, cpath

			assert.is_true(ok)
			assert.equals(1, #notified)
			assert.equals(vim.log.levels.WARN, notified[1])
		end)
	end)
end)
