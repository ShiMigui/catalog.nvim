# catalog.nvim

catalog.nvim is a plugin that automates package installation and setup through a provider system.

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
````

## Providers

A `catalog.provider` is responsible for resolving and installing packages.
It abstracts how packages are fetched, allowing different backends.

### Mason Provider

The built-in Mason provider (`catalog.provider.mason`) integrates with [Mason](https://github.com/mason-org/mason.nvim).

To use it, add Mason as a dependency and ensure the registry is ready before calling `setup`:
```lua
{ "williamboman/mason.nvim", opts = {} }
```

Then:
```lua
config = function(_, opts)
	local registry = require("mason-registry")

	if #registry.get_all_packages() > 0 then
		require("catalog").setup(opts)
	else
		registry.refresh(function()
			require("catalog").setup(opts)
		end)
	end
end
```

## Integrations

### LSP

Installs, configures, and enables LSP servers based on filetypes.

```lua
lsp = {
	config = require("settings").lsp,

	md = "marksman",
	lua = "lua-language-server",
	sql = "postgres-language-server",
	php = { "intelephense", "phpactor" },
	dockerfile = "dockerfile-language-server",

	{ "json", "jsonc", lsp = "json-lsp" },
	{ "js", "ts", "jsx", "tsx", lsp = { "typescript-language-server", "eslint-lsp" }},
}
```

#### Notes

* You can also configure individual LSPs using: `["lua-language-server"] = {...}`
* Keys like `lua = "lua-language-server"` map filetypes to LSPs
* List entries allow multiple filetypes and multiple LSPs
* Tables allow per-LSP configuration

### Conform

Automatically installs formatters detected by `conform.nvim`.

```lua
conform = true
```

**Important:** `conform` must be loaded before `catalog.setup()`.

### Ensure Installed

Installs a list of packages without additional configuration.

```lua
ensure_installed = { "pgformatter" }
```

## Provider Interface (Overview)

A provider must implement:

```lua
---@class catalog.provider
---@field resolve fun(name: string): catalog.pkg?
```

Where a package:

```lua
---@class catalog.pkg
---@field name string
---@field installed fun(): boolean
---@field install fun(): nil
---@field lsp? catalog.lsp
```

## Design Notes

* Providers handle package resolution and installation
* Integrations (LSP, Conform, etc.) define behavior on top of providers
* `catalog` focuses on orchestration, not implementation details
