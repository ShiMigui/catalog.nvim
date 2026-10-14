describe("catalog.ft_tools", function()
	local ft_tools = require("catalog.ft_tools")

	it("returns a non-empty mapping", function()
		assert.equals("table", type(ft_tools))
		assert.is_not_nil(next(ft_tools))
	end)

	it("maps every filetype to a table of tool kinds", function()
		for ft, tools in pairs(ft_tools) do
			assert.equals("table", type(tools))
			assert.equals("string", type(ft))
		end
	end)

	it("uses a uniform, non-empty list of strings for every kind", function()
		for ft, tools in pairs(ft_tools) do
			for kind, names in pairs(tools) do
				assert.equals("table", type(names))
				assert.is_true(#names > 0)
				for _, name in ipairs(names) do
					assert.equals("string", type(name))
				end
			end
		end
	end)

	it("only uses the known tool kinds", function()
		for _, tools in pairs(ft_tools) do
			for kind in pairs(tools) do
				assert.is_true(kind == "lsp" or kind == "formatter" or kind == "linter")
			end
		end
	end)

	it("lists Lua tooling", function()
		assert.are_same({ "lua-language-server" }, ft_tools.lua.lsp)
		assert.are_same({ "stylua" }, ft_tools.lua.formatter)
		assert.are_same({ "luacheck" }, ft_tools.lua.linter)
	end)

	it("lists several servers for JavaScript and TypeScript", function()
		for _, ft in ipairs({ "javascript", "javascriptreact", "typescript", "typescriptreact" }) do
			assert.are_same({ "typescript-language-server", "eslint-lsp" }, ft_tools[ft].lsp)
			assert.are_same({ "prettierd" }, ft_tools[ft].formatter)
		end
	end)

	it("only uses lists, never a bare string", function()
		for _, tools in pairs(ft_tools) do
			for _, names in pairs(tools) do
				assert.equals("table", type(names))
			end
		end
	end)
end)
