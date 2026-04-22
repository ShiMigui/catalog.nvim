local log = require("catalog.log").log(...)
local provider = require("catalog.provider")

---@alias fts_by_lsp table<catalog.pkg.name, string[]> -- fts by lsp

---@alias catalog.entry.lsp.spec.lsp_list string|string[]|table<string, catalog.lsp.config>

---{"lua", lsp="lua-language-server"}
---{"js", "jsx", "ts", "tsx", lsp={"eslint-lsp", "typescript-language-server"}}
---{"php", lsp={intelephense={...}}}
---@class catalog.entry.lsp.spec
---@field lsp? catalog.entry.lsp.spec.lsp_list
---@field [integer] string  -- filetypes

---{
---     config = {...}|nil,
---
---     {"lua", lsp="lua-language-server"},
---     {"js", "jsx", "ts", "tsx", lsp={"eslint-lsp", "typescript-language-server"}},
---     {"php", lsp={intelephense={...}}},
---     ...
---}
---@class catalog.entry.lsp
---@field config? catalog.lsp.config
---@field [integer] catalog.entry.lsp.spec

local function lsp_config(name, config, default)
	local p = provider.resolve(name)
	if p then
		if not p.lsp then
			log.err("Package '%s' is not a LSP", name)
			return
		end

		p.install()
		p.lsp.setup(default)
		if config then
			p.lsp.update(config)
		end
		return p.name
	end
end

local TABLE_LSP_ENTRIES = {
	string_table = lsp_config,
	number_string = function(_, name, default)
		return lsp_config(name, nil, default)
	end,
}

---Certifies the input becomes a LSP name list and related packages are installed and with config set
---@param lsp_list catalog.entry.lsp.spec.lsp_list
---@param config catalog.lsp.config
---@return catalog.pkg.name[]|nil
local function resolve_lsps(lsp_list, config)
	local t = type(lsp_list)
	if t == "string" then
		local p = lsp_config(lsp_list, nil, config)
		return p and { p } or nil
	elseif t ~= "table" then
		log.err("Invalid type for lsps, expected string/table, got %s", t)
		return
	end

	local list = {}
	for k, v in pairs(lsp_list) do
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
end

---@param str string possible filetype/extension name
---@param lsps catalog.lsp.name[]
---@param map fts_by_lsp
local function asigns_fts_to_lsp(str, lsps, map)
	local ft = vim.filetype.match({ filename = "file." .. str })
	if not ft then
		log.err("Invalid filetype/extension '%s'", str)
		return
	end
	for _, lsp in ipairs(lsps) do
		map[lsp] = map[lsp] or {}
		table.insert(map[lsp], ft)
	end
end

---configures a catalog.entry.lsp.spec
---@param i integer index
---@param spec catalog.entry.lsp.spec
---@param config catalog.lsp.config
---@param map fts_by_lsp
local function configure_spec(i, spec, config, map)
	local t = type(spec)
	if t ~= "table" then
		log.wrn("Spec [%d] is not a table, got %s", i, t)
		return
	elseif #spec == 0 then
		log.wrn("No filetypes in spec number [%d], nothing to do in this spec", i)
		return
	end

	local lsps = resolve_lsps(spec.lsp, config)
	if not lsps then
		log.err("There is no valid LSPs to asigns in Spec [%d]", i)
	end
	if lsps then
		for _, str in ipairs(spec) do
			asigns_fts_to_lsp(str, lsps, map)
		end
	end
end

---@type catalog.integration
return {
	---@param opts any|catalog.entry.lsp
	init = function(opts)
		if type(opts) ~= "table" then
			log.err("Options given wasn't a table, nothing to do!")
			return
		end

		if #opts == 0 then
			log.err("No LSPs specs given, nothing to do!")
			return
		end

		local config = opts.config or { capabilities = vim.lsp.protocol.make_client_capabilities() }

		log.header(true)
		---@type fts_by_lsp
		local map = {}

		for i, spec in ipairs(opts) do
			configure_spec(i, spec, config, map)
		end

		for name, fts in pairs(map) do
			log.dbg("Turning on %s", name)
			local p = provider.resolve(name)
			if p and p.lsp and p.installed() then
				local lsp = p.lsp.name
				---@diagnostic disable-next-line: missing-fields
				p.lsp.update({ filetypes = fts })
				vim.lsp.config(lsp, p.lsp.config)
				vim.lsp.enable(lsp)
				log.dbg("%s is running", name)
			end
		end

		log.header(false)
	end,
}
