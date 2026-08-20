local assert = require("luassert")

describe("catalog", function()
	local catalog

	before_each(function()
		package.loaded["catalog"] = nil
		catalog = require("catalog")
	end)

	describe("setup", function()
		it("accepts empty opts", function()
			assert.has_no.errors(function()
				catalog.setup({})
			end)
		end)

		it("accepts nil opts", function()
			assert.has_no.errors(function()
				catalog.setup(nil)
			end)
		end)

		it("rejects non-table opts", function()
			assert.has.errors(function()
				catalog.setup("invalid")
			end, "catalog.setup: opts must be a table")
		end)

		it("rejects non-table lsp", function()
			assert.has.errors(function()
				catalog.setup({ lsp = "invalid" })
			end, "catalog.setup: lsp must be a table")
		end)

		it("rejects non-table lsp_config", function()
			assert.has.errors(function()
				catalog.setup({ lsp_config = "invalid" })
			end, "catalog.setup: lsp_config must be a table")
		end)

		it("rejects non-boolean conform", function()
			assert.has.errors(function()
				catalog.setup({ conform = "invalid" })
			end, "catalog.setup: conform must be a boolean")
		end)

		it("rejects non-boolean lint", function()
			assert.has.errors(function()
				catalog.setup({ lint = "invalid" })
			end, "catalog.setup: lint must be a boolean")
		end)

		it("rejects non-table treesitter", function()
			assert.has.errors(function()
				catalog.setup({ treesitter = "invalid" })
			end, "catalog.setup: treesitter must be a table")
		end)

		it("rejects invalid ensure_installed", function()
			assert.has.errors(function()
				catalog.setup({ ensure_installed = 123 })
			end, "catalog.setup: ensure_installed must be a string or table")
		end)

		it("accepts string ensure_installed", function()
			-- Skip if mason is not available (needed for provider)
			local ok, _ = pcall(require, "mason-registry")
			if not ok then
				return -- skip
			end

			assert.has_no.errors(function()
				catalog.setup({ ensure_installed = "lua-language-server" })
			end)
		end)

		it("accepts table ensure_installed", function()
			-- Skip if mason is not available (needed for provider)
			local ok, _ = pcall(require, "mason-registry")
			if not ok then
				return -- skip
			end

			assert.has_no.errors(function()
				catalog.setup({ ensure_installed = { "lua-language-server" } })
			end)
		end)

		it("rejects non-boolean auto_update", function()
			assert.has.errors(function()
				catalog.setup({ auto_update = "invalid" })
			end, "catalog.setup: auto_update must be a boolean")
		end)

		it("rejects non-boolean auto_install", function()
			assert.has.errors(function()
				catalog.setup({ auto_install = "invalid" })
			end, "catalog.setup: auto_install must be a boolean")
		end)

		it("accepts valid config", function()
			-- Skip if mason is not available (needed for provider)
			local ok, _ = pcall(require, "mason-registry")
			if not ok then
				return -- skip
			end

			assert.has_no.errors(function()
				catalog.setup({
					conform = true,
					lint = true,
					auto_update = true,
					auto_install = true,
					ensure_installed = { "lua-language-server" },
				})
			end)
		end)
	end)
end)
