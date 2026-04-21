local logger = require("mason-catalog.logger")
local ext_to_ft = require("mason-catalog.normalize.ext_to_ft")

---@param groups ExtensionGroup
return function(groups)
	local list = {}
	for _, g in ipairs(groups) do
		for _, ext in ipairs(g) do
			local ft = ext_to_ft(ext)
			if ft then
				list[ft] = g.lsps
			else
				logger.err("Extension '%s' has not related filetype. Skipping...", ext)
			end
		end
	end
	return list
end
