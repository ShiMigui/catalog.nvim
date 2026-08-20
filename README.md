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

## Real-World Examples

### TypeScript/JavaScript

```lua
{
    "ShiMigui/catalog.nvim",
    dependencies = {
        { "williamboman/mason.nvim", opts = {} },
        "neovim/nvim-lspconfig",
        "stevearc/conform.nvim",
        "mfussenegger/nvim-lint",
    },
    opts = {
        lsp = {
            "typescript-language-server",
            "eslint-ls",
        },
        lsp_config = {
            capabilities = "blink.cmp",
        },
        conform = true,
        lint = true,
    },
    config = function(_, opts)
        local registry = require("mason-registry")
        local function run()
            require("catalog").setup(opts)
        end
        if #registry.get_all_packages() > 0 then
            run()
        else
            registry.refresh(run)
        end
    end,
}
```

### Python

```lua
{
    "ShiMigui/catalog.nvim",
    dependencies = {
        { "williamboman/mason.nvim", opts = {} },
        "neovim/nvim-lspconfig",
        "stevearc/conform.nvim",
        "mfussenegger/nvim-lint",
    },
    opts = {
        lsp = {
            "pylsp",
            "ruff-lsp",
        },
        conform = true,
        lint = true,
        treesitter = {
            ensure_installed = { "python" },
        },
    },
    config = function(_, opts)
        local registry = require("mason-registry")
        local function run()
            require("catalog").setup(opts)
        end
        if #registry.get_all_packages() > 0 then
            run()
        else
            registry.refresh(run)
        end
    end,
}
```

### Go

```lua
{
    "ShiMigui/catalog.nvim",
    dependencies = {
        { "williamboman/mason.nvim", opts = {} },
        "neovim/nvim-lspconfig",
        "stevearc/conform.nvim",
    },
    opts = {
        lsp = {
            "gopls",
        },
        conform = true,
        ensure_installed = { "golangci-lint" },
        treesitter = {
            ensure_installed = { "go", "gomod" },
        },
    },
    config = function(_, opts)
        local registry = require("mason-registry")
        local function run()
            require("catalog").setup(opts)
        end
        if #registry.get_all_packages() > 0 then
            run()
        else
            registry.refresh(run)
        end
    end,
}
```

### Rust

```lua
{
    "ShiMigui/catalog.nvim",
    dependencies = {
        { "williamboman/mason.nvim", opts = {} },
        "neovim/nvim-lspconfig",
        "stevearc/conform.nvim",
    },
    opts = {
        lsp = {
            "rust-analyzer",
        },
        conform = true,
        ensure_installed = { "codelldb" },
        treesitter = {
            ensure_installed = { "rust" },
        },
    },
    config = function(_, opts)
        local registry = require("mason-registry")
        local function run()
            require("catalog").setup(opts)
        end
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
| `lint` | `boolean` | Automatically install linters from `nvim-lint`. |
| `treesitter` | `catalog.TreesitterConfig` | Treesitter parser installation and configuration. |
| `ensure_installed` | `string[]\|string` | Packages to install without setup. |
| `auto_update` | `boolean` | Automatically update installed packages. |
| `auto_install` | `catalog.AutoInstallConfig` | Auto-install tools by filetype. |
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

    -- Disable a specific LSP
    ["some-server"] = {
        enabled = false,
    },
}
```

#### Global LSP Config

You can provide global defaults for all LSPs:

