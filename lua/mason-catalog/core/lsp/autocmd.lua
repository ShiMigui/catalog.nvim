local enable_lsp = require("mason-catalog.core.lsp.enable")
local M = {}

function M.setup()
   enable_lsp.setup_lsps_in_ft(vim.bo.filetype)
	local group = vim.api.nvim_create_augroup("MasonCatalogLsp", { clear = true })
	vim.api.nvim_create_autocmd("FileType", { group = group, callback = enable_lsp.setup_lsps_in_autocmd })
end

return M
