local log = require("catalog.log").log(...)
local provider = require("catalog.provider")
local lsp_config = require("catalog.lsp.config")
local default = lsp_config.config()

--- Catalog LSP configuration.
---
--- Supports two declaration styles:
---
--- Array entries:
---
--- ```lua
--- {
---     "lua-language-server",
---     "typescript-language-server",
--- }
--- ```
---
--- Keyed entries with custom configuration:
---
--- ```lua
--- {
---     ["yaml-language-server"] = {
---         settings = {
---             yaml = {
---                 schemas = {},
---             },
---         },
---     },
--- }
--- ```
---
--- Both styles may be combined:
---
--- ```lua
--- {
---     "lua-language-server",
---     "typescript-language-server",
---
---     ["yaml-language-server"] = {
---         settings = {
---             yaml = {
---                 schemas = {},
---             },
---         },
---     },
--- }
--- ```
---
---@class catalog.LspIntegrationConfig
---@field [integer] string
---@field [string] catalog.LspConfig

--- Registered LSP configurations.
---
--- Key: LSP name
--- Value: Final merged configuration
---
---@type table<string, catalog.LspConfig>
local index = {}

vim.api.nvim_create_user_command("CatalogShowLSPs", function()
	local ordered = vim.tbl_keys(index)
	table.sort(ordered)
	for _, lsp_name in ipairs(ordered) do
		log.inf("%s", lsp_name)
	end
end, { desc = "Show configured LSP servers" })

--- Resolve, install and configure a package as an LSP.
---
---@param name string
---@param config? catalog.LspConfig
---@return catalog.Lsp|nil
local function provide(name, config)
	local pkg = provider.resolve(name)

	if not pkg then
		return nil
	elseif not pkg.lsp then
		log.err("Package '%s' is not a LSP", name)
		return nil
	end

	if config and config.enabled == false then
		log.dbg("LSP '%s' is disabled, skipping", name)
		return nil
	end

	pkg.install()
	pkg.lsp:update(config or {}, default)
	return pkg.lsp
end

local LSP_HANDLERS = {

	--- Handles:
	---
	--- ```lua
	--- {
	---     "lua-language-server"
	--- }
	--- ```
	---
	---@param _ integer
	---@param pkg_name string
	---@return catalog.Lsp|nil
	number_string = function(_, pkg_name)
		return provide(pkg_name)
	end,

	--- Handles:
	---
	--- ```lua
	--- {
	---     ["yaml-language-server"] = {
	---         settings = {},
	---     }
	--- }
	--- ```
	---
	---@param pkg_name string
	---@param config catalog.LspConfig
	---@return catalog.Lsp|nil
	string_table = function(pkg_name, config)
		return provide(pkg_name, config)
	end,
}

---@type catalog.Integration
return {

	--- Configure and enable all declared LSP servers.
	---
	---@param opts catalog.LspIntegrationConfig
	setup = function(opts)
		if type(opts) ~= "table" then
			log.err("Options must be a table")
			return
		end

		for k, v in pairs(opts) do
			local signature = type(k) .. "_" .. type(v)
			local handler = LSP_HANDLERS[signature]

			if handler then
				local lsp = handler(k, v)

				if lsp then
					index[lsp.name] = lsp.config
				end
			else
				log.err("Invalid LSP declaration (%s)", signature)
			end
		end

		log.dbg("STARTING SERVERS")

		local on_attach = lsp_config.get_on_attach()

		for lsp_name, config in pairs(index) do
			log.dbg("STARTING SERVER: %s", lsp_name)

			local final_config = vim.deepcopy(config)
			if on_attach then
				final_config.on_attach = on_attach
			end

			if not vim.lsp.is_enabled(lsp_name) then
				vim.lsp.config(lsp_name, final_config)
				vim.lsp.enable(lsp_name)
			end
		end
	end,
}
