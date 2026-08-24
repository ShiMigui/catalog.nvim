---Logging system for catalog.nvim.
---
---Loggers are scoped: each scope gets a cached logger whose messages are
---prefixed with `[scope] `.
---
---```lua
---local log = require("catalog.log").new("provider")
---log:inf("resolved %d package(s)", n)
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

---Scoped logger; messages are prefixed with `[scope] `.
---@class catalog.Logger
---@field prefix string
---Formats `msg` and notifies it when `level` is enabled. The text is always
---returned, even when the level is disabled.
---@field message fun(self: catalog.Logger, level: vim.log.levels, msg: string, ...: any): string
---Debug message; only notified after setup(true).
---@field dbg fun(self: catalog.Logger, msg: string, ...: any): string
---Error message.
---@field err fun(self: catalog.Logger, msg: string, ...: any): string
---Info message.
---@field inf fun(self: catalog.Logger, msg: string, ...: any): string
---Warning message.
---@field wrn fun(self: catalog.Logger, msg: string, ...: any): string
---Alternates between `starting`/`finishing` debug messages, marking setup progress.
---@field header fun(self: catalog.Logger)

---Shared prototype; all cached loggers index into this table, so the methods
---exist only once in memory regardless of how many scopes are created.
local logger = {}

---Formats a message and notifies it when `level` is enabled.
---@param level vim.log.levels
---@param msg string Format string, or plain message when no extra args.
---@vararg any Format arguments.
---@return string text The formatted message.
function logger:message(level, msg, ...)
	if not enabled[level] then
		return msg
	end

	local text = select("#", ...) > 0 and msg:format(...) or msg
	vim.notify(self.prefix .. text, level)
	return text
end

---Logs at DEBUG level (only after setup(true)).
---@param msg string
---@vararg any
---@return string
function logger:dbg(msg, ...)
	return self:message(levels.DEBUG, msg, ...)
end

---Logs at ERROR level.
---@param msg string
---@vararg any
---@return string
function logger:err(msg, ...)
	return self:message(levels.ERROR, msg, ...)
end

---Logs at INFO level.
---@param msg string
---@vararg any
---@return string
function logger:inf(msg, ...)
	return self:message(levels.INFO, msg, ...)
end

---Logs at WARN level.
---@param msg string
---@vararg any
---@return string
function logger:wrn(msg, ...)
	return self:message(levels.WARN, msg, ...)
end

function logger:header()
	self.started = not self.started
	self:message(levels.DEBUG, self.started and "starting" or "finishing")
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

---Returns the logger tagged with `scope`, creating it on first use.
---@param scope string
---@return catalog.Logger
function M.new(scope)
	if not cache[scope] then
		cache[scope] = setmetatable({ prefix = "[" .. scope .. "] " }, { __index = logger })
	end

	return cache[scope]
end

return M
