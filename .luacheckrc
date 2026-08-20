-- Luacheck configuration for catalog.nvim

std = "lua51"

-- Global variables
globals = {
	"vim",
	"describe",
	"it",
	"before_each",
	"after_each",
	"skip",
}

-- Ignore unused loop variables
ignore = {
	"212", -- unused argument
	"213", -- unused loop variable
}

-- Max line length
max_line_length = 120

-- Files to exclude
exclude_files = {
	"tests/**",
	"docs/**",
}
