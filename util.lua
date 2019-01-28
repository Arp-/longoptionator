

local util = {}

util.read_man = function(cmd)
	local tmpfile = os.tmpname()
	local ok = os.execute("man " .. cmd .. " > " .. tmpfile)
	if not ok then
		io.stderr:write("couldn't get manpage for command: " .. cmd)
		return nil
	end

	local file = io.open(tmpfile, "r")

	return file
end

util.option_table = function(manpage)
	local line = manpage:read("l")
	local table = {}
	while (line ~= nil) do
		s,l = line:match('^%s+%-(%w+),.+%-%-(%w+)')
		if (s ~= nil and l ~= nil) then
			table[s]=l
		end
		line = manpage:read("l")
	end
	return table
end

util.table = {}

util.table.contains = function(table, val)
	for k,v in pairs(table) do
		if val == v then
			return true
		end
	end
	return nil
end

util.table.index = function(table, val)
	for k,v in pairs(table) do
		if v == val then return k end
	end
	return nil
end

util.table.empty = function(table)
	return next(table,k) == nil
end




return util
