local M = {}

---@param cb fun(): nil
function M.ensure_ready(cb)
	local logger = require("mason-catalog.utils.logger").with_scope("registry_verifier.ensure_ready")
	local registry = logger.require("mason-registry")

	logger.dbg("verifying mason-registry")

	if #registry.get_all_package_names() > 0 then
		logger.dbg("mason-registry already populated")
		cb()
	else
		logger.dbg("refreshing mason-registry")
		registry.refresh(cb)
	end
end

return M
