

local string_reader_meta = {}
string_reader_meta.__index = function(t,k)
	if (type(k) == "number") then
		return t.text:sub(k,k)
	end
	return string_reader_meta[k]
end

string_reader_meta.len = function(t)
	return t.text:len(t)
end

string_reader_meta.sub = function(t, start, ending)
	return t.text:sub(start, ending)
end

string_reader_meta.__tostring = function(t)
	return t.text
end

local TextReader = function(text)
	assert(type(text) == "string")
	local string_reader = { text = text }
	setmetatable(string_reader, string_reader_meta)
	return string_reader
end


return TextReader
