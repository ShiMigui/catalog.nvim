---@meta

---@alias catalog.lsp.name string
---@alias catalog.lsp.config vim.lsp.Config
---@alias catalog.package.name string

-- lsp
---@class catalog.Lsp
---@field name catalog.lsp.name
---@field config? catalog.lsp.config

-- package
---@class catalog.Package
---@field name catalog.package.name
---@field install fun(): nil
---@field lsp? catalog.Lsp
---@field sync_config fun(config?: catalog.lsp.config, default_config: catalog.lsp.config): boolean

-- provider
---@class catalog.Provider
---@field resolve fun(name: catalog.package.name): catalog.Package?
