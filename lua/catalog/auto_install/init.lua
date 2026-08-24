---@type table<string, table<'lsp'|'formatter'|'linter', catalog.Package>|boolean>
local seen_ft = {}
local lsp = require("catalog.lsp")
local log = require("catalog.log").new("auto_install")
local pkgs_table = require("catalog.auto_install.table")
local Providers = require("catalog.provider")
local default_config = require("catalog.lsp").default_config

local function lsp_auto_install(name)
	local p = Providers.try_resolve(name)
	log:dbg("Trying auto-install '%s'", name)
	if not p or lsp.configured_lsps[name] then
		return
	end

	log:dbg("Auto-installing '%s'", name)
	p:install()
	p.lsp:enable()
	p.lsp:update(default_config)
end

local function formatter_auto_install(name)
	return Providers.try_resolve(name)
end

local function linter_auto_install(name)
	return Providers.try_resolve(name)
end

return {
	---comment
	---@param opts table<'lsp'|'formatter'|'linter', boolean>
	setup = function(opts)
		local cbs = {}

		if opts.lsp then
			table.insert(cbs, lsp_auto_install)
		end

		if opts.linter then
			table.insert(cbs, linter_auto_install)
		end

		if opts.formatter then
			table.insert(cbs, formatter_auto_install)
		end

		log:header()
		vim.api.nvim_create_autocmd("FileType", {
			callback = function()
				local ft = vim.bo.filetype
				if seen_ft[ft] ~= nil then
					return
				end

				local table = pkgs_table[ft]
				seen_ft[ft] = table
				if not table then
					return
				end
			end,
		})
		log:header()
	end,
}
