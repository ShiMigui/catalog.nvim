local log = require("catalog.log").log(...)
local FT_TOOLS = require("catalog.auto_install_tools")
local provider = require("catalog.provider")

---@class catalog.AutoInstallConfig
---@field lsp? boolean|string[]
---@field formatter? boolean|string[]
---@field linter? boolean|string[]

---@param val any
---@return string[]
local function ensure_list(val)
	if type(val) == "string" then
		return { val }
	end
	return val
end

---@param tbl table
---@return boolean
local function has_value(tbl)
	return next(tbl) ~= nil
end

---@param tool string
---@param ft string
---@return catalog.Package|nil
local function resolve_package(tool, ft)
	local p = provider.resolve(tool)
	if not p then
		log.err("Package '%s' for filetype '%s' not found in provider", tool, ft)
		return nil
	end
	return p
end

---@param p catalog.Package
local function install_if_needed(p)
	if not p.installed() then
		p.install()
	end
end

--- Register an LSP with vim.lsp and enable it.
---@param name string
local function register_lsp(name)
	if vim.lsp.is_enabled(name) then
		return
	end

	local lsp_config = require("catalog.lsp.config")
	local default = lsp_config.config()
	local on_attach = lsp_config.get_on_attach()

	local config = vim.deepcopy(default)
	if on_attach then
		config.on_attach = on_attach
	end

	vim.lsp.config(name, config)
	vim.lsp.enable(name)
end

--- Register a formatter with conform for a filetype.
---@param tool string
---@param ft string
local function register_formatter(tool, ft)
	local ok, conform = pcall(require, "conform")
	if not ok then
		return
	end

	if not conform.formatters_by_ft then
		return
	end

	if not conform.formatters_by_ft[ft] then
		conform.formatters_by_ft[ft] = {}
	end

	-- Avoid duplicates
	for _, existing in ipairs(conform.formatters_by_ft[ft]) do
		if existing == tool then
			return
		end
	end

	table.insert(conform.formatters_by_ft[ft], tool)
end

--- Register a linter with nvim-lint for a filetype.
---@param tool string
---@param ft string
local function register_linter(tool, ft)
	local ok, lint = pcall(require, "lint")
	if not ok then
		return
	end

	if not lint.linters_by_ft then
		return
	end

	if not lint.linters_by_ft[ft] then
		lint.linters_by_ft[ft] = {}
	end

	-- Avoid duplicates
	for _, existing in ipairs(lint.linters_by_ft[ft]) do
		if existing == tool then
			return
		end
	end

	table.insert(lint.linters_by_ft[ft], tool)
end

--- Find the tool name associated with a Mason package name for a given tool type.
---@param pkg_name string
---@param tool_type '"lsp"'|'"formatter"'|'"linter"'
---@return string|nil tool_name, string|nil ft
local function find_tool_for_package(pkg_name, tool_type)
	for ft, tools in pairs(FT_TOOLS) do
		local tool_list = tools[tool_type]
		if tool_list then
			tool_list = ensure_list(tool_list)
			for _, name in ipairs(tool_list) do
				if name == pkg_name then
					return name, ft
				end
			end
		end
	end
	return nil, nil
end

--- Install tools and register post-install hooks for a filetype.
---@param ft string
---@param tools string[]
---@param tool_type '"lsp"'|'"formatter"'|'"linter"'
---@param register fun(tool: string, ft: string)
local function install_and_register(ft, tools, tool_type, register)
	for _, tool in ipairs(tools) do
		local p = resolve_package(tool, ft)
		if p then
			if p.installed() then
				-- Already installed: register immediately
				register(tool, ft)
				log.dbg("Auto-install %s '%s' for filetype '%s' (already installed)", tool_type, tool, ft)
			else
				-- Not installed: start install, registration happens via
				-- mason-registry package:install:success event listener
				install_if_needed(p)
				log.dbg("Auto-install %s '%s' for filetype '%s' (installing...)", tool_type, tool, ft)
			end
		end
	end
end

