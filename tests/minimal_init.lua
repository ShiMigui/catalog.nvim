-- Minimal init for running tests with plenary.nvim

-- Add plugin to runtime path
vim.opt.runtimepath:append(".")

-- Add plenary.nvim to runtime path (assuming it's installed)
-- You may need to adjust this path based on your setup
local plenary_path = vim.fn.stdpath("data") .. "/lazy/plenary.nvim"
if vim.fn.isdirectory(plenary_path) == 1 then
	vim.opt.runtimepath:append(plenary_path)
end

-- Disable swap file and backup for tests
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false

-- Set leader key (required by some plugins)
vim.g.mapleader = " "

-- Load the plugin
require("catalog")
