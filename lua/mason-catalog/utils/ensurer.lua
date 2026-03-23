---@type EnsureList
local M = {}
local pkg = require("mason-catalog.core.pkg")

---@type table<string, Pkg> # Cache of already processed packages (prevents duplicate installs)
local set = {}

function M.ensure(name)
	if set[name] then
		return
	end

	local p = pkg.install(name)
	if p then
		set[name] = p
      return p
	end
end

function M.ensure_many(list)
	for _, s in ipairs(list) do
		M.ensure(s)
	end
end

function M.ensure_any(initial)
	if type(initial) == "string" then
		M.ensure(initial)
	else
		M.ensure_many(initial)
	end
end

return M
