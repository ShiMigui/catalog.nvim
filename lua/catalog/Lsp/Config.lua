---Implementation of the [catalog.Lsp](lua://catalog.Lsp) contract.
---
---```lua
---local lsp = require("catalog.Lsp.Config").new("lua_ls")
---lsp:update({ capabilities = caps }):update({ settings = { Lua = {} } })
---```
local default = {}
local lsp = {}

---Deep-merges `cfg` into the current configuration.
---New values overwrite existing values (`vim.tbl_deep_extend("force")`).
---@param self catalog.Lsp
---@param cfg vim.lsp.Config Configuration fragment to merge in.
---@return catalog.Lsp self The same instance, for chaining.
function lsp.update(self, cfg)
	self.config = vim.tbl_deep_extend("force", self.config, cfg)
	return self
end

local meta = {
	__index = lsp,
}

---Factory for [catalog.Lsp](lua://catalog.Lsp) instances.
---@class catalog.LspFactory
---Creates an empty configuration bound to server `name`.
---@field new fun(name: string): catalog.Lsp

---@type catalog.LspFactory
return {
	new = function(name)
		return setmetatable({ name = name, config = vim.deepcopy(default) }, meta)
	end,
}
