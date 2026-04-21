local registry = require("mason-registry")
local logger = require("mason-catalog.logger").logger("Package")

---@param ok boolean
---@param receipt any|InstallReceipt
local function install_log(ok, receipt)
	if ok then
		logger.inf("Package '%s' installed successfully", receipt.name)
	else
		logger.err("Failed to install: %s", receipt)
	end
end

---@return catalog.Provider
return {
	resolve = function(name)
		local pkg = registry.get_package(name)
		if not pkg then
			logger.err("Package '%s' not found", name)
			return
		end

		local nvim = pkg.spec.neovim
		local m = { name = pkg.spec.name }

		m.lsp = (nvim and nvim.lspconfig) and { name = nvim.lspconfig }

		function m.install()
			if pkg:is_installed() then
				logger.dbg("Package '%s' already installed", name)
			elseif pkg:is_installing() then
				logger.dbg("Package '%s' is being installed", name)
			else
				pkg:install(nil, install_log)
			end
		end

		function m.sync_config(config, default_config)
			if not m.lsp then
				return false
			end
			m.lsp.config = m.lsp.config or vim.deepcopy(default_config)
			if config then
				m.lsp.config = vim.tbl_deep_extend("force", m.lsp.config, config)
			end
			return true
		end

		---@type catalog.Package
		return m
	end,
}
