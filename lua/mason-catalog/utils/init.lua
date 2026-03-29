local log = require("mason-catalog.utils.logger").with_scope(...)
local M = {}

function M.is_a_populated_list(any)
	return vim.islist(any) and any[1] ~= nil
end

function M.is_non_empty_table(any)
	return type(any) == "table" and next(any) ~= nil
end

---@param map table<FileType, LspEntry>
---@param ft FileType
---@param entry LspEntry
function M.push_ft(map, ft, entry)
	if type(ft) == "string" then
		map[ft] = entry
		return
	end
	log.wrn("Filetype '%s' is not a string!", vim.inspect(ft))
end

function M.push_ext(map, ext, entry)
	if type(ext) ~= "string" then
		log.error("Extension '%s' is not a string!", ext)
	end

	local ft = vim.filetype.match({ filename = "file." .. ext })
	if not ft then
		log.error("Extension '%s' has no matching filetype!", ext)
    return
	end
	M.push_ft(map, ft, entry)
end

return M
