local lsp_config = require("catalog.lsp.lsp_config")
local log = require("catalog.log").log(...)

local TABLE_LSP_ENTRIES = {
    string_table = lsp_config,
    number_string = function(_, name, default)
        return lsp_config(name, nil, default)
    end,
}

local TYPE_ENTRIES = {
    string = function(name, config)
        local p = lsp_config(name, nil, config)
        return p and { p } or nil
    end,
    table  = function(tbl, config)
        local list = {}
        for k, v in pairs(tbl) do
            local tk, tv = type(k), type(v)
            local handler = TABLE_LSP_ENTRIES[tk .. "_" .. tv]
            if handler then
                local p = handler(k, v, config)
                if p then
                    table.insert(list, p)
                end
            else
                log.err("Invalid LSP entry, key %s, value %s", tk, tv)
            end
        end
        return #list > 0 and list or nil
    end
}

---Certifies the input becomes a LSP name list and related packages are installed and with config set
---@param lsp catalog.entry.lsp.spec.lsp_list
---@param config catalog.lsp.config
---@return catalog.pkg.name[]|nil
return function(lsp, config)
    local t = type(lsp)
    local handler = TYPE_ENTRIES[t]
    if handler then
        return handler(lsp, config)
    end
    log.err("Invalid type for lsps, expected string/table, got %s", t)
end
