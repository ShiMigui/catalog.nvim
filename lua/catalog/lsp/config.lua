---@class catalog.entry.lsp.config
---@field config? catalog.lsp.config
---@field capabilities? "nvim-cmp"|"blink.cmp"

local log = require("catalog.log").log(...)
local lsp_default_config = {}

local capability_providers = {
	["blink.cmp"] = function()
		return require("blink.cmp").get_lsp_capabilities()
	end,
	["nvim-cmp"] = function()
		return require("cmp_nvim_lsp").default_capabilities()
	end,
}

---@param provider? string
---@return table
local function make_capabilities(provider)
	local default = vim.lsp.protocol.make_client_capabilities()

	if not provider then
		return default
	end

	local fn = capability_providers[provider]

	if not fn then
		log.err("Unknown capability provider: %s", provider)
		return default
	end

	local ok, capabilities = pcall(fn)

	if not ok then
		log.err("Failed to load capability provider '%s': %s", provider, capabilities)
		return default
	end

	return vim.tbl_deep_extend("force", default, capabilities)
end

---@type catalog.integration
return {
	---@param opts catalog.entry.lsp.config
	setup = function(opts)
		opts = opts or {}

		lsp_default_config = vim.tbl_deep_extend("force", {
			capabilities = make_capabilities(opts.capabilities),
		}, opts.config or {})
	end,

	config = function()
		return lsp_default_config
	end,
}
