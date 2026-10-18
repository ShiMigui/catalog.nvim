# catalog.nvim

`catalog.nvim` resolves, installs, and configures development tools in
Neovim through a small, provider-based API. Providers turn names into
package entities, and specialized entities such as language servers extend
a package with extra behavior.

Package-manager details stay inside providers, separate from the entities
consumers use.

> This is an in-progress rewrite. The provider registry, package entities,
> logger, LSP defaults, and filetype-event handling are implemented, and
> `catalog.setup` wires the opt-in integrations together.

## Features

-   **Provider registry:** a single super provider consults registered
    providers in order and caches every lookup.
-   **Mason provider:** resolves packages through `mason-registry`.
-   **Package entities:** `catalog.packages` builds the base package with
    `Package`; `Lsp` and `Formatter` extend it in place and reuse shared
    methods.
-   **Scoped logging:** `catalog.logger` emits `[scope] STATUS message`
    notifications with global level control.
-   **Setup entry point:** `catalog.setup` wires the opt-in integrations —
    LSP defaults and the filetype-event callback — in one call.
-   **Type definitions:** the public API is described in
    `lua/catalog/meta.lua` for LuaLS.

## Requirements

-   Neovim 0.11 or newer, using `vim.lsp.config` and `vim.lsp.enable`.
-   [mason.nvim](https://github.com/mason-org/mason.nvim) for the built-in
    Mason provider. Start Mason before catalog.nvim and load its registry
    before running the plugin (see [Installation](#installation)).
-   [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) is
    recommended because it supplies configurations for many language
    servers.
-   [conform.nvim](https://github.com/stevearc/conform.nvim) is optional;
    `catalog.formatter` registers formatters with it.

## Installation

Requires Neovim 0.11+ and at least one provider. The example below uses
[lazy.nvim](https://github.com/folke/lazy.nvim) with the built-in Mason
provider.

Providers are **not** registered by `catalog.setup`. Register the providers
you want on the super provider first, then apply the options:

```lua
return {
    "ShiMigui/catalog.nvim",
    dependencies = {
        { "mason-org/mason.nvim", opts = {} },
        "neovim/nvim-lspconfig",
    },
    opts = {
        lsp = { default = { flags = { debounce_text_changes = 150 } } },
        handle_ft_event = function(ft, lsps, formatters, linters)
            -- See "Options" below.
        end,
    },
    config = function(_, opts)
        -- 1. Register a provider on the super provider.
        require("catalog.providers"):sub(require("catalog.providers.mason_provider"))

        -- 2. Apply the options.
        require("catalog").setup(opts)
    end,
}
```

`mason.nvim` must be initialized before catalog.nvim runs:
`require("mason").setup()` registers the registry sources that the Mason
provider reads. As a lazy.nvim dependency with `opts = {}`, `mason.setup()`
runs before this plugin's `config`, so the order above is safe.

The registry must also be loaded before `catalog.setup({})`. Run `:Mason`
first, or refresh the registry explicitly and apply the options from the
callback:

```lua
require("mason-registry").refresh(function()
    require("catalog.providers"):sub(require("catalog.providers.mason_provider"))
    require("catalog").setup({}) -- your options
end)
```

Swap the registered provider for your own if you resolve packages from a
different source.

## Usage

### Options

`catalog.setup(opts)` applies the opt-in integrations. Both keys are
optional, and an absent or empty value is skipped:

```lua
require("catalog").setup({
    -- Merged on top of Neovim's client capabilities and seeded into every
    -- language server. Invalid values are ignored.
    lsp = {
        default = { flags = { debounce_text_changes = 150 } },
    },

    -- Called at most once per configured filetype per session.
    handle_ft_event = function(ft, lsps, formatters, linters)
        -- Maps keyed by package name, or `nil` for a kind the filetype
        -- does not configure.
    end,
})
```

`handle_ft_event` receives `nil` for a kind the filetype does not configure
and an empty map for a configured kind that resolved to no packages. The
callback installs and enables nothing: it receives the packages and decides
what to do with them.

Providers are intentionally not an option. `catalog.setup` never registers
them, so register at least one provider before calling setup, as shown in
[Installation](#installation).

### Resolving packages

```lua
local providers = require("catalog.providers")

-- `provide` reports a miss; `try_provide` returns nil quietly.
local pkg = providers:provide("lua-language-server")
```

A `catalog.package` exposes:

| Field           | Description                                                   |
| --------------- | ------------------------------------------------------------- |
| `provider_name` | Provider that created the package.                            |
| `name`          | Package name understood by the provider.                      |
| `exec_name`     | Executable name; for language servers, the server name.       |
| `installed()`   | Returns whether the package is installed.                     |
| `install()`     | Installs the package when needed.                             |
| `is_lsp`        | `true` when the package is a language server.                 |
| `is_linter`     | Reserved for a future linter specialization (always `false`). |
| `is_formatter`  | `true` when the package is a formatter.                       |

### Language servers

When a provider builds a language-server package it attaches the `Lsp`
entity, so the package also exposes `config`, `update(cfg)`, and
`enable()`:

```lua
local pkg = require("catalog.providers"):provide("lua-language-server")

pkg:install()
pkg:update({ settings = { Lua = { runtime = { version = "LuaJIT" } } } })
pkg:enable()
```

`update` deep-merges `cfg` into `pkg.config`; call it before `enable`.
`enable` registers the configuration under `exec_name` and enables the
server, and does nothing when the server is already enabled.

`pkg.config` starts as a deep copy of the shared default in
`catalog.opts.lsp`: Neovim's default client capabilities unless a default is
supplied through `catalog.setup({ lsp = { default = ... } })`.

`install()` delegates to the provider and is asynchronous for Mason; make
sure the package is installed before relying on the server starting.

### Formatters

Specialize a resolved package with `catalog.packages.Formatter` to attach
`add_to_conform(ft)`, which registers the formatter with
[conform.nvim](https://github.com/stevearc/conform.nvim) and files it under
the given filetype:

```lua
local entity = require("catalog.packages")
local pkg = require("catalog.providers"):provide("stylua")

pkg:install()
entity.Formatter(pkg):add_to_conform("lua")
```

`add_to_conform` defines `conform.formatters[pkg.name]` from `pkg.exec_name`
unless you already configured that name, then appends `pkg.name` to
`conform.formatters_by_ft[ft]`. Your own conform configuration is preserved.
When conform.nvim is not installed, it logs a warning and does nothing.

Conform needs both tables: `conform.formatters` maps a formatter name to its
command, while `conform.formatters_by_ft` lists the names to run for a
filetype. A formatter name is therefore the shared identity, and the filetype
is what selects it. `add_to_conform(ft)` writes both, so you only pass the
filetype.

## Providers

The super provider (`require("catalog.providers")`) keeps an ordered list
of providers:

-   `providers:sub(provider)` registers a provider.
-   `providers:try_provide(name)` returns the first package found or
    `nil`.
-   `providers:provide(name)` does the same but reports a miss.

Providers are consulted in registration order, so register preferred
providers first. Resolutions are cached for the rest of the session: a hit
returns the same package object, and a miss is remembered so providers are
not consulted again for that name.

### Mason provider

`catalog.providers.mason_provider` is a provider backed by
`mason-registry`; register it with `providers:sub(...)`. It uses
`mason-registry.has_package` for quiet lookups.

`exec_name` is the language-server name when the package maps to one
(`spec.neovim.lspconfig`), otherwise the first `spec.bin` entry, otherwise
the package name. Language servers get the `Lsp` entity, and packages in the
`Formatter` category get the `Formatter` entity so they can register with
conform.nvim.

Mason must be initialized and its registry loaded before this provider
resolves packages; see [Installation](#installation).

### Custom providers

A provider is a `catalog.provider`: it exposes
`name`, `try_provide(self, name)`, and `provide(self, name)`, and returns
`nil` for names it does not handle. Build packages with the
`catalog.packages` entities:

```lua
local entity = require("catalog.packages")

local provider = { name = "my-source" }

function provider.try_provide(self, name)
    local handle = my_package_manager.get(name)
    if not handle then
        return nil
    end

    return entity.Package("my-source", name, handle.executable, function(pkg)
        handle:install()
    end, function()
        return handle:is_installed()
    end)
end

function provider.provide(self, name)
    return self:try_provide(name)
end

require("catalog.providers"):sub(provider)

return provider
```

`Package(provider_name, name, exec_name, install, installed)` creates the
base entity; `exec_name` defaults to `name` when `nil`. To specialize a
package, extend the base before returning it, for example with
`entity.Lsp(pkg)` or `entity.Formatter(pkg)`.

The registry only calls `try_provide`; a provider's `provide` is available
to callers that want a reported miss.

## Logging

```lua
local logger = require("catalog.logger")
local log = logger.New("providers.mason")

log:DBG("resolved %d package(s)", n) -- silent until enabled

logger.Status.DBG = true -- enable debug messages globally
```

`New` returns the logger for a scope, creating it once. `NewIn` runs a
callback for a non-empty payload, indented and bracketed by debug markers:

```lua
logger.NewIn(packages, function(block)
    block.log:DBG("handling %s", block.payload.name)
end, "catalog.setup")
```

`logger.Status` toggles each level (`DBG`, `INF`, `WRN`, `ERR`) globally;
disabled levels are skipped before any formatting.

## Troubleshooting

### A package cannot be found

-   Verify the name in the provider's registry.
-   Lookups are cached, including misses. If a name missed before its
    provider or registry was ready, reload Neovim after fixing the setup.
-   Enable debug logging with `require("catalog.logger").Status.DBG = true`
    to inspect lookups.
-   Package names and language-server names can differ; the Mason provider
    maps `spec.neovim.lspconfig` to `exec_name`.

### An LSP server does not start

-   Confirm that Neovim is version 0.11 or newer.
-   Confirm that `catalog.providers.mason_provider` is required after
    `mason.setup()`.
-   Confirm that the package is installed, then call `pkg:enable()`.

## Contributing

Contributions are welcome. Every pull request must have exactly one related
tag (for a fix, the next patch tag such as `v2.0.1`). See
[CONTRIBUTING.md](CONTRIBUTING.md) for development setup, testing, style,
and pull request guidelines. AI coding agents should also follow
[AGENTS.md](AGENTS.md).
