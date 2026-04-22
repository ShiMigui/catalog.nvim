local log_setup = require("catalog.log")
local scope = (...) or "catalog"

---@class catalog.integration
---@field init fun(opts: table|boolean): nil

return {
	setup = function(opts)
		opts = opts or {}

		opts.log = opts.log or {}
		local log = log_setup.set_log(opts.log, opts.show_logs, opts.debug).log(scope)

		log.header(true)
		if opts.lsp then
			require("catalog.lsp").init(opts.lsp)
		end

		if opts.conform then
			require("catalog.conform").init(opts.conform)
		end

		if opts.ensure_installed then
			require("catalog.ensure_installed").init(opts.ensure_installed)
		end
		log.header(false)
	end,
}
