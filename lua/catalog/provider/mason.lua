local log = require("catalog.log").log(...)
local registry = require("mason-registry")
local lsp_node = require("catalog.provider.lsp_node")

---@type catalog.provider
return {
	resolve = function(str)
		log.dbg("Trying to get %s", str)
		local ok, msn_pkg = pcall(registry.get_package, str)

		if not ok then
			return nil
		end

		local nvim = msn_pkg.spec.neovim
		---@type catalog.pkg
		local pkg = {
			name = str,
			installed = function()
				return msn_pkg:is_installed()
			end,
			install = function()
				if msn_pkg:is_installed() then
					log.dbg("%s already installed", str)
				elseif msn_pkg:is_installing() then
					log.dbg("%s already beign installed", str)
				else
					msn_pkg:install()
				end
			end,
		}
		if nvim and nvim.lspconfig then
			pkg.lsp = lsp_node.new(nvim.lspconfig)
		end

		return pkg
	end,
}
