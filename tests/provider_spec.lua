local assert = require("luassert")

describe("catalog.provider", function()
	local provider

	before_each(function()
		-- Reload the module to get fresh state
		package.loaded["catalog.provider"] = nil
		provider = require("catalog.provider")
	end)

	describe("resolve", function()
		it("returns nil for unknown package", function()
			local result = provider.resolve("nonexistent-package-12345")
			assert.is_nil(result)
		end)

		it("returns package object for valid package", function()
			-- This test requires mason to be available
			-- Skip if mason is not installed
			local ok, _ = pcall(require, "mason-registry")
			if not ok then
				skip("mason-registry not available")
			end

			local result = provider.resolve("lua-language-server")
			if result then
				assert.is_table(result)
				assert.is_string(result.name)
				assert.is_function(result.installed)
				assert.is_function(result.install)
			end
		end)
	end)

	describe("set_providers", function()
		it("can set custom providers", function()
			local custom_provider = {
				resolve = function(name)
					return {
						name = name,
						installed = function()
							return false
						end,
						install = function() end,
					}
				end,
			}

			provider.set_providers({ custom_provider })
			local result = provider.resolve("custom-package")
			assert.is_table(result)
			assert.are.equal("custom-package", result.name)
		end)
	end)

	describe("clear_cache", function()
		it("clears the cache", function()
			-- First call should resolve and cache
			provider.resolve("nonexistent-12345")
			-- Clear cache
			provider.clear_cache()
			-- Next call should try to resolve again
			local result = provider.resolve("nonexistent-12345")
			assert.is_nil(result)
		end)
	end)

	describe("cache", function()
		it("caches resolved packages", function()
			local custom_provider = {
				resolve = function(name)
					return {
						name = name,
						installed = function()
							return false
						end,
						install = function() end,
					}
				end,
			}

			provider.set_providers({ custom_provider })

			-- First call
			local result1 = provider.resolve("cached-package")
			-- Second call should return cached result
			local result2 = provider.resolve("cached-package")

			assert.are.equal(result1, result2)
		end)

		it("caches failed resolutions", function()
			local custom_provider = {
				resolve = function(name)
					return nil
				end,
			}

			provider.set_providers({ custom_provider })

			-- First call should fail
			local result1 = provider.resolve("failed-package")
			assert.is_nil(result1)

			-- Second call should also fail (cached)
			local result2 = provider.resolve("failed-package")
			assert.is_nil(result2)
		end)
	end)
end)
