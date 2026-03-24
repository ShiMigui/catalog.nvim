local M = {}

vim.opt.rtp:prepend(vim.fn.getcwd())

local registry_verifier = require("mason-catalog.utils.registry_verifier")
local ensurer = require("mason-catalog.utils.ensurer")
local logger = require("mason-catalog.utils.logger")
local lsp = require("mason-catalog.core.lsp")

---@param opts MasonCatalogSetupOpts
local function _setup(opts)
	return function()
		vim.g.mason_catalog_silent = opts.silent == true
		vim.g.mason_catalog_debug = opts.debug == true
		logger.dbg("DEBUG=%s SILENT=%s", tostring(vim.g.mason_catalog_debug), tostring(vim.g.mason_catalog_silent))

		local lsps = opts.lsp
		if lsps then
			lsp.setup(lsps)
		end

		if opts.ensure_installed then
			ensurer.ensure_any(opts.ensure_installed)
		end

		if opts.integrations then
			logger.err("Income feature, please wait for updates!")
		end
	end
end

---@param opts MasonCatalogSetupOpts
function M.setup(opts)
	registry_verifier.ensure_ready(_setup(opts))
end

return M
