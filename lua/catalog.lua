---catalog.nvim entry point.
---
---Bootstraps every integration from a single call. Providers are NOT
---registered here: require whichever you want beforehand, keeping the setup
---fully modular.
---
---```lua
---require("catalog.provider.mason") -- register the built-in provider (or your own)
---require("catalog").setup({
---   debug = false,
---   silent = false,
---   ensure_installed = { "stylua" },
---   lsp = { default = {...}, config_by = { lua_ls = {...} } },
---   auto_install = true,
---})
---```
local log = require("catalog.log").new("setup")

---A single tool category handled by auto-install.
---@alias catalog.tool_kind 'lsp'|'formatter'|'linter'

---Receives the filetype that was processed first, then the packages provided
---for each enabled kind; a kind that is disabled arrives as `false`.
---@alias catalog.auto_install_callback fun(ft: string, lsps: catalog.package[]|false,
---	formatters: catalog.package[]|false, linters: catalog.package[]|false)

---Explicit per-kind switches for auto-install, plus an optional callback
---that receives the packages provided for each enabled kind. Leave the
---integration work (formatting setup, linter config, …) to that callback
---instead of wiring it internally.
---@alias catalog.auto_install_flags table<catalog.tool_kind, boolean> & { callback?: catalog.auto_install_callback }

---LSP integration options.
---@alias catalog.lsp_opts {
---   default: vim.lsp.Config,
---   config_by: table<string, vim.lsp.Config>,
---}

---User configuration options.
---@class catalog.opts
---Auto-install tools when a filetype is opened.
---`true` enables every tool kind; a table toggles each kind individually and
---may add a `callback` that receives the installed packages per enabled kind.
---@field auto_install? catalog.auto_install_flags | boolean
---Package names to install eagerly during setup.
---@field ensure_installed? string[]
---Per-server LSP configurations merged on top of the defaults, keyed by server name.
---@field lsp? catalog.lsp_opts
---Notify DEBUG messages.
---@field debug? boolean
---Mute ERROR/WARN/INFO messages.
---@field silent? boolean

---@type catalog.opts
local default_opts = {
	auto_install = true,
	debug = false,
	silent = false,
}

---Coerces any accepted `auto_install` shape into explicit per-kind flags,
---so downstream code never deals with booleans or missing keys.
---@type table<string, fun(auto_install: any): catalog.auto_install_flags>
local handlers = {
	boolean = function(auto_install)
		return { lsp = auto_install, formatter = auto_install, linter = auto_install }
	end,
	table = function(auto_install)
		auto_install.formatter = auto_install.formatter == true
		auto_install.linter = auto_install.linter == true
		auto_install.lsp = auto_install.lsp == true
		return auto_install
	end,
}

---Fills unset options with [default_opts](lua://default_opts) and expands the
---`auto_install` shorthand into per-kind flags.
---@param opts catalog.opts
---@return catalog.opts
local function normalize_opts(opts)
	opts = vim.tbl_deep_extend("force", default_opts, opts)

	if opts.auto_install then
		local handler = handlers[type(opts.auto_install)]
		opts.auto_install = handler and handler(opts.auto_install) or nil
	end

	return opts
end

---Bootstraps catalog.nvim.
---
---Registers the built-in providers, then wires each requested integration in
---order: eager installs -> LSP setup -> auto-install hooks.
---@param opts? catalog.opts
local function setup(opts)
	opts = normalize_opts(opts or {})

	require("catalog.log").setup(opts.debug, opts.silent)
	log:dbg("Starting catalog plugin setup")

	-- Seeds the session cache from every provider the user has registered
	require("catalog.provider").load_installed()

	if opts.ensure_installed then
		require("catalog.scripts.ensure_installed")(opts.ensure_installed)
	end

	if opts.lsp then
		require("catalog.lsp").setup(opts.lsp)
	end

	if opts.auto_install then
		require("catalog.auto_install").setup(opts.auto_install)
	end

	log:dbg("Finished process")
end

return {
	setup = setup,
}
