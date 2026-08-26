# Contributing to catalog.nvim

Thank you for your interest in contributing to catalog.nvim! This document provides guidelines and information for contributors.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Testing](#testing)
- [Code Style](#code-style)
- [Commit Conventions](#commit-conventions)
- [Pull Request Process](#pull-request-process)
- [Branch Protection](#branch-protection)

## Code of Conduct

Please be respectful and constructive in all interactions. We are committed to providing a welcoming and inclusive experience for everyone.

## Getting Started

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/catalog.nvim.git
   cd catalog.nvim
   ```
3. Add upstream remote:
   ```bash
   git remote add upstream https://github.com/ShiMigui/catalog.nvim.git
   ```
4. Create a feature branch:
   ```bash
   git checkout -b feat/your-feature-name
   ```

## Development Setup

### Prerequisites

- Neovim 0.9+
- [luacheck](https://github.com/mpeterv/luacheck) (for linting)
- [stylua](https://github.com/JohnnyMorganz/StyLua) (for formatting)

### Local Development

1. Clone the repository
2. Run tests to verify everything works:
   ```bash
   make test
   ```

## Testing

### Running Tests

```bash
# Run all tests
make test

# Run tests with verbose output
make test-verbose

# Run a specific test file
make test-file FILE=tests/init_spec.lua
```

### Test Coverage

- **Minimum coverage: 80%**
- All new features must include tests
- All bug fixes must include regression tests
- Run coverage locally before submitting:
  ```bash
  make coverage
  ```

### Writing Tests

- Use `plenary.busted` for tests
- Follow the existing test structure
- Test both success and error cases
- Mock external dependencies when necessary
- Name test files as `<module>_spec.lua`

## Code Style

### Lua

- Follow the [Neovim Lua Style Guide](https://github.com/luarocks/lua-style-guide)
- Use `stylua` for formatting
- Use meaningful variable and function names
- Add type annotations using EmmyLua annotations

### Comments

- Use `---` for documentation comments
- Use `--` for inline comments
- Document public functions with `@param` and `@return`
- Keep comments concise and relevant

### File Structure

```
lua/
├── catalog.lua                    -- Entry point: setup() and option normalization
└── catalog/
    ├── log.lua                    -- Scoped logging system
    ├── lsp/
    │   ├── init.lua               -- LSP integration setup
    │   └── config.lua             -- catalog.lsp handle (update/enable/is_enabled)
    ├── provider/
    │   ├── init.lua               -- Provider registry and session cache
    │   └── mason.lua              -- Built-in Mason provider
    ├── scripts/
    │   ├── ensure_installed.lua   -- Provide + install packages by name
    │   └── ensure_list_of.lua     -- Option list normalizer
    └── auto_install/
        ├── init.lua               -- FileType autocmd install hooks
        └── table.lua              -- Filetype -> tools mapping
```

## Commit Conventions

We use [Conventional Commits](https://www.conventionalcommits.org/) for all commits.

### Format

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

### Types

- **feat**: New feature
- **fix**: Bug fix
- **docs**: Documentation changes
- **style**: Code style changes (formatting, etc.)
- **refactor**: Code refactoring
- **test**: Adding or updating tests
- **chore**: Maintenance tasks
- **perf**: Performance improvements

### Examples

```
feat(lsp): add support for custom on_attach
fix(provider): resolve cache stale issue
docs: update README with new features
test: add tests for auto_install
chore: update dependencies
```

### Rules

- Use lowercase for description
- Use imperative mood ("add" not "added")
- Keep description under 72 characters
- Reference issues in footer: `Closes #123`

## Pull Request Process

### Before Submitting

1. **Create a feature branch** (never commit to `main`)
2. **Write tests** for new features
3. **Run all tests**: `make test`
4. **Check coverage**: `make coverage` (minimum 80%)
5. **Run linter**: `luacheck lua/`
6. **Format code**: `stylua lua/`
7. **Update documentation** if needed
8. **Write clear commit messages** following conventions

### PR Template

1. Fill out the PR template completely
2. Link related issues
3. Add screenshots for UI changes
4. Request review from maintainers

### Review Process

1. All PRs require at least one approval
2. Tests must pass
3. Coverage must be ≥ 80%
4. No merge conflicts
5. Maintainer will merge after approval

### After Merge

- Delete your feature branch
- Pull latest changes: `git pull upstream main`

## Branch Protection

### Main Branch Rules

- **No direct commits** to `main`
- **No force pushes** to `main`
- **PRs required** for all changes
- **At least 1 approval** required
- **Tests must pass**
- **Coverage ≥ 80%**

### Creating Feature Branches

```bash
# Always create a new branch for your work
git checkout main
git pull upstream main
git checkout -b feat/your-feature

# Or for bug fixes
git checkout -b fix/your-bugfix
```

## Questions?

If you have questions about contributing, please:

1. Check existing issues and documentation
2. Open a new issue with the `question` label
3. Join discussions in existing issues

Thank you for contributing to catalog.nvim!
