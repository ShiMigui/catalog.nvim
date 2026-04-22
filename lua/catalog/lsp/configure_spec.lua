local asigns_fts_to_lsp = require("catalog.lsp.asigns_fts_to_lsp")
local resolve_lsps = require("catalog.lsp.resolve_lsps")
local log = require("catalog.log").log(...)

---configures a catalog.entry.lsp.spec
---@param i integer index
---@param spec catalog.entry.lsp.spec
---@param config catalog.lsp.config
---@param map fts_by_lsp
return function(i, spec, config, map)
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
