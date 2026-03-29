local M = {}

---@type table<PkgName, Pkg>
local packages = {}

---@param name PkgName
---@return Pkg?
function M.get_package(name)
	return packages[name]
end

---@param name PkgName
---@param pkg Pkg
function M.set_package(name, pkg)
	packages[name] = pkg
end

---Reset cache (use ONLY for tests)
function M._clear()
	for k in pairs(packages) do
		packages[k] = nil
	end
end

return M
