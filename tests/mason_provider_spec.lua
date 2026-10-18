describe("catalog.providers.mason_provider", function()
	local provider

	---Stubs mason-registry and loads the provider.
	---@param packages table<string, table>
	---@param opts? { installed?: boolean, on_refresh?: fun(): boolean, string }
	local function load(packages, opts)
		opts = opts or {}
		package.loaded["mason-registry"] = {
			has_package = function(name)
				return packages[name] ~= nil
			end,
			get_package = function(name)
				if not packages[name] then
					error("unknown package " .. name)
				end
				return packages[name]
			end,
			sources = {
				size = function()
					return 1
				end,
				is_all_installed = function()
					return opts.installed ~= false
				end,
			},
			refresh = function()
				if opts.on_refresh then
					return opts.on_refresh()
				end
				return true
			end,
		}
		package.loaded["catalog.opts.lsp"] = nil
		package.loaded["catalog.packages"] = nil
		package.loaded["catalog.packages.package"] = nil
		package.loaded["catalog.packages.lsp"] = nil
		package.loaded["catalog.providers.mason_provider"] = nil
		provider = require("catalog.providers.mason_provider")
	end

	---Builds a stand-in for a mason-registry package.
	---@param name string
	---@param spec table
	---@param installed { value: boolean }
	---@return table
	local function mason_package(name, spec, installed)
		return {
			name = name,
			spec = spec,
			is_installed = function()
				return installed.value
			end,
			install = function()
				installed.value = true
			end,
		}
	end

	it("identifies itself as the mason provider", function()
		load({})
		assert.equals("mason", provider.name)
	end)

	it("returns nil for names the registry does not have", function()
		load({})
		assert.is_nil(provider:try_provide("ghost"))
	end)

	it("refreshes the registry when no source is installed", function()
		local original_notify = vim.notify
		local refreshes = 0
		vim.notify = function() end

		load({}, {
			installed = false,
			on_refresh = function()
				refreshes = refreshes + 1
				return true
			end,
		})

		vim.notify = original_notify
		assert.equals(1, refreshes)
	end)

	it("does not refresh the registry when a source is installed", function()
		local refreshes = 0
		load({}, {
			installed = true,
			on_refresh = function()
				refreshes = refreshes + 1
				return true
			end,
		})

		assert.equals(0, refreshes)
	end)

	it("warns once and does not retry when the refresh fails", function()
		local original_notify = vim.notify
		local levels = {}
		local refreshes = 0
		vim.notify = function(_, level)
			levels[#levels + 1] = level
		end

		load({}, {
			installed = false,
			on_refresh = function()
				refreshes = refreshes + 1
				return false, "offline"
			end,
		})
		provider:try_provide("ghost")

		vim.notify = original_notify
		assert.equals(1, refreshes)
		assert.is_true(vim.tbl_contains(levels, vim.log.levels.WARN))
	end)

	it("maps an LSP package to its server name and specializes it", function()
		load({
			["lua-language-server"] = mason_package("lua-language-server", {
				bin = { ["lua-language-server"] = "lua-language-server" },
				neovim = { lspconfig = "lua_ls" },
			}, { value = false }),
		})

		local pkg = provider:try_provide("lua-language-server")
		assert.equals("mason", pkg.provider_name)
		assert.equals("lua-language-server", pkg.name)
		assert.equals("lua_ls", pkg.exec_name)
		assert.is_not_nil(pkg.config)
		assert.equals("function", type(pkg.update))
		assert.equals("function", type(pkg.enable))
	end)

	it("uses the first binary as exec_name for non-LSP packages", function()
		load({
			["custom-tool"] = mason_package("custom-tool", {
				bin = { ["custom-tool"] = "custom-tool" },
			}, { value = false }),
		})

		local pkg = provider:try_provide("custom-tool")
		assert.equals("mason", pkg.provider_name)
		assert.equals("custom-tool", pkg.exec_name)
		assert.is_nil(pkg.config)
	end)

	it("falls back to the package name when the spec has no binary", function()
		load({
			metapackage = mason_package("metapackage", { bin = {} }, { value = false }),
		})

		local pkg = provider:try_provide("metapackage")
		assert.equals("metapackage", pkg.exec_name)
	end)

	it("falls back to the package name when the spec has no bin key", function()
		load({
			metapackage = mason_package("metapackage", {}, { value = false }),
		})

		local pkg = provider:try_provide("metapackage")
		assert.equals("metapackage", pkg.exec_name)
	end)

	it("specializes a Formatter-category package as a formatter", function()
		load({
			["custom-fmt"] = mason_package("custom-fmt", {
				bin = { ["custom-fmt"] = "custom-fmt" },
				categories = { "Formatter" },
			}, { value = false }),
		})

		local pkg = provider:try_provide("custom-fmt")
		assert.equals("custom-fmt", pkg.exec_name)
		assert.is_true(pkg.is_formatter)
		assert.is_false(pkg.is_lsp)
		assert.equals("function", type(pkg.add_to_conform))
	end)

	it("does not specialize a package as a formatter without the category", function()
		load({
			["not-a-fmt"] = mason_package("not-a-fmt", {
				bin = { ["not-a-fmt"] = "not-a-fmt" },
				categories = { "Linter" },
			}, { value = false }),
		})

		local pkg = provider:try_provide("not-a-fmt")
		assert.is_false(pkg.is_formatter)
		assert.is_nil(pkg.add_to_conform)
	end)

	it("mirrors the installed state of the registry package", function()
		local installed = { value = false }
		load({
			tool = mason_package("tool", { bin = { tool = "tool" } }, installed),
		})

		local pkg = provider:try_provide("tool")
		assert.is_false(pkg:installed())
		installed.value = true
		assert.is_true(pkg:installed())
	end)

	it("delegates install to the registry and is idempotent", function()
		local installed = { value = false }
		local installs = 0
		local raw = mason_package("tool", { bin = { tool = "tool" } }, installed)
		raw.install = function()
			installs = installs + 1
			installed.value = true
		end
		load({ tool = raw })

		local pkg = provider:try_provide("tool")
		pkg:install()
		pkg:install()
		assert.equals(1, installs)
	end)

	it("provide reports a miss through the logger", function()
		local original_notify = vim.notify
		local notified = {}
		vim.notify = function(_, level)
			notified[#notified + 1] = level
		end

		load({})
		assert.is_nil(provider:provide("ghost"))

		vim.notify = original_notify
		assert.equals(1, #notified)
		assert.equals(vim.log.levels.ERROR, notified[1])
	end)
end)
