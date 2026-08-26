describe("catalog.provider.mason", function()
	local provider

	before_each(function()
		for _, module in ipairs({ "mason-registry", "catalog.provider", "catalog.provider.mason" }) do
			package.loaded[module] = nil
		end
		provider = require("catalog.provider")
	end)

	---Stubs mason-registry with one package and registers the mason provider.
	---@param opts { name: string, lspconfig: string|nil, installed: boolean, installs: table<string, number>, lookups: string[] }
	---@return table fake The raw mason package object handed to the registry.
	local function register_mason(opts)
		local fake = {
			name = opts.name,
			spec = { neovim = { lspconfig = opts.lspconfig } },
			is_installed = function()
				return opts.installed
			end,
			install = function()
				opts.installs[opts.name] = (opts.installs[opts.name] or 0) + 1
			end,
		}
		package.loaded["mason-registry"] = {
			get_package = function(name)
				table.insert(opts.lookups, name)
				if name ~= opts.name then
					error("Unknown package: " .. name) -- mirrors real mason-registry behavior
				end
				return fake
			end,
			get_installed_packages = function()
				return { fake }
			end,
		}
		require("catalog.provider.mason")
		return fake
	end

	it("surfaces mason-registry errors for names outside the registry", function()
		register_mason({ name = "x", lspconfig = nil, installed = false, installs = {}, lookups = {} })

		-- documented caveat: get_package raises on unknown names, and the
		-- provider passes it through instead of converting it into a miss
		local ok, _ = pcall(provider.try_provide, "ghost")
		assert.is_false(ok)
	end)

	it("provides packages carrying an lsp handle when mapped", function()
		register_mason({
			name = "lua-language-server",
			lspconfig = "lua_ls",
			installed = false,
			installs = {},
			lookups = {},
		})

		local pkg = provider.provide("lua-language-server")
		assert.equals("mason", pkg.provider_name)
		assert.equals("lua_ls", pkg.lsp.name)
	end)

	it("provides packages without an lsp handle when unmapped", function()
		register_mason({ name = "marksman", lspconfig = nil, installed = false, installs = {}, lookups = {} })

		assert.is_nil(provider.provide("marksman").lsp)
	end)

	it("install delegates to the registry and skips already-installed packages", function()
		local installs, lookups = {}, {}
		local opts = { name = "stylua", lspconfig = nil, installed = false, installs = installs, lookups = lookups }
		register_mason(opts)
		local pkg = provider.provide("stylua")

		pkg:install()
		opts.installed = true -- simulate the install having landed
		pkg:install()

		assert.equals(1, installs.stylua)
	end)

	it("load_installed seeds the cache without consulting the registry", function()
		local lookups = {}
		register_mason({
			name = "lua-language-server",
			lspconfig = "lua_ls",
			installed = true,
			installs = {},
			lookups = lookups,
		})

		provider.load_installed()

		local pkg = provider.try_provide("lua-language-server")
		assert.equals("mason", pkg.provider_name)
		assert.equals(0, #lookups)
	end)
end)
