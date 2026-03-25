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
		vim.notify(M.fmt(msg, ...), level)
	end
end

---Creates a notify function bound to a specific log level.
---@param level vim.log.levels
---@param scope string
---@return fun(msg: string, ...: any)
local function notify_scope(level, scope)
	---@param msg string
	---@param ... any
	return function(msg, ...)
		vim.notify(M.fmt(scope .. msg, ...), level)
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
M.dbg = debug_flag and notify(lvls.DEBUG) or mock

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

function M.with_scope(scope)
	scope = "[mason-catalog] " .. scope .. ": "
	local m = {
		err = silent_flag and mock or notify_scope(lvls.ERROR, scope),
		inf = silent_flag and mock or notify_scope(lvls.INFO, scope),
		wrn = silent_flag and mock or notify_scope(lvls.WARN, scope),
		dbg = debug_flag and notify_scope(lvls.DEBUG, scope) or mock,
	}
	---Safely requires a module.
	---Throws an error if the module cannot be loaded.
	---@param name string
	---@return any
	function m.require(name)
		local ok, mod = pcall(require, name)
		if not ok then
			error(M.fmt(scope .. "[%s] could not be required!", name))
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
end

return M
