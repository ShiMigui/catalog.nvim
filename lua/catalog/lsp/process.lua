local registry = require("catalog.lsp.registry")
local prepare = require("catalog.lsp.prepare")
local log = require("catalog.log").log(...)

---Processes a single LSP spec entry.
---
---Steps:
---1. Validate spec structure
---2. Resolve LSP instances
---3. Register filetypes in the LSP registry
---
---@param index any
---@param spec catalog.entry.lsp.spec
return function(index, spec)
	local t = type(spec)
	if t ~= "table" then
		log.wrn("Spec [%d] is not a table, got %s", index, t)
		return
	elseif not spec.lsp then
		log.wrn("Spec [%d] has no LSP defined", index)
		return
	end

	local lsps = prepare(spec.lsp)
	if not lsps then
		log.err("There is no valid LSPs to assigns in Spec [%d]", index)
		return
	end

	for _, str in ipairs(spec) do
		registry.save(str, lsps)
	end
end
