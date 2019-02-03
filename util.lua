
local util = {}
--[[-------------------------------------------------------------------------]]--
util.getfilestring = function(filename)
	local f = io.open(filename, "r")
	if not f then
		return nil
	end
	return f:read("a")
end
--[[-------------------------------------------------------------------------]]--
util.debug = function(...)
	if DEBUG then
		print(arg)
	end
end
--[[-------------------------------------------------------------------------]]--
util.table = {}
--[[-------------------------------------------------------------------------]]--
util.table.contains = function(table, val)
	for k,v in pairs(table) do
		if val == v then
			return true
		end
	end
	return false
end
--[[-------------------------------------------------------------------------]]--
util.table.haskey = function(table, key)
	for k,v in pairs(table) do
		if key == k then
			return true
		end
	end
	return false
end
--[[-------------------------------------------------------------------------]]--
util.table.index = function(table, val)
	for k,v in pairs(table) do
		if v == val then return k end
	end
	return nil
end
--[[-------------------------------------------------------------------------]]--
util.table.empty = function(table)
	return next(table,k) == nil
end
--[[-------------------------------------------------------------------------]]--
return util
