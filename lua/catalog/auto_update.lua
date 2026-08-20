local provider = require("catalog.provider")
local log = require("catalog.log").log(...)

---@type catalog.Integration
return {
	setup = function()
		log.header()
		local registry = require("mason-registry")

		local ok, packages = pcall(registry.get_installed_packages)
		if not ok then
			log.err("Failed to get installed packages: %s", packages)
			return
		end

		for _, pkg in ipairs(packages) do
			local p = provider.resolve(pkg.name)
			if p and p.update then
				p.update()
			end
		end
		log.header()
	end,
}
