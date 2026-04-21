local function format(scope, msg, ...)
	if select("#", ...) > 0 then
		msg = msg:format(...)
	end
	return scope .. msg
end
return format
