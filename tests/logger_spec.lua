local levels = vim.log.levels

describe("catalog.logger", function()
	local logger
	local notified
	local original_notify = vim.notify

	before_each(function()
		package.loaded["catalog.logger"] = nil
		logger = require("catalog.logger")

		notified = {}
		vim.notify = function(msg, level)
			notified[#notified + 1] = { msg = msg, level = level }
		end
	end)

	after_each(function()
		vim.notify = original_notify
	end)

	---@return string[]
	local function messages()
		local out = {}
		for _, entry in ipairs(notified) do
			out[#out + 1] = entry.msg
		end
		return out
	end

	---@param level integer
	---@return string?
	local function last(level)
		for i = #notified, 1, -1 do
			if notified[i].level == level then
				return notified[i].msg
			end
		end
	end

	describe("New", function()
		it("exposes the four logging levels", function()
			local log = logger.New("test")
			for _, level in ipairs({ "DBG", "INF", "WRN", "ERR" }) do
				assert.equals("function", type(log[level]))
			end
		end)

		it("caches one instance per scope", function()
			assert.are.equal(logger.New("a"), logger.New("a"))
			assert.are_not.equal(logger.New("a"), logger.New("b"))
		end)

		it("stamps messages with the scope and the status code", function()
			logger.New("test"):INF("hello")
			assert.equals("[test] INF hello", last(levels.INFO))
		end)
	end)

	describe("levels", function()
		it("notifies INFO, WARN and ERROR by default", function()
			local log = logger.New("test")
			log:INF("i")
			log:WRN("w")
			log:ERR("e")
			assert.equals("[test] INF i", last(levels.INFO))
			assert.equals("[test] WRN w", last(levels.WARN))
			assert.equals("[test] ERR e", last(levels.ERROR))
		end)

		it("suppresses DEBUG by default", function()
			logger.New("test"):DBG("hidden")
			assert.equals(0, #notified)
		end)

		it("emits DEBUG once enabled", function()
			logger.Status.DBG = true
			logger.New("test"):DBG("shown")
			assert.equals("[test] DBG shown", last(levels.DEBUG))
		end)

		it("maps each status to its Neovim log level", function()
			logger.Status.DBG = true
			local log = logger.New("test")
			log:DBG("d")
			log:INF("i")
			log:WRN("w")
			log:ERR("e")
			assert.equals(levels.DEBUG, notified[1].level)
			assert.equals(levels.INFO, notified[2].level)
			assert.equals(levels.WARN, notified[3].level)
			assert.equals(levels.ERROR, notified[4].level)
		end)
	end)

	describe("formatting", function()
		it("interpolates arguments", function()
			logger.New("fmt"):INF("resolved %d for %s", 3, "lua")
			assert.equals("[fmt] INF resolved 3 for lua", last(levels.INFO))
		end)

		it("keeps literal percent signs when there are no arguments", function()
			logger.New("fmt"):INF("progress 100%")
			assert.equals("[fmt] INF progress 100%", last(levels.INFO))
		end)

		it("does not format suppressed messages", function()
			local ok = pcall(function()
				logger.New("fmt"):DBG("bad %d %s", "not-a-number")
			end)
			assert.is_true(ok)
			assert.equals(0, #notified)
		end)
	end)

	describe("NewIn", function()
		it("skips a nil payload", function()
			local called = false
			logger.NewIn(nil, function()
				called = true
			end, "scope")
			assert.is_false(called)
		end)

		it("skips an empty table payload", function()
			local called = false
			logger.NewIn({}, function()
				called = true
			end, "scope")
			assert.is_false(called)
		end)

		it("runs the callback with the payload and a logging block", function()
			local seen
			logger.NewIn({ name = "pkg" }, function(block)
				seen = block
			end, "scope")
			assert.are_same({ name = "pkg" }, seen.payload)
			assert.equals("table", type(seen.log))
			assert.equals("function", type(seen.log.INF))
		end)

		it("accepts a non-table truthy payload", function()
			local seen
			logger.NewIn(function() end, function(block)
				seen = block.payload
			end, "scope")
			assert.equals("function", type(seen))
		end)

		it("indents while a block is active and restores afterwards", function()
			logger.Status.DBG = true
			logger.NewIn({ 1 }, function(block)
				block.log:INF("inside")
			end, "scope")
			logger.New("scope"):INF("outside")

			assert.are_same({
				"  [scope] DBG initing...",
				"  [scope] INF inside",
				"  [scope] DBG finishing...",
				"[scope] INF outside",
			}, messages())
		end)

		it("nests indentation and unwinds one level per block", function()
			logger.Status.DBG = true
			logger.NewIn({ 1 }, function()
				logger.NewIn({ 2 }, function(inner)
					inner.log:INF("deep")
				end, "inner")
			end, "outer")

			assert.are_same({
				"  [outer] DBG initing...",
				"    [inner] DBG initing...",
				"    [inner] INF deep",
				"    [inner] DBG finishing...",
				"  [outer] DBG finishing...",
			}, messages())
		end)

		it("restores indentation and re-raises when the callback errors", function()
			logger.Status.DBG = true
			local ok = pcall(logger.NewIn, { 1 }, function()
				error("boom")
			end, "scope")
			assert.is_false(ok)

			notified = {}
			logger.New("scope"):INF("after")
			assert.are_same({ "[scope] INF after" }, messages())
		end)
	end)
end)
