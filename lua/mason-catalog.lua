return {
	setup = function()
		vim.cmd("LspStart lua_ls")
		vim.opt.rtp:prepend(vim.fn.getcwd())
		print("IT IS RUNNING")
	end,
}
