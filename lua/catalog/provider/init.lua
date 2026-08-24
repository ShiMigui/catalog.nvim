---Provider registry.
---
---A provider knows how to resolve a package name into a [catalog.Package](lua://catalog.Package).
---Register implementations with [append()](lua://catalog.provider.append) and
---resolve packages by name through [resolve()](lua://catalog.provider.resolve).
local log = require("catalog.log").new("provider")

---A package resolved by a provider.
---@class catalog.Package
---Name of the provider that resolved this package.
---@field provider_name string
---Package name (e.g. `"lua-language-server"`).
---@field name string
---LSP handle used to configure the language server; only set for LSP packages.
---@field lsp? catalog.Lsp
---Checks whether the package is already installed.
---@field installed fun(): boolean
---Installs the package; no-op when it is already installed.
---@field install fun(self: catalog.Package)

---A source of packages backed by a package manager (e.g. mason-registry).
---@class catalog.Provider
---Provider identifier.
---@field name string
---Resolves `name` into a package, or returns `nil` when unknown.
---@field resolve fun(name: string): catalog.Package?

---@type table<string, catalog.Provider>
local list = {}
---Cache of previously resolved packages (`false` marks known-unresolvable names).
---@type table<string, catalog.Package|false>
local pkg_cache = {}

local function try_resolve(name)
	if pkg_cache[name] ~= nil then
		return pkg_cache[name]
	end

	for _, provider in pairs(list) do
		log.dbg("Trying to get package '%s' from '%s'", name, provider.name)
		pkg_cache[name] = provider.resolve(name) or false
		if pkg_cache[name] then
			log.dbg("Package '%s' founded by '%s'", name, provider.name)
			return pkg_cache[name]
		end
	end
end

return {
	---Registers a provider under `name`.
	---@param name string
	---@param resolve fun(name: string): catalog.Package? Package resolver.
	append = function(name, resolve)
		log.dbg("Adding %s to provider list", name)
		list[name] = { name = name, resolve = resolve }
	end,
	try_resolve = try_resolve,
	---Resolves a package by name across all registered providers.
	---
	---Hits are cached: subsequent lookups return the same [catalog.Package](lua://catalog.Package)
	---without consulting providers again. Returns `nil` (and logs an error)
	---when no provider knows the package.
	---@param name string
	---@return catalog.Package?
	resolve = function(name)
		local pkg = try_resolve(name)

		if pkg then
			return pkg
		end

		if pkg == false then
			log.err("Package '%s' is already in cache, and was not found!", name)
		elseif pkg == nil then
			log.err("Package '%s' not found", name)
		end
	end,
}
