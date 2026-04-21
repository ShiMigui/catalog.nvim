local cache = {}
return function(ext)
	if cache[ext] then
		return cache[ext]
	end

	local ft = vim.filetype.match({ filename = "file." .. ext })
	cache[ext] = ft
	return ft
end
