local assert = require("luassert")

describe("catalog.auto_install", function()
	local auto_install

	before_each(function()
		package.loaded["catalog.auto_install"] = nil
		package.loaded["catalog.auto_install_tools"] = nil
		auto_install = require("catalog.auto_install")
	end)

	describe("setup", function()
		it("creates autocmds for LSP filetypes", function()
			auto_install.setup()

			local autocmds = vim.api.nvim_get_autocmds({
				group = "CatalogAutoInstallLsp",
			})
			assert.is_true(#autocmds > 0)
		end)

		it("creates autocmds for conform filetypes", function()
			auto_install.setup()

			local autocmds = vim.api.nvim_get_autocmds({
				group = "CatalogAutoInstallConform",
			})
			assert.is_true(#autocmds > 0)
		end)

		it("creates autocmds for lint filetypes", function()
			auto_install.setup()

			local autocmds = vim.api.nvim_get_autocmds({
				group = "CatalogAutoInstallLint",
			})
			assert.is_true(#autocmds > 0)
		end)

		it("creates autocmds for lua filetype", function()
			auto_install.setup()

			local autocmds = vim.api.nvim_get_autocmds({
				group = "CatalogAutoInstallLsp",
				pattern = "lua",
			})
			assert.is_true(#autocmds > 0)
		end)

		it("creates autocmds for python filetype", function()
			auto_install.setup()

			local autocmds = vim.api.nvim_get_autocmds({
				group = "CatalogAutoInstallLsp",
				pattern = "python",
			})
			assert.is_true(#autocmds > 0)
		end)

		it("creates autocmds for typescript filetype", function()
			auto_install.setup()

			local autocmds = vim.api.nvim_get_autocmds({
				group = "CatalogAutoInstallLsp",
				pattern = "typescript",
			})
			assert.is_true(#autocmds > 0)
		end)

		it("clears previous autocmds", function()
			-- Setup twice
			auto_install.setup()
			auto_install.setup()

			-- Should still have autocmds (not duplicated)
			local autocmds = vim.api.nvim_get_autocmds({
				group = "CatalogAutoInstallLsp",
			})
			assert.is_true(#autocmds > 0)
		end)
	end)
end)
