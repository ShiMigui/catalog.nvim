---catalog.nvim entry point.
---
---```lua
---require("catalog").setup()
---```

---@alias catalog.lspOpts {
---   default: vim.lsp.config,
---   configByLsp: table<string, vim.lsp.Config>,
---}

---User configuration options.
---
---Note: `setup()` does not consume these fields yet; they define the target API
---for the ongoing rewrite.
---@class catalog.Opts
---Auto-install tools when a filetype is opened.
---`true` enables every tool kind; a table toggles each kind individually.
---@field autoEnable? table<'lsp'|'formatter'|'linter', boolean> | boolean
---Package names to install eagerly during setup.
---@field ensure_installed? string[]
---Per-server LSP configurations merged on top of the defaults, keyed by server name.
---@field lsp? catalog.lspOpts
---@field debug? boolean
---@field silent? boolean

---@type catalog.Opts
local default_opts = {
	autoEnable = true,
	debug = false,
	silent = false,
}

local HANDLERS = {
	boolean = function(ai)
		return { lsp = ai, formatter = ai, linter = ai }
	end,
	table = function(ai)
		ai.formatter = ai.formatter == true
		ai.linter = ai.linter == true
		ai.lsp = ai.lsp == true
	end,
}
---@param opts catalog.Opts
local function normalizeOpts(opts)
	opts = vim.tbl_deep_extend("force", default_opts, opts)
	vim.print(opts)

	if opts.autoEnable then
		local handler = HANDLERS[type(opts.autoEnable)]
		opts.autoEnable = handler and handler(opts.autoEnable) or nil
	end
end

---Bootstraps catalog.nvim: enables logging and registers the built-in providers.
---@param opts catalog.Opts
local setup = function(opts)
	opts = opts or {}
	normalizeOpts(opts)

	local log = require("catalog.log").setup(opts.debug, opts.silent).new("Setup")
	log:dbg("Starting catalog plugin setup")

	require("catalog.Providers.MasonProvider") -- Starts the MasonProvider

	if opts.lsp then
		require("catalog.Lsp").setup(opts.lsp)
	end

	log:dbg("Finished proccess")
end

return {
	setup = setup,
}
