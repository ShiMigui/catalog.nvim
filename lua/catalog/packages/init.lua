---Package entities for catalog.nvim.
---
---[Package](lua://catalog.packages.package) builds the base
---[catalog.package](lua://catalog.package). Specialized entities such as
---[Lsp](lua://catalog.packages.lsp) and
---[Formatter](lua://catalog.packages.formatter) extend that base in place, so
---the specialized object stays a package. Build the base first, then
---specialize:
---
---```lua
---local entity = require("catalog.packages")
---
---local pkg = entity.Package("mason", "lua-language-server", nil, install, installed)
---entity.Lsp(pkg)
---```
return {
	Package = require("catalog.packages.package"),
	Lsp = require("catalog.packages.lsp"),
	Formatter = require("catalog.packages.formatter"),
}
