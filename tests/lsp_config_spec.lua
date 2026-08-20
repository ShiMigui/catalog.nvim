local assert = require("luassert")

describe("catalog.lsp.config", function()
	local lsp_config

	before_each(function()
		package.loaded["catalog.lsp.config"] = nil
		lsp_config = require("catalog.lsp.config")
	end)

	describe("config", function()
		it("returns a table", function()
			local config = lsp_config.config()
			assert.is_table(config)
		end)

		it("has capabilities", function()
			local config = lsp_config.config()
			assert.is_not_nil(config.capabilities)
		end)

		it("has default capabilities from vim.lsp.protocol", function()
			local config = lsp_config.config()
			assert.is_table(config.capabilities)
		end)
	end)

	describe("setup", function()
		it("accepts nil opts", function()
			assert.has_no.errors(function()
				lsp_config.setup(nil)
			end)
		end)

		it("accepts empty opts", function()
			assert.has_no.errors(function()
				lsp_config.setup({})
			end)
		end)

		it("merges custom config", function()
			lsp_config.setup({
				config = {
					custom_option = true,
				},
			})

			local config = lsp_config.config()
			assert.is_true(config.custom_option)
		end)

		it("deep merges custom config", function()
			lsp_config.setup({
				config = {
					settings = {
						Lua = {
							diagnostics = {
								globals = { "vim" },
							},
						},
					},
				},
			})

			local config = lsp_config.config()
			assert.is_table(config.settings)
			assert.is_table(config.settings.Lua)
			assert.is_table(config.settings.Lua.diagnostics)
			assert.is_table(config.settings.Lua.diagnostics.globals)
		end)
	end)

	describe("get_on_attach", function()
		it("returns nil by default", function()
			local on_attach = lsp_config.get_on_attach()
			assert.is_nil(on_attach)
		end)

		it("returns function when set", function()
			local function custom_on_attach() end

			lsp_config.setup({
				on_attach = custom_on_attach,
			})

			local on_attach = lsp_config.get_on_attach()
			assert.is_function(on_attach)
			assert.are.equal(custom_on_attach, on_attach)
		end)
	end)
end)
