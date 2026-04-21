local logger = require("mason-catalog.logger").logger(...)

---@type fun(k:string): string
return function(k)
	local ft = vim.filetype.match({ filename = "file." .. k })
	if not ft then
		logger.wrn("Unknown extension '%s'", k)
		return k
	end
	return ft
end
