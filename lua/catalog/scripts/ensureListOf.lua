local log = require("catalog.log").new("EnsureListOf")

---@generic T type
---@param value any
---@param t T
---@return T[]?,string?
return function(value, t)
	local tv = type(value)

	if tv == t then
		return { value }
	end

	if tv ~= "table" then
		return nil, log:err("Type of %s is not %s", value, t)
	end

	for _, v in pairs(value) do
		if type(v) ~= t then
			return nil, log:err("Type of %s is not %s", v, t)
		end
	end

	return value
end
