local logger = require("mason-catalog.logger").logger(...)
local lsp_spec = require("mason-catalog.normalize.lsp_spec")

---@class lsp.run.ctx
---@field map table<string, cat.pkg.name[]>
---@field default_config cat.lsp.config
---@field transform fun(k:string): string

---@param group cat.lsp.group
---@param ctx lsp.run.ctx
local function run(group, ctx)
	if not group.lsp then
		return
	end

	local specs = lsp_spec(group.lsp, ctx.default_config)
	if not specs then
		return
	end

	for _, k in ipairs(group) do
		k = ctx.transform(k)
		if ctx.map[k] then
			logger.err("LSP already configured, key = '%s'", k)
		else
			ctx.map[k] = specs
		end
	end
end

---@param opts cat.opts.lsp
---@param name "filetypes"|"extensions"
---@param ctx lsp.run.ctx
local function try_run(opts, name, ctx)
	logger.dbg("trying")
	local groups = opts[name]
	if #groups == 0 then
		return
	end

	logger.dbg("Configuring lsp.%s", name)
	for _, g in ipairs(groups) do
		local tg = type(g)
		if tg ~= "table" then
			logger.err("Group is not a table, got '%s'. Exiting", tg)
			return
		end
		run(g, ctx)
	end
end

return { try_run = try_run }
