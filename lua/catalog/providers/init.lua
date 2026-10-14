---Provider registry.
---
---A provider resolves a package name into a
---[catalog.package](lua://catalog.package). This module exposes a single
---[catalog.super_provider](lua://catalog.super_provider) that keeps the
---registered child providers and consults them in registration order; the
---first provider that recognizes a name wins. Lookups are cached for the
---rest of the session, including misses.
---
---Register a provider with [sub](lua://catalog.super_provider.sub); providers
---do not register themselves:
---
---```lua
---local providers = require("catalog.providers")
---providers:sub(require("catalog.providers.mason_provider")) -- "mason"
---
---local pkg = providers:try_provide("lua-language-server")
---```
local log = require("catalog.logger").New("providers")

---Child providers, checked in the order they were added.
---@type catalog.provider[]
local children = {}

---Session cache of resolutions, keyed by package name. A `false` entry marks a
---name already known to be unprovidable, so providers are not consulted again
---for it.
---@type table<string, catalog.package|false>
local cache = {}

---@type catalog.super_provider
return {
	name = "catalog",
	sub = function(self, provider)
		log:DBG("Adding provider '%s'", provider.name)
		children[#children + 1] = provider
		return self
	end,

	try_provide = function(_, name)
		local cached = cache[name]
		if cached ~= nil then
			log:DBG("Package '%s' resolved from cache", name)
			return cached or nil
		end

		for _, provider in ipairs(children) do
			log:DBG("Trying to get package '%s' from '%s'", name, provider.name)

			local pkg = provider:try_provide(name)
			if pkg then
				log:DBG("Package '%s' provided by '%s'", name, provider.name)
				cache[name] = pkg
				return pkg
			end
		end

		log:DBG("Package '%s' is not provided by any provider", name)
		cache[name] = false
		return nil
	end,

	provide = function(self, name)
		local pkg = self:try_provide(name)

		if not pkg then
			log:ERR("Package '%s' not found", name)
		end

		return pkg
	end,
}
