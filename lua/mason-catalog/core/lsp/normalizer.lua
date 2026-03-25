local log = require("mason-catalog.utils.logger").with_scope(...)
local ensurer = require("mason-catalog.utils.ensurer")
local M = {}

---@param pkg_name PkgName
---@param config vim.lsp.Config
---@param normalized table<LspName, vim.lsp.Config>
local function normalize_pkg(pkg_name, config, normalized)
	local p = ensurer.ensure(pkg_name)
	if p then
		if p.lspname then
			normalized[p.lspname] = config
			log.dbg("LSP '%s' config was added to normalized list", p.lspname)
			return normalized
		end
		log.wrn("LSPName for package '%s' is not set", pkg_name)
	end
end

---@param config vim.lsp.Config
---@param default vim.lsp.Config
function M.merge_config(config, default)
	return vim.tbl_deep_extend("force", vim.deepcopy(default), config)
end

-- handlers[k][v]
local table_handlers = {
	string = {
		table = function(pkg, cfg, default)
			log.dbg("Extending config for '%s' LSP", pkg)
			return pkg, M.merge_config(cfg, default)
		end,
	},
	number = {
		string = function(_, pkg, default)
			log.dbg("Adding LSP '%s' with default config", pkg)
			return pkg, vim.deepcopy(default)
		end,
	},
}

local entry_handlers = {
	string = function(entry, default)
		return normalize_pkg(entry, vim.deepcopy(default), {})
	end,
	table = function(entry, default)
		local normalized = {}
		for k, v in pairs(entry) do
			local handler = table_handlers[type(k)]
			local type_v = type(v)
			if handler and handler[type_v] then
				local pkg_name, config = handler[type_v](k, v, default)
				normalize_pkg(pkg_name, config, normalized)
			else
				log.err("Invalid config for '%s'", k)
			end
		end
		return next(normalized) and normalized or nil
	end,
}

---@param entry LspEntry
---@param default_config vim.lsp.Config
---@return NormalizedLsp?
function M.setup(entry, default_config)
	local entry_handler = entry_handlers[type(entry)]
	if entry_handler then
		return entry_handler(entry, default_config)
	end
	return log.err("Type of entry invalid!")
end

---@param ext FileExtension
---@return Filetype?
function M.ext_to_ft(ext)
	return vim.filetype.match({ extension = ext })
end

return M
