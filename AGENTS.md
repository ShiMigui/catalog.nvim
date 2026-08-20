# AGENTS.md - Guidelines for AI Agents

This document contains guidelines for AI agents working on catalog.nvim. All AI agents must follow these rules.

## Overview

AI agents are welcome to contribute to catalog.nvim, but must adhere to strict guidelines to maintain code quality and consistency.

## Core Rules

### 1. Follow CONTRIBUTING.md

**All rules in [CONTRIBUTING.md](CONTRIBUTING.md) apply to AI agents.**

Key requirements:
- Conventional Commits for all commits
- Feature branches (never commit to `main`)
- 80% minimum test coverage
- Run tests before committing
- Follow Lua style guide

### 2. Do NOT Modify Tests (Unless Requested)

**AI agents must NOT modify test files unless explicitly instructed to do so.**

- Do not create new test files
- Do not modify existing tests
- Do not delete tests
- Do not change test configuration

**Exception:** If the user specifically asks to add/modify tests, you may do so.

### 3. Read Before Writing

Before making any changes:

1. **Read the file you're modifying**
2. **Understand the existing code structure**
3. **Check for related code in other files**
4. **Follow existing patterns and conventions**

### 4. Minimal Changes

- Make only the necessary changes
- Do not refactor unrelated code
- Do not add unnecessary features
- Keep changes focused and minimal

## Development Workflow

### Step 1: Understand the Task

1. Read the issue or request carefully
2. Identify what needs to be changed
3. Find all related files
4. Understand the impact of changes

### Step 2: Create Feature Branch

```bash
git checkout main
git pull upstream main
git checkout -b feat/short-description
```

### Step 3: Make Changes

1. Read the file before modifying
2. Make minimal, focused changes
3. Follow existing code style
4. Add type annotations if needed

### Step 4: Verify Changes

```bash
# Run tests (MANDATORY)
make test

# Check coverage
make coverage

# Run linter
luacheck lua/

# Format code
stylua lua/
```

### Step 5: Commit

```bash
git add .
git commit -m "feat(scope): description"
```

Follow [Conventional Commits](https://www.conventionalcommits.org/).

### Step 6: Push and Create PR

```bash
git push origin feat/short-description
```

Create PR with proper description and link to issue.

## Code Quality Requirements

### Testing

- **Minimum coverage: 80%**
- Tests must pass before committing
- Do not modify tests unless requested
- New features should have tests (but ask user first)

### Code Style

- Use `stylua` for formatting
- Use `luacheck` for linting
- Follow existing patterns
- Add type annotations

### Documentation

- Update README if adding features
- Add comments for complex logic
- Document public functions

## Prohibited Actions

### Never Do These

1. **Never commit to `main`**
2. **Never force push**
3. **Never modify tests without permission**
4. **Never skip tests**
5. **Never commit secrets or keys**
6. **Never break existing functionality**
7. **Never add unnecessary dependencies**

### Always Do These

1. **Always create feature branches**
2. **Always run tests**
3. **Always follow commit conventions**
4. **Always read files before modifying**
5. **Always make minimal changes**
6. **Always verify your work**

## File Structure Reference

```
lua/catalog/
├── init.lua              -- Main entry, setup validation
├── log.lua              -- Logging system
├── provider/
│   ├── init.lua         -- Provider management, cache
│   ├── meta.lua         -- Type definitions
│   ├── mason.lua        -- Mason provider
│   └── lsp.lua          -- LSP helper
├── lsp/
│   ├── init.lua         -- LSP integration
│   └── config.lua       -- LSP configuration
├── conform.lua          -- Conform integration
├── lint.lua             -- Lint integration
├── treesitter.lua       -- Treesitter integration
├── ensure_installed.lua -- Package installation
├── auto_update.lua      -- Auto update
├── auto_install.lua     -- Auto install
└── auto_install_tools.lua -- Filetype mapping
```

## Testing Reference

### Test Files Location

```
tests/
├── init_spec.lua
├── provider_spec.lua
├── log_spec.lua
├── auto_install_spec.lua
├── auto_install_tools_spec.lua
├── lsp_config_spec.lua
├── lsp_spec.lua
├── ensure_installed_spec.lua
└── meta_spec.lua
```

### Running Tests

```bash
# Run all tests
make test

# Run specific test
make test-file FILE=tests/init_spec.lua

# Verbose output
make test-verbose
```

## Commit Message Examples

### Good

```
feat(lsp): add on_attach support
fix(provider): resolve cache stale issue
docs: update README
test: add tests for auto_install
refactor(log): simplify logging system
```

### Bad

```
update code
fix bug
add feature
wip
stuff
```

## Common Mistakes to Avoid

1. **Committing to `main`** - Always use feature branches
2. **Skipping tests** - Always run `make test`
3. **Modifying tests** - Don't unless explicitly asked
4. **Poor commit messages** - Use conventional commits
5. **Large changes** - Keep changes minimal and focused
6. **Not reading code** - Always read before modifying
7. **Breaking changes** - Ensure backward compatibility

## Questions?

If you're an AI agent and have questions:

1. Read CONTRIBUTING.md
2. Check existing code patterns
3. Ask the user for clarification
4. Follow existing conventions

## Summary

AI agents must:
- ✅ Follow CONTRIBUTING.md
- ✅ Create feature branches
- ✅ Run tests (make test)
- ✅ Use conventional commits
- ✅ Make minimal changes
- ✅ Read before writing
- ❌ Modify tests (unless asked)
- ❌ Commit to main
- ❌ Skip testing

Thank you for following these guidelines!
