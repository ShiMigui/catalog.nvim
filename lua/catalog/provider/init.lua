---Provider registry.
---
---A provider knows how to resolve a package name into a
---[catalog.package](lua://catalog.package). Register implementations with
---[append()](lua://catalog.provider.append) and resolve packages by name
---through [resolve()](lua://catalog.provider.resolve).
---
---```lua
---require("catalog.provider").append("my-source", function(name)
---   if name ~= "my-tool" then return end
---   return { name = "my-tool", provider_name = "my-source", ... }
---end)
---```
local log = require("catalog.log").new("provider")

---A package resolved by a provider.
---@class catalog.package
---Name of the provider that resolved this package.
---@field provider_name string
---Package name (e.g. `"lua-language-server"`).
---@field name string
---LSP handle used to configure the language server; only set for LSP packages.
---@field lsp? catalog.lsp
---Checks whether the package is already installed.
---@field installed fun(): boolean
---Installs the package; implementations must make this idempotent, since it
---is called unconditionally by consumers.
---@field install fun(self: catalog.package)

---Shape of a registered resolver entry: a package source backed by a package
---manager (e.g. mason-registry). Named `resolver` to avoid clashing with the
---`catalog.provider` module itself.
---@class catalog.resolver
---Provider identifier, used in logs.
---@field name string
---Resolves `name` into a [catalog.package](lua://catalog.package), or returns
---`nil` when unknown. Must not raise on unknown names.
---@field resolve fun(name: string): catalog.package?
---@field load_installed fun(): table<string, catalog.package>

---@type table<string, catalog.resolver>
local provider_list = {}
---Cache of previously resolved packages; `false` marks names already known to
---be unresolvable so repeated lookups never re-consult providers.
---@type table<string, catalog.package|false>
local pkg_cache = {}

---Looks `name` up across all registered providers without reporting failures:
---returns the cached/resolved [catalog.package](lua://catalog.package), `false`
---when previously found missing, or `nil` on a fresh miss (cached as such).
---@param name string
---@return catalog.package|false|nil
local function try_resolve(name)
	if pkg_cache[name] ~= nil then
		return pkg_cache[name]
	end

	for _, resolver in pairs(provider_list) do
		log:dbg("Trying to get package '%s' from '%s'", name, resolver.name)
		pkg_cache[name] = resolver.resolve(name) or false
		if pkg_cache[name] then
			log:dbg("Package '%s' found by '%s'", name, resolver.name)
			return pkg_cache[name]
		end
	end

	return pkg_cache[name]
end

return {
	load_installed = function()
		for provider_name, provider in pairs(provider_list) do
			for name, pkg in pairs(provider.load_installed()) do
				if not pkg_cache[name] then
					log:dbg("Package '%s' added to cache with '%s'", name, provider_name)
					pkg_cache[name] = pkg
				else
					log:dbg("Package '%s' is already cached with '%s'", name, provider_name)
				end
			end
		end
	end,
	---Registers a provider under `name`.
	---@param provider catalog.resolver  Provider identifier shown in logs.
	append = function(provider)
		log:dbg("Adding %s to provider list", provider.name)
		provider_list[provider.name] = provider
	end,
	try_resolve = try_resolve,
	---Resolves a package by name across all registered providers.
	---
	---Hits are cached: subsequent lookups return the same
	---[catalog.package](lua://catalog.package) without consulting providers
	---again. Returns `nil` (and notifies an error) when no provider knows the
	---package; use [try_resolve](lua://catalog.provider.try_resolve) for quiet
	---lookups.
	---@param name string
	---@return catalog.package?
	resolve = function(name)
		local pkg = try_resolve(name)

		if pkg then
			return pkg
		end

		log:err(
			pkg == false and "Package '%s' is already in cache, and was not found!" or "Package '%s' not found",
			name
		)
	end,
}
