local provider = require("mason-catalog.core.provider")
local logger = require("mason-catalog.logger").logger(...)

local function activate_lsps(map, ft)
	local lsps = map[ft]
	if not lsps then
		return
	end

	logger.dbg("found LSPs for %s", ft)
	for _, pkg_name in ipairs(lsps) do
		local p = provider.resolve(pkg_name)
		if p then
			local name = p.lspname
			if not p.installed then
				logger.wrn("LSP '%s' will not be enabled, because it's not installedd yet", name)
				return
			end

			if not vim.lsp.is_enabled(name) then
				logger.dbg("activating %s", name)
				vim.lsp.config(name, p.lspconfig)
				vim.lsp.enable(name)
			end
		end
	end
end

---@param map table<string, cat.pkg.name[]>
return function(map)
	local function callback(args)
		local ft = args.match
		logger.dbg("running FileType autocmd callback for %s", ft)
		activate_lsps(map, ft)
	end

	vim.api.nvim_create_autocmd("FileType", { callback = callback })

	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(buf) then
			activate_lsps(map, vim.bo[buf].filetype)
		end
	end
end
