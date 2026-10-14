---Language-server package entity.
local lsp_opts = require("catalog.opts.lsp")
local log = require("catalog.logger").New("packages.lsp")

---Deep-merges `cfg` into the server configuration, with `cfg` taking
---precedence.
---@param self catalog.lsp
---@param cfg vim.lsp.Config Configuration fragment to merge in.
local function update(self, cfg)
	log:DBG("LSP.update %s", self.name)
	self.config = vim.tbl_deep_extend("force", self.config, cfg)
end

---Registers the merged configuration and enables the server, unless it is
---already enabled. Must run after every `update` call.
---@param self catalog.lsp
local function enable(self)
	log:DBG("LSP.enable %s (exec=%s)", self.name, self.exec_name)
	if not vim.lsp.is_enabled(self.exec_name) then
		log:DBG("Registering/enabling %s", self.exec_name)
		vim.lsp.config(self.exec_name, self.config)
		vim.lsp.enable(self.exec_name)
	end
end

---Turns a base package into a language-server package by seeding its
---configuration from [catalog.opts.lsp](lua://catalog.opts.lsp) and attaching
---the shared `update`/`enable` methods, so the methods exist once and only the
---field aliases are set per package. The server name used with
---`vim.lsp.config`/`vim.lsp.enable` is the package's `exec_name`.
---@param base catalog.package
---@return catalog.lsp
return function(base)
	---@cast base catalog.lsp
	log:DBG("Creating LSP for %s", base.name)
	base.config = lsp_opts.copy()
	base.update = update
	base.enable = enable
	base.is_lsp = true
	return base
end
