local scope = ...

---@param opts CatalogSetupOpts
local function _setup(opts)
	local log = require("mason-catalog.logger").scope(scope)
	local pkg_adapter = require("mason-catalog.core.pkg.adapter")
	local lsp = require("mason-catalog.core.lsp")
	log.inf("Running setup...")
	lsp.setup(opts.lsp or {})

	for _, pkg_name in ipairs(opts.ensure_installed or {}) do
		pkg_adapter.install(pkg_name)
	end

	for _, integration_name in ipairs(opts.integrations or {}) do
		local integration = log.try_require("mason-catalog.integrations." .. integration_name)
		if integration and integration.setup then
			integration.setup()
		end
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

		require("mason-catalog.utils").on_ready_registry(function()
			_setup(opts)
		end)
	end,
}
