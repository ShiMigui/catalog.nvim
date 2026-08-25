describe("catalog", function()
	local catalog
	local lsp_calls, auto_install_calls, log_calls ---@type table[]

	before_each(function()
		lsp_calls = {}
		auto_install_calls = {}
		log_calls = {}

		package.loaded["catalog.provider.mason"] = {}
		package.loaded["catalog.lsp"] = {
			setup = function(opts)
				table.insert(lsp_calls, opts)
			end,
		}
		package.loaded["catalog.auto_install"] = {
			setup = function(opts)
				table.insert(auto_install_calls, opts)
			end,
		}
		package.loaded["catalog.log"] = {
			setup = function(debug, silent)
				table.insert(log_calls, { debug = debug, silent = silent })
				return {
					new = function()
						return { dbg = function() end }
					end,
				}
			end,
		}

		package.loaded["catalog"] = nil
		catalog = require("catalog")
	end)

	after_each(function()
		for _, module in ipairs({ "catalog.provider.mason", "catalog.lsp", "catalog.auto_install", "catalog.log" }) do
			package.loaded[module] = nil
		end
	end)

	it("registers mason and expands boolean auto_install by default", function()
		catalog.setup({})

		assert.equals(1, #log_calls)
		assert.equals(0, #lsp_calls)
		assert.are_same({ lsp = true, formatter = true, linter = true }, auto_install_calls[1])
	end)

	it("coerces partial auto_install tables into explicit booleans", function()
		catalog.setup({ auto_install = { lsp = true } })

		assert.are_same({ lsp = true, formatter = false, linter = false }, auto_install_calls[1])
	end)

	it("skips integrations that are disabled or absent", function()
		catalog.setup({ auto_install = false })

		assert.equals(0, #auto_install_calls)
		assert.equals(0, #lsp_calls)
	end)

	it("passes lsp options straight through", function()
		local lsp_opts = { default = { flags = {} }, config_by = { lua_ls = {} } }
		catalog.setup({ auto_install = false, lsp = lsp_opts })

		assert.equals(1, #lsp_calls)
		assert.equals(lsp_opts, lsp_calls[1])
	end)

	it("forwards debug/silent flags to the logger", function()
		catalog.setup({ debug = true })

		assert.same({ debug = true, silent = false }, log_calls[1])
	end)
end)
