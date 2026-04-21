---@type cat.provider[]
local providers = { require("mason-catalog.core.provider.mason") }

---@type table<string, cat.pkg|false>
local cache = {}

local function resolve_first(name)
	for _, prov in ipairs(providers) do
		local pkg = prov.resolve(name)
		if pkg then
			return pkg
		end
	end
end

local function resolve(name)
	if cache[name] ~= nil then
		return cache[name] or nil
	end

	local pkg = resolve_first(name)
	cache[name] = pkg or false
	return pkg
end

---@type cat.provider
return {
	resolve = resolve,

	---@param list cat.provider[]
	set_providers = function(list)
		providers = list
		cache = {}
	end,
}
