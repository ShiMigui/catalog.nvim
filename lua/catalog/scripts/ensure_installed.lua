local provider = require("catalog.provider")
local log = require("catalog.log").new("ensure_installed")

local cache = {}

---Resolves and installs every package in `list`, returning the resolved
---[catalog.Package](lua://catalog.Package) map. Lookups are cached across calls.
---@param list string[]
---@return table<string, catalog.Package>
return function(list)
	log.header()
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
