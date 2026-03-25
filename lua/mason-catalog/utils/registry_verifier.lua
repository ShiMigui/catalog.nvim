local M = {}
local log = require("mason-catalog.utils.logger").with_scope(...)
local registry = log.require("mason-registry")

---@param cb fun(): nil
function M.ensure_ready(cb)
	log.dbg("verifying mason-registry")

	if #registry.get_all_package_names() > 0 then
		log.dbg("mason-registry already populated")
		cb()
	else
		log.dbg("refreshing mason-registry")
		registry.refresh(cb)
	end
end

return M
