local log = require("catalog.log").log(...)

---@type catalog.Provider[]
local providers = {}

-- Try to load mason provider if available
local ok, mason = pcall(require, "catalog.provider.mason")
if ok then
	table.insert(providers, mason)
end

local cache = {}
local CACHE_TTL = 300 -- 5 minutes

---@type table<string, number>
local cache_timestamps = {}

local function is_cache_valid(name)
	local ts = cache_timestamps[name]
	return ts and (os.time() - ts) < CACHE_TTL
end

local function clear_cache()
	cache = {}
	cache_timestamps = {}
end

local function resolve(name)
	if cache[name] ~= nil and is_cache_valid(name) then
		return cache[name] or nil
	end

	for _, provider in pairs(providers) do
		local ok, p = pcall(provider.resolve, name)

		if not ok then
			log.err("Error trying to get '%s': %s", name, p)
		elseif p then
			cache[name] = p
			cache_timestamps[name] = os.time()
			return p
		else
			log.err("Package not found: %s", name)
			cache[name] = false
			cache_timestamps[name] = os.time()
		end
	end
end

---@class catalog.MainProvider: catalog.Provider
---@field set_providers fun(new: catalog.Provider[]): nil
---@field clear_cache fun(): nil
return {
	resolve = resolve,

	---@param new catalog.Provider[]
	set_providers = function(new)
		providers = new
	end,

	clear_cache = clear_cache,
}
