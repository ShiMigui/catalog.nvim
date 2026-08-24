---Logging system for catalog.nvim.
---
---Loggers are scoped: each scope gets a cached logger whose messages are
---prefixed with `[scope] `.
---
---```lua
---local log = require("catalog.log").new("provider")
---log:inf("resolved %d package(s)", n)
---```
local logger = { setupInProgress = false }
---@type table<vim.log.levels, boolean>
local enabled = {}
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
---Status is in progress message
---@field header fun()

---Formats a message and notifies it when `level` is enabled.
---@param level vim.log.levels
---@param msg string Format string, or plain message when no extra args.
---@vararg any Format arguments.
---@return string text The formatted message.
function logger:message(level, msg, ...)
	local text = select("#", ...) > 0 and msg:format(...) or msg

	if enabled[level] then
		vim.notify(self.prefix .. text, level)
	end

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
	if self.setupInProgress then
		self:dbg("Finishing setup()...")
	else
		self:dbg("Starting setup()...")
	end
	self.setupInProgress = not self.setupInProgress
end

local M = {}

---Configures which levels are notified.
---
---When `silent` is true, ERROR/WARN/INFO are muted; when `debug` is true,
---DEBUG is notified as well.
---@param debug boolean Notify DEBUG messages.
---@param silent boolean Mute ERROR/WARN/INFO messages.
function M.setup(debug, silent)
	local showMessages = not silent

	enabled = {
		[levels.DEBUG] = debug,
		[levels.ERROR] = showMessages,
		[levels.WARN] = showMessages,
		[levels.INFO] = showMessages,
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
