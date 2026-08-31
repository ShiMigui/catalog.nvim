---Logging system for catalog.nvim.
---
---Loggers are scoped: each scope gets a cached logger whose messages are
---prefixed with `[scope] `. All loggers share a single method prototype, so
---memory cost per scope is one small table, never a copy of the methods.
---
---The [header](lua://catalog.logger.header) is the primary way to mark setup
---blocks. Each call toggles the scope's `starting`/`finishing` marker and
---drives a shared indent level: `starting` indents, `finishing` de-indents,
---so nested stages read as a tree of `>`-marked messages.
---
---```lua
---local log = require("catalog.log").new("provider")
---log:inf("resolved %d package(s)", n)
---```
local M = {}

---Levels currently notified; defaults keep ERROR/WARN/INFO on so failures
---are never silently swallowed before `setup()` runs.
---@type table<vim.log.levels, boolean>
local enabled = {
	[vim.log.levels.ERROR] = true,
	[vim.log.levels.WARN] = true,
	[vim.log.levels.INFO] = true,
}
---@type table<string, catalog.logger>
local cache = {}
local levels = vim.log.levels

---Shared indent depth. Starts at 1 so every line carries a leading `> `,
---grows on each `header()` "starting" call and shrinks on each "finishing"
---call. Rendered as one `> ` per level before the `[scope] ` prefix.
---@type integer
local indent = 1

---Scoped logger; messages are prefixed with `[scope] `.
---@class catalog.logger
---Rendered `[scope] ` prefix prepended to every notification.
---@field prefix string
---Toggle flipped by [header](lua://catalog.logger.header) on each call.
---@field started? boolean
---Formats `msg` and notifies it when `level` is enabled. The text is always
---returned, even when the level is disabled.
---@field message fun(self: catalog.logger, level: vim.log.levels, msg: string, ...: any): string
---Debug message; only notified after setup(true).
---@field dbg fun(self: catalog.logger, msg: string, ...: any): string
---Error message.
---@field err fun(self: catalog.logger, msg: string, ...: any): string
---Info message.
---@field inf fun(self: catalog.logger, msg: string, ...: any): string
---Warning message.
---@field wrn fun(self: catalog.logger, msg: string, ...: any): string
---Alternates between `starting`/`finishing` markers, marking setup progress
---while indenting (`starting`) and unindenting (`finishing`) the message tree.
---@field header fun(self: catalog.logger)

---Shared prototype; instances created by [M.new](lua://catalog.log.new) only
---carry their own state (`prefix`, `started`) and resolve methods through
---`__index`, so the functions exist exactly once regardless of scope count.
local logger = {}

---Formats `msg` with `...`, indents it, and notifies when `level` is enabled.
---Formatting is skipped entirely when the level is disabled, so callers may
---pass expensive arguments or partially-invalid format strings safely.
---@param level vim.log.levels
---@param msg string Format string, or plain message when no extra args.
---@vararg any Format arguments.
---@return string text The formatted message.
function logger:message(level, msg, ...)
	if not enabled[level] then
		return msg
	end

	local text = select("#", ...) > 0 and msg:format(...) or msg
	vim.notify(self:indent() .. text, level)
	return text
end

---Indented prefix for the current depth, e.g. `> [setup] ` at the base level
---or `> > [setup] ` one block deep.
---@return string
function logger:indent()
	return ("%s%s"):format(string.rep("> ", indent), self.prefix)
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

---Toggles a scope's `starting`/`finishing` marker, driving the shared indent:
---`starting` moves one level deeper and `finishing` pops back. The marker is a
---DEBUG message rendered at the depth it opens/closes, so content logged inside
---the block lines up between its two markers.
---@return string
function logger:header()
	self.started = not self.started

	if self.started then
		indent = indent + 1
		return self:message(levels.DEBUG, "starting")
	else
		local text = self:message(levels.DEBUG, "finishing")
		indent = math.max(1, indent - 1)
		return text
	end
end

---Configures which levels are notified.
---
---When `silent` is true, ERROR/WARN/INFO are muted; when `debug` is true,
---DEBUG is notified as well. Returns the module so `setup(...).new(...)`
---chains in a single expression.
---@param debug boolean Notify DEBUG messages.
---@param silent boolean Mute ERROR/WARN/INFO messages.
---@return table M The module itself, for chaining.
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

---Returns the logger tagged with `scope`, creating it on first use and
---reusing the same instance afterwards.
---@param scope string Dot-separated module-ish name (e.g. `"provider.mason"`).
---@return catalog.logger
function M.new(scope)
	if not cache[scope] then
		cache[scope] = setmetatable({ prefix = "[" .. scope .. "] " }, { __index = logger })
	end

	return cache[scope]
end

return M
