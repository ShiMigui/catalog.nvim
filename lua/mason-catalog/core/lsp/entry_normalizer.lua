local log = require("mason-catalog.logger").scope(...)
local pkg_adapter = require("mason-catalog.core.pkg.adapter")

---@class LspNormalizer
local M = {}

---Ensures a Mason package is installed and returns its LSP representation.
---Also handles config initialization and merging.
---
---@param pkg_name string            -- Mason package name
---@param default LspConfig          -- Default LSP config
---@param override LspConfig?        -- Optional override config
---@return PkgName?                      -- Resolved LSP object
local function ensure_package_lsp_config(pkg_name, default, override)
	local pkg = pkg_adapter.install(pkg_name)
	if not pkg then
		return
	end

	if not pkg.lsp then
		log.wrn("Package '%s' has no LSP associated", pkg_name)
		return
	end

	-- First time: create config from default
	if not pkg.lsp.config then
		local base = vim.deepcopy(default)
		pkg.lsp.config = override and vim.tbl_deep_extend("force", base, override) or base

		log.dbg("Created config for package '%s'", pkg_name)

	-- Already exists: merge override
	elseif override then
		pkg.lsp.config = vim.tbl_deep_extend("force", pkg.lsp.config, override)
		log.dbg("Updated config for package '%s'", pkg_name)
	end

	return pkg.name
end

---Handles combinations of key/value types inside table LspEntry
---
---Example supported formats:
---  { "lua-language-server" }                      -- list
---  { ["lua-language-server"] = { ...config } }   -- map
---
local ENTRY_TABLE_HANDLERS = {
	string = {
		---@param pkg_name string
		---@param config LspConfig
		---@param default LspConfig
		table = function(pkg_name, config, default)
			return ensure_package_lsp_config(pkg_name, default, config)
		end,
	},

	number = {
		---@param _ number
		---@param pkg_name string
		---@param default LspConfig
		string = function(_, pkg_name, default)
			return ensure_package_lsp_config(pkg_name, default)
		end,
	},
}

local ENTRY_HANDLERS = {
	---Case: single package string
	---
	---@param pkg_name string
	---@param default LspConfig
	---@return PkgName[]|nil
	string = function(pkg_name, default)
		local pkg = ensure_package_lsp_config(pkg_name, default)
		return pkg and { pkg } or nil
	end,

	---Case: table (list or map)
	---
	---@param entry table
	---@param default LspConfig
	---@return PkgName[]|nil
	table = function(entry, default)
		local normalized = {}
		local set = {}

		for key, value in pairs(entry) do
			local handler_by_key = ENTRY_TABLE_HANDLERS[type(key)]
			local handler = handler_by_key and handler_by_key[type(value)]

			if handler then
				local pkg = handler(key, value, default)
				if pkg and not set[pkg] then
					table.insert(normalized, pkg)
					set[pkg] = true
				end
			else
				log.wrn("Invalid LSP entry key/value: %s", tostring(key))
			end
		end

		return normalized[1] and normalized or nil
	end,
}

---Normalizes a user-provided LSP entry into a consistent map:
---
---Input examples:
---  "lua-language-server"
---  { "lua-language-server", "eslint-lsp" }
---  { ["lua-language-server"] = { settings = {} } }
---
---Output:
---  { "lua-language-server", "eslint-lsp" }
---
---@param entry LspEntry
---@param default LspConfig
---@return PkgName[]?
function M.normalize_lsp(entry, default)
	local handler = ENTRY_HANDLERS[type(entry)]

	if not handler then
		log.wrn("Invalid LSP entry: %s", vim.inspect(entry))
		return
	end

	return handler(entry, default)
end

return M
