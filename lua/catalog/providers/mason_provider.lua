---Provider backed by the mason-registry.
---
---Requires `require("mason").setup()` to have been called beforehand, as it
---is what registers the registry sources that provide package specs. When the
---registry has no local cache yet, the provider refreshes it once on the first
---lookup so names resolve without a prior `:Mason` run.
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

---Whether the registry sources were already loaded.
local registry_checked = false

---Ensures the registry has its local cache loaded before a lookup.
---
---`require("mason").setup()` only registers the sources; resolving a package
---reads the on-disk registry cache that `:Mason` or a previous refresh
---populates. On a first run that cache is missing, so `has_package` would
---miss every name and the super provider would cache those misses for the
---whole session.
---
---`refresh()` without a callback is synchronous, so it guarantees the cache
---exists when it returns. It is only called when a source is not installed,
---which keeps the network stall off the common path; when the provider is
---required before `mason.setup()`, the source list is still empty and the
---check runs again on the first lookup.
local function ensure_registry()
	if registry_checked then
		return
	end

	local sources = mason_registry.sources
	if not sources or sources:size() == 0 then
		return
	end
	if sources:is_all_installed() then
		registry_checked = true
		return
	end

	log:INF("mason-registry has no local cache, refreshing...")
	local ok, err = mason_registry.refresh()
	if not ok then
		log:WRN("could not refresh mason-registry: %s", vim.inspect(err))
	end
	registry_checked = true
end

ensure_registry()

---Converts a mason package into a [catalog.package](lua://catalog.package).
---
---`exec_name` is always the language-server name when the package maps to one
---(`spec.neovim.lspconfig`), otherwise the first `spec.bin` entry, otherwise
---the package name.
---
---Language servers get the [Lsp](lua://catalog.packages.lsp) entity so
---[enable](lua://catalog.lsp.enable) can register and enable them, and
---packages in the `Formatter` category get the
---[Formatter](lua://catalog.packages.formatter) entity so they can register
---with conform.nvim.
---@param pkg Package A mason-registry package object.
---@return catalog.package
local function convert(pkg)
	local spec = pkg.spec
	local lspconfig = spec.neovim and spec.neovim.lspconfig
	local bin = next(spec.bin or {})

	---@param self catalog.package
	local function install(self)
		if self:installed() then
			log:DBG("Package '%s' is already installed", self.name)
			return
		end

		log:INF("Installing package '%s'...", self.name)
		pkg:install()
	end

	local base = entity.Package(providerName, pkg.name, lspconfig or bin or pkg.name, install, function()
		return pkg:is_installed()
	end)

	if lspconfig then
		entity.Lsp(base)
	end

	for _, category in ipairs(spec.categories or {}) do
		if category == "Formatter" then
			entity.Formatter(base)
		end
	end

	return base
end

---@type catalog.provider
return {
	name = providerName,
	try_provide = function(_, name)
		ensure_registry()
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
