---catalog.nvim entry point.
---
---Bootstraps the configured integrations from a single call. Providers are
---not registered here: register whichever providers you want beforehand, so
---the setup stays modular.
---
---```lua
---require("catalog.providers"):sub(require("catalog.providers.mason_provider"))
---require("catalog").setup({
---    lsp = { default = { ... } },
---    handle_ft_event = function(ft, lsps, formatters, linters) ... end,
---})
---```
local logger = require("catalog.logger")
local lsp_opts = require("catalog.opts.lsp")
local handle_ft_event = require("catalog.opts.handle_ft_event")

local M = {}

---Bootstraps catalog.nvim.
---
---Each option is applied through [NewIn](lua://catalog.logger.NewIn), so an
---absent or empty option is skipped without side effects. Missing options
---leave the corresponding default untouched.
---@param opts? catalog.opts.init
function M.setup(opts)
	opts = opts or {}

	logger.NewIn(opts.lsp, lsp_opts.setup, "opts.lsp")
	logger.NewIn(opts.handle_ft_event, handle_ft_event.setup, "opts.handle_ft_event")
end

return M
