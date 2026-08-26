---Provider registry.
---
---A provider knows how to provide a package name as a
---[catalog.package](lua://catalog.package). Register implementations with
---[append()](lua://catalog.provider.append) and request packages by name
---through [provide()](lua://catalog.provider.provide).
---
---```lua
---require("catalog.provider").append({
---   name = "my-source",
---   provide = function(name)
---      if name ~= "my-tool" then return end
---      return { name = "my-tool", provider_name = "my-source", ... }
---   end,
---   load_installed = function() return {} end,
---})
---```
local log = require("catalog.log").new("provider")

---A package provided by a provider.
---@class catalog.package
---Name of the provider that provided this package.
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

---Shape every provider implements. Declared as `catalog.provider` after the
---domain term; the `catalog/provider/init.lua` module file is unrelated and
---holds the registry itself.
---@class catalog.provider
---Provider identifier, used in logs and as the registration key.
---@field name string
---Provides `name` as a [catalog.package](lua://catalog.package), or returns
---`nil` when unknown. Must not raise on unknown names.
---@field provide fun(name: string): catalog.package?
---Returns every package already installed through this provider, keyed by
---name; consumed by the registry [load_installed](lua://catalog.provider.load_installed)
---to seed its cache.
---@field load_installed fun(): table<string, catalog.package>

---@type table<string, catalog.provider>
local provider_list = {}
---Cache of previously provided packages; `false` marks names already known to
---be unprovidable so repeated lookups never re-consult providers.
---@type table<string, catalog.package|false>
local pkg_cache = {}

---Asks every registered provider for `name` without reporting failures:
---returns the cached/provided [catalog.package](lua://catalog.package), `false`
---when previously found missing, or `nil` on a fresh miss (cached as such).
---@param name string
---@return catalog.package|false|nil
local function try_provide(name)
	if pkg_cache[name] ~= nil then
		return pkg_cache[name]
	end

	for _, provider in pairs(provider_list) do
		log:dbg("Trying to get package '%s' from '%s'", name, provider.name)
		pkg_cache[name] = provider.provide(name) or false
		if pkg_cache[name] then
			log:dbg("Package '%s' provided by '%s'", name, provider.name)
			return pkg_cache[name]
		end
	end

	return pkg_cache[name]
end

return {
	---Seeds [pkg_cache](lua://pkg_cache) with every package the registered
	---providers report as already installed, so later provide()/try_provide()
	---calls hit the cache without reinstalling anything. Called once by
	---`catalog.setup()`; safe to call again afterwards.
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
	---Registers a provider object under its own `name`.
	---@param provider catalog.provider Provider implementation.
	append = function(provider)
		log:dbg("Adding %s to provider list", provider.name)
		provider_list[provider.name] = provider
	end,
	try_provide = try_provide,
	---Provides a package by name across all registered providers.
	---
	---Hits are cached: subsequent lookups return the same
	---[catalog.package](lua://catalog.package) without consulting providers
	---again. Returns `nil` (and notifies an error) when no provider provides
	---the package; use [try_provide](lua://catalog.provider.try_provide) for
	---quiet lookups.
	---@param name string
	---@return catalog.package?
	provide = function(name)
		local pkg = try_provide(name)

		if pkg then
			return pkg
		end

		log:err(
			pkg == false and "Package '%s' is already in cache, and was not found!" or "Package '%s' not found",
			name
		)
	end,
}
