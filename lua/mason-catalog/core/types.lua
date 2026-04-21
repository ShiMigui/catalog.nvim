---@meta

---@alias LspConfig vim.lsp.Config
---@alias LspName string
---@alias PackageName string
---@alias FileType string
---@alias FileExtension string

---@alias LspSpec LspName | LspName[] | table<LspName, LspConfig>

---@class FileGroup<T>: table<T>
---@field lsps LspSpec

---@class FileTypeGroup: FileGroup<FileType>
---@class ExtensionGroup: FileGroup<FileExtension>

---@class LspDefinition
---@field name LspName
---@field config? LspConfig

---@class CatalogPackage
---@field name PackageName
---@field lsp? LspDefinition
---@field install fun(): nil

---@class LspSetupOptions
---@field default_config? LspConfig
---@field groups? FileTypeGroup[]
---@field by_ft? table<FileType, LspSpec>
---@field by_ext? ExtensionGroup[]

---@class CatalogOptions
---@field debug? boolean
---@field silent? boolean
---@field lsp? LspSetupOptions
---@field integrations? string[]
---@field ensure_installed? PackageName[]
