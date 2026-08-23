---catalog.nvim entry point.
---
---```lua
---require("catalog").setup()
---```

---User configuration options.
---
---Note: `setup()` does not consume these fields yet; they define the target API
---for the ongoing rewrite.
---@class catalog.Opts
---Auto-install tools when a filetype is opened.
---`true` enables every tool kind; a table toggles each kind individually.
---@field auto_install? table<'lsp'|'formatter'|'linter', boolean> | boolean
---Package names to install eagerly during setup.
---@field ensure_installed? string[]
---Per-server LSP configurations merged on top of the defaults, keyed by server name.
---@field lsp? table<string, vim.lsp.Config>
---@field debug? boolean
---@field silent? boolean

---Bootstraps catalog.nvim: enables logging and registers the built-in providers.
---@param opts catalog.Opts
local setup = function(opts)
	local log = require("catalog.log").setup(opts.debug == true, opts.silent == true)
	local providers = require("catalog.Providers")
	require("catalog.Providers.MasonProvider")
end

setup()

return {
	setup = setup,
}
