local ensurer = require("mason-catalog.utils.ensurer")
local logger = require("mason-catalog.utils.logger")

---@param pkg_name PkgName
---@param config vim.lsp.Config
---@param normalized table<LspName, vim.lsp.Config>
local function normalize_pkg(pkg_name, config, normalized)
	local p = ensurer.ensure(pkg_name)
	if p then
		if p.lspname then
			normalized[p.lspname] = config()
			return
		end
		logger.wrn("LSPName for package '%s' is not set", pkg_name)
	end
end

---@param entry LspEntry
---@param default_config vim.lsp.Config
---@return NormalizedLsp?
return function(entry, default_config)
	local t = type(entry)
	local normalized = {}
	if t == "string" then
		normalize_pkg(entry, vim.deepcopy(default_config), normalized)
		return normalized
	elseif t ~= "table" then
		return logger.err("Type of entry invalid!")
	end

	if vim.islist(entry) then
		for _, pkg_name in ipairs(entry) do
			normalize_pkg(pkg_name, vim.deepcopy(default_config), normalized)
		end
	else
		for pkg_name, config in pairs(entry) do
			config = type(config) == "table" and config or {}
			normalize_pkg(pkg_name, vim.tbl_deep_extend("force", vim.deepcopy(default_config), config), normalized)
		end
	end
	return next(normalized) and normalized or nil
end