--- Build filetype-to-tools mapping from FT_TOOLS.
---@param enabled_types table<string, boolean|string[]>
---@return table<string, string[]>, table<string, string[]>, table<string, string[]>
local function build_filetype_maps(enabled_types)
	---@type table<string, string[]>
	local lsp_filetypes = {}
	---@type table<string, string[]>
	local formatter_filetypes = {}
	---@type table<string, string[]>
	local linter_filetypes = {}

	for ft, tools in pairs(FT_TOOLS) do
		if enabled_types.lsp and tools.lsp then
			if enabled_types.lsp == true then
				lsp_filetypes[ft] = ensure_list(tools.lsp)
			elseif type(enabled_types.lsp) == "table" then
				-- Only include if this LSP is in the explicit list
				local lsp_tools = ensure_list(tools.lsp)
				local filtered = {}
				for _, name in ipairs(lsp_tools) do
					for _, allowed in ipairs(enabled_types.lsp) do
						if name == allowed then
							table.insert(filtered, name)
							break
						end
					end
				end
				if #filtered > 0 then
					lsp_filetypes[ft] = filtered
				end
			end
		end

		if enabled_types.formatter and tools.formatter then
			if enabled_types.formatter == true then
				formatter_filetypes[ft] = ensure_list(tools.formatter)
			elseif type(enabled_types.formatter) == "table" then
				local fmt_tools = ensure_list(tools.formatter)
				local filtered = {}
				for _, name in ipairs(fmt_tools) do
					for _, allowed in ipairs(enabled_types.formatter) do
						if name == allowed then
							table.insert(filtered, name)
							break
						end
					end
				end
				if #filtered > 0 then
					formatter_filetypes[ft] = filtered
				end
			end
		end

		if enabled_types.linter and tools.linter then
			if enabled_types.linter == true then
				linter_filetypes[ft] = ensure_list(tools.linter)
			elseif type(enabled_types.linter) == "table" then
				local lint_tools = ensure_list(tools.linter)
				local filtered = {}
				for _, name in ipairs(lint_tools) do
					for _, allowed in ipairs(enabled_types.linter) do
						if name == allowed then
							table.insert(filtered, name)
							break
						end
					end
				end
				if #filtered > 0 then
					linter_filetypes[ft] = filtered
				end
			end
		end
	end

	return lsp_filetypes, formatter_filetypes, linter_filetypes
end

--- Create FileType autocmds for a tool type.
---@param filetypes table<string, string[]>
---@param tool_type '"LSP"'|'"formatter"'|'"linter"'
---@param group_name string
---@param register fun(tool: string, ft: string)
local function create_autocmds(filetypes, tool_type, group_name, register)
	if not has_value(filetypes) then
		return
	end

	vim.api.nvim_create_autocmd("FileType", {
		pattern = vim.tbl_keys(filetypes),
		callback = function(args)
			local tools = filetypes[args.match]
			if not tools then
				return
			end
			install_and_register(args.match, tools, tool_type, register)
		end,
		group = vim.api.nvim_create_augroup(group_name, { clear = true }),
	})
end

---@type catalog.Integration
return {
	---@param opts? boolean|catalog.AutoInstallConfig
	setup = function(opts)
		log.header()

		-- Normalize opts: true → { lsp = true, formatter = true, linter = true }
		if opts == true or opts == nil then
			opts = { lsp = true, formatter = true, linter = true }
		end

		if type(opts) ~= "table" then
			log.err("auto_install options must be a boolean or table")
			return
		end

		local lsp_filetypes, formatter_filetypes, linter_filetypes = build_filetype_maps(opts)

		create_autocmds(lsp_filetypes, "LSP", "CatalogAutoInstallLsp", register_lsp)
		create_autocmds(formatter_filetypes, "formatter", "CatalogAutoInstallFormatter", register_formatter)
		create_autocmds(linter_filetypes, "linter", "CatalogAutoInstallLinter", register_linter)

		-- Listen for Mason install success events to register LSP/formatter/linter
		-- after async installation completes.
		local ok, registry = pcall(require, "mason-registry")
		if ok then
			registry:on("package:install:success", function(handle)
				local pkg_name = handle.package.name
				-- Check LSP
				local tool, ft = find_tool_for_package(pkg_name, "lsp")
				if tool then
					register_lsp(tool)
					log.inf("Auto-install LSP '%s' registered after install", tool)
					return
				end
				-- Check formatter
				tool, ft = find_tool_for_package(pkg_name, "formatter")
				if tool and ft then
					register_formatter(tool, ft)
					log.inf("Auto-install formatter '%s' registered after install", tool)
					return
				end
				-- Check linter
				tool, ft = find_tool_for_package(pkg_name, "linter")
				if tool and ft then
					register_linter(tool, ft)
					log.inf("Auto-install linter '%s' registered after install", tool)
					return
				end
			end)
		end

		local count = #vim.tbl_keys(lsp_filetypes)
			+ #vim.tbl_keys(formatter_filetypes)
			+ #vim.tbl_keys(linter_filetypes)
		log.inf("Auto-install enabled for %d filetypes", count)
		log.header()
	end,
}
