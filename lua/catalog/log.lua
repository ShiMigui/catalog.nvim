---Logging system for catalog.nvim.
---
---Loggers are scoped: each scope gets a cached logger whose messages are
---prefixed with `[scope] `.
---
---```lua
---local log = require("catalog.log").new("provider")
---log.inf("resolved %d package(s)", n)
---```
local M = {}

---@type table<vim.log.levels, boolean>
local enabled = {
	[vim.log.levels.ERROR] = true,
	[vim.log.levels.WARN] = true,
	[vim.log.levels.INFO] = true,
}
local cache = {}
local levels = vim.log.levels

---Formats a message and notifies it when `level` is enabled.
---@param level vim.log.levels
---@param prefix string
---@param msg string Format string, or plain message when no extra args.
---@vararg any Format arguments.
---@return string text The formatted message.
local function message(level, prefix, msg, ...)
	if not enabled[level] then
		return msg
	end

	local text = select("#", ...) > 0 and msg:format(...) or msg
	vim.notify(prefix .. text, level)
	return text
end

---Scoped logger; messages are prefixed with `[scope] `.
---@class catalog.Logger
---Debug message; only notified after setup(true).
---@field dbg fun(msg: string, ...: any): string
---Error message.
---@field err fun(msg: string, ...: any): string
---Info message.
---@field inf fun(msg: string, ...: any): string
---Warning message.
---@field wrn fun(msg: string, ...: any): string
---Alternates between `starting`/`finishing` debug messages, marking setup progress.
---@field header fun()

---Returns the logger tagged with `scope`, creating it on first use.
---@param scope string
---@return catalog.Logger
function M.new(scope)
	if cache[scope] then
		return cache[scope]
	end

	local prefix = "[" .. scope .. "] "
	local started = false

	---@type catalog.Logger
	local logger = {
		dbg = function(msg, ...)
			return message(levels.DEBUG, prefix, msg, ...)
		end,
		err = function(msg, ...)
			return message(levels.ERROR, prefix, msg, ...)
		end,
		inf = function(msg, ...)
			return message(levels.INFO, prefix, msg, ...)
		end,
		wrn = function(msg, ...)
			return message(levels.WARN, prefix, msg, ...)
		end,
		header = function()
			started = not started
			message(levels.DEBUG, prefix, started and "starting" or "finishing")
		end,
	}

	cache[scope] = logger
	return logger
end

---Configures which levels are notified.
---
---When `silent` is true, ERROR/WARN/INFO are muted; when `debug` is true,
---DEBUG is notified as well.
---@param debug boolean Notify DEBUG messages.
---@param silent boolean Mute ERROR/WARN/INFO messages.
function M.setup(debug, silent)
	local show_messages = not silent

	enabled = {
		[levels.DEBUG] = debug,
		[levels.ERROR] = show_messages,
		[levels.WARN] = show_messages,
		[levels.INFO] = show_messages,
	}

	return M
end

return M
