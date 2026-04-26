local lsp_default_config

---@type catalog.integration
return {
	setup = function(opts)
		lsp_default_config = opts or { capabilities = vim.lsp.protocol.make_client_capabilities() }
	end,
	config = function()
		return lsp_default_config
	end,
}
