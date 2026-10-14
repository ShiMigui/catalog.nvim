describe("catalog.opts.lsp", function()
	local lsp_opts
	local log = { DBG = function() end }

	before_each(function()
		package.loaded["catalog.opts.lsp"] = nil
		lsp_opts = require("catalog.opts.lsp")
	end)

	describe("copy", function()
		it("returns a configuration carrying Neovim client capabilities", function()
			local cfg = lsp_opts.copy()
			assert.equals("table", type(cfg))
			assert.is_not_nil(cfg.capabilities)
		end)

		it("returns a fresh, independent table on each call", function()
			local a = lsp_opts.copy()
			local b = lsp_opts.copy()
			assert.are_not.equal(a, b)

			a.capabilities.marker = true
			assert.is_nil(b.capabilities.marker)
			assert.is_nil(lsp_opts.copy().capabilities.marker)
		end)
	end)

	describe("setup", function()
		it("merges the user default on top of the shared default", function()
			lsp_opts.setup({ payload = { default = { flags = { debounce_text_changes = 150 } } }, log = log })
			local cfg = lsp_opts.copy()
			assert.is_not_nil(cfg.capabilities)
			assert.equals(150, cfg.flags.debounce_text_changes)
		end)

		it("lets user values override the shared default", function()
			lsp_opts.setup({ payload = { default = { capabilities = "custom" } }, log = log })
			assert.equals("custom", lsp_opts.copy().capabilities)
		end)

		it("ignores a non-table payload", function()
			lsp_opts.setup({ payload = true, log = log })
			local cfg = lsp_opts.copy()
			assert.equals("table", type(cfg.capabilities))
			assert.is_nil(cfg.flags)
		end)

		it("ignores a payload without a table default", function()
			lsp_opts.setup({ payload = {}, log = log })
			assert.is_nil(lsp_opts.copy().flags)
		end)
	end)
end)
