---Default configuration for language servers.
---
---This module owns the shared default every [catalog.lsp](lua://catalog.lsp)
---starts from. [setup](lua://M.setup) merges the user's `opts.lsp.default` on
---top of Neovim's default client capabilities, and [copy](lua://M.copy) hands
---each package its own deep copy so instances never share mutable state.
local M = {}

---Shared default every language server is seeded with.
---@type vim.lsp.Config
local default = { capabilities = vim.lsp.protocol.make_client_capabilities() }

---Merges the user's default configuration into the shared default.
---
---A payload that is not a table (for example `opts.lsp = true`), or a payload
---whose `default` is not a table, is ignored. The shared default keeps its
---current value, which starts as Neovim's client capabilities. Otherwise the
---payload's `default` is deep-merged on top of it, so user values take
---precedence.
---
---Intended to run as a [NewIn](lua://catalog.logger.NewIn) callback, which is
---why it receives a [block](lua://catalog.logger.block) carrying `payload` and
---`log`:
---
---```lua
---logger.NewIn(opts.lsp, require("catalog.opts.lsp").setup, "opts.lsp")
---```
---@param block catalog.logger.block<catalog.opts.lsp>
function M.setup(block)
	local payload = block.payload

	if type(payload) ~= "table" then
		block.log:DBG("opts.lsp is not a table, ignoring")
		return
	end
	if type(payload.default) ~= "table" then
		block.log:DBG("opts.lsp.default is not a table, ignoring")
		return
	end

	block.log:DBG("Merging user default into the shared LSP configuration")
	default = vim.tbl_deep_extend("force", default, payload.default or {})
end

---Returns a deep copy of the shared default, so each
---[catalog.lsp](lua://catalog.lsp) owns its configuration.
---@return vim.lsp.Config
function M.copy()
	return vim.deepcopy(default)
end

return M
