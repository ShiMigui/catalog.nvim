local logger = require("mason-catalog.logger").logger(...)

---@type cat.opts.lsp
local defaults = {
	default_config = { capabilities = vim.lsp.protocol.make_client_capabilities() },
	extensions = {},
	filetypes = {},
}

---@param opts? cat.opts.lsp
---@return cat.opts.lsp
return function(opts)
	logger.dbg("starting")
	opts = vim.tbl_deep_extend("force", {}, defaults, opts)

	if type(opts.default_config) ~= "table" then
		logger.err("Invalid type for lsp.default_config")
		opts.default_config = defaults.default_config
	end

	return opts
end
