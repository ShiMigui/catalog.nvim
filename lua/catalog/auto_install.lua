local provider = require("catalog.provider")
local log = require("catalog.log").log(...)

---@class catalog.AutoInstallConfig
---@field lsp? table<string, string|string[]>
---@field conform? table<string, string|string[]>
---@field lint? table<string, string|string[]>

local function ensure_list(val)
	if type(val) == "string" then
		return { val }
	end
	return val
end

local function install_for_filetype(ft, mapping, integration_name)
	local tools = mapping[ft]
	if not tools then
		return
	end

	tools = ensure_list(tools)
	for _, tool in ipairs(tools) do
		local p = provider.resolve(tool)
		if p and not p.installed() then
			log.dbg("Auto-installing %s '%s' for filetype '%s'", integration_name, tool, ft)
			p.install()
		end
	end
end

---@type catalog.Integration
return {
	---@param opts catalog.AutoInstallConfig
	setup = function(opts)
		log.header()

		if opts.lsp then
			vim.api.nvim_create_autocmd("FileType", {
				pattern = vim.tbl_keys(opts.lsp),
				callback = function(args)
					install_for_filetype(args.match, opts.lsp, "LSP")
				end,
				group = vim.api.nvim_create_augroup("CatalogAutoInstallLsp", { clear = true }),
			})
		end

		if opts.conform then
			vim.api.nvim_create_autocmd("FileType", {
				pattern = vim.tbl_keys(opts.conform),
				callback = function(args)
					install_for_filetype(args.match, opts.conform, "formatter")
				end,
				group = vim.api.nvim_create_augroup("CatalogAutoInstallConform", { clear = true }),
			})
		end

		if opts.lint then
			vim.api.nvim_create_autocmd("FileType", {
				pattern = vim.tbl_keys(opts.lint),
				callback = function(args)
					install_for_filetype(args.match, opts.lint, "linter")
				end,
				group = vim.api.nvim_create_augroup("CatalogAutoInstallLint", { clear = true }),
			})
		end

		log.header()
	end,
}
