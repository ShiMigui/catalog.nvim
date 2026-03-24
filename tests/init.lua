for k in pairs(package.loaded) do
  if k:match("^mason%-catalog") then
    package.loaded[k] = nil
  end
end

vim.opt.runtimepath:prepend(".")

vim.g.mason_catalog_silent = false
vim.g.mason_catalog_debug = true
