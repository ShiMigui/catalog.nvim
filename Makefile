.PHONY: test test-verbose test-file clean lint format-check format check hooks

# Run all tests
test:
	nvim --headless -u tests/minimal_init.lua -c "PlenaryBustedDirectory tests/"

# Run all tests with verbose output
test-verbose:
	nvim --headless -u tests/minimal_init.lua -c "PlenaryBustedDirectory tests/ --verbose"

# Run a specific test file
test-file:
	nvim --headless -u tests/minimal_init.lua -c "PlenaryBustedFile $(FILE)"

# Clean generated files
clean:
	rm -rf tests/plenary/
	find . -name "Session.vim" -delete
	find . -name ".netrwhist" -delete

# Run luacheck linter
lint:
	luacheck lua/

# Check formatting with stylua
format-check:
	stylua --check lua/ tests/

# Format code with stylua
format:
	stylua lua/ tests/

# Run all checks (lint, format, test)
check: lint format-check test
	@echo "✅ All checks passed!"

# Activate the versioned git hooks (pre-commit + commit-msg) for this clone
hooks:
	git config core.hooksPath .githooks
