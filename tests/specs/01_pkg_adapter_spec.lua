local mock = {
	registry = require("tests.mock.mason_registry").setup(),
}
local registry = mock.registry.get_registry()

local cache = require("mason-catalog.core.pkg.cache")
local pkg_adapter = require("mason-catalog.core.pkg.adapter")

local lua_ls_name = "lua-language-server"

describe("PkgAdapter", function()
	before_each(function()
		mock.registry.reset()
		cache._clear()
	end)

	it("returns a package from registry", function()
		local pkg = pkg_adapter.get_package(lua_ls_name)
		assert.is_not_nil(pkg)
		assert.equals(lua_ls_name, pkg.name)
	end)

	it("converts lsp name correctly", function()
		local pkg = pkg_adapter.get_package(lua_ls_name)
		assert.is_not_nil(pkg.lsp)
		assert.equals("lua_ls", pkg.lsp.name)
	end)

	it("returns same instance from cache", function()
		assert.are.equal(pkg_adapter.get_package(lua_ls_name), pkg_adapter.get_package(lua_ls_name))
	end)

	it("stores package in cache", function()
		assert.are.equal(pkg_adapter.get_package(lua_ls_name), cache.get_package(lua_ls_name))
	end)

	it("returns nil for invalid package", function()
		assert.is_nil(pkg_adapter.get_package("invalid-package"))
	end)

	it("install calls underlying install", function()
		local pkg = pkg_adapter.install(lua_ls_name)

		assert.is_not_nil(pkg)
		assert.is_true(registry.get_package(lua_ls_name):is_installed())
	end)

	it("install does not reinstall if already installed", function()
		local pkg = pkg_adapter.install(lua_ls_name)
		local pkg2 = pkg_adapter.install(lua_ls_name)

		assert.are.equal(pkg, pkg2)
		assert.is_true(registry.get_package(lua_ls_name):is_installed())
	end)

	it("returns nil when installing invalid package", function()
		assert.is_nil(pkg_adapter.install("invalid-package"))
	end)
end)
