---Formatter package entity.
local log = require("catalog.logger").New("packages.formatter")

---Registers this formatter with [conform.nvim](https://github.com/stevearc/conform.nvim).
---
---Conform resolves formatters in two steps: `conform.formatters` holds one
---configuration per formatter name, and `conform.formatters_by_ft` lists the
---names to run for a filetype. This method writes both, so callers only pass
---the filetype. It defines `conform.formatters[name]` from `exec_name` unless
---the user already configured that name, then appends the name to
---`conform.formatters_by_ft[ft]`. Existing user configuration is preserved:
---the definition is not overwritten and the filetype list is only appended
---to. Requires conform.nvim; logs a warning and does nothing when it is
---unavailable.
---@param self catalog.formatter
---@param ft string Filetype the formatter should run for.
local function add_to_conform(self, ft)
	log:DBG("add_to_conform %s for ft=%s", self.name, ft)
	local ok, conform = pcall(require, "conform")
	if not ok then
		log:WRN("conform.nvim is unavailable, skipping formatter '%s'", self.name)
		return
	end

	-- Define the formatter from its executable unless the user already did.
	-- Conform merges overrides with a matching built-in definition, so built-in
	-- args and metadata are preserved when one exists.
	if conform.formatters[self.name] == nil then
		log:DBG("Defining conform.formatters[%s] with command %s", self.name, self.exec_name)
		conform.formatters[self.name] = { command = self.exec_name }
	end

	local by_ft = conform.formatters_by_ft[ft]
	if by_ft == nil then
		conform.formatters_by_ft[ft] = { self.name }
		return
	end
	if type(by_ft) ~= "table" then
		log:ERR("conform.formatters_by_ft['%s'] is not a list, leaving it unchanged", ft)
		return
	end
	for _, name in ipairs(by_ft) do
		if name == self.name then
			log:DBG("Formatter %s already in conform.formatters_by_ft[%s]", self.name, ft)
			return
		end
	end
	log:DBG("Appending %s to conform.formatters_by_ft[%s]", self.name, ft)
	by_ft[#by_ft + 1] = self.name
end

---Turns a base package into a formatter package by attaching the shared
---`add_to_conform` method.
---@param base catalog.package
---@return catalog.formatter
return function(base)
	---@cast base catalog.formatter
	base.add_to_conform = add_to_conform
	log:DBG("Creating Formatter for %s", base.name)
	base.is_formatter = true
	return base
end
