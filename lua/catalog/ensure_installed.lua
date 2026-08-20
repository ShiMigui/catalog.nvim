local provider = require("catalog.provider")
local log = require("catalog.log").log(...)

---@type catalog.Integration
return {
	setup = function(opts)
		log.header()
		if type(opts) == "string" then
			opts = { opts }
		elseif not vim.islist(opts) then
			log.wrn("No packages to ensure installation in ensure_installed")
			return
		end

		---@diagnostic disable-next-line: param-type-mismatch
		for _, pkg in ipairs(opts) do
			local p = provider.resolve(pkg)
			if p and not p.installed() then
				p.install()
			end
		end
		log.header()
	end,
}
