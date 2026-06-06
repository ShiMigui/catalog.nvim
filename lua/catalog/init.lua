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

		if opts.lsp_config then
			require("catalog.lsp.config").setup(opts.lsp_config)
		end

		if opts.lsp then
			require("catalog.lsp").setup(opts.lsp)
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
