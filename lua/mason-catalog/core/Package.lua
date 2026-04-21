local logger = require("mason-catalog.logger")("Package")

local Provider = require("mason-catalog.core.Provider")

local M = {}

local pkgs = {}
function M.from(name)
	logger.dbg("Trying to find package '%s'", name)

	local pkg = pkgs[name] or Provider.get(name)
	pkgs[name] = pkg or false
	if not pkg then
		logger.err("Package '%s' not found", name)
		return
	end

	local p = Provider.adapt(pkg)
	pkgs.set(name, p)
	return p
end

function M.install(name)
	local pkg = M.from(name)
	if pkg then
		pkg.install()
	end
	return pkg
end

---@param pkg_name PackageName
---@param config? LspConfig
---@param default_config LspConfig
function M.verify_lsp(pkg_name, config, default_config)
	local pkg = M.install(pkg_name)
	if not pkg then
		return
	end

	local lsp = pkg.lsp
	if lsp then
		lsp.config = lsp.config or vim.deepcopy(default_config)
		if config then
			lsp.config = vim.tbl_deep_extend("force", lsp.config, config)
		end
		return pkg.name
	end

	logger.wrn("Given pkg_name '%s' is not registered as LSP", pkg_name)
end

return M
