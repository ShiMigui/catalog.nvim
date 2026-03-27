local on_ready_registry = require("mason-catalog.utils.on_ready_registry")
local scope = ...

---@param opts CatalogSetupOpts
local function _setup(opts)
	local log = require("mason-catalog.utils.logger").with_scope(scope)
	local pkg_adapter = require("mason-catalog.core.pkg.adapter")
	local lsp = require("mason-catalog.core.lsp")

	log.dbg("Initializing MasonCatalog...")

	lsp.setup(opts.lsp or {})

	for _, pkg_name in ipairs(opts.ensure_installed or {}) do
		pkg_adapter.install(pkg_name)
	end

	if opts.integrations then
		log.wrn("Integrations, this feature has not been implemented yet!")
	end
end

return {
	---@param opts CatalogSetupOpts
	setup = function(opts)
		if not opts or type(opts) ~= "table" then
			return
		end

		vim.g.mason_catalog_debug = opts.debug == true
		vim.g.mason_catalog_silent = opts.silent == true

		on_ready_registry(function()
			_setup(opts)
		end)
	end,
}
