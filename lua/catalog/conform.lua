local provider = require("catalog.provider")
local log = require("catalog.log").log(...)

---@type catalog.integration
return {
	setup = function()
		log.header(true)
		local ok, conform = pcall(require, "conform")

		if not ok then
			log.err("Conform is not installed")
			return
		end

		local seen = {}
		for _, fmt in ipairs(conform.list_all_formatters()) do
			local nm = fmt.command
			if nm and not seen[nm] then
				seen[nm] = true
				local p = provider.resolve(fmt.command)
				if p and not p.installed() then
					p.install()
				end
			end
		end
		log.header(false)
	end,
}
