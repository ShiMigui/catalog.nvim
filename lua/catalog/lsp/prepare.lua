local log = require("catalog.log").log(...)
local provider = require("catalog.provider")

---@param name catalog.pkg.name
---@param config? catalog.lsp.config
---@param default catalog.lsp.config
---@return catalog.lsp?
local function lsp_config(name, config, default)
	local p = provider.resolve(name)
	if p then
		if p.lsp then
			p.install()
			p.lsp.setup(default)
			if config then
				p.lsp.update(config)
			end
			return p.lsp
		end
		log.err("Package '%s' is not a LSP", name)
	end
end

local TABLE_LSP_ENTRIES = {
	string_table = lsp_config,
	number_string = function(_, name, default)
		return lsp_config(name, nil, default)
	end,
}

local TYPE_ENTRIES = {
	string = function(name, config)
		local p = lsp_config(name, nil, config)
		return p and { p } or nil
	end,
	table = function(tbl, config)
		local list = {}
		for k, v in pairs(tbl) do
			local tk, tv = type(k), type(v)
			local handler = TABLE_LSP_ENTRIES[tk .. "_" .. tv]
			if handler then
				local p = handler(k, v, config)
				if p then
					table.insert(list, p)
				end
			else
				log.err("Invalid LSP entry, key %s, value %s", tk, tv)
			end
		end
		return #list > 0 and list or nil
	end,
}

---Resolves user-defined LSP specification into initialized LSP instances.
---
---Responsibilities:
---- Normalize input (string | list | map)
---- Install required packages via provider
---- Apply default and custom configurations
---
---@param lsp catalog.entry.lsp.spec.lsp_list
---@param config catalog.lsp.config
---@return catalog.lsp[]|nil
return function(lsp, config)
	local t = type(lsp)
	local handler = TYPE_ENTRIES[t]
	if handler then
		return handler(lsp, config)
	end
	log.err("Invalid type for lsps, expected string/table, got %s", t)
end
