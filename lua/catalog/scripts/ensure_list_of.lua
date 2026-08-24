local log = require("catalog.log").new("ensure_list_of")

---Wraps `value` into a single-element list when it is a plain `t`,
---validates every element when it is already a table.
---@generic T
---@param value any
---@param t type Expected type name (e.g. `"string"`).
---@return T[]?, string? Error message when invalid.
return function(value, t)
	if type(value) == t then
		return { value }
	end

	if type(value) ~= "table" then
		return nil, log.err("Type of %s is not %s", value, t)
	end

	for _, v in pairs(value) do
		if type(v) ~= t then
			return nil, log.err("Type of %s is not %s", v, t)
		end
	end

	return value
end
