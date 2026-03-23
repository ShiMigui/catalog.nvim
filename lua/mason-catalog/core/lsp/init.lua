local lsp_normalizer = require("mason-catalog.core.lsp.normalizer")
local state = require("mason-catalog.core.lsp.state")
local logger = require("mason-catalog.utils.logger")

return {
	---@param by_ft? LspByFt
	---@param by_group? LspByGroup[]
	---@param default_config? vim.lsp.Config
	setup = function(by_ft, by_group, default_config)
		logger.dbg("Running LSP setup()...")
		default_config = default_config or {}

		if type(by_group) == "table" and next(by_group) then
			for _, data in ipairs(by_group) do
				if type(data.filetypes) == "table" and data.lsps then
					local normalized = lsp_normalizer(data.lsps, default_config)
					if normalized then
						for _, ft in ipairs(data.filetypes) do
							state.add(ft, vim.deepcopy(normalized))
						end
					end
				end
			end
		end

		if type(by_ft) ~= "table" or not next(by_ft) then
			return
		end
		for ft, entry in pairs(by_ft) do
			local normalized = lsp_normalizer(entry, state.get(ft) or default_config)
			if normalized then
				state.add(ft, normalized)
			end
		end
	end,
}
