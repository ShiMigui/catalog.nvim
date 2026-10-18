# Instructions for AI Coding Agents

These guidelines apply to AI agents working in `catalog.nvim`. Follow
the repository's `CONTRIBUTING.md` and keep changes correct, focused,
and easy to maintain.

## Before changing code

1.  Read the files relevant to the task.
2.  Trace related code paths and existing conventions before designing a
    solution.
3.  Identify the intended behavior and the smallest change that
    satisfies it.
4.  Ask for clarification when a requirement is materially ambiguous; do
    not invent product requirements.

## Design principles

### Keep it simple

-   Prefer the smallest clear solution that meets the requirements.
-   Do not add speculative features, unnecessary dependencies, or
    configuration options without a concrete use case.
-   Avoid abstractions and indirection that make the code harder to
    understand.
-   Concise code is valuable only when it remains readable and correct.

### Avoid duplication

-   Reuse existing functions, helpers, and conventions when they fit the
    requirement.
-   Keep business rules and normalization logic in one appropriate
    place.
-   Extract shared logic when duplication is meaningful, but do not
    create generic abstractions to eliminate trivial repetition.
-   Fix the source of a problem rather than adding parallel workarounds.
-   Remove obsolete code only when its lack of use is established.

### Keep modules cohesive

-   Give each module a clear responsibility.
-   Keep implementation details local and expose only the API consumers
    need.
-   Avoid circular dependencies and unnecessary coupling.
-   Do not create one module per function by default; group related
    behavior coherently.
-   Follow the existing architecture unless the task specifically
    requires changing it.

## Lua and Neovim conventions

-   Follow the existing Lua style and format with StyLua.
-   Use meaningful names and EmmyLua/LuaLS annotations where they
    clarify public APIs or non-obvious types.
-   Document public functions and non-obvious behavior; keep comments
    concise and current.
-   Use Neovim APIs compatible with the project's declared minimum
    version.
-   Preserve compatibility with the Neovim LSP API used by the project
    (`vim.lsp.config` and `vim.lsp.enable`).
-   Keep provider behavior consistent with the documented provider
    interface.
-   Prefer explicit error handling and useful diagnostic context over
    silently swallowing failures.

## Tests and verification

-   Do not modify unrelated tests or weaken assertions to make a change
    pass.
-   Add or update tests when the requested behavior requires coverage,
    including regression tests for bug fixes. If the user explicitly
    prohibits test changes, explain the verification trade-off.
-   Run the relevant tests and checks available in the repository. At
    minimum, run `make test` when practical.
-   Run formatting and lint checks when available, such as
    `make format-check`, `make lint`, `stylua`, or `luacheck`.
-   Report commands that could not be run and why. Never claim that a
    check passed unless it was actually run.
-   Do not claim a coverage threshold is met unless the repository has a
    working way to measure it.

## Scope and safety

-   Make focused changes; do not refactor unrelated code.
-   Do not change public behavior unintentionally.
-   Do not commit secrets, credentials, personal data, or generated
    artifacts unless explicitly required.
-   Never commit directly to `main`, force-push, or create commits
    unless the user asks you to perform Git operations.
-   Do not bypass failing checks without explaining the reason.

## Documentation

-   Update the README when user-facing behavior, configuration,
    requirements, or examples change.
-   Keep examples consistent with the current implementation.
-   Do not document unsupported options, commands, or guarantees.
-   Avoid repeating long instructions across files; link to
    `CONTRIBUTING.md` for contributor workflow.
-   Write all documentation, comments, and responses in English.

## Suggested workflow

1.  Inspect the repository and identify relevant code.
2.  Make the smallest coherent implementation.
3.  Add or update relevant tests.
4.  Run applicable tests, linting, and formatting checks.
5.  Review the diff for duplication, unnecessary complexity, and
    unrelated changes.
6.  Summarize what changed, what was verified, and any remaining
    limitations.

## Repository structure

The main implementation currently lives under `lua/catalog/`. Check the
actual repository before relying on this outline, since files may
change:

-   `lua/catalog.lua`: public entry point and option normalization.
-   `lua/catalog/meta.lua`: public LuaCATS types for the API.
-   `lua/catalog/logger.lua`: scoped logging.
-   `lua/catalog/ft_tools.lua`: filetype-to-tools mapping.
-   `lua/catalog/opts/`: integrations applied by `catalog.setup` (`lsp`,
    `handle_ft_event`).
-   `lua/catalog/packages/`: package entities (`Package`, `Lsp`,
    `Formatter`).
-   `lua/catalog/providers/`: provider registry, super provider, and Mason
    provider.

## Versioning and Git Tags

- Follow Semantic Versioning (`MAJOR.MINOR.PATCH`) for stable releases.
- Use annotated Git tags for releases, following the existing repository convention (for example, `v1.2.3`).
- Every pull request must have exactly one related tag. Use the patch tag for a fix (for example, `v2.0.1` after `v2.0.0`) and reference it in the pull request description.
- Never create, move, overwrite, or delete release tags unless explicitly instructed by the user.
- Before preparing a release, inspect the existing tags and review the changes since the latest release.
- Ensure the release version is consistent with the project's changelog and release notes, when present.
- Do not assume that a change qualifies for a major, minor, or patch release without considering its impact on the public API and existing behavior.
- If a release requires changes to version metadata or documentation, update them only when the release task calls for it.
- Do not push tags or publish releases without explicit authorization.
- When asked to prepare a release, report the proposed version, the reasoning behind it, and any checks that remain incomplete.

The implementation is the source of truth when it differs from stale
documentation.
