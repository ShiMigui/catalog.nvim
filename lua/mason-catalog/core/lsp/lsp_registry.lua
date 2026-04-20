local normalizer = require("mason-catalog.core.lsp.entry_normalizer")
local log = require("mason-catalog.utils.logger").scope(...)
local state = require("mason-catalog.core.lsp.lsp_state")
local utils = require("mason-catalog.utils")

local M = {}

---@param by_ft LspByFt
---@param default LspConfig
function M.register_filetypes(by_ft, default)
	if not utils.is_non_empty(by_ft) then
		return
	end
	for ft, lsp_entry in pairs(by_ft) do
		local pkg_names = normalizer.normalize_lsp(lsp_entry, default)
		if pkg_names then
			state.set(ft, pkg_names)
		end
	end
end

---@param by_ext LspByExt
function M.resolve_extensions_to_filetypes(by_ext)
	if not utils.is_non_empty(by_ext) then
		return
	end

	local by_ft = {}
	for ext, entry in pairs(by_ext) do
		utils.push_ext(by_ft, ext, entry)
	end
	return by_ft
end

---@param groups LspByGroup[]
function M.resolve_groups_to_filetypes(groups)
	if not utils.is_populated(groups) then
		return
	end

	local by_ft = {}
	for i, group in ipairs(groups) do
		if group.lsps and utils.is_populated(group.lsps) then
			for _, ext in ipairs(group.extensions or {}) do
				utils.push_ext(by_ft, ext, group.lsps)
			end

			for _, ft in ipairs(group.filetypes or {}) do
				utils.push_ft(by_ft, ft, group.lsps)
			end
		else
			log.wrn("Lsps in group[%d] is not a populated list!", i)
		end
	end
	return by_ft
end

return M
