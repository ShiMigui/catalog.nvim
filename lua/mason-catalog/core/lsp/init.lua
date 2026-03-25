local lsp_normalizer = require("mason-catalog.core.lsp.normalizer")
local autocmd = require("mason-catalog.core.lsp.autocmd")
local state = require("mason-catalog.core.lsp.state")
local log = require("mason-catalog.utils.logger").with_scope(...)

return {
	---@param opts MasonCatalogLspOpts
	setup = function(opts)
		log.dbg("Running LSP setup()...")
		local default_config = opts.default_config or {}
		local by_group = opts.by_group or nil
		local by_ft = opts.by_ft or nil

		if type(by_group) == "table" and next(by_group) then
			for _, data in ipairs(by_group) do
				if type(data.filetypes) == "table" and data.lsps then
					local normalized = lsp_normalizer.setup(data.lsps, default_config)
					if normalized then
						for _, ft in ipairs(data.filetypes) do
							state.add(ft, vim.deepcopy(normalized))
						end
					end
				end
			end
		end

		if type(by_ft) == "table" and next(by_ft) then
			for ft, entry in pairs(by_ft) do
				local normalized = lsp_normalizer.setup(entry, state.get(ft) or default_config)
				if normalized then
					state.add(ft, normalized)
				end
			end
		end

		if opts.auto_enable then
			autocmd.setup()
		end
	end,
}
