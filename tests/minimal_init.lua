-- Minimal init for running tests with plenary.nvim.

-- Project root first so `require("catalog")` resolves to the working copy.
vim.opt.rtp:prepend(vim.fn.getcwd())

-- plenary.nvim location differs between CI (vendor pack) and local setups (lazy.nvim).
local data = vim.fn.stdpath("data")
for _, path in ipairs({
	data .. "/site/pack/vendor/start/plenary.nvim",
	data .. "/lazy/plenary.nvim",
}) do
	if vim.fn.isdirectory(path) == 1 then
		vim.opt.rtp:prepend(path)
	end
end
