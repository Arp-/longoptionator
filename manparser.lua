
local StringReader = require "string_reader"
--[[-------------------------------------------------------------------------]]--
local tab = {}
--[[-------------------------------------------------------------------------]]--
tab.read = function(cmd)
	local tmpfile = os.tmpname()
	local ok = os.execute("man " .. cmd .. " > " .. tmpfile)
	if not ok then
		io.stderr:write("couldn't get manpage for command: " .. cmd)
		return nil
	end
	local file = io.open(tmpfile, "r")
	return file
end
--[[-------------------------------------------------------------------------]]--
tab.make_option_table = function(manpage)
	local line = manpage:read("l")
	local table = {}
	while (line ~= nil) do
		s,l = line:match('^%s+%-(%w+),.+%-%-([%w-]+)')
		if (s ~= nil and l ~= nil) then
			table[s]=l
		end
		line = manpage:read("l")
	end
	return table
end
--[[-------------------------------------------------------------------------]]--
tab.make_table = function(command_list)
	local table = {}
	for _,v in pairs(command_list) do
		local man_text = tab.read(v)
		if not man_text then
			return nil
		end
		local option_table = tab.make_option_table(man_text)
		table[v] = option_table
	end
	return table
end
--[[-------------------------------------------------------------------------]]--
return tab
