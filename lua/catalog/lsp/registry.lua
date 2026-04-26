local log = require("catalog.log").log(...)

---Internal registry that groups filetypes by LSP.
---
---Ensures:
---- Filetypes are unique per LSP
---- LSPs are configured only once
---@class catalog.lsp.registry.entry
---@field ft_set table<string, boolean>
---@field fts string[]
---@field lsp catalog.lsp
local map = {}

return {
	---Registers filetypes for given LSPs.
	---
	---@param str string filetype or extension
	---@param lsps catalog.lsp[]
	save = function(str, lsps)
		local ft = vim.filetype.match({ filename = "file." .. str })
		if not ft then
			log.err("Invalid filetype/extension '%s'", str)
			return
		end

		for _, lsp in ipairs(lsps) do
			local name = lsp.name

			local entry = map[name]
			if not entry then
				map[name] = {
					ft_set = {},
					fts = {},
					lsp = lsp,
				}
				entry = map[name]
			end

			if not entry.ft_set[ft] then
				entry.ft_set[ft] = true
				table.insert(entry.fts, ft)
			end
		end
	end,

	---Enables all registered LSPs with their collected filetypes.
	---
	---This will:
	---- Update LSP filetypes
	---- Apply configuration
	---- Start the LSP client
	enable_all = function()
		for name, m in pairs(map) do
			local lsp, fts = m.lsp, m.fts

			lsp.update({ filetypes = fts })
			vim.lsp.config(name, lsp.config)
			vim.lsp.enable(name)
			log.dbg("%s is running", name)
		end
	end,
}
