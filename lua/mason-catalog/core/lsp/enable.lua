local state = require("mason-catalog.core.lsp.state")
local log = require("mason-catalog.utils.logger").with_scope(...)
local M = {}

---@param lsp_name LspName
function M.setup_lsp(lsp_name, config)
	if not vim.lsp.is_enabled(lsp_name) then
		vim.lsp.config(lsp_name, config)
		vim.lsp.enable(lsp_name)
	end
end

---@param ft Filetype
function M.setup_lsps_in_ft(ft)
	local lsps = state.get(ft)
	if lsps then
		log.dbg("Initializing LSPs with filetype '%s'...", ft)
		for lsp_name, config in pairs(lsps) do
			M.setup_lsp(lsp_name, config)
		end
	end
end

---@param args vim.api.keyset.create_autocmd.callback_args
function M.setup_lsps_in_autocmd(args)
	M.setup_lsps_in_ft(args.match)
end

return M
