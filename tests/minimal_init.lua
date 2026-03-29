vim.opt.rtp:append(vim.fn.stdpath("data") .. "/lazy/plenary.nvim")
local root = vim.fn.getcwd()

package.path = package.path .. ";" .. root .. "/tests/?.lua"
package.path = package.path .. ";" .. root .. "/tests/?/init.lua"

require("plenary.busted")
vim.cmd("PlenaryBustedDirectory tests/specs")
