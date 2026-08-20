local provider = require("catalog.provider")
local log = require("catalog.log").log(...)
local FT_TOOLS = require("catalog.auto_install_tools")

local function ensure_list(val)
	if type(val) == "string" then
		return { val }
	end
	return val
end

local function has_value tbl)
	return next(tbl) ~= nil
end

local function install_tools(ft, tools, integration_name)
	if not tools then
		return false
	end

	tools = ensure_list(tools)
	local installed_any = false

	for _, tool in ipairs(tools) do
		local p = provider.resolve(tool)
		if p and not p.installed() then
			log.dbg("Auto-installing %s '%s' for filetype '%s'", integration_name, tool, ft)
			p.install()
			installed_any = true
		end
	end

	return installed_any
end

---@type catalog.Integration
return {
	setup = function()
		log.header()

		local all_filetypes = vim.tbl_keys(FT_TOOLS)
		if #all_filetypes == 0 then
			log.dbg("No filetools configured for auto_install")
			return
		end

		---@type table<string, string[]>
		local lsp_filetypes = {}
		---@type table<string, string[]>
		local conform_filetypes = {}
		---@type table<string, string[]>
		local lint_filetypes = {}

		for ft, tools in pairs(FT_TOOLS) do
			if tools.lsp then
				lsp_filetypes[ft] = ensure_list(tools.lsp)
			end
			if tools.conform then
				conform_filetypes[ft] = ensure_list(tools.conform)
			end
			if tools.lint then
				lint_filetypes[ft] = ensure_list(tools.lint)
			end
		end

		if has_value(lsp_filetypes) then
			vim.api.nvim_create_autocmd("FileType", {
				pattern = vim.tbl_keys(lsp_filetypes),
				callback = function(args)
					local tools = lsp_filetypes[args.match]
					if not tools then
						return
					end

					local installed = install_tools(args.match, tools, "LSP")
					if not installed and #tools == 0 then
						log.inf("No LSP available for filetype '%s'", args.match)
					end
				end,
				group = vim.api.nvim_create_augroup("CatalogAutoInstallLsp", { clear = true }),
			})
		end

		if has_value(conform_filetypes) then
			vim.api.nvim_create_autocmd("FileType", {
				pattern = vim.tbl_keys(conform_filetypes),
				callback = function(args)
					local tools = conform_filetypes[args.match]
					if not tools then
						return
					end

					local installed = install_tools(args.match, tools, "formatter")
					if not installed and #tools == 0 then
						log.inf("No formatter available for filetype '%s'", args.match)
					end
				end,
				group = vim.api.nvim_create_augroup("CatalogAutoInstallConform", { clear = true }),
			})
		end

		if has_value(lint_filetypes) then
			vim.api.nvim_create_autocmd("FileType", {
				pattern = vim.tbl_keys(lint_filetypes),
				callback = function(args)
					local tools = lint_filetypes[args.match]
					if not tools then
						return
					end

					local installed = install_tools(args.match, tools, "linter")
					if not installed and #tools == 0 then
						log.inf("No linter available for filetype '%s'", args.match)
					end
				end,
				group = vim.api.nvim_create_augroup("CatalogAutoInstallLint", { clear = true }),
			})
		end

		log.inf("Auto-install enabled for %d filetypes", #all_filetypes)
		log.header()
	end,
}
