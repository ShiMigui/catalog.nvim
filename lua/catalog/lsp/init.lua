---Type definitions for the LSP integration.
---
---This module only carries annotations (`@meta`) and is never loaded at
---runtime; the implementation lives in `catalog.lsp.config`.

---Handle over a language server configuration.
---
---Instances are created by `catalog.lsp.config.new(name)` and share one
---method table through a metatable, so each handle costs only its own state.
---@class catalog.lsp
---Server name as expected by nvim-lspconfig (e.g. `"lua_ls"`).
---@field name string
---Configuration merged so far; starts empty.
---@field config vim.lsp.Config
---Deep-merges `cfg` into [config](lua://catalog.lsp.config) (new values win)
---and returns the same instance, so calls can be chained.
---@field update fun(self: catalog.lsp, cfg: vim.lsp.Config): catalog.lsp
---Registers the merged config and enables the server (no-op when already enabled).
---@field enable fun(self: catalog.lsp)

local log = require("catalog.log").new("lsp")
local ensure_installed = require("catalog.scripts.ensure_installed")

local M = {
	---Defaults merged into every configured server; extended by
	---`opts.default` during setup().
	default_config = {
		capabilities = vim.lsp.protocol.make_client_capabilities(),
		flags = { debounce_text_changes = 150 },
	},
}

---Installs every server in `opts.config_by` and wires them up: per server it
---merges user config on top of [default_config](lua://catalog.lsp.default_config)
---and only then enables it, because enable() is what hands the final
---configuration over to nvim-lspconfig.
---@param opts catalog.lsp_opts
function M.setup(opts)
	log:header()
	local default, config_by = opts.default, opts.config_by

	if default and type(default) == "table" then
		log:dbg("Overwriting internal default config with user default config")
		M.default_config = vim.tbl_deep_extend("force", M.default_config, default)
	end

	if config_by then
		local config_by_type = type(config_by)
		if config_by_type ~= "table" then
			log:err("config_by must be a table, got %s", config_by_type)
			return
		end

		local pkgs = ensure_installed(vim.tbl_keys(config_by))
		for name, pkg in pairs(pkgs) do
			pkg.lsp:update(config_by[name])
			pkg.lsp:enable()
		end
	end

	log:header()
end

return M
