describe("catalog", function()
	local catalog
	local lsp_calls
	local handle_calls

	before_each(function()
		lsp_calls = {}
		handle_calls = {}

		package.loaded["catalog.providers"] = nil
		package.loaded["catalog.providers.mason_provider"] = nil
		package.loaded["catalog.opts.lsp"] = {
			setup = function(block)
				lsp_calls[#lsp_calls + 1] = block
			end,
			copy = function()
				return {}
			end,
		}
		package.loaded["catalog.opts.handle_ft_event"] = {
			setup = function(block)
				handle_calls[#handle_calls + 1] = block
			end,
		}
		package.loaded["catalog"] = nil
		catalog = require("catalog")
	end)

	after_each(function()
		package.loaded["catalog"] = nil
		package.loaded["catalog.opts.lsp"] = nil
		package.loaded["catalog.opts.handle_ft_event"] = nil
	end)

	it("exposes setup", function()
		assert.equals("function", type(catalog.setup))
	end)

	it("does nothing without options", function()
		catalog.setup()
		catalog.setup({})
		assert.equals(0, #lsp_calls)
		assert.equals(0, #handle_calls)
	end)

	it("forwards the lsp option to the lsp module", function()
		local lsp = { default = { flags = {} } }
		catalog.setup({ lsp = lsp })
		assert.equals(1, #lsp_calls)
		assert.are.equal(lsp, lsp_calls[1].payload)
		assert.equals(0, #handle_calls)
	end)

	it("skips an empty lsp option", function()
		catalog.setup({ lsp = {} })
		assert.equals(0, #lsp_calls)
	end)

	it("forwards the handle_ft_event callback to the event module", function()
		local callback = function() end
		catalog.setup({ handle_ft_event = callback })
		assert.equals(1, #handle_calls)
		assert.are.equal(callback, handle_calls[1].payload)
		assert.equals(0, #lsp_calls)
	end)

	it("applies both options when both are given", function()
		catalog.setup({ lsp = { default = {} }, handle_ft_event = function() end })
		assert.equals(1, #lsp_calls)
		assert.equals(1, #handle_calls)
	end)

	it("does not register providers on its own", function()
		catalog.setup({ lsp = { default = {} }, handle_ft_event = function() end })
		assert.is_nil(package.loaded["catalog.providers"])
		assert.is_nil(package.loaded["catalog.providers.mason_provider"])
	end)
end)
