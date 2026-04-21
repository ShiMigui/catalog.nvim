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

-- provider
---@class catalog.Provider
---@field get fun(name: catalog.package.name): catalog.Package?
