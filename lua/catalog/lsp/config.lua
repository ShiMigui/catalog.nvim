local log = require("catalog.log").new("lsp.config")
---Implementation of the [catalog.lsp](lua://catalog.lsp) contract.
---
---```lua
---local lsp = require("catalog.lsp.config").new("lua_ls")
---lsp:update({ capabilities = caps }):update({ settings = { Lua = {} } })
---```

---Base configuration every instance deep-copies from, so instances never
---share mutable state. TODO: seed this from `catalog.lsp.default_config`
---once the two modules share a single source of truth.
local default = {}

---@class catalog.lsp
---@field name string Server name as expected by nvim-lspconfig (e.g. `"lua_ls"`).
---@field config vim.lsp.Config Configuration merged so far; starts empty.

---Method table used as `__index` for every [catalog.lsp](lua://catalog.lsp) instance.
local lsp = {}

---Deep-merges `cfg` into the current configuration.
---New values overwrite existing values (`vim.tbl_deep_extend("force")`).
---@param self catalog.lsp
---@param cfg vim.lsp.Config Configuration fragment to merge in.
---@return catalog.lsp self The same instance, for chaining.
function lsp.update(self, cfg)
	log:dbg("Updating '%s' lsp configuration", self.name)
	self.config = vim.tbl_deep_extend("force", self.config, cfg)
	return self
end

---Registers the merged config with nvim-lspconfig and enables the server,
---unless it is already enabled. Must run AFTER all update() calls: this is
---the moment the configuration is handed to the editor.
---@param self catalog.lsp
function lsp.enable(self)
	log:dbg("Enabling '%s' lsp", self.name)
	if not vim.lsp.is_enabled(self.name) then
		vim.lsp.config(self.name, self.config)
		vim.lsp.enable(self.name)
		log:dbg("'%s' enabled", self.name)
	end
end

function lsp.is_enabled(self)
	return vim.lsp.is_enabled(self.name)
end

local meta = { __index = lsp }

---Creates an instance bound to server `name`, starting from an empty
---configuration that can be extended through chained update() calls.
---@param name string Server name as expected by nvim-lspconfig (e.g. `"lua_ls"`).
---@return catalog.lsp
local function new(name)
	return setmetatable({ name = name, config = vim.deepcopy(default) }, meta)
end

return { new = new }
