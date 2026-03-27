---@alias LogFunction fun(msg: string, ...: any): nil

---@class MasonCatalogLogger
local M = {}

---@param message string
---@param ... any
---@return string
function M.build_msg(message, ...)
	if select("#", ...) > 0 then
		local ok, result = pcall(string.format, message, ...)
		if ok then
			return result
		end
	end
	return message
end

---@param level vim.log.levels
---@param scope string
---@return LogFunction
local function notify_scope(level, scope)
	return function(msg, ...)
		vim.notify(scope .. M.build_msg(msg, ...), level)
	end
end

---@param success LogFunction
---@param failure LogFunction
local function req_builder(success, failure)
	---@param mod string
	---@return any?
	return function(mod)
		local ok, res = pcall(require, mod)
		if ok then
			success("Module '%s' found", mod)
			return res
		end
		failure("Module '%s' not found", mod)
	end
end

---@param ... any
local function noop(...) end

local ic_silent = vim.g.mason_catalog_silent
local ic_debug = vim.g.mason_catalog_debug

---@param scope string
function M.with_scope(scope)
	scope = "[" .. scope .. "] "

	local logger = {
		err = ic_silent and noop or notify_scope(vim.log.levels.ERROR, scope),
		inf = ic_silent and noop or notify_scope(vim.log.levels.INFO, scope),
		wrn = ic_silent and noop or notify_scope(vim.log.levels.WARN, scope),
		dbg = ic_debug and notify_scope(vim.log.levels.DEBUG, scope) or noop,

		---@type LogFunction
		error = function(msg, ...)
			error(scope .. M.build_msg(msg, ...))
		end,
	}

	logger.require_or_error = req_builder(logger.dbg, logger.error)
	logger.try_require = req_builder(logger.dbg, logger.err)

	return logger
end

return M
