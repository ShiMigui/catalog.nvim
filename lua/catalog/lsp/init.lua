---LSP integration.
---
---Merges user defaults into [default_config](lua://catalog.lsp.default_config)
---and installs + configures every server listed in `opts.config_by`. The
---[catalog.lsp](lua://catalog.lsp) handle type is declared once in
---`catalog/lsp/config.lua`, next to its implementation.

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

		local servers = vim.tbl_keys(config_by)
		log:inf("Configuring %d LSP server(s)", #servers)
		local pkgs = ensure_installed(servers)
		for name, pkg in pairs(pkgs) do
			pkg.lsp:update(config_by[name])
			pkg.lsp:enable()
		end
	end

	log:header()
end

return M
