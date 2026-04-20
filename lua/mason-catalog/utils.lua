local log = require("mason-catalog.utils.logger").scope(...)

---@param data any
---@param expected type
---@param field ?string
local function is_a(data, expected, field)
	local t = type(data)
	if t ~= expected then
		log.wrn("%s expected a %s, got %s", field or "Field", expected, t)
		return false
	end
	return true
end

return {
	is_a = is_a,

	is_populated = function(any)
		return vim.islist(any) and #any > 0
	end,

	is_non_empty = function(any)
		return type(any) == "table" and next(any) ~= nil
	end,

	---@param map table<FileType, LspEntry>
	---@param ft FileType
	---@param entry LspEntry
	push_ft = function(map, ft, entry)
		if is_a(ft, "string", "Filetype") then
			map[ft] = entry
		end
	end,

	push_ext = function(map, ext, entry)
		if is_a(ext, "string", "Extension") then
			local ft = vim.filetype.match({ filename = "file." .. ext })
			if not ft then
				log.error("Extension '%s' has no matching filetype!", ext)
				return
			end
			map[ft] = entry
		end
	end,
}
