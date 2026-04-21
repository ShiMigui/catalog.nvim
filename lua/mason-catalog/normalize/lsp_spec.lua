local logger = require("mason-catalog.logger").logger(...)
local provider = require("mason-catalog.core.provider")

---Applies LSP configuration.
---If successful, installs LSP and appends the package name to the provided list.
---
---@param list cat.pkg.name[] Accumulator list for normalized package names
---@param pkg_name cat.pkg.name Package name to resolve/install
---@param config? cat.lsp.config Optional LSP-specific configuration
---@param default cat.lsp.config Default configuration fallback
local function sync_config(list, pkg_name, config, default)
	local pkg = provider.resolve(pkg_name)
	if pkg and pkg.sync_config(config, default) then
		pkg.install()
		table.insert(list, pkg_name)
	end
end

local HANDLERS = {
	---Handles table<string, config>
	string_table = sync_config,

	---Handles list { "lsp_name" }
	number_string = function(list, _, pkg_name, default)
		sync_config(list, pkg_name, nil, default)
	end,
}

---Normalizes a LSP specification into a list of package names.
---@param spec cat.lsp.spec User-provided LSP specification
---@param default cat.lsp.config Default LSP configuration
---@return cat.pkg.name[]? list Normalized package names or nil if empty/invalid
return function(spec, default)
	local list = {}
	local tspec = type(spec)

	if tspec == "string" then
		sync_config(list, spec, nil, default)
		return #list > 0 and list or nil
	end

	if tspec ~= "table" then
		logger.err("Invalid LspSpec type, expected string or table, got '%s'", tspec)
		return nil
	end

	for k, v in pairs(spec) do
		local tk, tv = type(k), type(v)
		local handler = HANDLERS[tk .. "_" .. tv]

		if handler then
			handler(list, k, v, default)
		else
			logger.err("Invalid LspSpec entry: table<%s,%s>", tk, tv)
		end
	end

	return #list > 0 and list or nil
end
