# catalog.nvim

`catalog.nvim` is a plugin that automates package installation and setup through a provider system.

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
        lsp = ...,
    },

    config = function(_, opts)
        local registry = require("mason-registry")

        local function run()
            require("catalog").setup(opts)
        end

        return #registry.get_all_packages() > 0
            and run()
            or registry.refresh(run)
    end,
}
```

## Providers

A provider is responsible for resolving and installing packages.

Providers abstract package management, allowing Catalog to work independently from a specific backend.

### Mason Provider

The built-in Mason provider (`catalog.provider.mason`) integrates with Mason.nvim.

Add Mason as a dependency:

```lua
{
    "williamboman/mason.nvim",
    opts = {},
}
```

Then ensure the Mason registry is loaded before calling `catalog.setup()`:

```lua
config = function(_, opts)
    local registry = require("mason-registry")

    local function run()
        require("catalog").setup(opts)
    end

    return #registry.get_all_packages() > 0
        and run()
        or registry.refresh(run)
end
```

## Integrations

### LSP

Installs, configures and enables language servers using Neovim's built-in LSP client.

```lua
lsp = {
    capability_provider = "blink.cmp",
    config = { capabilities = {} },
    "marksman",
    "lua-language-server",
    "intelephense",
    "phpactor",
    "json-lsp",
    "typescript-language-server",
    "eslint-lsp",
    ["yaml-language-server"] = {...},
}
```

#### LSP Notes

* String entries enable an LSP using the default configuration.
* Keyed entries allow per-server configuration overrides.
* All LSPs inherit the configuration provided in `lsp.config`.
* Custom server configurations are merged with the global configuration.
* When the same server is declared multiple times, the last configuration wins.

### Conform

Automatically installs formatters configured in `conform.nvim`.

```lua
conform = true
```

**Important:** `conform.nvim` must be loaded before `catalog.setup()`.

### Ensure Installed

Installs packages without enabling any integration.

```lua
ensure_installed = {
    "pgformatter",
}
```

Useful for tools that do not require additional setup.

## Provider Interface

A provider must implement:

```lua
---@class catalog.provider
---@field resolve fun(name: string): catalog.pkg?
```

Resolved packages follow this interface:

```lua
---@class catalog.pkg
---@field name string
---@field installed fun(): boolean
---@field install fun(): nil
---@field lsp? catalog.lsp
```

The `lsp` field is optional and is only present when the package provides a language server.

## Design Notes

* Providers are responsible for package resolution and installation.
* Integrations define behavior on top of providers.
* Catalog focuses on orchestration rather than implementation details.
* Package installation is performed lazily when required by an integration.
* New providers and integrations can be added independently.
* Catalog remains provider-agnostic whenever possible.

```
```
