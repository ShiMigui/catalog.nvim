local registry = require("mason-registry")

return {
	---@param msn Package
	adapt = function(msn)
		local spec = msn.spec
		local nvim = spec.neovim
		---@type CatalogPackage
		return {
			name = spec.name,
			install = function()
				msn:install()
			end,
			lsp = (nvim and nvim.lspconfig) and { name = nvim.lspconfig },
		}
	end,
	get = function(name)
		return registry.get_package(name)
	end,
}
