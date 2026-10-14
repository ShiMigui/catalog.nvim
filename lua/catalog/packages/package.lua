---Base package entity.
---
local log = require("catalog.logger").New("packages.package")

---[Package](lua://catalog.packages.package) builds the
---[catalog.package](lua://catalog.package) shape from provider data. Providers
---supply their own `install` and `installed`, which usually close over a
---provider-specific handle (for example, a mason-registry package).

---Creates the base [catalog.package](lua://catalog.package) for a provider.
---
---Every call returns a new map. `exec_name` defaults to `name` when `nil` is
---passed.
---@param provider_name string Provider that provides this package.
---@param name string Package name understood by that provider.
---@param exec_name? string Executable name; defaults to `name`.
---@param install fun(self: catalog.package) Installs the package.
---@param installed fun(self: catalog.package): boolean Checks whether it is installed.
---@return catalog.package
return function(provider_name, name, exec_name, install, installed)
	log:DBG("Creating package: provider=%s name=%s exec=%s", provider_name, name, tostring(exec_name or name))
	---@type catalog.package
	return {
		provider_name = provider_name,
		name = name,
		exec_name = exec_name or name,
		install = install,
		installed = installed,

		is_lsp = false,
		is_linter = false,
		is_formatter = false,
	}
end
