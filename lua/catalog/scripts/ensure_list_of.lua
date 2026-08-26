local log = require("catalog.log").new("ensure_list_of")

---Normalizes a user-provided option that accepts either a single value or a
---list into an always-list shape, logging (and returning) an error when the
---value or any list element does not match `expected`.
---
---```lua
---local names = ensure_list_of(opts.formatters, "string") or {}
---```
---@generic T
---@param value any Single value of type `T`, or a table whose elements are all `T`.
---@param expected type Expected type name (e.g. `"string"`).
---@return T[]? list The normalized list, or nil when invalid.
---@return string? err Error description when invalid.
return function(value, expected)
	if type(value) == expected then
		return { value }
	end

	if type(value) ~= "table" then
		return nil, log:err("Type of %s is not %s", value, expected)
	end

	for _, item in pairs(value) do
		if type(item) ~= expected then
			return nil, log:err("Type of %s is not %s", item, expected)
		end
	end

	return value
end
