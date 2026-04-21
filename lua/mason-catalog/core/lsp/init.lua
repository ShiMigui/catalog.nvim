local logger = require("mason-catalog.logger").logger(...)
local lsp_entry = require("mason-catalog.normalize.lsp_entry")
local mapper = require("mason-catalog.core.lsp.mapper")
local ext_to_ft = require("mason-catalog.normalize.ext")
local config_autocmd = require("mason-catalog.core.lsp.config_autocmd")

local identity = function(x)
	return x
end

---@param opts? cat.opts.lsp
return function(opts)
	logger.dbg("starting")

	opts = lsp_entry(opts)

	local map = {}
	local ctx = { map = map, default_config = opts.default_config, transform = identity }

	mapper.try_run(opts, "filetypes", ctx)

	ctx.transform = ext_to_ft
	mapper.try_run(opts, "extensions", ctx)

	config_autocmd(map)
end
