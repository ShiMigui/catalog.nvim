local scope = ...

local setup_opts
local function setup()
	vim.g.mason_catalog_debug = false
	vim.g.mason_catalog_silent = false
	local logger = require("mason-catalog.logger").logger(scope)
	local provider = require("mason-catalog.core.provider")
	logger.dbg("starting")

	if setup_opts.lsp then
		local lsp = require("mason-catalog.core.lsp")
		lsp(setup_opts.lsp)
	end

	for _, pkg in ipairs(setup_opts.ensure_installed or {}) do
		local p = provider.resolve(pkg)
		if p then
			p.install()
		end
	end

	for _, integration in ipairs(setup_opts.integrations or {}) do
		local p = logger.try_require("mason-catalog.integrations." .. integration)
		if p then
			p()
		end
	end
end

return {
	setup = function(opts)
		setup_opts = opts or {}
		local registry = require("mason-registry")

		if #registry.get_all_packages() > 0 then
			setup()
		else
			registry.refresh(setup)
		end
	end,
}
