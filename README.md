# Mason Catalog

![Demo](assets/demo.gif)

Mason Catalog manages package installation (LSPs, formatters, DAPs, linters, and runtimes) within the Mason ecosystem, while also handling LSP configuration.

## Features

- Automatic LSP enablement by filetype
- Group-based LSP configuration
- Seamless integration with Mason
- Integrations with other plugins, for now: `ensure_conform_formatters`
- Extension-based configuration in `by_group`

## Installation

> [!NOTE]
> Mason should be set up before using Mason Catalog.

### lazy.nvim

```lua
{
    "ShiMigui/mason-catalog.nvim",
    branch = "main",
    dependencies = { { "williamboman/mason.nvim", opts = {} } },
}
```

## Configuration
```lua
{
    lsp = {
        default_config = {
            capabilities = require("cmp_nvim_lsp").default_capabilities()
        }, -- Assuming you're using 'hrsh7th/nvim-cmp'
        by_group = {
            {
                filetypes = { "javascript", "javascriptreact", "typescriptreact", "typescript" },
                lsps = { "typescript-language-server", "eslint-lsp" },
            },
            { filetypes = { "json", "jsonc" }, lsps = { "json-lsp" } },
            { filetypes = { "markdown" }, lsps = { "marksman" } },
        },
        by_ft = {
            lua = { "lua-language-server" }, -- or simply: lua = "lua-language-server"
        },
        auto_enable = true, -- creates autocmd and enables LSP for the first opened buffer
    },
    debug = false, -- disables debug logs (if you don't enjoy chaos)
    silent = true, -- disables all logs (recommended for sanity)
    integrations = { "ensure_conform_formatters" },
}
```

---

This plugin is not affiliated with mason.nvim.
