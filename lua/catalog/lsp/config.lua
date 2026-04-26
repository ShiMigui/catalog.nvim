local log = require("catalog.log").log(...)
local lsp_default_config

local CAPABILITY_PROVIDERS = {
	["blink.cmp"] = function()
		return pcall(function()
			return require("blink.cmp").get_lsp_capabilities()
		end)
	end,
	["nvim-cmp"] = function()
		return pcall(function()
			return require("cmp_nvim_lsp").default_capabilities()
		end)
	end,
}

---@class catalog.entry.lsp.config
---@field config? catalog.lsp.config
---@field capabilities? "nvim-cmp"|"blink.cmp"

local function resolve_capabilities(cap, user_config)
	if type(cap) ~= "string" then
		return
	end

	local default = vim.lsp.protocol.make_client_capabilities()
	local fn = CAPABILITY_PROVIDERS[cap]
	if not fn then
		log.err("Invalid capabilities provider %s", cap)
		return default
	end

	local ok, m = fn()
	if not ok or not m then
		log.err("Capability provider not installed or inaccessible! %s", cap)
		return default
	end

	local user_caps = user_config and user_config.capabilities or {}

	return vim.tbl_deep_extend("force", default, m, user_caps)
end

---@type catalog.integration
return {
	---Stores and mutate config with default providers
	---@param opts catalog.entry.lsp.config
	setup = function(opts)
		if opts then
			local user_config = opts.config or {}
			local capabilities = resolve_capabilities(opts.capabilities, user_config)

			lsp_default_config = vim.tbl_deep_extend("force", user_config, { capabilities = capabilities })
		end
	end,
	config = function()
		return lsp_default_config
	end,
}
