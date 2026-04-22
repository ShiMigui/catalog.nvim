local log = require("catalog.log").log(...)

---@param str string possible filetype/extension name
---@param lsps catalog.lsp.name[]
---@param map fts_by_lsp
return function(str, lsps, map)
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
