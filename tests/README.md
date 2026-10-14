# Testing

This directory contains tests for catalog.nvim using [plenary.nvim](https://github.com/nvim-lua/plenary.nvim).

## Prerequisites

- Neovim (0.11+)
- plenary.nvim

## Running Tests

### Using Make

```bash
# Run all tests
make test

# Run all tests with verbose output
make test-verbose

# Run a specific test file
make test-file FILE=tests/providers_spec.lua
```

### Using Neovim directly

```bash
# Run all tests
nvim --headless -u tests/minimal_init.lua -c "PlenaryBustedDirectory tests/"

# Run a specific test file
nvim --headless -u tests/minimal_init.lua -c "PlenaryBustedFile tests/providers_spec.lua"
```

## Test Files

- `minimal_init.lua` - Headless test bootstrap (runtime path setup)
- `catalog_spec.lua` - Tests for `setup()` wiring and option skipping
- `logger_spec.lua` - Tests for the scoped logging system and `NewIn` blocks
- `packages_spec.lua` - Tests for the base package and the `Lsp`/`Formatter` specializations
- `providers_spec.lua` - Tests for the super-provider registry and its cache
- `mason_provider_spec.lua` - Tests for the Mason-backed provider conversion
- `ft_tools_spec.lua` - Tests for the filetype to tools mapping shape
- `opts_lsp_spec.lua` - Tests for the shared LSP default configuration
- `handle_ft_event_spec.lua` - Tests for the `FileType` handler and resolution

## Adding New Tests

1. Create a new file `tests/<module_name>_spec.lua`
2. Use the `describe`, `it`, `before_each` functions from plenary
3. Run tests with `make test`

## CI

Tests are automatically run on push and pull requests using GitHub Actions. See `.github/workflows/ci.yml` for details.
