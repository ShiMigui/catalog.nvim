local lvls = vim.log.levels

---No-op function used when logging is disabled.
---@param ... any
local function mock(...) end

local silent_flag = vim.g.mason_catalog_silent
local debug_flag = vim.g.mason_catalog_debug

---@class MasonCatalogLogger
return {
	---@param scope string
	with_scope = function(scope)
		local m = { scope = "[mason-catalog] " .. scope .. ": " }

		---Formats a message using `string.format` if arguments are provided.
		---Safely wraps formatting in `pcall` to avoid runtime errors.
		---@param message string
		---@param ... any
		---@return string
		local function build_msg(message, ...)
			if select("#", ...) > 0 then
				message = m.scope .. message
				local ok, result = pcall(string.format, message, ...)
				return ok and result or message
			end
			return m.scope .. message
		end

		---Creates a notify function bound to a specific log level.
		---@param level vim.log.levels
		---@return fun(msg: string, ...: any)
		local function notify_scope(level)
			return function(msg, ...)
				vim.notify(build_msg(msg, ...), level)
			end
		end

		m.err = silent_flag and mock or notify_scope(lvls.ERROR)
		m.inf = silent_flag and mock or notify_scope(lvls.INFO)
		m.wrn = silent_flag and mock or notify_scope(lvls.WARN)
		m.dbg = debug_flag and notify_scope(lvls.DEBUG) or mock

		---Safely requires a module.
		---Throws an error if the module cannot be loaded.
		---@param name string
		---@return any
		function m.require(name)
			local ok, mod = pcall(require, name)
			if not ok then
				error(build_msg("[%s] could not be required!", name))
			end
			return mod
		end

		---Attempts to require a module without interrupting execution.
		---If the module is not available, a debug message is logged.
		---@param name string
		---@return any|nil
		function m.try_require(name)
			local ok, mod = pcall(require, name)
			if not ok then
				m.dbg("[%s] not available", name)
			end
			return mod
		end
		return m
	end,
}
