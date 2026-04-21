local Package = require("mason-catalog.core.Package")
local logger = require("mason-catalog.logger")("LSP Spec normalizer")

local TABLE_ENTRIES = {
	string_table = function(pkg_name, config, default_config)
		return Package.verify_lsp(pkg_name, config, default_config)
	end,
	number_string = function(_, pkg_name, default_config)
		return Package.verify_lsp(pkg_name, nil, default_config)
	end,
}

local TYPE_ENTRIES = {
	string = function(pkg_name, default_config)
		local r = Package.verify_lsp(pkg_name, nil, default_config)
		return r and { r } or nil
	end,

	table = function(tbl, default_config)
		local list = {}
		for k, v in pairs(tbl) do
			local tk, tv = type(k), type(v)
			local handler = TABLE_ENTRIES[tk .. "_" .. tv]

			if not handler then
				logger.err("Invalid LspSpec given, got a table with [%s] = [%s]", tk, tv)
				goto continue
			end

			local value = handler(k, v, default_config)
			if value then
				table.insert(list, value)
			end

			::continue::
		end

		return #list > 0 and list or nil
	end,
}

---@param lsp LspSpec
---@param default_config LspConfig
---@return PackageName[]?
return function(lsp, default_config)
	local t = type(lsp)
	local handler = TYPE_ENTRIES[t]
	if handler then
		return handler(lsp, default_config)
	end

	logger.err("Type of LspSpec invalid, it should be a string or table, got '%s'", t)
end
