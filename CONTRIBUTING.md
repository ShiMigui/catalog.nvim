# Contributing to catalog.nvim

Thank you for helping improve `catalog.nvim`. This guide describes how
to set up a local checkout, run checks, and submit a focused
contribution.

## Code of conduct

Be respectful, constructive, and considerate in all project discussions
and reviews.

## Getting started

Fork the repository, then clone your fork:

``` bash
git clone https://github.com/YOUR_USERNAME/catalog.nvim.git
cd catalog.nvim
git remote add upstream https://github.com/ShiMigui/catalog.nvim.git
git checkout -b feat/short-description
```

Use a `fix/short-description` branch for bug fixes. Do not work directly
on `main`.

## Requirements

-   Neovim 0.11 or newer.
-   Lua development tools used by this repository, including
    [StyLua](https://github.com/JohnnyMorganz/StyLua) and
    [Luacheck](https://github.com/mpeterv/luacheck).
-   The test dependencies declared by the repository, including Plenary
    if required by the test setup.

Check the `Makefile` and test bootstrap for the current supported
commands before assuming additional tooling is available.

## Local setup

Activate the versioned Git hooks once per clone:

``` bash
make hooks
```

Run the test suite:

``` bash
make test
```

### Git hooks

The hooks in `.githooks/` can be enabled with `make hooks`, which
configures `core.hooksPath`.

  -----------------------------------------------------------------------
  Hook                                Checks
  ----------------------------------- -----------------------------------
  `pre-commit`                        Runs the repository's format check,
                                      lint, and test commands.

  `commit-msg`                        Checks the commit subject against
                                      the project's Conventional Commits
                                      convention.
  -----------------------------------------------------------------------

If a hook fails, investigate and fix the cause before committing. Avoid
`--no-verify`; bypassing checks should be exceptional and explained.

## Development guidelines

-   Read relevant code and tests before making changes.
-   Keep changes focused and avoid unrelated refactoring.
-   Prefer straightforward implementations over speculative
    abstractions.
-   Reuse existing helpers and conventions; avoid duplicated business
    logic.
-   Keep module responsibilities clear and dependencies explicit.
-   Preserve compatibility with the project's supported Neovim version.
-   Update documentation when public behavior, configuration, or
    examples change.

AI coding agents must also follow [`AGENTS.md`](AGENTS.md).

## Language

All contributions must be written in English, including code comments, documentation, commit messages, pull request descriptions, and issue discussions. This keeps the project consistent and accessible.

## Tests and checks

Run the checks relevant to your change. The standard test command is:

``` bash
make test
```

Other useful commands, when defined by the repository, include:

``` bash
make test-verbose
make test-file FILE=tests/providers_spec.lua
make format-check
make lint
```

Check `make help` or inspect the `Makefile` if a command is unavailable.

New behavior should have tests, and bug fixes should include regression
coverage where practical. Test both successful behavior and relevant
failure cases. Do not change tests merely to hide a defect.

Coverage should reflect the public behavior and important branches
affected by the change. Do not report a specific coverage percentage
unless the repository has a working coverage tool and the command has
actually been run.

For local checks, format and lint the Lua source using the project's
configured tools. Prefer the repository's Makefile targets so local and
CI checks stay consistent.

## Lua style

-   Follow the existing style and the [Lua Style
    Guide](https://github.com/luarocks/lua-style-guide).
-   Use StyLua for formatting and Luacheck for linting.
-   Use descriptive names and add LuaLS/EmmyLua annotations when they
    improve type clarity.
-   Use `---` for documentation comments and `--` for implementation
    comments.
-   Document public functions and non-obvious behavior without narrating
    self-explanatory code.

## Commit messages

Use [Conventional Commits](https://www.conventionalcommits.org/) for
commit subjects:

``` text
<type>(<scope>): <description>
```

Common types:

-   `feat`: add functionality.
-   `fix`: correct a bug.
-   `docs`: change documentation.
-   `style`: formatting-only changes.
-   `refactor`: restructure code without changing behavior.
-   `test`: add or change tests.
-   `chore`: maintenance tasks.
-   `perf`: improve performance.

Examples:

``` text
feat(lsp): support custom server options
fix(provider): handle missing packages
docs: clarify setup order
test(auto-install): cover unknown filetypes
refactor(log): simplify notification handling
```

Use lowercase, imperative descriptions and keep the subject concise
(preferably under 72 characters). Add issue references in the footer
when relevant, such as `Closes #123`.

## Pull requests

Before opening a pull request:

1.  Confirm the branch contains only changes related to the task.
2.  Run relevant tests, formatting, and lint checks.
3.  Update documentation and examples as needed.
4.  Review the diff for accidental changes, duplicated logic, and
    secrets.
5.  Write a description explaining the problem, the solution, and how it
    was tested.
6.  Link related issues and include screenshots or logs when they
    clarify the change.

Maintainers should review behavior, maintainability, compatibility, and
test coverage before merging. Repository settings determine required
approvals and branch protection; contributors should not assume a
specific approval count unless it is configured.

After merge, update your local `main` branch and remove the feature
branch when it is no longer needed.

## Reporting issues

Before opening an issue, check existing issues and documentation.
Include relevant Neovim versions, reproduction steps, expected behavior,
actual behavior, and useful error messages. Remove secrets and personal
information from logs.
