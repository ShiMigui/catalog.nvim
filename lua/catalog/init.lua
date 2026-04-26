local log_setup = require("catalog.log")
local scope = (...) or "catalog"

---@class catalog.integration
---@field setup fun(opts: table|boolean): nil

return {
	setup = function(opts)
		opts = opts or {}

		opts.log = opts.log or {}
		local show_errors = opts.silent_errors ~= true
		local log = log_setup.set_log(opts.log, show_errors, opts.debug).log(scope)

		log.header(true)
		if opts.lsp then
			require("catalog.lsp.config").setup(opts.lsp_config)
			require("catalog.lsp").setup(opts.lsp)
		end

		if opts.conform then
			require("catalog.conform").setup(opts.conform)
		end

		if opts.ensure_installed then
			require("catalog.ensure_installed").setup(opts.ensure_installed)
		end
		log.header(false)
	end,
}
