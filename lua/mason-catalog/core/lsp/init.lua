local lsp_normalizer = require("mason-catalog.core.lsp.normalizer")
local autocmd = require("mason-catalog.core.lsp.autocmd")
local state = require("mason-catalog.core.lsp.state")
local log = require("mason-catalog.utils.logger").with_scope(...)

local normalize_fields = {
	---@param groups? LspByGroup[]
	---@param default vim.lsp.Config
	by_group = function(groups, default)
		if not groups or not next(groups) then
			return
		end
		for i, group in ipairs(groups) do
			local filetypes = group.filetypes
			local lsps = group.lsps

			if not filetypes or not lsps then
				log.err("Filetypes or LSPs not set to group[%d]", i)
			elseif not vim.islist(filetypes) then
				log.err("Type incorrect of filetypes in group[%d]", i)
			elseif not vim.islist(lsps) then
				log.err("Type incorrect of lsps in group[%d]", i)
			else
				local normalized = lsp_normalizer.setup(lsps, default)
				if normalized then
					for _, ft in ipairs(filetypes) do
						local pre_config = state.get(ft)
						if pre_config then
							pre_config = lsp_normalizer.merge_config(pre_config, normalized)
							state.add(ft, pre_config)
						else
							state.add(ft, vim.deepcopy(normalized))
						end
					end
				end
			end
		end
	end,
	by_ft = function(by_ft, default)
		if not by_ft or not next(by_ft) then
			return
		end
		for ft, lsp_entry in pairs(by_ft) do
			local normalized = lsp_normalizer.setup(lsp_entry, state.get(ft) or default)
			if normalized then
				state.add(ft, normalized)
			end
		end
	end,
}

return {
	---@param opts? MasonCatalogLspOpts
	setup = function(opts)
		if not opts then
			return
		end
		local default_config = opts.default_config or { capabilities = vim.lsp.protocol.make_client_capabilities() }

		normalize_fields.by_group(opts.by_group, default_config)
		normalize_fields.by_ft(opts.by_ft, default_config)

		autocmd.setup()
	end,
}
