local Provider = require("catalog.Providers")
local log = require("catalog.log").new("EnsureInstalled")

local cache = {}

---@param list string[]
---@return table<string, catalog.Pkg>
return function(list)
	log:header()
	local map = {}
	for _, nm in pairs(list) do
		if cache[nm] == nil then
			local p = Provider.package(nm) or false
			if p then
				p:install()
			end
			cache[nm] = p
		end

		if cache[nm] then
			map[nm] = cache[nm]
		end
	end
	return map
end
