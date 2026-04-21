local logger = require("mason-catalog.logger").logger(...)
local provider = require("mason-catalog.core.provider")
local mod = logger.require("conform")

return function()
  logger.inf("starting")
  local seen = {}
  for _, fmt in ipairs(mod.list_all_formatters()) do
    local nm = fmt.command or fmt.name
    if not seen[nm] then
      local p  = provider.resolve(nm)
      seen[nm] = p or false
      if p then
        p.install()
      end
    end
  end
end
