local lvls = vim.log.levels

describe("catalog.log", function()
	local original_notify = vim.notify
	local log ---@type table
	---@type { msg: string, level: vim.log.levels }[]
	local notified = {}

	before_each(function()
		package.loaded["catalog.log"] = nil
		log = require("catalog.log")
		notified = {}
		vim.notify = function(msg, level)
			table.insert(notified, { msg = msg, level = level })
		end
	end)

	after_each(function()
		vim.notify = original_notify
	end)

	---@param level vim.log.levels
	---@return string?
	local function last_msg(level)
		for i = #notified, 1, -1 do
			if notified[i].level == level then
				return notified[i].msg
			end
		end
	end

	describe("new", function()
		it("returns a logger with all levels and header", function()
			local logger = log.new("test")
			assert.equals("function", type(logger.dbg))
			assert.equals("function", type(logger.inf))
			assert.equals("function", type(logger.wrn))
			assert.equals("function", type(logger.err))
			assert.equals("function", type(logger.header))
		end)

		it("returns the same logger for the same scope (cache)", function()
			assert.are.equal(log.new("provider"), log.new("provider"))
		end)

		it("returns different loggers for different scopes", function()
			assert.are_not.equal(log.new("a"), log.new("b"))
		end)
	end)

	describe("levels", function()
		it("notifies info by default", function()
			log.new("test"):inf("hello")
			assert.equals("[test] hello", last_msg(lvls.INFO))
		end)

		it("notifies warn by default", function()
			log.new("test"):wrn("careful")
			assert.equals("[test] careful", last_msg(lvls.WARN))
		end)

		it("notifies error by default", function()
			log.new("test"):err("boom")
			assert.equals("[test] boom", last_msg(lvls.ERROR))
		end)

		it("does not notify debug by default", function()
			log.new("test"):dbg("hidden")
			assert.equals(0, #notified)
		end)

		it("passes the correct level to vim.notify", function()
			log.new("test"):inf("msg")
			log.new("test"):wrn("msg")
			log.new("test"):err("msg")
			assert.equals(lvls.INFO, notified[1].level)
			assert.equals(lvls.WARN, notified[2].level)
			assert.equals(lvls.ERROR, notified[3].level)
		end)
	end)

	describe("format", function()
		it("interpolates arguments into the message", function()
			log.new("fmt"):inf("resolved %d package(s) for %s", 3, "lua")
			assert.equals("[fmt] resolved 3 package(s) for lua", last_msg(lvls.INFO))
		end)

		it("keeps the message as-is when no arguments are given", function()
			log.new("fmt"):inf("progress 100%")
			assert.equals("[fmt] progress 100%", last_msg(lvls.INFO))
		end)

		it("does not format when the level is disabled", function()
			log.new("fmt"):dbg("bad format %d %s", "not-a-number")
			assert.equals(0, #notified)
		end)
	end)

	describe("setup", function()
		it("enables debug messages", function()
			log.setup(true)
			log.new("test"):dbg("now visible")
			assert.equals("[test] now visible", last_msg(lvls.DEBUG))
		end)

		it("disables debug messages", function()
			log.setup(true)
			log.setup(false)
			log.new("test"):dbg("hidden again")
			assert.equals(0, #notified)
		end)

		it("disables debug when called without arguments", function()
			log.setup(true)
			log.setup()
			log.new("test"):dbg("hidden")
			assert.equals(0, #notified)
		end)

		it("applies to cached loggers created before setup", function()
			local logger = log.new("early")
			log.setup(true)
			logger:dbg("late config")
			assert.equals("[early] late config", last_msg(lvls.DEBUG))
		end)
	end)

	describe("header", function()
		it("logs starting on the first call", function()
			log.setup(true)
			log.new("hdr"):header()
			assert.equals("[hdr] starting", last_msg(lvls.DEBUG))
		end)

		it("logs finishing on the second call", function()
			log.setup(true)
			local logger = log.new("hdr")
			logger:header()
			logger:header()
			assert.equals("[hdr] finishing", last_msg(lvls.DEBUG))
		end)

		it("alternates starting/finishing on further calls", function()
			log.setup(true)
			local logger = log.new("hdr")
			logger:header()
			logger:header()
			logger:header()
			assert.equals("[hdr] starting", last_msg(lvls.DEBUG))
		end)

		it("shares state between cached loggers of the same scope", function()
			log.setup(true)
			log.new("shared"):header()
			log.new("shared"):header()
			assert.equals("[shared] finishing", last_msg(lvls.DEBUG))
		end)
	end)
end)
