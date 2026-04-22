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
				msn_pkg:install()
			end,
		}
		if nvim and nvim.lspconfig then
			pkg.lsp = lsp_node.new(nvim.lspconfig)
		end

		return pkg
	end,
}
