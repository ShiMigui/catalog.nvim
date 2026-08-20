---@class catalog.AutoInstallTools
---@field lsp? string|string[]
---@field conform? string|string[]
---@field lint? string|string[]

---@type table<string, catalog.AutoInstallTools>
local FT_TOOLS = {
	-- Lua
	lua = {
		lsp = "lua-language-server",
		conform = "stylua",
		lint = "luacheck",
	},

	-- TypeScript / JavaScript
	typescript = {
		lsp = "typescript-language-server",
		conform = "prettierd",
		lint = "eslint-ls",
	},
	typescriptreact = {
		lsp = "typescript-language-server",
		conform = "prettierd",
		lint = "eslint-ls",
	},
	javascript = {
		lsp = "typescript-language-server",
		conform = "prettierd",
		lint = "eslint-ls",
	},
	javascriptreact = {
		lsp = "typescript-language-server",
		conform = "prettierd",
		lint = "eslint-ls",
	},
	json = {
		lsp = "json-lsp",
		conform = "prettierd",
	},
	jsonc = {
		lsp = "json-lsp",
		conform = "prettierd",
	},

	-- Python
	python = {
		lsp = { "pylsp", "ruff-lsp" },
		conform = { "black", "isort" },
		lint = { "ruff", "mypy" },
	},

	-- Go
	go = {
		lsp = "gopls",
		conform = "gofumpt",
		lint = "golangci-lint",
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
		conform = "rustfmt",
	},

	-- C / C++
	c = {
		lsp = "clangd",
		conform = "clang-format",
		lint = "cpplint",
	},
	cpp = {
		lsp = "clangd",
		conform = "clang-format",
		lint = "cpplint",
	},

	-- Java
	java = {
		lsp = "jdtls",
		conform = "google-java-format",
	},

	-- C#
	cs = {
		lsp = "csharp-language-server",
	},

	-- PHP
	php = {
		lsp = "intelephense",
		conform = "php-cs-fixer",
		lint = { "phpcs", "phpstan" },
	},

	-- Ruby
	ruby = {
		lsp = "ruby-lsp",
		conform = "rubocop",
		lint = "rubocop",
	},

	-- Haskell
	haskell = {
		lsp = "haskell-language-server",
		conform = "ormolu",
		lint = "hlint",
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
		conform = "dart-format",
	},

	-- Kotlin
	kotlin = {
		lsp = "kotlin-language-server",
		conform = "ktfmt",
		lint = "ktlint",
	},

	-- Swift
	swift = {
		conform = "swiftformat",
		lint = "swiftlint",
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
		lint = "shellcheck",
	},
	bash = {
		lsp = "bash-language-server",
		lint = "shellcheck",
	},
	zsh = {
		lsp = "bash-language-server",
		lint = "shellcheck",
	},

	-- PowerShell
	ps1 = {
		lsp = "powershell-editor-services",
	},

	-- HTML
	html = {
		lsp = "html-lsp",
		conform = "prettierd",
	},

	-- CSS
	css = {
		lsp = "css-lsp",
		conform = "prettierd",
	},
	scss = {
		lsp = "css-lsp",
		conform = "prettierd",
	},
	less = {
		lsp = "css-lsp",
		conform = "prettierd",
	},

	-- Sass
	sass = {
		lsp = "some-sass-language-server",
		conform = "prettierd",
	},

	-- XML
	xml = {
		conform = "xmlformatter",
	},

	-- YAML
	yaml = {
		lsp = "yaml-language-server",
		lint = "yamllint",
	},
	yml = {
		lsp = "yaml-language-server",
		lint = "yamllint",
	},

	-- TOML
	toml = {
		lsp = "taplo",
	},

	-- Markdown
	markdown = {
		lsp = "marksman",
		lint = "markdownlint",
	},
	markdown_inline = {
		lsp = "marksman",
	},

	-- Docker
	dockerfile = {
		lsp = "dockerfile-language-server",
		lint = "hadolint",
	},

	-- Terraform / HCL
	terraform = {
		lsp = "terraform-ls",
		conform = "terraform_fmt",
		lint = "tflint",
	},
	hcl = {
		lsp = "terraform-ls",
	},

	-- SQL
	sql = {
		lsp = "sqls",
		conform = "sql-formatter",
	},

	-- GraphQL
	graphql = {
		lsp = "graphql-language-service-cli",
		conform = "prettierd",
	},

	-- Protobuf
	proto = {
		lsp = "protols",
		conform = "buf",
		lint = "protolint",
	},

	-- Nix
	nix = {
		lsp = "nil",
		conform = "nixfmt",
	},

	-- Elm
	elm = {
		lsp = "elm-language-server",
		conform = "elm-format",
	},

	-- Clojure
	clojure = {
		lsp = "clojure-lsp",
		lint = "clj-kondo",
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
		conform = "prettierd",
	},

	-- Svelte
	svelte = {
		lsp = "svelte-language-server",
		conform = "prettierd",
	},

	-- Astro
	astro = {
		lsp = "astro-language-server",
		conform = "prettierd",
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
	docker-compose = {
		lsp = "docker-compose-language-service",
	},

	-- Ansible
	ansible = {
		lsp = "ansible-language-server",
		lint = "ansible-lint",
	},

	-- Helm
	helm = {
		lsp = "helm-ls",
	},

	-- CMake
	cmake = {
		lsp = "cmake-language-server",
		lint = "cmakelint",
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

	-- Nim
	nim = {
		lsp = "nimlangserver",
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
		lint = "checkmake",
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
		conform = "ocamlformat",
	},

	-- Reason
	reason = {
		lsp = "reason-language-server",
	},

	-- PureScript
	purescript = {
		lsp = "purescript-language-server",
		conform = "purescript-tidy",
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
		conform = "fprettify",
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
		conform = "clang-format",
	},

	-- Arduino
	arduino = {
		lsp = "arduino-language-server",
	},

	-- Solidity
	solidity = {
		lsp = "solidity-ls",
		lint = "solhint",
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

	-- Rust (additional)
	toml = {
		lsp = "taplo",
	},

	-- Dockerfile
	dockerfile = {
		lsp = "dockerfile-language-server",
		lint = "hadolint",
	},

	-- Git
	gitcommit = {
		lint = "commitlint",
	},

	-- ENV
	dotenv = {
		lint = "dotenv-linter",
	},

	-- EditorConfig
	editorconfig = {
		lint = "editorconfig-checker",
	},

	-- Typst
	typst = {
		lsp = "tinymist",
		conform = "typstyle",
	},

	-- Pandoc Markdown
	pandoc = {
		lint = "vale",
	},

	-- Text
	text = {
		lint = "vale",
	},

	-- Git Commit
	gitcommit = {
		lint = "commitlint",
	},

	-- GitHub Actions
	yaml = {
		lsp = "yaml-language-server",
		lint = "actionlint",
	},

	-- Neovim Config
	lua = {
		lsp = "lua-language-server",
		conform = "stylua",
		lint = "luacheck",
	},
}

return FT_TOOLS
