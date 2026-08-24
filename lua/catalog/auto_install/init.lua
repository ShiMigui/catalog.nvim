---@type table<string, table<'lsp'|'formatter'|'linter', catalog.Package>|boolean>
local seen_ft = {}
local lsp = require("catalog.lsp")
local log = require("catalog.log").new("auto_install")
local pkgs_table = require("catalog.auto_install.table")
local Providers = require("catalog.provider")
local default_config = require("catalog.lsp").default_config
local ensure_list_of = require("catalog.scripts.ensure_list_of")

local function lsp_auto_install(tbl)
	local name = tbl.lsp
	local p = Providers.try_resolve(name)
	log:dbg("Trying auto-install '%s'", name)
	if not p or lsp.configured_lsps[name] then
		log:dbg("Package is not availible '%s'", name)
		return
	end

	if not lsp.configured_lsps[name] then
		log:dbg("Auto-installing '%s'", name)
		p:install()
		p.lsp:update(default_config)
		p.lsp:enable()
	else
		log:dbg("LSP already has been configured '%s'", name)
	end
	return p
end

local function formatter_auto_install(tbl)
	local name = tbl.formatter
	log:dbg("Trying auto-install '%s'", name)
	local p = Providers.try_resolve(name)
	if not p then
		log:dbg("Package is not availible '%s'", name)
		return
	end
	return p
end

local function linter_auto_install(tbl)
	local name = tbl.linter
	log:dbg("Trying auto-install '%s'", name)
	local p = Providers.try_resolve(name)
	if not p then
		log:dbg("Package is not availible '%s'", name)
		return
	end
	return p
end

return {
	---comment
	---@param opts table<'lsp'|'formatter'|'linter', boolean>
	setup = function(opts)
		local cbs = {}

		if opts.lsp then
			cbs["lsp"] = lsp_auto_install
		end

		if opts.linter then
			cbs["linter"] = linter_auto_install
		end

		if opts.formatter then
			cbs["formatter"] = formatter_auto_install
		end

		log:header()
		if #cbs == 0 then
			log:dbg("auto-install fast exit, there are no auto-install groups enabled")
			log:header()
			return
		end
		vim.api.nvim_create_autocmd("FileType", {
			callback = function()
				local ft = vim.bo.filetype
				if seen_ft[ft] ~= nil then
					return
				end

				local tbl = pkgs_table[ft]
				seen_ft[ft] = tbl
				if not tbl then
					return
				end

				for cat, list in pairs(tbl) do
					for _, pkg in pairs(ensure_list_of(list, "string") or {}) do
						cbs[cat](pkg)
					end
				end
			end,
		})
		log:header()
	end,
}
