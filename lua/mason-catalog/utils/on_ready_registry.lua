local log = require("mason-catalog.utils.logger").with_scope(...)
local mason_registry = require("mason-registry")

return {
	---@param cb fun(): nil
	on_ready = function(cb)
		if #mason_registry.get_all_packages() > 0 then
			log.dbg("Mason registry is already populated!")
			return cb()
		end

		log.inf("Mason registry is not populated! Refreshing...")
		mason_registry.refresh(function()
			log.inf("Mason registry refreshed!")
			cb()
		end)
	end,
}
