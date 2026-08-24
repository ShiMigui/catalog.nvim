local log = require("catalog.log").new("lsp.config")
---Implementation of the [catalog.Lsp](lua://catalog.Lsp) contract.
---
---```lua
---local lsp = require("catalog.lsp.config").new("lua_ls")
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
	log.dbg("Updating '%s' lsp configuration", self.name)
	self.config = vim.tbl_deep_extend("force", self.config, cfg)
	return self
end

---Registers and enables the server when not already enabled.
---@param self catalog.Lsp
function lsp.enable(self)
	log.dbg("Enabling '%s' lsp", self.name)
	if not vim.lsp.is_enabled(self.name) then
		vim.lsp.config(self.name, self.config)
		vim.lsp.enable(self.name)
		log.dbg("'%s' enabled", self.name)
	end
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
