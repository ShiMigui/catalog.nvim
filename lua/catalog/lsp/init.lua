local log = require("catalog.log").log(...)
local provider = require("catalog.provider")
local default = require("catalog.lsp.config").config()

---@alias lsp_name string

---filetype -> set<lsp_name>
---@type table<lsp_name, catalog.lsp.config>
local index = {}

vim.api.nvim_create_user_command("CatalogShowLSPs", function()
	local ordered = vim.tbl_keys(index)
	table.sort(ordered)
	for _, lsp_name in ipairs(ordered) do
		log.inf("%s", lsp_name)
	end
end, {})

---@param name catalog.pkg.name
---@param config? catalog.lsp.config
---@return catalog.lsp|nil
local function provide(name, config)
	local pkg = provider.resolve(name)

	if pkg then
		if pkg.lsp then
			pkg.install()
			pkg.lsp:update(config or {}, default)
			return pkg.lsp
		end
		log.err("Package '%s' is not a LSP", name)
	end
end

---@alias input_lsp_entry string | table<string, catalog.lsp.config>

local LSP_HANDLERS = {
	---@type fun(_, pkg_name: string): catalog.lsp?
	number_string = function(_, pkg_name)
		return provide(pkg_name)
	end,

	---@type fun(pkg_name: string, entries: catalog.lsp.config): catalog.lsp?
	string_table = function(pkg_name, config)
		return provide(pkg_name, config)
	end,
}

---@type catalog.integration
return {
	setup = function(opts)
		if type(opts) ~= "table" then
			log.err("Options must be a table")
			return
		end

		for k, v in pairs(opts) do
			local path = type(k) .. "_" .. type(v)
			local handler = LSP_HANDLERS[path]

			if handler then
				local lsp = handler(k, v)
				if lsp then
					index[lsp.name] = lsp.config
				end
			else
				log.err("Invalid LSP type (%s)", path)
			end
		end

		local lsp = vim.lsp
		log.dbg("STARTING SERVERS")
		for lsp_name, config in pairs(index) do
			log.dbg("STARTING SERVER: %s", lsp_name)
			if not lsp.is_enabled(lsp_name) then
				lsp.config(lsp_name, config)
				lsp.enable(lsp_name)
			end
		end
	end,
}
