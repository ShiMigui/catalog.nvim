describe("catalog.scripts", function()
	describe("ensure_list_of", function()
		local ensure_list_of = require("catalog.scripts.ensure_list_of")

		it("wraps a single matching value into a list", function()
			assert.are_same({ "a" }, ensure_list_of("a", "string"))
		end)

		it("accepts tables whose elements all match", function()
			assert.are_same({ "a", "b" }, ensure_list_of({ "a", "b" }, "string"))
		end)

		it("accepts empty tables as empty lists", function()
			assert.are_same({}, ensure_list_of({}, "string"))
		end)

		it("rejects scalars of another type", function()
			local list, err = ensure_list_of(42, "string")
			assert.is_nil(list)
			assert.equals("string", type(err))
		end)

		it("rejects lists containing mismatched elements", function()
			local list, err = ensure_list_of({ "a", 1 }, "string")
			assert.is_nil(list)
			assert.equals("string", type(err))
		end)
	end)

	describe("ensure_installed", function()
		local provider

		before_each(function()
			package.loaded["catalog.provider"] = nil
			package.loaded["catalog.scripts.ensure_installed"] = nil
			provider = require("catalog.provider")
		end)

		it("resolves, installs and returns requested packages once", function()
			local installs = {}
			provider.append("fake", function(name)
				return {
					name = name,
					provider_name = "fake",
					installed = function()
						return false
					end,
					install = function(self)
						installs[self.name] = (installs[self.name] or 0) + 1
					end,
				}
			end)

			local ensure_installed = require("catalog.scripts.ensure_installed")
			local map = ensure_installed({ "tool" })
			assert.equals("tool", map.tool.name)
			assert.equals(1, installs.tool)

			map = ensure_installed({ "tool" })
			assert.not_nil(map.tool)
			assert.equals(1, installs.tool)
		end)

		it("omits packages that cannot be resolved", function()
			provider.append("fake", function()
				return nil
			end)

			local ensure_installed = require("catalog.scripts.ensure_installed")
			assert.are_same({}, ensure_installed({ "ghost" }))
			assert.are_same({}, ensure_installed({ "ghost" }))
		end)
	end)
end)
