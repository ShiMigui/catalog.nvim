local state_registry = require('mason-catalog.utils.state_registry')

---@type StateMap<Filetype, NormalizedLsp>
return state_registry.state("lsp_by_ft")
