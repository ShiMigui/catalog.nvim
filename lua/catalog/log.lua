---Logging system for catalog.nvim.
---
---```lua
---local log = require("catalog.log").new("provider")
---log.inf("resolved %d package(s)", n)
---```

local lvls = vim.log.levels

---@type table<vim.log.levels, boolean>
local enabled = {
	[lvls.ERROR] = true,
	[lvls.WARN] = true,
	[lvls.INFO] = true,
	[lvls.DEBUG] = false,
}

---@param level vim.log.levels
---@param prefix string
---@return fun(msg: string, ...: any)
local function build(level, prefix)
	return function(msg, ...)
		if enabled[level] then
			local text = select("#", ...) > 0 and msg:format(...) or msg
			vim.notify(prefix .. text, level)
		end
	end
end

---@class catalog.Logger
---@field dbg fun(msg: string, ...: any) Debug message.
---@field inf fun(msg: string, ...: any) Info message.
---@field wrn fun(msg: string, ...: any) Warning message.
---@field err fun(msg: string, ...: any) Error message.
---@field header fun() Logs "starting" on the first call and "finishing" afterwards.

---@type table<string, catalog.Logger>
local cache = {}

local M = {}

---Creates a logger tagged with `scope`, or returns the cached one.
---State (e.g. `header`) is shared between all `new(scope)` calls.
---@param scope string
---@return catalog.Logger
function M.new(scope)
	local cached = cache[scope]
	if cached then
		return cached
	end

	local prefix = "[" .. scope .. "] "
	local dbg = build(lvls.DEBUG, prefix)
	local started = false
	local logger = {
		dbg = dbg,
		inf = build(lvls.INFO, prefix),
		wrn = build(lvls.WARN, prefix),
		err = build(lvls.ERROR, prefix),
		header = function()
			started = not started
			dbg(started and "starting" or "finishing")
		end,
	}
	cache[scope] = logger
	return logger
end

---Enables or disables debug messages.
---@param debug? boolean
function M.setup(debug)
	enabled[lvls.DEBUG] = debug == true
end

return M
