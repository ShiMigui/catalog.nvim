local configure_spec = require("catalog.lsp.configure_spec")
local provider = require("catalog.provider")
local log = require("catalog.log").log(...)

---@type catalog.integration
return {
	---@param opts any|catalog.entry.lsp
	init = function(opts)
		if type(opts) ~= "table" then
			log.err("Options given wasn't a table, nothing to do!")
			return
		end

		local config = opts.config or { capabilities = vim.lsp.protocol.make_client_capabilities() }

		log.header(true)
		---@type fts_by_lsp
		local map = {}

		opts.config = nil
		for i, spec in ipairs(opts) do
			configure_spec(i, spec, config, map)
			opts[i] = nil
		end
		for ft, lsp in pairs(opts) do
			configure_spec(ft, { ft, lsp = lsp }, config, map)
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
