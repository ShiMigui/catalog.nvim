local M = {}

---@type table<FileType, PkgName[]>
local state = {}

---@param ft FileType
---@param pkg_name PkgName[]
function M.set(ft, pkg_name)
	if state[ft] then
		vim.list_extend(state[ft], pkg_name)
	else
		state[ft] = pkg_name
	end
end

---@param ft FileType
---@return PkgName[]?
function M.get(ft)
	return state[ft]
end

---Reset state (use ONLY for tests)
function M._clear()
	for k in pairs(state) do
		state[k] = nil
	end
end

return M
