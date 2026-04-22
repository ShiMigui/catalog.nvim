local log_setup = require("catalog.log")
local scope = (...) or "catalog"

---@class catalog.integration
---@field init fun(opts: table|boolean): nil

return {
	setup = function(opts)
		opts = opts or {}

		opts.log = opts.log or {}
		local log = log_setup.set_log(opts.log, not opts.silent, opts.debug).log(scope)

		log.header(true)
		if opts.lsp then
			require("catalog.lsp").init(opts.lsp)
		end
		log.header(false)
	end,
}
