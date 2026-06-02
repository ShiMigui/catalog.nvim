local log_setup = require("catalog.log")
local scope = (...) or "catalog"

---@class catalog.integration
---@field setup fun(opts: table|boolean): nil

return {
	setup = function(opts)
		opts = opts or {}

		opts.log = opts.log or {}
		local log = log_setup.set_log(opts.log, opts.silent_errors == true, opts.debug).log(scope)

		log.header()
		if opts.lsp then
			local lsp = opts.lsp

			require("catalog.lsp.config").setup({ config = lsp.config, capabilites = lsp.capability_provider })
			lsp.capability_provider = nil
			lsp.config = nil

			require("catalog.lsp").setup(lsp)
		end

		if opts.conform then
			require("catalog.conform").setup(opts.conform)
		end

		if opts.ensure_installed then
			require("catalog.ensure_installed").setup(opts.ensure_installed)
		end
		log.header()
	end,
}
