---catalog.nvim entry point.
---
---```lua
---require("catalog").setup()
---```

---@alias catalog.lsp_opts {
---   default: vim.lsp.Config,
---   config_by_lsp: table<string, vim.lsp.Config>,
---}

---User configuration options.
---
---Note: `setup()` does not consume these fields yet; they define the target API
---for the ongoing rewrite.
---@class catalog.Opts
---Auto-install tools when a filetype is opened.
---`true` enables every tool kind; a table toggles each kind individually.
---@field auto_enable? table<'lsp'|'formatter'|'linter', boolean> | boolean
---Package names to install eagerly during setup.
---@field ensure_installed? string[]
---Per-server LSP configurations merged on top of the defaults, keyed by server name.
---@field lsp? catalog.lsp_opts
---@field debug? boolean
---@field silent? boolean

---@type catalog.Opts
local default_opts = {
	auto_enable = true,
	debug = false,
	silent = false,
}

local handlers = {
	boolean = function(ai)
		return { lsp = ai, formatter = ai, linter = ai }
	end,
	table = function(ai)
		ai.formatter = ai.formatter == true
		ai.linter = ai.linter == true
		ai.lsp = ai.lsp == true
	end,
}

---Normalizes `opts` against [default_opts](lua://default_opts), expanding the
---`auto_enable` shorthand into per-kind flags.
---@param opts catalog.Opts
local function normalize_opts(opts)
	opts = vim.tbl_deep_extend("force", default_opts, opts)

	if opts.auto_enable then
		local handler = handlers[type(opts.auto_enable)]
		opts.auto_enable = handler and handler(opts.auto_enable) or nil
	end

	return opts
end

---Bootstraps catalog.nvim: enables logging and registers the built-in providers.
---@param opts catalog.Opts
local function setup(opts)
	opts = normalize_opts(opts or {})

	local log = require("catalog.log").setup(opts.debug, opts.silent).new("setup")
	log.dbg("Starting catalog plugin setup")

	require("catalog.provider.mason") -- Registers the mason provider

	if opts.lsp then
		require("catalog.lsp").setup(opts.lsp)
	end

	log.dbg("Finished process")
end

return {
	setup = setup,
}
