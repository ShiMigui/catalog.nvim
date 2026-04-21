local logger = require("mason-catalog.logger").logger(...)
local registry = require("mason-registry")

---@type cat.provider
return {
	resolve = function(name)
		local msn = registry.get_package(name)
		if not msn then
			logger.err("Package '%s' not found", name)
			return
		end

		local pkg = {
			name = msn.spec.name,
			installed = msn:is_installed(),
			sync_config = function(_, _)
				logger.err("Package '%s' is not a LSP", name)
				return false
			end,
		}

		local function log_install(ok, result)
			if ok then
				logger.inf("Package '%s' installed successfully", name)
			else
				logger.err("Failed to install '%s': %s", name, result)
			end
			pkg.installed = ok
		end

		function pkg.install()
			if msn:is_installed() then
				logger.dbg("Package '%s' already installed", name)
			elseif msn:is_installing() then
				logger.dbg("Package '%s' is being installed", name)
			else
				msn:install(nil, log_install)
			end
		end

		local nvim = msn.spec.neovim
		if nvim and nvim.lspconfig then
			pkg.lspname = nvim.lspconfig
			function pkg.sync_config(cfg, default)
				pkg.lspconfig = pkg.lspconfig or vim.deepcopy(default)
				if cfg then
					pkg.lspconfig = vim.tbl_deep_extend("force", pkg.lspconfig, cfg)
				end
				return true
			end
		end

		return pkg
	end,
}
