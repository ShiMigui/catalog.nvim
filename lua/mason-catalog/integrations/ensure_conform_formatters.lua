local pkg_adapter = require("mason-catalog.core.pkg.adapter")
local log = require("mason-catalog.logger").scope(...)
local conform = log.require("conform")

return {
	setup = function()
		log.inf("Running...")
		conform = require("conform")

		local seen = {}
		for _, f in ipairs(conform.list_all_formatters()) do
			local nm = f.command or f.name
			if nm and not seen[nm] then
				seen[nm] = true
				pkg_adapter.install(nm)
			end
		end
	end,
}
