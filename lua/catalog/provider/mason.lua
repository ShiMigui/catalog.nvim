---Provider backed by the mason-registry.
---
---Requires `require("mason").setup()` to have been called beforehand, as it
---is what registers the registry sources that provide package specs.
---
---Requiring this module registers the provider under `"mason"`.
local mason_registry = require("mason-registry")
local lsp_config = require("catalog.lsp.config")
local log = require("catalog.log").new("provider.mason")

---Converts a mason package into a [catalog.Package](lua://catalog.Package).
---
---The `lsp` field is only set for packages categorized as LSP; the server
---name is taken from `pkg.spec.neovim.lspconfig`.
---@param pkg Package
---@return catalog.Package
local function convert(pkg)
	local spec = pkg.spec
	local nvim = spec.neovim or {}

	return {
		name = pkg.name,
		lsp = nvim.lspconfig and lsp_config.new(nvim.lspconfig) or nil,
		installed = function()
			return pkg:is_installed()
		end,
		---@param self catalog.Package
		install = function(self)
			if not self:installed() then
				pkg:install()
				log:inf("%s is being installed", self.name)
				return
			end
			log:dbg("%s is already installed", self.name)
		end,
	}
end

require("catalog.provider").append("mason", function(name)
	return convert(mason_registry.get_package(name))
end)
