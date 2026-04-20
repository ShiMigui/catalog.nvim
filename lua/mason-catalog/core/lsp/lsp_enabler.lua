local log = require("mason-catalog.utils.logger").scope(...)
local lsp_state = require("mason-catalog.core.lsp.lsp_state")
local pkg_adapter = require("mason-catalog.core.pkg.adapter")

local M = {}

local function enable_lsp(lsp)
	if vim.lsp.is_enabled(lsp.name) then
		log.dbg("Already enabled '%s'...", lsp.name)
	else
		log.inf("Starting '%s'...", lsp.name)
		vim.lsp.config(lsp.name, lsp.config)
		vim.lsp.enable(lsp.name)
	end
end

---@param ft string
function M.enable_lsp_in_ft(ft)
	local pkgs = lsp_state.get(ft)
	if pkgs then
		log.dbg("Configuring LSP to ft '%s'", ft)
		for _, pkg_name in ipairs(pkgs) do
			enable_lsp(pkg_adapter.get_package(pkg_name).lsp)
		end
	end
end

---@param args vim.api.keyset.create_autocmd.callback_args
function M.enable_lsp_with_autocmd(args)
	M.enable_lsp_in_ft(args.match or vim.bo[args.buf].filetype)
end

return M
