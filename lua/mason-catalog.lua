local scope = ...

local function setup(opts)
	vim.g.mason_catalog_debug = opts.debug == true
	vim.g.mason_catalog_silent = opts.silent == true

	local logger = require("mason-catalog.logger").logger(scope)
	local provider = require("mason-catalog.core.provider")

	logger.dbg("starting")

	if opts.lsp then
		require("mason-catalog.core.lsp")(opts.lsp)
	end

	-- ensure_installed
	local seen = {}
	for _, pkg in ipairs(opts.ensure_installed or {}) do
		if not seen[pkg] then
			seen[pkg] = true

			local p = provider.resolve(pkg)
			if p then
				p.install()
			else
				logger.err("Package '%s' not found", pkg)
			end
		end
	end

	-- integrations
	for _, integration in ipairs(opts.integrations or {}) do
		local mod = logger.try_require("mason-catalog.integrations." .. integration)
		if type(mod) == "function" then
			mod()
		end
	end
end

return {
	setup = function(opts)
		opts = opts or {}

		local registry = require("mason-registry")

		if registry.get_all_packages and #registry.get_all_packages() > 0 then
			setup(opts)
		else
			registry.refresh(function()
				setup(opts)
			end)
		end
	end,
}
