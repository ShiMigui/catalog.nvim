local ensurer = require("mason-catalog.utils.ensurer")
local logger = require("mason-catalog.utils.logger")

---@param pkg_name PkgName
---@param config vim.lsp.Config
---@param normalized table<LspName, vim.lsp.Config>
local function normalize_pkg(pkg_name, config, normalized)
	local log = logger.with_scope("lsp.normalizer.normalize_pkg")
	local p = ensurer.ensure(pkg_name)
	if p then
		if p.lspname then
			normalized[p.lspname] = config
			log.dbg("LSP '%s' config was added to normalized list", p.lspname)
			return
		end
		log.wrn("LSPName for package '%s' is not set", pkg_name)
	end
end

---@param config vim.lsp.Config
---@param default vim.lsp.Config
local function merge_config(config, default)
	return vim.tbl_deep_extend("force", vim.deepcopy(default), config)
end

return {
	---@param entry LspEntry
	---@param default_config vim.lsp.Config
	---@return NormalizedLsp?
	setup = function(entry, default_config)
		local log = logger.with_scope("lsp.normalizer.setup")
		local t = type(entry)
		local normalized = {}
		if t == "string" then
			normalize_pkg(entry, vim.deepcopy(default_config), normalized)
		elseif t ~= "table" then
			return log.err("Type of entry invalid!")
		elseif vim.islist(entry) then
			for _, pkg_name in ipairs(entry) do
				normalize_pkg(pkg_name, vim.deepcopy(default_config), normalized)
			end
		else
			for pkg_name, config in pairs(entry) do
				if type(config) == "table" then
					log.dbg("Extending config for '%s' LSP", pkg_name)
					normalize_pkg(pkg_name, merge_config(config, default_config), normalized)
				elseif type(config) == "string" then
					normalize_pkg(config, vim.deepcopy(default_config), normalized)
				else
					log.wrn("Invalid config for '%s'", pkg_name)
				end
			end
		end

		return next(normalized) and normalized or nil
	end,
}
