# catalog.nvim

`catalog.nvim` is a Neovim plugin that automates package installation and setup through a provider system.

It acts as an orchestration layer between package managers (providers) and integrations such as LSPs, formatters, linters, and treesitter.

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
        auto_install = {
            formatter = true,
            linter = true,
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
        auto_install = {
            formatter = true,
            linter = true,
        },
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
        auto_install = {
            formatter = true,
        },
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
        auto_install = {
            formatter = true,
        },
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
| `conform` | `boolean` | **Deprecated:** Use `auto_install = { formatter = true }`. |
| `lint` | `boolean` | **Deprecated:** Use `auto_install = { linter = true }`. |
| `treesitter` | `catalog.TreesitterConfig` | Treesitter parser installation and configuration. |
| `ensure_installed` | `string[]\|string` | Packages to install without setup. |
| `auto_update` | `boolean` | Automatically update installed packages. |
| `auto_install` | `boolean\|catalog.AutoInstallConfig` | Auto-install and auto-configure tools by filetype. |
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

### Auto Install

Automatically installs and configures recommended LSPs, formatters, and linters when opening a file. Uses a built-in mapping of filetypes to Mason packages with post-install hooks that register tools with conform.nvim, nvim-lint, and vim.lsp.

```lua
-- Enable all types for all filetypes
auto_install = true

-- Enable specific types
auto_install = {
    lsp = true,
    formatter = true,
    linter = true,
}

-- Only enable specific tools
auto_install = {
    lsp = { "lua-language-server", "pyright" },
    formatter = { "stylua", "prettierd" },
    linter = { "luacheck", "ruff" },
}
```

When a filetype is opened, catalog will:
1. Resolve the recommended tools via the provider
2. Install missing tools via Mason (async)
3. Register the tools with their respective integrations:
   - **LSP** → `vim.lsp.config()` + `vim.lsp.enable()`
   - **Formatter** → `conform.formatters_by_ft[ft]`
   - **Linter** → `lint.linters_by_ft[ft]`

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

## Advanced Usage

### Provider Interface

A provider is responsible for providing packages from a package manager. Custom providers can be registered.

```lua
---@class catalog.provider
---@field name string
---@field provide fun(name: string): catalog.package?
---@field load_installed fun(): table<string, catalog.package>
```

### Package Interface

Provided packages follow this interface:

```lua
---@class catalog.package
---@field provider_name string
---@field name string
---@field installed fun(): boolean
---@field install fun(self: catalog.package)
---@field lsp? catalog.lsp
```

### Creating a Custom Provider

You can create your own provider to support different package managers:

```lua
-- lua/catalog/provider/my_provider.lua
local M = {}

M.name = "my-source"

M.provide = function(name)
    -- Provide the package from your package manager, or nil when unknown
    local pkg = my_package_manager.get(name)
    if not pkg then
        return nil
    end

    return {
        name = name,
        provider_name = M.name,
        installed = function()
            return pkg:is_installed()
        end,
        install = function(self)
            pkg:install()
        end,
    }
end

M.load_installed = function()
    -- Return every package already installed through your provider,
    -- keyed by name, so catalog.setup() can seed its cache
    local pkgs = {}
    for _, pkg in pairs(my_package_manager.installed()) do
        pkgs[pkg.name] = { name = pkg.name, provider_name = M.name }
    end
    return pkgs
end

return M
```

### Registering a Custom Provider

```lua
-- In your Neovim config, before require("catalog").setup()
local my_provider = require("catalog.provider.my_provider")

require("catalog.provider").append(my_provider)
```

### Using Multiple Providers

Catalog asks every registered provider in registration order. The first provider that provides a package wins, and results are cached per session:

```lua
-- Example: register local packages first, then Mason (built-in)
require("catalog.provider").append(local_provider) -- mason registers itself on setup()
```

## Design Principles

* **Lazy Installation:** Packages are only installed when required by an integration.
* **Provider Agnostic:** Catalog works with any provider implementing the interface (Mason is built-in).
* **Orchestration First:** Focuses on connecting packages to integrations rather than implementing the setup logic itself.

## Contributing

Contributions are welcome! Please read our [Contributing Guide](CONTRIBUTING.md) for details on:

- Development setup
- Testing requirements (80% minimum coverage)
- Commit conventions (Conventional Commits)
- Pull request process

### AI Agents

This project includes guidelines for AI agents in [AGENTS.md](AGENTS.md). All AI agents working on this project must follow these guidelines, which include:

- Reading files before modifying
- Running tests before committing
- Following existing code patterns
- Not modifying tests unless explicitly requested

## Troubleshooting

### LSP not connecting

1. Ensure `mason.nvim` is loaded before `catalog.setup()`
2. Check if the package is installed: `:Mason` to open Mason UI
3. Enable debug logging: `opts = { debug = true }`
4. Run `:CatalogShowLSPs` to see configured servers

### Package not found

1. Check the package name on [mason-registry](https://github.com/nvim-mason/mason-registry)
2. Some packages have different names in Mason (e.g., `typescript-language-server` vs `tsserver`)
3. Enable debug logging to see provide errors

### Formatter/Linter not installing

1. If using `auto_install = { formatter = true }`, ensure `conform.nvim` is installed for formatters, or `nvim-lint` for linters
2. Check the formatter/linter name matches the command in the respective plugin
3. Some formatters/linters may not be available in Mason
4. Check logs with `opts = { debug = true }`

### Treesitter parsers not installing

1. Ensure `nvim-treesitter` is installed as a dependency
2. Check parser name at [treesitter parsers](https://github.com/nvim-treesitter/nvim-treesitter#supported-languages)
3. Run `:TSInstall <parser>` manually to test

### Performance issues

1. Use `silent = true` to reduce notification overhead
2. The package cache lives for the whole Neovim session (seeded from installed packages at `setup()`); restart Neovim to rebuild it
