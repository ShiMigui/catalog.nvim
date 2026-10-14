describe("catalog.providers", function()
	local providers

	before_each(function()
		package.loaded["catalog.providers"] = nil
		providers = require("catalog.providers")
	end)

	---Builds a provider recognizing `known`, counting calls per name.
	---@param name string
	---@param known table<string, boolean>
	---@return catalog.provider, table<string, number>
	local function fake(name, known)
		local calls = {}
		return {
			name = name,
			try_provide = function(_, pkg_name)
				calls[pkg_name] = (calls[pkg_name] or 0) + 1
				if known[pkg_name] then
					return { name = pkg_name, provider_name = name }
				end
			end,
			provide = function(self, pkg_name)
				return self:try_provide(pkg_name)
			end,
		},
			calls
	end

	it("identifies itself as the catalog super-provider", function()
		assert.equals("catalog", providers.name)
	end)

	it("sub returns the super-provider for chaining", function()
		assert.are.equal(providers, providers:sub(fake("p", {})))
	end)

	it("resolves a name through the registered provider", function()
		providers:sub(fake("p", { tool = true }))
		local pkg = providers:try_provide("tool")
		assert.equals("tool", pkg.name)
		assert.equals("p", pkg.provider_name)
	end)

	it("consults providers in order and returns the first hit", function()
		providers:sub(fake("first", { tool = true }))
		providers:sub(fake("second", { tool = true }))
		assert.equals("first", providers:try_provide("tool").provider_name)
	end)

	it("returns the same cached object for repeated hits", function()
		local provider, calls = fake("p", { tool = true })
		providers:sub(provider)
		local a = providers:try_provide("tool")
		local b = providers:try_provide("tool")
		assert.are.equal(a, b)
		assert.equals(1, calls.tool)
	end)

	it("returns nil for names no provider recognizes", function()
		providers:sub(fake("p", {}))
		assert.is_nil(providers:try_provide("ghost"))
	end)

	it("caches misses so providers are not consulted twice", function()
		local provider, calls = fake("p", {})
		providers:sub(provider)
		assert.is_nil(providers:try_provide("ghost"))
		assert.is_nil(providers:try_provide("ghost"))
		assert.equals(1, calls.ghost)
	end)

	it("keeps a cached miss even if a later provider knows the name", function()
		local provider, calls = fake("second", { late = true })
		providers:sub(fake("first", {}))
		assert.is_nil(providers:try_provide("late"))
		providers:sub(provider)
		assert.is_nil(providers:try_provide("late"))
		assert.is_nil(calls.late)
	end)

	it("provide returns the package on a hit", function()
		providers:sub(fake("p", { tool = true }))
		assert.equals("tool", providers:provide("tool").name)
	end)

	it("provide reports a miss through the logger", function()
		local original_notify = vim.notify
		local notified = {}
		vim.notify = function(_, level)
			notified[#notified + 1] = level
		end

		providers:sub(fake("p", {}))
		assert.is_nil(providers:provide("ghost"))

		vim.notify = original_notify
		assert.equals(1, #notified)
		assert.equals(vim.log.levels.ERROR, notified[1])
	end)
end)
