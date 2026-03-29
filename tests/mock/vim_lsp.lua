local M = {}
---@alias VimLspMock {enabled: boolean, config: LspConfig?}

---@type table<PkgName, VimLspMock>
local lsps = {}

---@param name PkgName
---@return VimLspMock
function M.get(name)
	return lsps[name]
end

---@return table<PkgName, VimLspMock>
function M.get_all()
	return lsps
end

---@param name string
---@return VimLspMock
local function verify_lsp(name)
	if not lsps[name] then
		lsps[name] = { enabled = false, config = nil }
	end
	return lsps[name]
end

function M.setup()
	---@param name PkgName
	---@param config LspConfig
	vim.lsp.config = function(name, config)
		verify_lsp(name).config = config
	end

	---@param name string|string[]
	---@param enable? boolean
	vim.lsp.enable = function(name, enable)
		enable = enable == nil or enable
		if type(name) == "string" then
			name = { name }
		end
		for _, nm in ipairs(name) do
			verify_lsp(nm).enabled = enable
		end
	end
end

function M.reset()
	lsps = {}
end

return M
