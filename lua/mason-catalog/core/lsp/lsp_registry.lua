local normalizer = require("mason-catalog.core.lsp.entry_normalizer")
local log = require("mason-catalog.utils.logger").with_scope(...)
local state = require("mason-catalog.core.lsp.lsp_state")
local utils = require("mason-catalog.utils").setup(log)

local M = {}

---@param by_ft LspByFt
---@param default LspConfig
function M.register_filetypes(by_ft, default)
	if utils.is_non_empty_table(by_ft) then
		for ft, lsp_entry in pairs(by_ft) do
			local pkg_names = normalizer.normalize_lsp(lsp_entry, default)
			if pkg_names then
				state.set(ft, pkg_names)
			end
		end
	end
end

---@param by_ext LspByExt
function M.resolve_extensions_to_filetypes(by_ext)
	if utils.is_non_empty_table(by_ext) then
		local by_ft = {}
		for ext, entry in pairs(by_ext) do
			local ft = utils.ext_to_ft(ext)
			if ft then
				utils.push_ft(by_ft, ft, entry)
			end
		end
		return by_ft
	end
end

---@param groups LspByGroup[]
function M.resolve_groups_to_filetypes(groups)
	if utils.is_a_populated_list(groups) then
		for i, group in ipairs(groups) do
			if group.lsps and utils.is_a_populated_list(group.lsps) then
				local by_ft = {}

				for _, ext in ipairs(group.extensions or {}) do
					local ft = utils.ext_to_ft(ext)
					if ft then
						utils.push_ft(by_ft, ft, group.lsps)
					end
				end

				for _, ft in ipairs(group.filetypes or {}) do
					utils.push_ft(by_ft, ft, group.lsps)
				end

				return by_ft
			else
				log.wrn("Lsps in group[%d] is not a populated list!", i)
			end
		end
	end
end

return M
