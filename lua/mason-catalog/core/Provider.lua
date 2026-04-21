local registry = require("mason-registry")

return {
	---@param msn Package
	---@return CatalogPackage
	adapt = function(msn)
		local spec = msn.spec
		local nvim = spec.neovim
		local lsp = (nvim and nvim.lspconfig) and { name = nvim.lspconfig }
		local m = { name = spec.name, lsp = lsp }

		function m.install()
			msn:install()
		end
		function m.verify_lsp(config, default_config)
			if m.lsp then
				m.lsp.config = m.lsp.config or vim.deepcopy(default_config)
				if config then
					m.lsp.config = vim.tbl_deep_extend("force", m.lsp.config, config)
				end
				return m.name
			end
		end

		---@type CatalogPackage
		return m
	end,
	get = function(name)
		return registry.get_package(name)
	end,
}
