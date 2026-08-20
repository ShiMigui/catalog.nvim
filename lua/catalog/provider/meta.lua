---@meta

---Alias for Neovim's LSP configuration.
---@class catalog.LspConfig: vim.lsp.config
---@field enabled? boolean
---@field cmd? string[]

---Represents an LSP entry in the catalog.
---@class catalog.Lsp
---@field name string
---@field config? catalog.LspConfig
---@field update fun(self: catalog.Lsp, cfg: catalog.LspConfig, default: catalog.LspConfig): nil

---Represents an installable package.
---@class catalog.Package
---@field name string
---@field installed fun(): boolean
---@field install fun(): nil
---@field update? fun(): nil
---@field lsp? catalog.Lsp

---Responsible for resolving and providing packages.
---@class catalog.Provider
---@field resolve fun(str: string): catalog.Package?
