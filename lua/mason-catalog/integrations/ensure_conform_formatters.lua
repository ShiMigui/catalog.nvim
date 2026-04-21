local logger = require("mason-catalog.logger").logger(...)
local provider = require("mason-catalog.core.provider")
local mod = logger.require("conform")

return function()
	logger.inf("starting")
	local seen = {}

	for _, f in ipairs(mod.list_all_formatters()) do
		local nm = f.command

		if nm and not seen[nm] then
			seen[nm] = true
			local p = provider.resolve(nm)
			if p then
				p.install()
			end
		end
	end
end
