local assert = require("luassert")

describe("catalog.auto_install_tools", function()
	local FT_TOOLS

	before_each(function()
		package.loaded["catalog.auto_install_tools"] = nil
		FT_TOOLS = require("catalog.auto_install_tools")
	end)

	describe("FT_TOOLS mapping", function()
		it("is a table", function()
			assert.is_table(FT_TOOLS)
		end)

		it("has entries for common filetypes", function()
			assert.is_not_nil(FT_TOOLS.lua)
			assert.is_not_nil(FT_TOOLS.typescript)
			assert.is_not_nil(FT_TOOLS.python)
			assert.is_not_nil(FT_TOOLS.go)
			assert.is_not_nil(FT_TOOLS.rust)
		end)

		it("has correct structure for lua filetype", function()
			local lua_tools = FT_TOOLS.lua
			assert.is_table(lua_tools)
			assert.are.equal("lua-language-server", lua_tools.lsp)
			assert.are.equal("stylua", lua_tools.conform)
			assert.are.equal("luacheck", lua_tools.lint)
		end)

		it("has correct structure for python filetype", function()
			local python_tools = FT_TOOLS.python
			assert.is_table(python_tools)
			assert.is_table(python_tools.lsp)
			assert.is_table(python_tools.conform)
			assert.is_table(python_tools.lint)
		end)

		it("has LSP for typescript", function()
			local ts_tools = FT_TOOLS.typescript
			assert.is_table(ts_tools)
			assert.are.equal("typescript-language-server", ts_tools.lsp)
		end)

		it("has formatter for go", function()
			local go_tools = FT_TOOLS.go
			assert.is_table(go_tools)
			assert.are.equal("gofumpt", go_tools.conform)
		end)

		it("has linter for shell", function()
			local sh_tools = FT_TOOLS.sh
			assert.is_table(sh_tools)
			assert.are.equal("shellcheck", sh_tools.lint)
		end)

		it("supports multiple tools per category", function()
			local python_tools = FT_TOOLS.python
			assert.is_table(python_tools.lsp)
			assert.are.equal(2, #python_tools.lsp)
			assert.is_table(python_tools.conform)
			assert.are.equal(2, #python_tools.conform)
			assert.is_table(python_tools.lint)
			assert.are.equal(2, #python_tools.lint)
		end)

		it("has web framework filetypes", function()
			assert.is_not_nil(FT_TOOLS.vue)
			assert.is_not_nil(FT_TOOLS.svelte)
			assert.is_not_nil(FT_TOOLS.astro)
		end)

		it("has devops filetypes", function()
			assert.is_not_nil(FT_TOOLS.dockerfile)
			assert.is_not_nil(FT_TOOLS.terraform)
			assert.is_not_nil(FT_TOOLS.yaml)
		end)

		it("has database filetypes", function()
			assert.is_not_nil(FT_TOOLS.sql)
		end)

		it("has markdown filetypes", function()
			assert.is_not_nil(FT_TOOLS.markdown)
			assert.is_not_nil(FT_TOOLS.markdown_inline)
		end)

		it("has config filetypes", function()
			assert.is_not_nil(FT_TOOLS.json)
			assert.is_not_nil(FT_TOOLS.toml)
			assert.is_not_nil(FT_TOOLS.yaml)
		end)
	end)
end)
