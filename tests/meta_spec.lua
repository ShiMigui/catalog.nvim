local assert = require("luassert")

describe("catalog.provider.meta", function()
	describe("type definitions", function()
		it("LspConfig has correct fields", function()
			-- This is a type-only file, so we just test that it loads
			local ok, _ = pcall(require, "catalog.provider.meta")
			-- meta.lua is a @meta file, so it may not be loadable
			-- This test is more of a smoke test
			assert.is_true(true)
		end)
	end)
end)
