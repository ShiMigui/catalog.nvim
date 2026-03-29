local installed = {}
---@type table<string, Package>
local packages = {}
local install_calls = {}

local M = {}

function M.setup()
	package.preload["mason-registry"] = function()
		return {
			get_package = function(name)
				return packages[name]
			end,
		}
	end
	package.loaded["mason-registry"] = nil
	return M
end

function M.get_registry()
	return package.preload["mason-registry"]()
end

function M.to_lsp_name(name)
	return name:gsub("-language%-server", "_ls"):gsub("%-lsp", "_ls")
end

function M.get_install_calls(name)
	return install_calls[name] or 0
end

function M.add_package(name)
	local p = {
		spec = {
			name = name,
			categories = { "LSP" },
			neovim = {
				lspconfig = M.to_lsp_name(name),
			},
		},
	}
	function p:install()
		installed[name] = true
		install_calls[name] = (install_calls[name] or 0) + 1
	end
	function p:is_installing()
		return M.get_install_calls(name) > 0
	end
	function p:is_installed()
		return installed[name]
	end
	packages[name] = p
end

function M.reset()
	installed = {}
	packages = {}

	M.add_package("lua-language-server")
	M.add_package("typescript-language-server")
	M.add_package("bash-language-server")
	M.add_package("pyright")
end

return M
