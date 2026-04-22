local log = require("catalog.log").log(...)

---@type catalog.provider[]
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
			cache[name] = p or false
			return p
		end
	end
end

---@class catalog.main_provider: catalog.provider
---@field install fun(str: string|catalog.pkg.name): catalog.pkg?
---@field set_providers fun(new: catalog.provider[]): nil
return {
	resolve = resolve,

	install = function(name)
		local p = resolve(name)
		if p and not p.installed() then
			p.install()
		end
		return p
	end,

	---@param new catalog.provider[]
	set_providers = function(new)
		providers = new
	end,
}
