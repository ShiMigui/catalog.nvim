local log = require("catalog.log").log(...)
return {
	---@param lsp_name catalog.lsp.name
	---@return catalog.lsp
	new = function(lsp_name)
		---@type catalog.lsp
		local lsp = { name = lsp_name, config = nil }

		lsp.update = function(cfg, default)
			lsp.config = vim.tbl_deep_extend("force", lsp.config or vim.deepcopy(default), cfg)
		end

		return lsp
	end,
}
