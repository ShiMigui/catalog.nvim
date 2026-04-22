local logger = require("mason-catalog.logger").logger(...)
local lsp_spec = require("mason-catalog.normalize.lsp_spec")
local provider = require("mason-catalog.core.provider")

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

	local fts = {}
	for _, k in ipairs(group) do
		fts[#fts + 1] = ctx.transform(k)
	end

	for _, pkg_name in ipairs(specs) do
		local p = provider.resolve(pkg_name)
		if p then
			local name = p.lspname
			if not p.installed then
				logger.wrn("LSP '%s' will not be enabled, because it's not installedd yet", name)
				return
			end

			if not vim.lsp.is_enabled(name) then
				logger.dbg("activating %s", name)
				vim.lsp.config(name, vim.tbl_deep_extend("force", p.lspconfig, { filetypes = fts }))
				vim.lsp.enable(name)
			end
		end
	end
end

return {
	---@param opts cat.opts.lsp
	---@param name "filetypes"|"extensions"
	---@param ctx lsp.run.ctx
	try_run = function(opts, name, ctx)
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
	end,
}
