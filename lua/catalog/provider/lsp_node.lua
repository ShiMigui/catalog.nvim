local log = require("catalog.log").log(...)
return {
	---@param lsp_name catalog.lsp.name
	---@return catalog.lsp
	new = function(lsp_name)
		---@type catalog.lsp
		local lsp = { name = lsp_name, config = nil }

		lsp.update = function(cfg)
			if lsp.config then
				lsp.config = vim.tbl_deep_extend("force", lsp.config, cfg)
				return
			end
			log.err("Lsp '%s' hasn't a config related to it", lsp_name)
		end

		lsp.setup = function(default)
			if not lsp.config then
				lsp.config = vim.deepcopy(default)
			end
		end

		return lsp
	end,
}
