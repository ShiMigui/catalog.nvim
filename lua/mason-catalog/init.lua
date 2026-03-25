local M = {}

vim.opt.rtp:prepend(vim.fn.getcwd())

local scope = ...
local ensurer, log, lsp

---@param opts MasonCatalogSetupOpts
local function _setup(opts)
	return function()
		log.dbg("DEBUG=%s SILENT=%s", tostring(vim.g.mason_catalog_debug), tostring(vim.g.mason_catalog_silent))

		lsp.setup(opts.lsp)

		if opts.ensure_installed then
			ensurer.ensure_any(opts.ensure_installed)
		end

		if opts.integrations then
			log.err("Incoming feature, please wait for updates!")
		end
	end
end

---@param opts MasonCatalogSetupOpts
function M.setup(opts)
	vim.g.mason_catalog_silent = opts.silent == true
	vim.g.mason_catalog_debug = opts.debug == true

	local registry_verifier = require("mason-catalog.utils.registry_verifier")
	ensurer = require("mason-catalog.utils.ensurer")
	log = require("mason-catalog.utils.logger").with_scope(scope)
	lsp = require("mason-catalog.core.lsp")

	registry_verifier.ensure_ready(_setup(opts))
end

return M
