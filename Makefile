.PHONY: test test-verbose test-file clean

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

# Run tests and generate coverage report
coverage:
	nvim --headless -u tests/minimal_init.lua -c "PlenaryBustedDirectory tests/ --coverage" -c "lua require('plenary.coverage').show()"
