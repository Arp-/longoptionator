

local string_reader_meta = {}
--[[-------------------------------------------------------------------------]]--
local TextReader = function(text)
	assert(type(text) == "string")
	local string_reader = { text = text }
	setmetatable(string_reader, string_reader_meta)
	return string_reader
end
--[[-------------------------------------------------------------------------]]--
string_reader_meta.__index = function(t,k)
	if (type(k) == "number") then
		return t.text:sub(k,k)
	end
	return string_reader_meta[k]
end
--[[-------------------------------------------------------------------------]]--
string_reader_meta.len = function(t)
	return t.text:len(t)
end
--[[-------------------------------------------------------------------------]]--
string_reader_meta.sub = function(t, start, ending)
	return TextReader(t.text:sub(start, ending))
end
--[[-------------------------------------------------------------------------]]--
--string_reader_meta.__tostring = function(t)
--	return t.text
--end
--[[-------------------------------------------------------------------------]]--
string_reader_meta.__concat = function(t1,t2)
	assert(type(t1) == "table")
	if type(t2) == "string" then
		return TextReader(t1.text .. t2)
	end
	return TextReader(t1.text .. t2.text)
end
--[[-------------------------------------------------------------------------]]--
return TextReader
