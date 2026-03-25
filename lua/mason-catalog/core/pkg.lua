---@class RegistryPkgAdapter
local M = {}
local logger = require("mason-catalog.utils.logger")
local registry = require("mason-registry")

---@type table<PkgName, Pkg>
local packages_in_cache = {}

---Creates (or retrieves from cache) a Catalog package from a Mason package.
---This function memoizes packages to avoid recreating objects during setup.
---@param mason_package Package
---@return Pkg
function M.new(mason_package)
	local log = logger.with_scope("Pkg.new")
	local name = mason_package.name
	local spec = mason_package.spec or {}

	log.dbg("Converting mason_package to Pkg [%s]", name)
	if not packages_in_cache[name] then
		packages_in_cache[name] = {
			name = name,
			categories = spec.categories or {},
			lspname = spec.neovim and spec.neovim.lspconfig or nil,
			---Installs the package if not already installed.
			---Prevents duplicate installations when possible.
			install = function()
				if not mason_package:is_installed() then
					if mason_package.is_installing and mason_package:is_installing() then
						log.dbg("Package %s is already installing", name)
						return
					end

					log.inf("Installing package %s", name)
					mason_package:install()
				end
			end,
		}
	end
	return packages_in_cache[name]
end

---Retrieves a package from Mason registry and converts it to a Catalog package.
---Returns nil if the package does not exist or cannot be retrieved.
---@param name string
---@return Pkg?
function M.from(name)
	local log = logger.with_scope("Pkg.from")
	log.dbg("Getting package %s from registry", name)

	local ok, pkg = pcall(registry.get_package, name)
	if not ok then
		return log.err("Error retrieving package %s: %s", name, pkg)
	end

	if not pkg then
		return log.err("Package %s not found", name)
	end

	log.dbg("Package %s found", name)
	return M.new(pkg)
end

---Retrieves a package by name and installs it if available.
---This is a convenience wrapper around `from()` and `Pkg.install()`.
---
---If the package does not exist or cannot be retrieved, no installation is attempted.
---Returns the package instance when successful, or nil otherwise.
---@param name string @ Mason package name
---@return Pkg|nil @ The package instance if found, otherwise nil
function M.install(name)
	local pkg = M.from(name)
	if pkg then
		pkg.install()
	end
	return pkg
end

return M
