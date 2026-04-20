local log = require("mason-catalog.logger").scope(...)
local cache = require("mason-catalog.core.pkg.cache")
local mason_registry = require("mason-registry")

---@class PkgAdapter
local M = {}

---@param mason_package Package
---@return Pkg
local function convert(mason_package)
	local spec = mason_package.spec
	local name = spec.name

	local lsp_name = spec.neovim and spec.neovim.lspconfig
	log.dbg("Converting Mason package '%s'", name)
	return {
		name = name,
		categories = spec.categories,
		lsp = lsp_name and { name = lsp_name } or nil,
		install = function()
			if mason_package:is_installed() then
				return log.dbg("Package '%s' already installed", name)
			end
			if mason_package.is_installing and mason_package:is_installing() then
				return log.dbg("Package '%s' is already being installed", name)
			end
			mason_package:install() -- no log because of mason's notify
		end,
	}
end

---@param name PkgName
---@return Pkg?
function M.get_package(name)
	local cached = cache.get_package(name)
	if cached then
		return cached
	end

	local ok, p = pcall(mason_registry.get_package, name)
	if ok then
		if p then
			log.dbg("Package '%s' found in registry", name)
			local converted = convert(p)
			cache.set_package(name, converted)
			return converted
		else
			log.wrn("Package '%s' not found in registry", name)
		end
	else
		log.wrn("Error calling mason-registry.get_package('%s'): %s", name, p)
	end
end

---@param name string
---@return Pkg?
function M.install(name)
	local p = M.get_package(name)
	if p then
		p.install()
		return p
	end
end

return M
