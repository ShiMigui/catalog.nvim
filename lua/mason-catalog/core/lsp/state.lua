---@class LspConfigsState
local M = {}

---@type table<Filetype, NormalizedLsp>
local set = {}

---@param ft Filetype
---@param normalized NormalizedLsp
function M.add(ft, normalized)
	set[ft] = normalized
end

---@param ft Filetype
---@return NormalizedLsp?
function M.get(ft)
	return set[ft]
end

return M
