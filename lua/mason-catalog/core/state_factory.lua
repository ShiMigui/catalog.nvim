---@generic K, V
---@class state<K, V>
---@field get fun(k:K): V?
---@field clear fun(): nil
---@field all fun(): table<K, V>
---@field set fun(k:K, v:V): nil

---@generic K, V
---@param initial_value? table<K, V>
---@param verify_fn? fun(k:K, v:V): boolean
---@return state<K,V>
return function(initial_value, verify_fn)
	local state = initial_value or {}
	local m = {}

	local function raw_set(k, v)
		if k then
			state[k] = v
		end
	end

	function m.clear()
		for k in pairs(state) do
			state[k] = nil
		end
	end

	function m.get(k)
		return state[k]
	end

	m.set = verify_fn and function(k, v)
		if verify_fn(k, v) then
			raw_set(k, v)
		end
	end or raw_set

	function m.all()
		return state
	end

	return m
end
