# Testing

This directory contains tests for catalog.nvim using [plenary.nvim](https://github.com/nvim-lua/plenary.nvim).

## Prerequisites

- Neovim (0.9+)
- plenary.nvim

## Running Tests

### Using Make

```bash
# Run all tests
make test

# Run all tests with verbose output
make test-verbose

# Run a specific test file
make test-file FILE=tests/provider_spec.lua
```

### Using Neovim directly

```bash
# Run all tests
nvim --headless -u tests/minimal_init.lua -c "PlenaryBustedDirectory tests/"

# Run a specific test file
nvim --headless -u tests/minimal_init.lua -c "PlenaryBustedFile tests/provider_spec.lua"
```

## Test Files

- `minimal_init.lua` - Headless test bootstrap (runtime path setup)
- `catalog_spec.lua` - Tests for `setup()` wiring and option coercion
- `log_spec.lua` - Tests for the scoped logging system
- `provider_spec.lua` - Tests for the provider registry, provide/try_provide and caching
- `mason_spec.lua` - Tests for the built-in Mason provider conversion
- `scripts_spec.lua` - Tests for ensure_installed / ensure_list_of helpers
- `lsp_spec.lua` - Tests for the LSP setup flow
- `lsp_config_spec.lua` - Tests for the catalog.lsp handle (update/enable/is_enabled)
- `auto_install_spec.lua` - Tests for auto-install FileType hooks

## Adding New Tests

1. Create a new file `tests/<module_name>_spec.lua`
2. Use the `describe`, `it`, `before_each` functions from plenary
3. Run tests with `make test`

## CI

Tests are automatically run on push and pull requests using GitHub Actions. See `.github/workflows/test.yml` for details.
