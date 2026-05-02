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

local function base(cap)
	local default = vim.lsp.protocol.make_client_capabilities()
	local fn = CAPABILITY_PROVIDERS[cap]
	if fn then
		local ok, m = fn()
		if ok and m then
			return vim.tbl_deep_extend("force", default, m)
		end
		log.err("Capability provider not installed or inaccessible! %s", cap)
	end

	return default
end

---@type catalog.integration
return {
	---Stores and mutate config with default providers
	---@param opts catalog.entry.lsp.config
	setup = function(opts)
		lsp_default_config = opts.config or {}
		local capabilities = opts.capabilities

		if capabilities then
			lsp_default_config = vim.tbl_deep_extend("force", { capabilities = base(capabilities) }, lsp_default_config)
		end
	end,
	config = function()
		return lsp_default_config
	end,
}
