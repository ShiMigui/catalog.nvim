---Filetype event handling.
---
---Registers a single `FileType` autocommand that resolves the tools mapped for
---the filetype in [catalog.ft_tools](lua://catalog.ft_tools) and hands them to
---the user's `opts.handle_ft_event` callback. Nothing is installed or enabled
---here: the callback receives the packages and decides what to do with them.
local providers = require("catalog.providers")
local ft_tools = require("catalog.ft_tools")

local M = {}

---Filetypes already handled, so the callback runs at most once per filetype.
---@type table<string, boolean>
local handled = {}

---Resolves the names configured for `kind` into a map of provided packages
---keyed by name.
---
---Returns `nil` when `tools` does not configure `kind`, preserving the
---difference between a missing category and one that resolved to nothing. A
---configured kind whose names are all unknown yields an empty map.
---@param tools table<catalog.tool_kind, string[]>
---@param kind catalog.tool_kind
---@return catalog.package_map?
local function resolve(tools, kind)
	local names = tools[kind]
	if names ~= nil then
		---@type catalog.package_map
		local map = {}
		for _, name in ipairs(names) do
			local pkg = providers:try_provide(name)
			if pkg then
				map[name] = pkg
			end
		end
		return map
	end
end

---Registers the `FileType` autocommand that drives `payload`.
---
---Does nothing when `payload` is not a function.
---@param block catalog.logger.block<catalog.opts.handle_ft_event>
function M.setup(block)
	local callback = block.payload
	if type(callback) ~= "function" then
		block.log:WRN("handle_ft_event is not a function, skipping")
		return
	end

	block.log:DBG("handle_ft_event: registering FileType autocmd")
	vim.api.nvim_create_autocmd("FileType", {
		group = vim.api.nvim_create_augroup("catalog.handle_ft_event", { clear = true }),
		callback = function(args)
			local ft = args.match
			if not handled[ft] then
				block.log:DBG("handle_ft_event: first time handling ft=%s", ft)
				handled[ft] = true
				local tools = ft_tools[ft]
				if not tools then
					block.log:DBG("handle_ft_event: no tools mapped for ft=%s", ft)
					return
				end

				local lsp = resolve(tools, "lsp")
				local fmt = resolve(tools, "formatter")
				local lin = resolve(tools, "linter")

				block.log:DBG(
					"handle_ft_event: calling callback for ft=%s (lsp=%d fmt=%d linter=%d)",
					ft,
					lsp and vim.tbl_count(lsp) or 0,
					fmt and vim.tbl_count(fmt) or 0,
					lin and vim.tbl_count(lin) or 0
				)
				callback(ft, lsp, fmt, lin)
			end
		end,
	})
end

return M
