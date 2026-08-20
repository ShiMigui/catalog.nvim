local assert = require("luassert")

describe("catalog.ensure_installed", function()
	local ensure_installed

	before_each(function()
		package.loaded["catalog.ensure_installed"] = nil
		ensure_installed = require("catalog.ensure_installed")
	end)

	describe("setup", function()
		it("accepts string input", function()
			-- This will try to resolve the package, which may fail
			-- but should not error in the setup itself
			assert.has_no.errors(function()
				ensure_installed.setup("lua-language-server")
			end)
		end)

		it("accepts table input", function()
			assert.has_no.errors(function()
				ensure_installed.setup({ "lua-language-server" })
			end)
		end)

		it("accepts empty table", function()
			assert.has_no.errors(function()
				ensure_installed.setup({})
			end)
		end)

		it("warns on invalid input", function()
			-- Should warn but not error
			assert.has_no.errors(function()
				ensure_installed.setup(123)
			end)
		end)

		it("warns on nil input", function()
			-- Should warn but not error
			assert.has_no.errors(function()
				ensure_installed.setup(nil)
			end)
		end)

		it("handles multiple packages", function()
			assert.has_no.errors(function()
				ensure_installed.setup({
					"lua-language-server",
					"stylua",
				})
			end)
		end)
	end)
end)
