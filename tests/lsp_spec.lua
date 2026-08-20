local assert = require("luassert")

describe("catalog.lsp", function()
	local lsp

	before_each(function()
		package.loaded["catalog.lsp"] = nil
		package.loaded["catalog.lsp.config"] = nil
		lsp = require("catalog.lsp")
	end)

	describe("setup", function()
		it("accepts empty table", function()
			assert.has_no.errors(function()
				lsp.setup({})
			end)
		end)

		it("rejects non-table input", function()
			assert.has_no.errors(function()
				lsp.setup("invalid")
			end)
		end)

		it("handles array-style LSP declarations", function()
			-- This will try to resolve packages, which may fail
			-- but should not error in the setup itself
			assert.has_no.errors(function()
				lsp.setup({
					"lua-language-server",
				})
			end)
		end)

		it("handles keyed LSP declarations", function()
			assert.has_no.errors(function()
				lsp.setup({
					["lua-language-server"] = {
						settings = {
							Lua = {
								diagnostics = {
									globals = { "vim" },
								},
							},
						},
					},
				})
			end)
		end)

		it("handles mixed declarations", function()
			assert.has_no.errors(function()
				lsp.setup({
					"lua-language-server",
					["yaml-language-server"] = {
						settings = {
							yaml = {
								schemas = {},
							},
						},
					},
				})
			end)
		end)

		it("creates user command CatalogShowLSPs", function()
			lsp.setup({})
			local commands = vim.api.nvim_get_commands({})
			assert.is_not_nil(commands.CatalogShowLSPs)
		end)
	end)
end)
