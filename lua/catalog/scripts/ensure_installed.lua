local provider = require("catalog.provider")
local log = require("catalog.log").new("ensure_installed")

---Per-name memo of provided packages; `false` marks names that no provider
---could provide, so they are never re-provided (nor re-error-notified) on
---later calls.
---@type table<string, catalog.package|false>
local cache = {}

---Provides and installs every package in `list`, returning the provided
---[catalog.package](lua://catalog.package) map keyed by name. Lookups and
---installs are cached across calls, making this safe to repeat per session.
---@param list string[] Package names to provide and install.
---@return table<string, catalog.package> map Only successfully provided packages.
return function(list)
	log:header()
	log:inf("Installing %d package(s) from ensure_installed", #list)
	local map = {}
	for _, name in pairs(list) do
		if cache[name] == nil then
			local pkg = provider.provide(name) or false
			if pkg then
				pkg:install()
			end
			cache[name] = pkg
		end

		if cache[name] then
			map[name] = cache[name]
		end
	end
	log:header()
	return map
end
