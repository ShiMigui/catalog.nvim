local function format(scope, msg, ...)
	if select("#", ...) > 0 then
		msg = msg:format(...)
	end
	return scope .. msg
end

local lvls = vim.log.levels

---@type table<vim.log.levels, boolean>
local log = {
	[lvls.ERROR] = false,
	[lvls.WARN] = false,
	[lvls.DEBUG] = false,
}

local function notify_builder(level, scope, msg_scope)
	local cfg = log[scope] or log
	local should_log = cfg[level]

	if should_log then
		return function(msg, ...)
			vim.notify(format(msg_scope, msg, ...), level)
		end
	end
	return function(_, _) end
end

local M = {}

M.log = function(scope)
	local msg_scope = "[" .. scope .. "] "

	local start = true
	local dbg = notify_builder(lvls.DEBUG, scope, msg_scope)
	return {
		dbg = dbg,
		wrn = notify_builder(lvls.WARN, scope, msg_scope),
		err = notify_builder(lvls.ERROR, scope, msg_scope),

		header = function()
			if start then
				dbg("starting")
				start = false
			else
				dbg("finishing")
			end
		end,
	}
end

M.set_log = function(tbl, show_logs, debug)
	log = vim.tbl_deep_extend("force", log, tbl)

	log[lvls.WARN] = show_logs
	log[lvls.ERROR] = show_logs
	log[lvls.DEBUG] = debug

	return M
end

return M
