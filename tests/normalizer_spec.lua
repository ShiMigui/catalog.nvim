local normalizer = require("mason-catalog.core.lsp.normalizer")

package.loaded["mason-catalog.utils.ensurer"] = {
	ensure = function(name)
		return {
			name = name,
			lspname = name:gsub("%-language%-server", "_ls"):gsub("%-lsp", ""),
		}
	end,
}

describe("lsp normalizer", function()
	describe("invalid inputs", function()
		it("returns nil for invalid input type", function()
			local result = normalizer(123, {})
			assert.is_nil(result)
		end)

		it("ignores invalid config types", function()
			local result = normalizer({
				["lua-language-server"] = true,
			}, {})

			assert.is_nil(result)
		end)

		it("returns nil for empty table", function()
			local result = normalizer({}, {})
			assert.is_nil(result)
		end)
	end)

	describe("valid inputs", function()
		it("normalizes string input", function()
			local result = normalizer("lua-language-server", {})
			assert.is_table(result)
			assert.is_not_nil(result.lua_ls)
		end)

		it("normalizes list input", function()
			local result = normalizer({ "lua-language-server" }, {})
			assert.is_table(result)
			assert.is_not_nil(result.lua_ls)
		end)

		it("normalizes table input", function()
			local result = normalizer({
				["lua-language-server"] = {
					settings = { Lua = {} },
				},
			}, {})

			assert.is_table(result)
			assert.is_not_nil(result.lua_ls)
		end)

		it("handles mixed input", function()
			local result = normalizer({
				"lua-language-server",
				["eslint-lsp"] = {},
			}, {})

			assert.is_not_nil(result.lua_ls)
			assert.is_not_nil(result.eslint)
		end)
	end)

	describe("edge cases", function()
		it("handles missing lspname", function()
			-- mock isolado
			package.loaded["mason-catalog.utils.ensurer"] = {
				ensure = function()
					return {}
				end,
			}

			package.loaded["mason-catalog.core.lsp.normalizer"] = nil
			local normalizer = require("mason-catalog.core.lsp.normalizer")

			local result = normalizer("lua-language-server", {})
			assert.is_nil(result)
		end)
	end)
end)
