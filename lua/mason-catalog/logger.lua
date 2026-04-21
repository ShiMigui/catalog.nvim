---@alias LogFunction fun(msg: string, ...: any): nil

local function format(scope, msg, ...)
	if select("#", ...) > 0 then
		msg = msg:format(...)
	end
	return scope .. msg
end

---@param scope string
---@param level vim.log.levels
---@return LogFunction
local function notify_scope(scope, level)
	return function(msg, ...)
		vim.notify(format(scope, msg, ...), level)
	end
end

---@param success LogFunction
---@param failure LogFunction
---@return fun(mod:string): any?, string?
local function require_builder(success, failure)
	return function(mod)
		local ok, res = pcall(require, mod)
		if ok then
			success("Module '%s' found", mod)
			return res, nil
		end

		failure("Module '%s' not found", mod)
		return nil, res
	end
end

local function return_noop(_, _, _)
	return function(...) end
end

local fn_ic_silent = vim.g.mason_catalog_silent and return_noop or notify_scope
local fn_ic_debug = vim.g.mason_catalog_debug and notify_scope or return_noop
local levels = vim.log.levels

---@param scope string
local function logger(scope)
	scope = scope and "[" .. scope .. "] " or ""

	local m = {
		err = fn_ic_silent(scope, levels.ERROR),
		inf = fn_ic_silent(scope, levels.INFO),
		wrn = fn_ic_silent(scope, levels.WARN),
		dbg = fn_ic_debug(scope, levels.DEBUG),
		error = function(msg, ...)
			error(format(scope, msg, ...), 2)
		end,
	}

	m.require = require_builder(m.dbg, m.error)
	m.try_require = require_builder(m.dbg, m.err)

	return m
end

return { logger = logger }
