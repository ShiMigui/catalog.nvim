local scope = ...

local function setup(opts)
	vim.g.mason_catalog_debug = false
	vim.g.mason_catalog_silent = false
	local logger = require("mason-catalog.logger").logger(scope)
	logger.dbg("Starting setup")

	if opts.lsp then
		local lsp = require("mason-catalog.core.lsp")
		lsp(opts.lsp)
	end

	vim.opt.rtp:prepend(vim.fn.getcwd())
end

return {
	setup = function(opts)
		opts = opts or {}
		setup({
			lsp = { extensions = { { "lua", lsp = { "lua-language-server", "emmylua_ls" } } } },
		})
	end,
}
