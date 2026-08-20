local log_setup = require("catalog.log")
local scope = (...) or "catalog"

---@class catalog.Config
---@field lsp? catalog.LspIntegrationConfig
---@field lsp_config? catalog.LspDefaultConfig
---@field conform? boolean @deprecated Use auto_install instead
---@field lint? boolean @deprecated Use auto_install instead
---@field treesitter? catalog.TreesitterConfig
---@field ensure_installed? string[]|string
---@field auto_update? boolean
---@field auto_install? boolean|catalog.AutoInstallConfig
---@field silent_errors? boolean
---@field debug? boolean
---@field log? table

---@class catalog.TreesitterConfig
---@field ensure_installed? string[]|string
---@field config? table

---@class catalog.Integration
---@field setup fun(opts: any): nil

---@param auto_install boolean|catalog.AutoInstallConfig|nil
---@param conform boolean|nil @deprecated
---@param lint boolean|nil @deprecated
---@return boolean|catalog.AutoInstallConfig
local function merge_auto_install(auto_install, conform, lint)
	-- If auto_install is already a table, use it
	if type(auto_install) == "table" then
		return auto_install
	end

	-- If only auto_install=true (no legacy conform/lint), enable all
	if auto_install == true and not conform and not lint then
		return true
	end

	-- Merge legacy conform/lint into auto_install
	local merged = {}
	if auto_install == true then
		merged.lsp = true
		merged.formatter = true
		merged.linter = true
	end
	if conform then
		merged.formatter = true
	end
	if lint then
		merged.linter = true
	end

	return next(merged) and merged or (auto_install == true or false)
end

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

		if opts.auto_install ~= nil and type(opts.auto_install) ~= "boolean" and type(opts.auto_install) ~= "table" then
			error("catalog.setup: auto_install must be a boolean or table")
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
			log.inf("DEPRECATED: conform = true is deprecated, use auto_install = { formatter = true } instead")
			require("catalog.conform").setup(opts.conform)
		end

		if opts.lint then
			log.inf("DEPRECATED: lint = true is deprecated, use auto_install = { linter = true } instead")
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
			local merged = merge_auto_install(opts.auto_install, opts.conform, opts.lint)
			require("catalog.auto_install").setup(merged)
		elseif opts.conform or opts.lint then
			-- Legacy conform/lint without auto_install: still trigger auto_install
			local merged = merge_auto_install(false, opts.conform, opts.lint)
			if next(merged) then
				require("catalog.auto_install").setup(merged)
			end
		end

		log.header()
	end,
}
