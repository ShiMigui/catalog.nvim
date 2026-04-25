local log = require("catalog.log").log(...)

---@param str string possible filetype/extension name
---@param lsps catalog.lsp[]
---@param map table
return function(str, lsps, map)
	local ft = vim.filetype.match({ filename = "file." .. str })
	if not ft then
		log.err("Invalid filetype/extension '%s'", str)
		return
	end

	for _, lsp in ipairs(lsps) do
		local name = lsp.name
		map[name] = map[name] or { {}, {}, lsp }

		if not map[name][1][ft] then
			table.insert(map[name][2], ft)
			map[name][1][ft] = true
		end
	end
end
