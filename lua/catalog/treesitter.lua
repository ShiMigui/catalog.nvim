local log = require("catalog.log").log(...)

---@type catalog.Integration
return {
	setup = function(opts)
		log.header()

		if type(opts) ~= "table" then
			log.err("treesitter options must be a table")
			return
		end

		local ok, ts_install = pcall(function()
			return require("nvim-treesitter.install")
		end)

		if not ok then
			log.err("nvim-treesitter is not installed")
			return
		end

		local parsers = opts.ensure_installed or {}
		if type(parsers) == "string" then
			parsers = { parsers }
		end

		for _, parser in ipairs(parsers) do
			local installed_ok, installed = pcall(function()
				return require("nvim-treesitter.parsers").has_parser(parser)
			end)

			if installed_ok and not installed then
				log.dbg("Installing treesitter parser: %s", parser)
				ts_install.install(parser)
			end
		end

		if opts.config then
			local ts_config = require("nvim-treesitter.configs")
			ts_config.setup(opts.config)
		end

		log.header()
	end,
}
