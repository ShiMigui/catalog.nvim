---Provider backed by the mason-registry.
---
---Requires `require("mason").setup()` to have been called beforehand, as it
---is what registers the registry sources that provide package specs.
---
---Requiring this module registers the provider under `"MasonProvider"`.
local masonRegistry = require("mason-registry")
local lspConfig = require("catalog.Lsp.Config")
local log = require("catalog.log").new("MasonProvider")

---Converts a mason package into a [catalog.Pkg](lua://catalog.Pkg).
---
---The `lsp` field is only set for packages categorized as LSP; the server
---name is taken from `pkg.spec.neovim.lspconfig`.
---@param pkg Package
---@return catalog.Pkg
local function convert(pkg)
	local spec = pkg.spec
	local nvim = spec.neovim or {}

	return {
		name = pkg.name,
		lsp = nvim.lspconfig and lspConfig.new(nvim.lspconfig) or nil,
		installed = function()
			return pkg:is_installed()
		end,
		---@param self catalog.Pkg
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

require("catalog.Providers").append("MasonProvider", function(name)
	return convert(masonRegistry.get_package(name))
end)