```lua
lsp_config = {
    capabilities = "blink.cmp", -- or "nvim-cmp"
    on_attach = function(client, bufnr)
        -- Global on_attach for all LSPs
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = bufnr })
    end,
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

### Lint

Automatically installs linters configured in `nvim-lint`.

```lua
lint = true
```

**Note:** `nvim-lint` must be loaded before `catalog.setup()`.

### Treesitter

Installs and configures treesitter parsers.

```lua
treesitter = {
    ensure_installed = {
        "lua",
        "typescript",
        "python",
    },
    config = {
        highlight = {
            enable = true,
        },
    },
}
```

**Note:** `nvim-treesitter` must be installed as a dependency.

### Ensure Installed

Installs packages without enabling any integration. Useful for CLI tools.

```lua
ensure_installed = {
    "pgformatter",
}
```

### Auto Update

Automatically updates all installed packages when the plugin loads.

```lua
auto_update = true
```

### Auto Install

Automatically installs LSPs, formatters, and linters when opening a file of a specific filetype. This creates `FileType` autocmds that trigger installation on demand.

```lua
auto_install = {
    -- Install LSPs by filetype
    lsp = {
        lua = "lua-language-server",
        python = { "pylsp", "ruff-lsp" },
        typescript = "typescript-language-server",
        go = "gopls",
        rust = "rust-analyzer",
    },

    -- Install formatters by filetype
    conform = {
        lua = "stylua",
        python = "black",
        typescript = "prettier",
        go = "gofumpt",
        rust = "rustfmt",
    },

    -- Install linters by filetype
    lint = {
        lua = "luacheck",
        python = "ruff",
        typescript = "eslint_d",
        go = "golangci-lint",
    },
}
```

**Note:** Tools are only installed when you open a file with the matching filetype. Already installed tools are skipped.

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
---@field update? fun(): nil
---@field lsp? catalog.Lsp
```

### Creating a Custom Provider

You can create your own provider to support different package managers:

```lua
-- lua/catalog/provider/my_provider.lua
local M = {}

M.resolve = function(name)
    -- Check if package exists in your package manager
    local pkg = my_package_manager.get(name)
    if not pkg then
        return nil
    end

    return {
        name = name,
        installed = function()
            return pkg:is_installed()
        end,
        install = function()
            pkg:install()
        end,
        update = function()
            pkg:update()
        end,
    }
end

return M
```

### Registering a Custom Provider

```lua
-- In your Neovim config
local catalog = require("catalog")
local my_provider = require("catalog.provider.my_provider")

-- Get current providers and add yours
local providers = require("catalog.provider")
table.insert(providers, my_provider)
```

### Using Multiple Providers

Catalog tries providers in order. The first provider that resolves a package wins:

```lua
-- Example: Try local packages first, then Mason
local local_provider = require("catalog.provider.local")
local mason_provider = require("catalog.provider.mason")

providers.set_providers({ local_provider, mason_provider })
```

## Design Principles

* **Lazy Installation:** Packages are only installed when required by an integration.
* **Provider Agnostic:** Catalog works with any provider implementing the interface (Mason is built-in).
* **Orchestration First:** Focuses on connecting packages to integrations rather than implementing the setup logic itself.

## Troubleshooting

### LSP not connecting

1. Ensure `mason.nvim` is loaded before `catalog.setup()`
2. Check if the package is installed: `:Mason` to open Mason UI
3. Enable debug logging: `opts = { debug = true }`
4. Run `:CatalogShowLSPs` to see configured servers

### Package not found

1. Check the package name on [mason-registry](https://github.com/nvim-mason/mason-registry)
2. Some packages have different names in Mason (e.g., `typescript-language-server` vs `tsserver`)
3. Enable debug logging to see resolve errors

### Formatter/Linter not installing

1. Ensure `conform.nvim` or `nvim-lint` is loaded before `catalog.setup()`
2. Check the formatter/linter name matches the command in the respective plugin
3. Some formatters may not be available in Mason

### Treesitter parsers not installing

1. Ensure `nvim-treesitter` is installed as a dependency
2. Check parser name at [treesitter parsers](https://github.com/nvim-treesitter/nvim-treesitter#supported-languages)
3. Run `:TSInstall <parser>` manually to test

### Performance issues

1. Use `silent_errors = true` to reduce notification overhead
2. The package cache has a 5-minute TTL; restart Neovim to clear it
3. Call `require("catalog.provider").clear_cache()` to manually clear cache
