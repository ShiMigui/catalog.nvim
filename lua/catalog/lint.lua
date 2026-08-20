local provider = require("catalog.provider")
local log = require("catalog.log").log(...)

---@type catalog.Integration
return {
	setup = function()
		log.header()
		local ok, lint = pcall(require, "lint")

		if not ok then
			log.err("nvim-lint is not installed")
			return
		end

		local ok2, linters = pcall(function()
			local result = {}
			for _, linter in pairs(lint.linters) do
				if linter.cmd then
					table.insert(result, linter.cmd)
				end
			end
			return result
		end)

		if not ok2 then
			log.err("Failed to list nvim-lint linters: %s", linters)
			return
		end

		local seen = {}
		for _, cmd in ipairs(linters) do
			if cmd and not seen[cmd] then
				seen[cmd] = true
				local p = provider.resolve(cmd)
				if p and not p.installed() then
					p.install()
				end
			end
		end
		log.header()
	end,
}
