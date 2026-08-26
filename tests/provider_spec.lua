describe("catalog.provider", function()
	local provider

	before_each(function()
		package.loaded["catalog.provider"] = nil
		provider = require("catalog.provider")
	end)

	---Registers a fake provider providing the names in `known`, counting
	---invocations per name.
	---@param known table<string, boolean>
	---@return table<string, number> calls
	local function register_fake(known)
		local calls = {}
		provider.append({
			name = "fake",
			provide = function(name)
				calls[name] = (calls[name] or 0) + 1
				if known[name] then
					return { name = name, provider_name = "fake" }
				end
				return nil
			end,
			load_installed = function()
				return {}
			end,
		})
		return calls
	end

	it("appends providers and provides packages through them", function()
		register_fake({ known = true })
		local pkg = provider.provide("known")
		assert.equals("known", pkg.name)
		assert.equals("fake", pkg.provider_name)
	end)

	it("caches hits so the provider runs once per package", function()
		local calls = register_fake({ known = true })
		provider.provide("known")
		provider.provide("known")
		assert.equals(1, calls.known)
	end)

	it("returns nil for unknown packages and notifies an error", function()
		local original_notify = vim.notify
		local notified = {}
		vim.notify = function(msg, level)
			table.insert(notified, { msg = msg, level = level })
		end

		register_fake({})
		assert.is_nil(provider.provide("ghost"))
		assert.equals(vim.log.levels.ERROR, notified[1].level)

		vim.notify = original_notify
	end)

	it("try_provide caches misses as false without notifying", function()
		local original_notify = vim.notify
		local notified = {}
		vim.notify = function(msg, level)
			table.insert(notified, { msg = msg, level = level })
		end

		local calls = register_fake({})
		assert.is_false(provider.try_provide("ghost"))
		assert.is_false(provider.try_provide("ghost"))
		assert.equals(1, calls.ghost)
		assert.equals(0, #notified)

		vim.notify = original_notify
	end)

	it("load_installed seeds the cache so packages are provided without lookups", function()
		local pkg = { name = "cached", provider_name = "fake" }
		local looked_up = false
		provider.append({
			name = "fake",
			provide = function()
				looked_up = true
				return nil
			end,
			load_installed = function()
				return { cached = pkg }
			end,
		})

		provider.load_installed()
		assert.equals(pkg, provider.try_provide("cached"))
		assert.is_false(looked_up)
	end)
end)
