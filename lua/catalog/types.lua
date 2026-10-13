---Core EmmyLua type definitions for catalog.nvim.
---This module exists solely to centralize shared types so they don't
---get duplicated across modules. It returns nothing.

---A single tool category handled by auto-install.
---@alias catalog.tool_kind 'lsp'|'formatter'|'linter'

---Receives the filetype that was processed first, then the packages provided
---for each enabled kind; a kind that is disabled arrives as `false`.
---@alias catalog.auto_install_callback fun(ft: string, lsps: catalog.package[]|false,
---	formatters: catalog.package[]|false, linters: catalog.package[]|false)

---Explicit per-kind switches for auto-install, plus an optional callback
---that receives the packages provided for each enabled kind. Leave the
---integration work (formatting setup, linter config, …) to that callback
---instead of wiring it internally.
---@alias catalog.auto_install_flags table<catalog.tool_kind, boolean> & { callback?: catalog.auto_install_callback }

---LSP integration options.
---@alias catalog.lsp_opts {
---   default: vim.lsp.Config,
---   config_by: table<string, vim.lsp.Config>,
---}

---User configuration options.
---@class catalog.opts
---Auto-install tools when a filetype is opened.
---`true` enables every tool kind; a table toggles each kind individually and
---may add a `callback` that receives the installed packages per enabled kind.
---@field auto_install? catalog.auto_install_flags | boolean
---Package names to install eagerly during setup.
---@field ensure_installed? string[]
---Per-server LSP configurations merged on top of the defaults, keyed by server name.
---@field lsp? catalog.lsp_opts
---Notify DEBUG messages.
---@field debug? boolean
---Suppress non-error notifications (overrides debug).
---@field silent? boolean

---A package provided by a provider.
---@class catalog.package
---Name of the provider that provided this package.
---@field provider_name string
---Package name (e.g. `"lua-language-server"`).
---@field name string
---LSP handle used to configure the language server; only set for LSP packages.
---@field lsp? catalog.lsp
---Checks whether the package is already installed.
---@field installed fun(): boolean
---Installs the package; implementations must make this idempotent, since it
---is called unconditionally by consumers.
---@field install fun(self: catalog.package)

---Shape every provider implements.
---@class catalog.provider
---Provider identifier, used in logs and as the registration key.
---@field name string
---Provides `name` as a [catalog.package](lua://catalog.package), or returns
---`nil` when unknown. Must not raise on unknown names.
---@field provide fun(name: string): catalog.package?
---Returns every package already installed through this provider, keyed by
---name; consumed by the registry [load_installed](lua://catalog.provider.load_installed)
---to seed its cache.
---@field load_installed fun(): table<string, catalog.package>

---LSP handle wrapping configuration and enabling.
---@class catalog.lsp
---Server name as expected by nvim-lspconfig (e.g. `"lua_ls"`).
---@field name string
---Configuration merged so far.
---@field config vim.lsp.Config
---Deep-merges `cfg` into configuration and returns self for chaining.
---@field update fun(self: catalog.lsp, cfg: vim.lsp.Config): catalog.lsp
---Registers merged config and enables the server.
---@field enable fun(self: catalog.lsp)
---Whether the server is currently enabled.
---@field is_enabled fun(self: catalog.lsp): boolean

---Scoped logger.
---@class catalog.logger
---Rendered `[scope] ` prefix prepended to every notification.
---@field prefix string
---Toggles starting/finishing markers and updates the shared indent level.
---@field header fun(self: catalog.logger)
---Logs an ERROR message.
---@field err fun(self: catalog.logger, fmt: string, ...: any)
---Logs a WARN message.
---@field warn fun(self: catalog.logger, fmt: string, ...: any)
---Logs an INFO message.
---@field inf fun(self: catalog.logger, fmt: string, ...: any)
---Logs a DEBUG message (only shown when DEBUG is enabled).
---@field dbg fun(self: catalog.logger, fmt: string, ...: any)
---Disables all notifications for this logger instance.
---@field disable fun(self: catalog.logger)
---Re-enables notifications for this logger instance.
---@field enable fun(self: catalog.logger)
---True when this logger will emit notifications.
---@field enabled fun(self: catalog.logger): boolean
---Sets the log level filter for this logger.
---@field set_level fun(self: catalog.logger, level: vim.log.levels)

return {}
