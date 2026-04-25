local configure_spec = require("catalog.lsp.configure_spec")
local log = require("catalog.log").log(...)

---@type catalog.integration
return {
	---@param opts any|catalog.entry.lsp
	init = function(opts)
		log.header(true)
		if type(opts) ~= "table" then
			log.err("Options given wasn't a table, nothing to do!")
			return
		end

		local config = opts.config or { capabilities = vim.lsp.protocol.make_client_capabilities() }

		local map = {}

		opts.config = nil
		for i, spec in ipairs(opts) do
			configure_spec(i, spec, config, map)
			opts[i] = nil
		end
		for ft, lsp in pairs(opts) do
			configure_spec(ft, { ft, lsp = lsp }, config, map)
		end

		for name, m in pairs(map) do
			local lsp = m[3]
			local fts = m[2]

			lsp.update({ filetypes = fts })
			vim.lsp.config(lsp, lsp.config)
			vim.lsp.enable(lsp)
			log.dbg("%s is running", name)
		end
		log.header(false)
	end,
}
