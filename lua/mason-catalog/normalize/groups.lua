local normalize_lsp_spec = require("mason-catalog.normalize.lsp_spec")

local function group(g, default_config)
	local names = {}
	local lsps = normalize_lsp_spec(g.lsps, default_config)

	for i = 1, #g do
		names[g[i]] = lsps
	end

	return names
end

---@param groups FileGroup
---@param default_config LspConfig
return function(groups, default_config)
	local names = {}
	for _, g in ipairs(groups) do
		group(g, default_config)
	end
	return names
end
