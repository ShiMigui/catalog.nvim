local scope = ...

vim.opt.rtp:prepend(vim.fn.getcwd())
---@param opts CatalogSetupOpts
local function _setup(opts) end

return {
	---@param opts CatalogSetupOpts
	setup = function(opts)
		if not opts or type(opts) ~= "table" then
			return
		end

		vim.g.mason_catalog_debug = opts.debug == true
		vim.g.mason_catalog_silent = opts.silent == true
	end,
}
