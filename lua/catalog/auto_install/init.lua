---@type table<string, boolean>
local seen_ft = {}
local lsp = require("catalog.lsp")
local log = require("catalog.log").new("auto_install")
local pkgs_table = require("catalog.auto_install.table")
local provider = require("catalog.provider")
local ensure_list_of = require("catalog.scripts.ensure_list_of")

---Builds an installer for one tool kind: resolves the package by name and,
---when found, hands it to `handle`.
---@param kind string Tool category ('lsp'|'formatter'|'linter'), for log context.
---@param handle fun(pkg: catalog.Package) Runs when the package resolves.
---@return fun(name: string)
local function installer(kind, handle)
	return function(name)
		log:dbg("Trying to auto-install %s '%s'", kind, name)
		local pkg = provider.try_resolve(name)
		if not pkg then
			log:dbg("No provider resolved '%s'", name)
			return
		end
		handle(pkg)
	end
end

local installers = {
	lsp = installer("lsp", function(pkg)
		if not pkg.lsp then
			log:wrn("Package '%s' has no lspconfig mapping, skipping", pkg.name)
			return
		end
		if lsp.configured_lsps[pkg.name] then
			log:dbg("LSP '%s' already configured", pkg.name)
			return
		end

		pkg:install()
		pkg.lsp:update(lsp.default_config)
		pkg.lsp:enable()
		lsp.configured_lsps[pkg.name] = pkg
	end),
	formatter = installer("formatter", function(pkg)
		pkg:install()
	end),
	linter = installer("linter", function(pkg)
		pkg:install()
	end),
}

return {
	---Registers a FileType autocommand that installs, once per filetype, every
	---tool mapped in `pkgs_table` whose kind is enabled in `opts`.
	---@param opts table<'lsp'|'formatter'|'linter', boolean>
	setup = function(opts)
		local cbs = {}
		for kind, install in pairs(installers) do
			if opts[kind] then
				cbs[kind] = install
			end
		end

		log:header()
		if next(cbs) == nil then
			log:dbg("Fast exit, there are no auto-install groups enabled")
			log:header()
			return
		end

		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("catalog.auto_install", { clear = true }),
			callback = function()
				local ft = vim.bo.filetype
				if seen_ft[ft] then
					return
				end

				local tbl = pkgs_table[ft]
				seen_ft[ft] = tbl ~= nil
				if not tbl then
					return
				end

				for cat, list in pairs(tbl) do
					local cb = cbs[cat]
					if cb then
						for _, name in ipairs(ensure_list_of(list, "string") or {}) do
							cb(name)
						end
					end
				end
			end,
		})
		log:header()
	end,
}
