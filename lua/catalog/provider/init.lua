local log = require("catalog.log").log(...)

---@type catalog.Provider[]
local providers = { require("catalog.provider.mason") }

local cache = {}

local function resolve(name)
	if cache[name] ~= nil then
		return cache[name] or nil
	end
	for _, provider in pairs(providers) do
		local ok, p = pcall(provider.resolve, name)

		if not ok then
			log.err("Error trying to get '%s': %s", name, p)
		elseif p then
			if not p then
				log.err("Package not found: %s", name)
				cache[name] = false
			else
				cache[name] = p
			end
			return p
		end
	end
end

---@class catalog.MainProvider: catalog.Provider
---@field set_providers fun(new: catalog.Provider[]): nil
return {
	resolve = resolve,

	---@param new catalog.Provider[]
	set_providers = function(new)
		providers = new
	end,
}
