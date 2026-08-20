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
make test-file FILE=tests/init_spec.lua
```

### Using Neovim directly

```bash
# Run all tests
nvim --headless -u tests/minimal_init.lua -c "PlenaryBustedDirectory tests/"

# Run a specific test file
nvim --headless -u tests/minimal_init.lua -c "PlenaryBustedFile tests/init_spec.lua"
```

## Test Files

- `init_spec.lua` - Tests for catalog.setup() validation
- `provider_spec.lua` - Tests for provider resolution and caching
- `log_spec.lua` - Tests for logging system
- `auto_install_spec.lua` - Tests for auto_install functionality
- `auto_install_tools_spec.lua` - Tests for filetype-to-tools mapping
- `lsp_config_spec.lua` - Tests for LSP configuration
- `lsp_spec.lua` - Tests for LSP setup
- `ensure_installed_spec.lua` - Tests for ensure_installed
- `meta_spec.lua` - Tests for type definitions

## Adding New Tests

1. Create a new file `tests/<module_name>_spec.lua`
2. Use the `describe`, `it`, `before_each` functions from plenary
3. Run tests with `make test`

## CI

Tests are automatically run on push and pull requests using GitHub Actions. See `.github/workflows/test.yml` for details.
