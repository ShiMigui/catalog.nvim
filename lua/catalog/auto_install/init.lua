---Auto-install hooks.
---
---Registers a single FileType autocommand that, on the first time a filetype
---is opened, provides every tool mapped for it in
---[table](lua://catalog.auto_install.table) through the provider registry and
---installs it — LSP servers additionally get the default config applied and
---are enabled right away.
---
---Each tool kind only runs when enabled in `setup({ auto_install = ... })`.
---@see catalog.auto_install.table
local lsp = require("catalog.lsp")
local log = require("catalog.log").new("auto_install")
local pkgs_table = require("catalog.auto_install.table")
local provider = require("catalog.provider")
local ensure_list_of = require("catalog.scripts.ensure_list_of")

---Filetypes already processed; caches misses too (`false`), so unmapped
---filetypes do not re-run the lookup on every event.
---@type table<string, boolean>
local seen_ft = {}

---Builds an installer for one tool kind: quietly provides the package by name
---and hands it to `handle` when a provider knows it.
---@param kind catalog.tool_kind Tool category, used for log context.
---@param handle fun(pkg: catalog.package) Runs when the package is provided.
---@return fun(name: string)
local function installer(kind, handle)
	return function(name)
		log:dbg("Trying to auto-install %s '%s'", kind, name)
		local pkg = provider.try_provide(name)
		if not pkg then
			log:dbg("Package '%s' not provided by any source", name)
			return
		end
		handle(pkg)
	end
end

---One installer per tool kind. The lsp handle merges defaults and enables the
---server only after installing, because enable() is what registers the final
---configuration with nvim-lspconfig.
---@type table<catalog.tool_kind, fun(name: string)>
local installers = {
	lsp = installer("lsp", function(pkg)
		if not pkg.lsp then
			log:wrn("Package '%s' has no lspconfig mapping, skipping", pkg.name)
			return
		end
		if pkg.lsp:is_enabled() then
			log:dbg("LSP '%s' already configured", pkg.name)
			return
		end

		pkg:install()
		pkg.lsp:update(lsp.default_config)
		pkg.lsp:enable()
	end),
	formatter = installer("formatter", function(pkg)
		pkg:install()
	end),
	linter = installer("linter", function(pkg)
		pkg:install()
	end),
}

return {
	---Registers a FileType autocommand (in its own cleared augroup) that
	---installs, once per filetype, every tool mapped in
	---[pkgs_table](lua://catalog.auto_install.table) whose kind is enabled in
	---`opts`. Does nothing at all when no kind is enabled.
	---@param opts table<catalog.tool_kind, boolean>
	setup = function(opts)
		---Only the enabled kinds make it into this map; kinds missing from it
		---are skipped per-filetype without warnings.
		---@type table<catalog.tool_kind, fun(name: string)>
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

				local tools = pkgs_table[ft]
				seen_ft[ft] = tools ~= nil
				if not tools then
					return
				end

				for kind, list in pairs(tools) do
					local install = cbs[kind]
					if install then
						for _, name in ipairs(ensure_list_of(list, "string") or {}) do
							install(name)
						end
					end
				end
			end,
		})
		log:header()
	end,
}
