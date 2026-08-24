---Provider registry.
---
---A provider knows how to resolve a package name into a [catalog.Pkg](lua://catalog.Pkg).
---Register implementations with [append()](lua://catalog.Providers.append) and
---resolve packages by name through [package()](lua://catalog.Providers.package).
local log = require("catalog.log").new("Providers")

---A package resolved by a provider.
---@class catalog.Pkg
---Name of the provider that resolved this package.
---@field provider_name string
---Package name (e.g. `"lua-language-server"`).
---@field name string
---LSP handle used to configure the language server; only set for LSP packages.
---@field lsp? catalog.Lsp
---Checks whether the package is already installed.
---@field installed fun(): boolean
---Installs the package; no-op when it is already installed.
---@field install fun(self: catalog.Pkg)

---Maps package names to resolved packages.
---@alias catalog.PkgByName table<string, catalog.Pkg>

---A source of packages backed by a package manager (e.g. mason-registry).
---@class catalog.Provider
---Provider identifier.
---@field name string
---Resolves `name` into a package, or returns `nil` when unknown.
---@field ["package"] fun(name: string): catalog.Pkg?

---@type table<string, catalog.Provider>
local list = {}
---Cache of previously resolved packages.
---@type table<string, catalog.Pkg|boolean>
local pkgCache = {}

return {
	---Registers a provider under `name`.
	---@param name string
	---@param package fun(name: string): catalog.Pkg? Package resolver.
	append = function(name, package)
		log:dbg("Adding %s to Providers list", name)
		list[name] = { name = name, package = package }
	end,
	---Resolves a package by name across all registered providers.
	---
	---Hits are cached: subsequent lookups return the same [catalog.Pkg](lua://catalog.Pkg)
	---without consulting providers again. Returns `nil` (and logs an error)
	---when no provider knows the package.
	---@param name string
	---@return catalog.Pkg?
	package = function(name)
		if pkgCache[name] ~= nil then
			if pkgCache[name] == false then
				log:err("Package '%s' is already in cache, and was not found!", name)
				return
			end
			return pkgCache[name]
		end

		for _, provider in pairs(list) do
			log:dbg("Trying to get package '%s' from '%s'", name, provider.name)
			pkgCache[name] = provider.package(name) or false
			if pkgCache[name] then
				log:dbg("Package '%s' founded by '%s'", name, provider.name)
				return pkgCache[name]
			end
		end
		log:err("Package '%s' not found", name)
	end,
}
