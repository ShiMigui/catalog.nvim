local provider = require("catalog.provider")
local log = require("catalog.log").new("ensure_installed")

---Per-name memo of resolved packages; `false` marks names that failed to
---resolve so they are never re-resolved (nor re-error-notified) on later calls.
---@type table<string, catalog.package|false>
local cache = {}

---Resolves and installs every package in `list`, returning the resolved
---[catalog.package](lua://catalog.package) map keyed by name. Lookups and
---installs are cached across calls, making this safe to repeat per session.
---@param list string[] Package names to resolve and install.
---@return table<string, catalog.package> map Only successfully resolved packages.
return function(list)
	log:header()
	local map = {}
	for _, name in pairs(list) do
		if cache[name] == nil then
			local pkg = provider.resolve(name) or false
			if pkg then
				pkg:install()
			end
			cache[name] = pkg
		end

		if cache[name] then
			map[name] = cache[name]
		end
	end
	return map
end
