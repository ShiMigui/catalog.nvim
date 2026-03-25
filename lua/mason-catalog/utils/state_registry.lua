local M = {}
M.states = {}

---@param state string
---@return StateMap
function M.state(state)
	if M.states[state] then
		M.states[state] = {}
	end
	local _s = M.states[state]
	return {
		add = function(k, v)
			_s[k] = v
		end,
		get = function(k)
			return _s[k]
		end,
		get_all = function()
			return _s
		end,
	}
end

return M
