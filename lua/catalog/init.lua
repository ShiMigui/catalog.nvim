local log_setup = require("catalog.log")
local scope = (...) or "catalog"

---@class catalog.Config
---@field lsp? catalog.LspIntegrationConfig
---@field lsp_config? catalog.LspDefaultConfig
---@field conform? boolean
---@field lint? boolean
---@field treesitter? catalog.TreesitterConfig
---@field ensure_installed? string[]|string
---@field auto_update? boolean
---@field auto_install? boolean
---@field silent_errors? boolean
---@field debug? boolean
---@field log? table

---@class catalog.TreesitterConfig
---@field ensure_installed? string[]|string
---@field config? table

---@class catalog.Integration
---@field setup fun(opts: any): nil

return {
	---@param opts? catalog.Config
	setup = function(opts)
		opts = opts or {}

		if type(opts) ~= "table" then
			error("catalog.setup: opts must be a table")
		end

		if opts.lsp ~= nil and type(opts.lsp) ~= "table" then
			error("catalog.setup: lsp must be a table")
		end

		if opts.lsp_config ~= nil and type(opts.lsp_config) ~= "table" then
			error("catalog.setup: lsp_config must be a table")
		end

		if opts.conform ~= nil and type(opts.conform) ~= "boolean" then
			error("catalog.setup: conform must be a boolean")
		end

		if opts.lint ~= nil and type(opts.lint) ~= "boolean" then
			error("catalog.setup: lint must be a boolean")
		end

		if opts.treesitter ~= nil and type(opts.treesitter) ~= "table" then
			error("catalog.setup: treesitter must be a table")
		end

		if
			opts.ensure_installed ~= nil
			and type(opts.ensure_installed) ~= "string"
			and type(opts.ensure_installed) ~= "table"
		then
			error("catalog.setup: ensure_installed must be a string or table")
		end

		if opts.auto_update ~= nil and type(opts.auto_update) ~= "boolean" then
			error("catalog.setup: auto_update must be a boolean")
		end

		if opts.auto_install ~= nil and type(opts.auto_install) ~= "boolean" then
			error("catalog.setup: auto_install must be a boolean")
		end

		opts.log = opts.log or {}
		local log = log_setup.set_log(opts.log, opts.silent_errors == true, opts.debug).log(scope)

		log.header()

		if opts.lsp_config then
			require("catalog.lsp.config").setup(opts.lsp_config)
		end

		if opts.lsp then
			require("catalog.lsp").setup(opts.lsp)
		end

		if opts.conform then
			require("catalog.conform").setup(opts.conform)
		end

		if opts.lint then
			require("catalog.lint").setup(opts.lint)
		end

		if opts.treesitter then
			require("catalog.treesitter").setup(opts.treesitter)
		end

		if opts.ensure_installed then
			require("catalog.ensure_installed").setup(opts.ensure_installed)
		end

		if opts.auto_update then
			require("catalog.auto_update").setup()
		end

		if opts.auto_install then
			require("catalog.auto_install").setup()
		end
		log.header()
	end,
}
