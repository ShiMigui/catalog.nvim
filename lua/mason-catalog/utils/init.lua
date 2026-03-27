return {
	setup = function(log)
		local M = {}

		function M.is_a_populated_list(any)
			return vim.islist(any) and any[1]
		end

		function M.is_non_empty_table(any)
			return type(any) == "table" and next(any)
		end

		---@param map table<FileType, LspEntry>
		---@param ft FileType
		---@param entry LspEntry
		function M.push_ft(map, ft, entry)
			if type(ft) ~= "string" then
				return log.wrn("Filetype '%s' is not a string! Ignoring....", vim.inspect(ft))
			end
			map[ft] = entry
		end

		---@param ext FileExtension
		---@return FileType?
		function M.ext_to_ft(ext)
			if type(ext) ~= "string" then
				return log.error("Extension '%s' is not a string! Ignoring...", ext)
			end

			local ft = vim.filetype.match({ extension = ext })
			if not ft then
				log.error("Extension '%s' has no matching filetype! Ignoring...", ext)
			end
			return ft
		end

		return M
	end,
}
