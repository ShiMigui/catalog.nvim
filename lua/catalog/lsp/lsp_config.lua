local provider = require("catalog.provider")
local log = require("catalog.log").log(...)

return function(name, config, default)
	local p = provider.resolve(name)
	if p then
		if not p.lsp then
			log.err("Package '%s' is not a LSP", name)
			return
		end

		p.install()
		p.lsp.setup(default)
		if config then
			p.lsp.update(config)
		end
		return p.name
	end
end
