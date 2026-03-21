---@class MasonCatalogLogger
local M = {}
local lvls = vim.log.levels

---Formats a message using `string.format` if arguments are provided.
---Safely wraps formatting in `pcall` to avoid runtime errors.
---@param message string
---@param ... any
---@return string
function M.fmt(message, ...)
	if select("#", ...) > 0 then
		local ok, result = pcall(string.format, message, ...)
		return ok and result or message
	end
	return message
end

---Creates a notify function bound to a specific log level.
---@param level vim.log.levels
---@return fun(msg: string, ...: any)
local function notify(level)
	---@param msg string
	---@param ... any
	return function(msg, ...)
		vim.notify(M.fmt(msg, ...), level, { title = "mason-catalog" })
	end
end

---No-op function used when logging is disabled.
---@param ... any
local function mock(...) end

local silent_flag = vim.g.mason_catalog_silent
local debug_flag = vim.g.mason_catalog_debug

M.err = silent_flag and mock or notify(lvls.ERROR)
M.inf = silent_flag and mock or notify(lvls.INFO)
M.wrn = silent_flag and mock or notify(lvls.WARN)
M.dbg = (not debug_flag or silent_flag) and mock or notify(lvls.DEBUG)

---Safely requires a module.
---Throws an error if the module cannot be loaded.
---@param name string
---@return any
function M.require(name)
	local ok, mod = pcall(require, name)
	if not ok then
		error(M.fmt("[%s] could not be required!", name))
	end
	return mod
end

---Attempts to require a module without interrupting execution.
---If the module is not available, a debug message is logged.
---@param name string
---@return any|nil
function M.try_require(name)
	local ok, mod = pcall(require, name)
	if not ok then
		M.dbg("[%s] not available", name)
	end
	return mod
end

return M
