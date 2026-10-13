# catalog.nvim

`catalog.nvim` coordinates tool installation and configuration in Neovim
through a small, provider-based API. It includes a Mason provider and
integrations for language servers and filetype-based auto-installation.

The goal is to keep package-manager details separate from the
integrations that consume tools.

## Features

-   **Provider registry:** register only the package providers your
    setup needs.
-   **Session cache:** seed the cache with already-installed packages at
    startup.
-   **LSP integration:** merge shared defaults with per-server
    configuration, then configure and enable servers.
-   **Filetype-based installation:** install mapped tools when a
    supported filetype is first opened.
-   **Scoped logging:** control notifications with `debug` and `silent`
    options.

## Requirements

-   Neovim 0.11 or newer, using `vim.lsp.config` and `vim.lsp.enable`.
-   [mason.nvim](https://github.com/mason-org/mason.nvim) for the
    built-in Mason provider.
-   [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) is
    recommended because it supplies configurations for many language
    servers.

## Installation

Example for [lazy.nvim](https://github.com/folke/lazy.nvim):

``` lua
{
    "ShiMigui/catalog.nvim",
    dependencies = {
        { "mason-org/mason.nvim", opts = {} },
        "neovim/nvim-lspconfig",
    },
    opts = {},
}
```

Register the Mason provider before calling `catalog.setup()`. Mason's
registry may need to refresh before it can resolve packages; the quick
start below handles that case.

## Quick start

``` lua
{
    "ShiMigui/catalog.nvim",
    dependencies = {
        { "mason-org/mason.nvim", opts = {} },
        "neovim/nvim-lspconfig",
    },
    config = function()
        local registry = require("mason-registry")

        local function setup_catalog()
            require("catalog.provider.mason")

            require("catalog").setup({
                lsp = {
                    config_by = {
                        lua_ls = {},
                        ["yamlls"] = {
                            settings = { yaml = { schemas = {} } },
                        },
                    },
                },
            })
        end

        if registry.has_package("lua-language-server") then
            setup_catalog()
        else
            registry.refresh(setup_catalog)
        end
    end,
}
```

Use the server configuration name expected by Neovim, not necessarily
the package name used by Mason. For example, the Mason package
`typescript-language-server` is commonly configured as `ts_ls`.

## Configuration

Call `require("catalog").setup(opts)`.

  --------------------------------------------------------------------------------
  Option               Type                 Default           Description
  -------------------- -------------------- ----------------- --------------------
  `auto_install`       `boolean \| table`   `true`            Enables or disables
                                                              filetype-triggered
                                                              installation. A
                                                              table can enable
                                                              `lsp`, `formatter`,
                                                              and `linter`
                                                              independently and
                                                              may include a
                                                              `callback`.

  `ensure_installed`   `string[]`           `nil`             Package names to
                                                              provide and install
                                                              during setup.

  `lsp`                `table`              `nil`             LSP integration
                                                              settings.

  `debug`              `boolean`            `false`           Enables debug
                                                              notifications.

  `silent`             `boolean`            `false`           Suppresses error,
                                                              warning, and info
                                                              notifications.
  --------------------------------------------------------------------------------

### LSP options

  ---------------------------------------------------------------------------------
  Option                  Type                              Description
  ----------------------- --------------------------------- -----------------------
  `default`               `vim.lsp.Config`                  Configuration merged
                                                            into every server
                                                            configured through
                                                            Catalog.

  `config_by`             `table<string, vim.lsp.Config>`   Per-server
                                                            configuration keyed by
                                                            Neovim's server
                                                            configuration name.
                                                            Each entry is
                                                            installed, configured,
                                                            and enabled during
                                                            setup.
  ---------------------------------------------------------------------------------

Example:

``` lua
require("catalog.provider.mason")

require("catalog").setup({
    auto_install = {
        lsp = true,
        formatter = true,
        linter = false,
    },
    ensure_installed = {
        "typescript-language-server",
    },
    lsp = {
        default = {
            flags = { debounce_text_changes = 150 },
        },
        config_by = {
            ts_ls = {},
            eslint = {
                settings = {
                    workingDirectories = { mode = "auto" },
                },
            },
        },
    },
})
```

### Auto-install callback

The optional callback runs after a filetype has been processed. It
receives the filetype followed by the provided package lists for LSP
servers, formatters, and linters. A disabled kind is passed as `false`.

``` lua
auto_install = {
    lsp = true,
    formatter = true,
    linter = false,
    callback = function(ft, lsps, formatters, linters)
        -- Integrate the provided packages with your preferred tools.
    end,
}
```

Catalog provides packages and orchestrates installation; it does not
configure formatter or linter plugins internally.

## How it works

1.  Register providers before calling `setup()`.
2.  Catalog loads installed packages from registered providers into a
    session cache.
3.  `ensure_installed`, LSP setup, and auto-install request packages
    through the provider registry.
4.  The first registered provider that can provide a package handles
    that package.

The built-in Mason provider is registered explicitly:

``` lua
require("catalog.provider.mason")
```

### Custom providers

A provider supplies packages from a package manager. It must expose
`name`, `provide(name)`, and `load_installed()`.

``` lua
local provider = {}

provider.name = "my-source"

function provider.provide(name)
    local package = my_package_manager.get(name)
    if not package then
        return nil
    end

    return {
        name = name,
        provider_name = provider.name,
        installed = function()
            return package:is_installed()
        end,
        install = function()
            package:install()
        end,
    }
end

function provider.load_installed()
    local installed = {}

    for _, package in pairs(my_package_manager.installed()) do
        installed[package.name] = {
            name = package.name,
            provider_name = provider.name,
        }
    end

    return installed
end

return provider
```

Register a custom provider before setup:

``` lua
local provider = require("catalog.provider.my_provider")
require("catalog.provider").append(provider)
```

Unknown package names should return `nil` rather than raising an error.
Providers are checked in registration order, so register preferred
providers first.

## Troubleshooting

### An LSP server does not start

1.  Confirm that Neovim is version 0.11 or newer.
2.  Confirm the Mason provider is registered before `catalog.setup()`.
3.  Confirm the package is installed in Mason.
4.  Check that `lsp.config_by` uses the server configuration name
    expected by Neovim.
5.  Enable `debug = true` and inspect Catalog notifications.
6.  Use Neovim's `:checkhealth vim.lsp` and `:LspInfo` where available
    to inspect the LSP state.

### A package cannot be found

-   Verify the package name in the relevant provider's registry.
-   Remember that package names and LSP configuration names can differ.
-   Enable debug logging to inspect provider lookup failures.

### A formatter or linter is not installed

-   Confirm that its kind is enabled in `auto_install`.
-   Check that the current filetype is present in
    `lua/catalog/auto_install/table.lua`.
-   Confirm that a registered provider supports the requested package.

## Contributing

Contributions are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md) for
development setup, testing, style, and pull request guidelines. AI
coding agents should also follow [AGENTS.md](AGENTS.md).
