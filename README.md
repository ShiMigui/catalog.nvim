# catalog.nvim

`catalog.nvim` is a Neovim plugin that automates package installation and setup through a provider system.

It acts as an orchestration layer between package managers (providers) and integrations such as LSPs and formatters.

## Installation

```lua
{
    "ShiMigui/catalog.nvim",
    dependencies = {
        "neovim/nvim-lspconfig", -- recommended for LSP integration
    },
    opts = {
        silent_errors = false, -- disable error/warning notifications
        debug = false,         -- enable debug logging
    },
}
```

## Quick Start

Example using Mason and LSP integration:

```lua
{
    "ShiMigui/catalog.nvim",
    dependencies = {
        { "williamboman/mason.nvim", opts = {} },
        "neovim/nvim-lspconfig",
    },
    opts = {
        lsp = {
            "lua-language-server",
            ["yaml-language-server"] = {
                settings = {
                    yaml = { schemas = {} },
                },
            },
        },
    },
    config = function(_, opts)
        local registry = require("mason-registry")

        local function run()
            require("catalog").setup(opts)
        end

        -- Ensure Mason registry is loaded before setup
        if #registry.get_all_packages() > 0 then
            run()
        else
            registry.refresh(run)
        end
    end,
}
```

## Configuration

The `setup` function accepts a `catalog.Config` table:

| Field | Type | Description |
| :--- | :--- | :--- |
| `lsp` | `catalog.LspIntegrationConfig` | List of LSPs to install and configure. |
| `lsp_config` | `catalog.LspDefaultConfig` | Global configuration for all LSPs. |
| `conform` | `boolean` | Automatically install formatters from `conform.nvim`. |
| `ensure_installed` | `string[]\|string` | Packages to install without setup. |
| `silent_errors` | `boolean` | Disable error notifications. |
| `debug` | `boolean` | Enable debug logging. |

## Integrations

### LSP

Installs, configures, and enables language servers using Neovim's built-in LSP client.

```lua
lsp = {
    -- Keyed entries for custom configuration
    ["lua-language-server"] = {
        settings = { Lua = { diagnostics = { globals = { "vim" } } } }
    },

    -- Array entries for default configuration
    "marksman",
    "intelephense",
}
```

#### Global LSP Config

You can provide global defaults for all LSPs:

```lua
lsp_config = {
    capabilities = "blink.cmp", -- or "nvim-cmp"
    config = {
        -- Base vim.lsp.config for all servers
    },
}
```

### Conform

Automatically installs formatters configured in `conform.nvim`.

```lua
conform = true
```

**Note:** `conform.nvim` must be loaded before `catalog.setup()`.

### Ensure Installed

Installs packages without enabling any integration. Useful for CLI tools.

```lua
ensure_installed = {
    "pgformatter",
}
```

## Advanced Usage

### Provider Interface

A provider is responsible for resolving packages. Custom providers can be registered.

```lua
---@class catalog.Provider
---@field resolve fun(name: string): catalog.Package?
```

### Package Interface

Resolved packages follow this interface:

```lua
---@class catalog.Package
---@field name string
---@field installed fun(): boolean
---@field install fun(): nil
---@field lsp? catalog.Lsp
```

## Design Principles

* **Lazy Installation:** Packages are only installed when required by an integration.
* **Provider Agnostic:** Catalog works with any provider implementing the interface (Mason is built-in).
* **Orchestration First:** Focuses on connecting packages to integrations rather than implementing the setup logic itself.
