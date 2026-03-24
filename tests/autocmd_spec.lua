package.loaded["mason-catalog.core.lsp.state"] = {
  get = function(ft)
    if ft == "lua" then
      return { lua_ls = {} }
    elseif ft == "empty" then
      return nil
    elseif ft == "multi" then
      return {
        lua_ls = {},
        eslint = {},
      }
    end
  end,
}

vim.lsp = {
  _enabled = {},
  _config_called = {},

  enable = function(name)
    vim.lsp._enabled[name] = true
  end,

  is_enabled = function(name)
    return vim.lsp._enabled[name] == true
  end,

  config = function(name)
    vim.lsp._config_called[name] = true
  end,
}

local autocmd = require("mason-catalog.core.lsp.autocmd")

describe("lsp autocmd", function()
  before_each(function()
    vim.lsp._enabled = {}
    vim.lsp._config_called = {}
  end)

  it("initializes LSP immediately for current filetype", function()
    vim.bo.filetype = "lua"
    autocmd.setup()
    assert.is_true(vim.lsp.is_enabled("lua_ls"))
  end)

  it("initializes LSP on FileType event", function()
    vim.bo.filetype = "lua"
    autocmd.setup()
    vim.api.nvim_exec_autocmds("FileType", { buffer = 0 })
    assert.is_true(vim.lsp.is_enabled("lua_ls"))
  end)

  it("does nothing when no LSP is configured", function()
    vim.bo.filetype = "empty"

    autocmd.setup()
    vim.api.nvim_exec_autocmds("FileType", { buffer = 0 })

    assert.is_nil(vim.lsp._enabled["lua_ls"])
  end)

  it("initializes multiple LSPs", function()
    vim.bo.filetype = "multi"

    autocmd.setup()
    vim.api.nvim_exec_autocmds("FileType", { buffer = 0 })

    assert.is_true(vim.lsp.is_enabled("lua_ls"))
    assert.is_true(vim.lsp.is_enabled("eslint"))
  end)

  it("does not enable LSP twice", function()
    vim.bo.filetype = "lua"

    autocmd.setup()

    vim.api.nvim_exec_autocmds("FileType", { buffer = 0 })
    vim.api.nvim_exec_autocmds("FileType", { buffer = 0 })

    assert.is_true(vim.lsp.is_enabled("lua_ls"))
  end)

  it("handles missing filetype safely", function()
    vim.bo.filetype = ""

    autocmd.setup()

    assert.is_nil(vim.lsp._enabled["lua_ls"])
  end)

  it("applies config when enabling LSP", function()
    vim.bo.filetype = "lua"

    autocmd.setup()

    assert.is_true(vim.lsp._config_called["lua_ls"])
  end)
end)
