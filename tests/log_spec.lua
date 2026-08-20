local assert = require("luassert")

describe("catalog.log", function()
	local log_setup

	before_each(function()
		-- Reload the module to get fresh state
		package.loaded["catalog.log"] = nil
		log_setup = require("catalog.log")
	end)

	describe("set_log", function()
		it("returns the module itself", function()
			local result = log_setup.set_log({}, false, false)
			assert.are.equal(log_setup, result)
		end)

		it("enables debug when debug=true", function()
			log_setup.set_log({}, false, true)
			local log = log_setup.log("test")
			-- Should not error when calling debug
			log.dbg("test message")
		end)

		it("disables warnings when silent_errors=true", function()
			log_setup.set_log({}, true, false)
			local log = log_setup.log("test")
			-- Should not error when calling warn
			log.wrn("test warning")
		end)
	end)

	describe("log", function()
		it("returns a table with all log functions", function()
			local log = log_setup.log("test")
			assert.is_function(log.dbg)
			assert.is_function(log.wrn)
			assert.is_function(log.err)
			assert.is_function(log.inf)
			assert.is_function(log.header)
		end)

		it("header toggles between starting and finishing", function()
			local log = log_setup.log("test")
			-- First call should log "starting"
			log.header()
			-- Second call should log "finishing"
			log.header()
		end)
	end)
end)
