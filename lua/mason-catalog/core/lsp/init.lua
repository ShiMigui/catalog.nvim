local log = require("mason-catalog.utils.logger").with_scope(...)
local lsp_enabler = require("mason-catalog.core.lsp.lsp_enabler")
local resolver = require("mason-catalog.core.lsp.lsp_registry")

local register_filetypes = resolver.register_filetypes
local resolve_groups_to_filetypes = resolver.resolve_groups_to_filetypes
local resolve_extensions_to_filetypes = resolver.resolve_extensions_to_filetypes

return {
	---@param opts LspSetupOpts
	setup = function(opts)
		log.dbg("Starting LSP process")
		---@type LspConfig
		local default = opts.default_config or { capabilities = vim.lsp.protocol.make_client_capabilities() }

		register_filetypes(resolve_groups_to_filetypes(opts.by_group), default)
		register_filetypes(resolve_extensions_to_filetypes(opts.by_ext), default)
		register_filetypes(opts.by_ft, default)

		local group = vim.api.nvim_create_augroup("MasonCatalogLsp", { clear = true })
		vim.api.nvim_create_autocmd("FileType", { group = group, callback = lsp_enabler.enable_lsp_with_autocmd })
		local ft = vim.bo.filetype
		if ft and ft ~= "" then
			lsp_enabler.enable_lsp_in_ft(ft)
		end
	end,
}
