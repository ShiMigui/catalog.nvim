---@class catalog.AutoInstallTools
---@field lsp? string|string[]
---@field formatter? string|string[]
---@field linter? string|string[]

---@type table<string, catalog.AutoInstallTools>
local FT_TOOLS = {
	-- Lua
	lua = {
		lsp = "lua-language-server",
		formatter = "stylua",
		linter = "luacheck",
	},

	-- TypeScript / JavaScript
	typescript = {
		lsp = "typescript-language-server",
		formatter = "prettierd",
		linter = "eslint-ls",
	},
	typescriptreact = {
		lsp = "typescript-language-server",
		formatter = "prettierd",
		linter = "eslint-ls",
	},
	javascript = {
		lsp = "typescript-language-server",
		formatter = "prettierd",
		linter = "eslint-ls",
	},
	javascriptreact = {
		lsp = "typescript-language-server",
		formatter = "prettierd",
		linter = "eslint-ls",
	},
	json = {
		lsp = "json-lsp",
		formatter = "prettierd",
	},
	jsonc = {
		lsp = "json-lsp",
		formatter = "prettierd",
	},

	-- Python
	python = {
		lsp = { "pylsp", "ruff-lsp" },
		formatter = { "black", "isort" },
		linter = { "ruff", "mypy" },
	},

	-- Go
	go = {
		lsp = "gopls",
		formatter = "gofumpt",
		linter = "golangci-lint",
	},
	gomod = {
		lsp = "gopls",
	},
	gowork = {
		lsp = "gopls",
	},

	-- Rust
	rust = {
		lsp = "rust-analyzer",
		formatter = "rustfmt",
	},

	-- C / C++
	c = {
		lsp = "clangd",
		formatter = "clang-format",
		linter = "cpplint",
	},
	cpp = {
		lsp = "clangd",
		formatter = "clang-format",
		linter = "cpplint",
	},

	-- Java
	java = {
		lsp = "jdtls",
		formatter = "google-java-format",
	},

	-- C#
	cs = {
		lsp = "csharp-language-server",
	},

	-- PHP
	php = {
		lsp = "intelephense",
		formatter = "php-cs-fixer",
		linter = { "phpcs", "phpstan" },
	},

	-- Ruby
	ruby = {
		lsp = "ruby-lsp",
		formatter = "rubocop",
		linter = "rubocop",
	},

	-- Haskell
	haskell = {
		lsp = "haskell-language-server",
		formatter = "ormolu",
		linter = "hlint",
	},

	-- Elixir
	elixir = {
		lsp = "elixir-ls",
	},

	-- Erlang
	erlang = {
		lsp = "erlang-ls",
	},

	-- Dart
	dart = {
		lsp = "dartls",
		formatter = "dart-format",
	},

	-- Kotlin
	kotlin = {
		lsp = "kotlin-language-server",
		formatter = "ktfmt",
		linter = "ktlint",
	},

	-- Swift
	swift = {
		formatter = "swiftformat",
		linter = "swiftlint",
	},

	-- Zig
	zig = {
		lsp = "zls",
	},

	-- Nim
	nim = {
		lsp = "nimlangserver",
	},

	-- Scala
	scala = {
		lsp = "metals",
	},

	-- R
	r = {
		lsp = "r-languageserver",
	},

	-- Julia
	julia = {
		lsp = "julialsp",
	},

	-- Shell / Bash
	sh = {
		lsp = "bash-language-server",
		linter = "shellcheck",
	},
	bash = {
		lsp = "bash-language-server",
		linter = "shellcheck",
	},
	zsh = {
		lsp = "bash-language-server",
		linter = "shellcheck",
	},

	-- PowerShell
	ps1 = {
		lsp = "powershell-editor-services",
	},

	-- HTML
	html = {
		lsp = "html-lsp",
		formatter = "prettierd",
	},

	-- CSS
	css = {
		lsp = "css-lsp",
		formatter = "prettierd",
	},
	scss = {
		lsp = "css-lsp",
		formatter = "prettierd",
	},
	less = {
		lsp = "css-lsp",
		formatter = "prettierd",
	},

	-- Sass
	sass = {
		lsp = "some-sass-language-server",
		formatter = "prettierd",
	},

	-- XML
	xml = {
		formatter = "xmlformatter",
	},

	-- YAML
	yaml = {
		lsp = "yaml-language-server",
		linter = "yamllint",
	},
	yml = {
		lsp = "yaml-language-server",
		linter = "yamllint",
	},

	-- TOML
	toml = {
		lsp = "taplo",
	},

	-- Markdown
	markdown = {
		lsp = "marksman",
		linter = "markdownlint",
	},
	markdown_inline = {
		lsp = "marksman",
	},

	-- Docker
	dockerfile = {
		lsp = "dockerfile-language-server",
		linter = "hadolint",
	},

	-- Terraform / HCL
	terraform = {
		lsp = "terraform-ls",
		formatter = "terraform_fmt",
		linter = "tflint",
	},
	hcl = {
		lsp = "terraform-ls",
	},

	-- SQL
	sql = {
		lsp = "sqls",
		formatter = "sql-formatter",
	},

	-- GraphQL
	graphql = {
		lsp = "graphql-language-service-cli",
		formatter = "prettierd",
	},

	-- Protobuf
	proto = {
		lsp = "protols",
		formatter = "buf",
		linter = "protolint",
	},

	-- Nix
	nix = {
		lsp = "nil",
		formatter = "nixfmt",
	},

	-- Elm
	elm = {
		lsp = "elm-language-server",
		formatter = "elm-format",
	},

	-- Clojure
	clojure = {
		lsp = "clojure-lsp",
		linter = "clj-kondo",
	},

	-- F#
	fsharp = {
		lsp = "fsautocomplete",
	},

	-- LaTeX / TeX
	tex = {
		lsp = "texlab",
	},
	latex = {
		lsp = "texlab",
	},

	-- Vue
	vue = {
		lsp = "vue-language-server",
		formatter = "prettierd",
	},

	-- Svelte
	svelte = {
		lsp = "svelte-language-server",
		formatter = "prettierd",
	},

	-- Astro
	astro = {
		lsp = "astro-language-server",
		formatter = "prettierd",
	},

	-- Angular
	angular = {
		lsp = "angular-language-server",
	},

	-- Ember
	ember = {
		lsp = "ember-language-server",
	},

	-- Prisma
	prisma = {
		lsp = "prisma-language-server",
	},

	-- Tailwind CSS
	tailwindcss = {
		lsp = "tailwindcss-language-server",
	},

	-- ESLint
	eslint = {
		lsp = "eslint-ls",
	},

	-- Docker Compose
	["docker-compose"] = {
		lsp = "docker-compose-language-service",
	},

	-- Ansible
	ansible = {
		lsp = "ansible-language-server",
		linter = "ansible-lint",
	},

	-- Helm
	helm = {
		lsp = "helm-ls",
	},

	-- CMake
	cmake = {
		lsp = "cmake-language-server",
		linter = "cmakelint",
	},

	-- Meson
	meson = {
		lsp = "mesonlsp",
	},

	-- Bazel
	bzl = {
		lsp = "bazelrc-lsp",
	},

	-- Groovy
	groovy = {
		lsp = "groovy-language-server",
	},

	-- Kotlin Script
	kscript = {
		lsp = "kotlin-language-server",
	},

	-- V
	v = {
		lsp = "v-analyzer",
	},

	-- Fennel
	fennel = {
		lsp = "fennel-language-server",
	},

	-- Teal
	teal = {
		lsp = "teal-language-server",
	},

	-- Luau
	luau = {
		lsp = "luau-lsp",
	},

	-- WGSL (Shaders)
	wgsl = {
		lsp = "wgsl-analyzer",
	},

	-- GLSL (Shaders)
	glsl = {
		lsp = "glsl_analyzer",
	},

	-- VHDL
	vhdl = {
		lsp = "vhdl_ls",
	},

	-- Verilog / SystemVerilog
	verilog = {
		lsp = "verible",
	},
	systemverilog = {
		lsp = "verible",
	},

	-- Assembly
	asm = {
		lsp = "asm-lsp",
	},

	-- Makefile
	make = {
		linter = "checkmake",
	},

	-- Caddyfile
	caddyfile = {
		lsp = "caddyfile-lsp",
	},

	-- Nginx
	nginx = {
		lsp = "nginx-language-server",
	},

	-- Emacs Lisp
	elisp = {
		lsp = "emmylua_ls",
	},

	-- Lisp
	lisp = {
		lsp = "common-lisp-language-server",
	},

	-- Scheme
	scheme = {
		lsp = "racket-langserver",
	},

	-- Racket
	racket = {
		lsp = "racket-langserver",
	},

	-- OCaml
	ocaml = {
		lsp = "ocamllsp",
		formatter = "ocamlformat",
	},

	-- Reason
	reason = {
		lsp = "reason-language-server",
	},

	-- PureScript
	purescript = {
		lsp = "purescript-language-server",
		formatter = "purescript-tidy",
	},

	-- Idris
	idris = {
		lsp = "idris2-lsp",
	},

	-- Coq
	coq = {
		lsp = "coq-lsp",
	},

	-- Lean
	lean = {
		lsp = "lean-language-server",
	},

	-- Agda
	agda = {
		lsp = "agda-language-server",
	},

	-- ApL
	apl = {
		lsp = "apl-language-server",
	},

	-- Ada
	ada = {
		lsp = "ada-language-server",
	},

	-- Cobol
	cobol = {
		lsp = "cobol-language-support",
	},

	-- Fortran
	fortran = {
		lsp = "fortls",
		formatter = "fprettify",
	},

	-- Pascal
	pascal = {
		lsp = "pascal-language-server",
	},

	-- Delphi
	delphi = {
		lsp = "pascal-language-server",
	},

	-- Objective-C
	objc = {
		lsp = "clangd",
		formatter = "clang-format",
	},

	-- Arduino
	arduino = {
		lsp = "arduino-language-server",
	},

	-- Solidity
	solidity = {
		lsp = "solidity-ls",
		linter = "solhint",
	},

	-- Vyper
	vyper = {
		lsp = "vyper-ls",
	},

	-- Move
	move = {
		lsp = "move-analyzer",
	},

	-- Cairo
	cairo = {
		lsp = "cairo-language-server",
	},

	-- Git
	gitcommit = {
		linter = "commitlint",
	},

	-- ENV
	dotenv = {
		linter = "dotenv-linter",
	},

	-- EditorConfig
	editorconfig = {
		linter = "editorconfig-checker",
	},

	-- Typst
	typst = {
		lsp = "tinymist",
		formatter = "typstyle",
	},

	-- Pandoc Markdown
	pandoc = {
		linter = "vale",
	},

	-- Text
	text = {
		linter = "vale",
	},
}

return FT_TOOLS
