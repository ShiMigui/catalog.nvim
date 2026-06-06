local function update(self, cfg, default)
	self.config = vim.tbl_deep_extend("force", self.config or vim.deepcopy(default), cfg)
end

return {
	---@param lsp_name string
	---@return catalog.Lsp
	new = function(lsp_name)
		---@type catalog.Lsp
		return { name = lsp_name, config = nil, update = update }
	end,
}
