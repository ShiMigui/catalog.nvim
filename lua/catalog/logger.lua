---Scoped, low-overhead logging for catalog.nvim.
---
---The four level methods live once on a shared prototype; each logger only
---keeps its `[scope] ` prefix and resolves the methods through `__index`. A
---disabled call returns after a single table lookup, and formatting is
---skipped until a message is actually emitted.
---
---Messages render as `[scope] STATUS message`, indented while a
---[NewIn](lua://M.NewIn) block is active:
---
---```lua
---local logger = require("catalog.logger")
---local log = logger.New("provider.mason")
---log:INF("resolved %d package(s)", n)
---
---logger.NewIn(opts, function(block)
---    block.log:DBG("preparing %s", block.payload.name)
---end, "provider.mason.setup")
---```
local M = {}

---Whether each status is emitted. Flip these at runtime to (de)activate a
---level globally, e.g. `require("catalog.logger").Status.DBG = true`. A status
---set to `false` is ignored everywhere.
---@type catalog.logger.Status
M.Status = {
	DBG = false,
	INF = true,
	WRN = true,
	ERR = true,
}

---Status name to Neovim log level, resolved once at load time.
---@type table<string, vim.log.levels>
local level_of = {
	DBG = vim.log.levels.DEBUG,
	INF = vim.log.levels.INFO,
	WRN = vim.log.levels.WARN,
	ERR = vim.log.levels.ERROR,
}

---Indentation shared by every logger: each active [NewIn](lua://M.NewIn)
---block adds two spaces. `pad` caches the rendered spaces so a message never
---has to rebuild them.
---@type string
local pad = ""

---Formats and notifies `msg` when `status` is enabled. Returning before any
---formatting keeps disabled calls allocation-free.
---@param log catalog.logger
---@param status string One of `DBG`, `INF`, `WRN`, `ERR`.
---@param msg string Format string, or a plain message when there are no `...`.
---@vararg any
local function message(log, status, msg, ...)
	if M.Status[status] then
		local text = select("#", ...) > 0 and msg:format(...) or msg
		vim.notify(pad .. log.prefix .. status .. " " .. text, level_of[status])
	end
end

---Shared method prototype, resolved by every logger through `__index`.
---@type catalog.logger
local logger = {
	DBG = function(self, msg, ...)
		message(self, "DBG", msg, ...)
	end,
	INF = function(self, msg, ...)
		message(self, "INF", msg, ...)
	end,
	WRN = function(self, msg, ...)
		message(self, "WRN", msg, ...)
	end,
	ERR = function(self, msg, ...)
		message(self, "ERR", msg, ...)
	end,
}

---Loggers created so far, keyed by scope, so a scope maps to one instance.
---@type table<string, catalog.logger>
local cache = {}

---Returns the logger for `scope`, creating it on first use.
---
---Methods and [Status](lua://M.Status) are shared, so an instance only
---allocates its own `[scope] ` prefix.
---@param scope string Dot-separated name, e.g. `"provider.mason"`.
---@return catalog.logger
function M.New(scope)
	local instance = cache[scope]
	if not instance then
		instance = setmetatable({ prefix = "[" .. scope .. "] " }, { __index = logger })
		cache[scope] = instance
	end
	return instance
end

---Runs `callback` for `scope`, bracketed by DEBUG `initing...`/`finishing...`
---markers and indented one level while it runs.
---
---When `payload` is `nil` or an empty table, nothing happens: the callback is
---not called. Otherwise the callback receives a
---[block](lua://catalog.logger.block) whose `log` is the logger for `scope`
---and whose `payload` is the value it was given. If the callback errors,
---indentation is restored and the error is re-raised instead of being
---swallowed.
---@generic T
---@param payload T Block input; `nil` or an empty table skips the block.
---@param callback fun(block: catalog.logger.block<T>) Receives the block context.
---@param scope string Scope for the block and the callback's logger.
function M.NewIn(payload, callback, scope)
	if payload == nil or (type(payload) == "table" and next(payload) == nil) then
		return
	end

	local log = M.New(scope)
	pad = pad .. "  "
	log:DBG("initing...")

	local ok, err = pcall(callback, { log = log, payload = payload })

	log:DBG("finishing...")
	pad = pad:sub(3)
	if not ok then
		error(err, 0)
	end
end

return M
