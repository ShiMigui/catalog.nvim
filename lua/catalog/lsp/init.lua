local registry = require("catalog.lsp.registry")
local process = require("catalog.lsp.process")
local log = require("catalog.log").log(...)

---@type catalog.integration
return {
	---Entry point for catalog LSP integration.
	---
	---Responsibilities:
	---- Normalize user input (array + map styles)
	---- Process all specs
	---- Enable all configured LSPs
	---
	---@param opts catalog.entry.lsp
	setup = function(opts)
		log.header()
		if type(opts) ~= "table" then
			log.err("Options given wasn't a table, nothing to do!")
			return
		end

		for i, spec in pairs(opts) do
			if type(i) == "string" then
				process(i, { i, lsp = spec })
			else
				process(i, spec)
			end
		end

		registry.enable_all()
		log.header()
	end,
}
