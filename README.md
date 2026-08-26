# catalog.nvim

`catalog.nvim` automates tool installation and configuration in Neovim through a small provider system: package managers (Mason out of the box) feed packages to integrations that install, configure and enable them for you.

## Features

- **Provider registry** — Mason ships built-in, but nothing is implicit: you register only the providers you use.
- **Session cache** — installed packages are seeded at startup, so lookups never redo work.
- **LSP integration** — merge defaults, configure and enable servers by name.
- **Auto-install** — the first time you open a filetype, its mapped tools are provided and installed.
- **Scoped logging** — `[scope]`-prefixed notifications controlled by `debug`/`silent`.

## Requirements

- Neovim >= 0.11 (`vim.lsp.config` / `vim.lsp.enable`)
- [mason.nvim](https://github.com/nvim-mason/mason.nvim) for the built-in provider
- [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) (recommended) so server configurations exist to enable

## Installation

<details>
<summary>lazy.nvim</summary>

```lua
{
    "ShiMigui/catalog.nvim",
    dependencies = {
        { "williamboman/mason.nvim", opts = {} },
        "neovim/nvim-lspconfig",
    },
    opts = {},
}
```

</details>

## Quick Start

Mason's registry is lazy — make sure it is loaded before `setup()`:

```lua
{
    "ShiMigui/catalog.nvim",
    dependencies = {
        { "williamboman/mason.nvim", opts = {} },
        "neovim/nvim-lspconfig",
    },
    config = function()
        local registry = require("mason-registry")

        local function run()
            -- Register providers explicitly: add/remove lines to fit your setup
            require("catalog.provider.mason")

            require("catalog").setup({
                lsp = {
                    config_by = {
                        lua_ls = {},
                        ["yaml-language-server"] = {
                            settings = { yaml = { schemas = {} } },
                        },
                    },
                },
            })
        end

        if #registry.get_all_packages() > 0 then
            run()
        else
            registry.refresh(run)
        end
    end,
}
```

## Setup

`require("catalog").setup({ ... })` accepts:

| Option             | Type                                        | Default       | Description                                                              |
| ------------------ | ------------------------------------------- | ------------- | ------------------------------------------------------------------------ |
| `auto_install`     | `boolean \| table<'lsp'\|'formatter'\|'linter', boolean>` | `true` | Install tools mapped for a filetype the first time it is opened. A boolean toggles every kind; a table toggles per kind. |
| `ensure_installed` | `string[]`                                  | `nil`         | Package names to provide and install eagerly during setup.               |
| `lsp`              | `table`                                     | `nil`         | LSP integration options (see below).                                     |
| `debug`            | `boolean`                                   | `false`       | Notify DEBUG messages.                                                   |
| `silent`           | `boolean`                                   | `false`       | Mute ERROR/WARN/INFO messages.                                           |

### `lsp` options

| Option      | Type                              | Description                                                            |
| ----------- | --------------------------------- | ---------------------------------------------------------------------- |
| `default`   | `vim.lsp.Config`                  | Merged into every configured server, on top of catalog's baseline.     |
| `config_by` | `table<string, vim.lsp.Config>`   | Per-server configuration keyed by server name (`"lua_ls"`, not the package name). Every entry is installed, configured and enabled during setup. |

### Real-world example

TypeScript with formatters/linters handled automatically on first open:

```lua
{
    "ShiMigui/catalog.nvim",
    dependencies = {
        { "williamboman/mason.nvim", opts = {} },
        "neovim/nvim-lspconfig",
    },
    config = function()
        require("catalog.provider.mason")
        require("catalog").setup({
            auto_install = { formatter = true, linter = true }, -- lsp kind off: ts server comes from ensure_installed below
            ensure_installed = { "typescript-language-server" },
            lsp = {
                default = { flags = { debounce_text_changes = 150 } },
                config_by = {
                    ts_ls = {},
                    eslint = { settings = { workingDirectories = { mode = "auto" } } },
                },
            },
        })
    end,
}
```

## How installation works

1. **Providers** map a package name to a `catalog.package` handle. Nothing is registered implicitly: require `catalog.provider.mason` for the built-in one and/or `append()` your own, before calling `setup()`.
2. **Cache seeding** — at startup every package already installed through your registered providers is loaded into the session cache.
3. **Consumers** (`ensure_installed`, LSP setup, auto-install) ask the registry via `provide()` / `try_provide()`; hits are cached for the whole session.

## Auto-install mapping

The filetype → tools mapping lives in `lua/catalog/auto_install/table.lua`. When you open a file whose filetype has an entry (e.g. `python`), each mapped tool is provided through the registry and installed; LSP servers also get `default_config` applied and are enabled immediately. Kinds disabled in `auto_install` are skipped silently.

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

> **Note:** unknown names should return `nil` instead of raising. Mason's registry raises for unknown packages, so only ask it for names you trust.

### Registering a Custom Provider

```lua
-- In your Neovim config, before require("catalog").setup()
local my_provider = require("catalog.provider.my_provider")

require("catalog.provider").append(my_provider)
```

Providers are consulted in registration order; the first one that provides a package wins.

## Design Principles

* **Lazy Installation:** Packages are only installed when required by an integration or explicitly requested.
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
4. Check that the `config_by` key matches the server name expected by nvim-lspconfig (e.g. `ts_ls`, not `typescript-language-server`)

### Package not found

1. Check the package name on [mason-registry](https://github.com/nvim-mason/mason-registry)
2. Some packages have different names than their servers (e.g., `typescript-language-server` vs `ts_ls`)
3. Enable debug logging to see provide errors

### Formatter/Linter not installing

1. Ensure the kind is enabled: `opts = { auto_install = { formatter = true } }`
2. Check the filetype actually has an entry in the mapping table
3. Some tools may not be available in Mason
4. Check logs with `opts = { debug = true }`
