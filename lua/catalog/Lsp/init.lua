---Type definitions for the LSP integration.
---
---This module only carries annotations (`@meta`) and is never loaded at
---runtime; the implementation lives in `catalog.Lsp.Config`.

---Handle over a language server configuration.
---@class catalog.Lsp
---Server name as expected by nvim-lspconfig (e.g. `"lua_ls"`).
---@field name string
---Configuration merged so far; starts empty.
---@field config vim.lsp.Config
---Deep-merges `cfg` into [config](lua://catalog.Lsp.config) (new values win)
---and returns the same instance, so calls can be chained.
---@field update fun(self: catalog.Lsp, cfg: vim.lsp.Config): catalog.Lsp
---@field enable fun(self: catalog.Lsp)

local log = require("catalog.log").new("Lsp")
local ensureInstalled = require("catalog.scripts.ensureInstalled")

local LspInit = {
	defaultConfig = {
		capabilities = vim.lsp.protocol.make_client_capabilities(),
		flags = { debounce_text_changes = 150 },
	},
}

---@param lspOpts catalog.lspOpts
function LspInit.setup(lspOpts)
	log:header()
	local default, configByLsp = lspOpts.default, lspOpts.configByLsp

	if default and type(default) == "table" then
		log:dbg("Overwriting internal default config with user default config")
		LspInit.defaultConfig = vim.tbl_deep_extend("force", LspInit.defaultConfig, lspOpts.default)
	end

	if configByLsp and type(configByLsp) == "table" then
		local pkgs = ensureInstalled(vim.tbl_keys(configByLsp))
		for nm, pkg in pairs(pkgs) do
			pkg.lsp:update(configByLsp[nm])
			pkg.lsp:enable()
		end
	end

	log:header()
end

return LspInit
