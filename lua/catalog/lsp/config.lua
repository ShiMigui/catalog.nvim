---@alias catalog.capability_provider
---| "blink.cmp"
---| "nvim-cmp"
---
---@class catalog.entry.lsp.config
---@field config? catalog.lsp.config
---@field capabilities? catalog.capability_provider

local log = require("catalog.log").log(...)

---@type catalog.lsp.config
local lsp_default_config = { capabilities = vim.lsp.protocol.make_client_capabilities() }

---@type table<string, fun(): table>
local capability_providers = {
	["blink.cmp"] = function()
		return require("blink.cmp").get_lsp_capabilities()
	end,
	["nvim-cmp"] = function()
		return require("cmp_nvim_lsp").default_capabilities()
	end,
}

---@param provider string
---@return nil
local function apply_provider_capabilities(provider)
	log.dbg("Loading capabilities from '%s'", provider)
	local loader = capability_providers[provider]
	if not loader then
		log.err("Unknown capability provider: %s", provider)
		return
	end

	local ok, capabilities = pcall(loader)
	if not ok then
		log.err("Failed to load capability provider '%s': %s", provider, capabilities)
		return
	end

	log.dbg("Capabilities loaded from '%s'", provider)
	lsp_default_config.capabilities = vim.tbl_deep_extend("force", lsp_default_config.capabilities, capabilities)
end

---@type catalog.integration
return {
	---@param opts? catalog.entry.lsp.config
	setup = function(opts)
		if not opts then
			return
		end

		if type(opts.capabilities) == "string" then
			apply_provider_capabilities(opts.capabilities)
		end

		if type(opts.config) == "table" then
			lsp_default_config = vim.tbl_deep_extend("force", lsp_default_config, opts.config)
		end
	end,

	---@return catalog.lsp.config
	config = function()
		return lsp_default_config
	end,
}
