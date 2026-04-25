local provider = require("catalog.provider")
local log = require("catalog.log").log(...)

---@param name string
---@param config catalog.lsp.config
---@param default catalog.lsp.config
---@return catalog.lsp?
return function(name, config, default)
	local p = provider.resolve(name)
	if p then
		if p.lsp then
			p.install()
			p.lsp.setup(default)
			if config then
				p.lsp.update(config)
			end
			return p.lsp
		end

		log.err("Package '%s' is not a LSP", name)
	end
end
