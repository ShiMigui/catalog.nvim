---Provider backed by the mason-registry.
---
---Requires `require("mason").setup()` to have been called beforehand, as it
---is what registers the registry sources that provide package specs.
---
---The module returns a [catalog.provider](lua://catalog.provider). Register it
---with [sub](lua://catalog.super_provider.sub) before resolving its packages:
---
---```lua
---require("catalog.providers"):sub(require("catalog.providers.mason_provider"))
---```
local mason_registry = require("mason-registry")
local entity = require("catalog.packages")
local log = require("catalog.logger").New("providers.mason")
local providerName = "mason"

---Converts a mason package into a [catalog.package](lua://catalog.package).
---
---When the package maps to a language server (`spec.neovim.lspconfig`), that
---server name is used as `exec_name` and the
---[Lsp](lua://catalog.packages.lsp) entity is attached, so
---[enable](lua://catalog.lsp.enable) can register and enable the server.
---Otherwise `exec_name` is the package's first `spec.bin` entry, falling
---back to the package name.
---@param pkg Package A mason-registry package object.
---@return catalog.package
local function convert(pkg)
	local spec = pkg.spec
	local lspconfig = spec.neovim and spec.neovim.lspconfig
	local bin = next(spec.bin) or pkg.name

	---@param self catalog.package
	local function install(self)
		if self:installed() then
			log:DBG("Package '%s' is already installed", self.name)
			return
		end

		log:INF("Installing package '%s'...", self.name)
		pkg:install()
	end

	local base = entity.Package(providerName, pkg.name, lspconfig or bin, install, function()
		return pkg:is_installed()
	end)

	if lspconfig then
		entity.Lsp(base)
	end

	return base
end

---@type catalog.provider
return {
	name = providerName,
	try_provide = function(_, name)
		if mason_registry.has_package(name) then
			return convert(mason_registry.get_package(name))
		end
	end,
	provide = function(self, name)
		local pkg = self:try_provide(name)
		if pkg then
			return pkg
		end
		log:ERR("Package '%s' is not provided by mason", name)
	end,
}
