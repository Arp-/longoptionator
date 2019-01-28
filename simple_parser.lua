
local inspect = require "inspect"
local util = require "util"
local Stack = require "stack"

-- What do I neet
-- First I need to look for the command


local word_regex = "[a-zA-Z0-9_-]"

local terminator = ";|"

function is_word_char(c)
	if type(c) ~= "string" then
		return nil
	end
	return c:match("^" .. word_regex .. "$")
end

function word_map(str)
	local words = {}
	local index = 1
	local word = ""
	repeat
		local c = str:sub(index, index)
		if is_word_char(c) then
			word = word .. c
		elseif word ~= "" then
			words[#words+1] = { pos = index - word:len(), word = word }
			word = ""
		end
		index = index+1
	until index >= str:len()
	if word ~= "" then
		words[#words+1] = { pos = index - word:len(), word = word }
		word = ""
	end

	return words
end

function getfilestring(filename)
	local f = io.open(filename, "r")
	if not f then
		return nil
	end
	return f:read("a")
end


function command_pos(filename)

	local str = getfilestring(filename)
	local it = str:gmatch("ls")
	local val = nil
	repeat 
		val = it()
	until val == nil

	

	f:close()

end

function getchar(str, index)
	if str:len() < index then
		return nil -- TODO throw
	end
	return str:sub(index, index)
end

function make_option_helper(short_options, map)
	local option_helper = {}
	local long = {}
	local short = {}
	for _,v in pairs(short_options) do
		if map[v] ~= nil then
			long[#long+1] = map[v]
		else
			short[#short+1] = v
		end
	end
	option_helper.short = short
	option_helper.long = long
	return option_helper
end

function helper(text, index, option_map)
	local before = text:sub(0, index-1)
	local options = {}
	local i = index +1
	local c = getchar(text, i)
	repeat
		options[#options+1] = c
		i = i+1
		c = getchar(text, i)
	until not is_word_char(c)
	local option_helper = make_option_helper(options, option_map)
	local after = text:sub(i, text:len())
	local newtext = before
	if not util.table.empty(option_helper.short) then
		newtext = newtext .. "-" .. (table.concat(option_helper.short, " -")) .. " "
	end
	if not util.table.empty(option_helper.long) then
		newtext = newtext .. "--" .. (table.concat(option_helper.long, " --")) .. " "
	end
	newtext = newtext .. after
	local len = newtext:len() - text:len()
	return newtext, len
end


function parse_command(text, option_table, command_obj)
	if option_table[command_obj.word] == nil then
		return nil
	end
	local index = command_obj.pos + command_obj.word:len()
	local stack = Stack.new()
	local left_brackets = { "{", "(", "[", "\"", "'" }
	local right_brackets = { "}", ")", "[", "\"", "'" }
	local eoc = { "|", "&", ";", "\n" }

	is_pair = function(c_left, c_right)
		local left_index = util.table.index(left_brackets, c_left)
		local right_index = util.table.index(right_brackets, c_right)
		if left_index == nil then
			return nil
		elseif left_index == right_index then
			return left_index
		end
		return false
	end

	repeat
		local c = getchar(text, index)
		if stack:top() == nil and util.table.contains(eoc, c) then
			return text
		elseif stack:top() == "'" and c ~= "'" then
			-- NOP
		elseif stack:top() == "\"" and c ~= "\"" then
			-- NOP
		elseif c == "-" and stack:top() == nil then
			if getchar(text, index+1) == "-" then
			elseif is_word_char(c) then
				text, len = helper(text, index, option_table[command_obj.word])
				index = index + len -1
			end
		elseif util.table.contains(right_brackets, c) and is_pair(stack:top(), c) then
			stack:pop()
		elseif util.table.contains(left_brackets, c) then
			stack:push(c)
		end
		index = index+1
	until index == text:len()
	return text
end

local str = getfilestring("test.sh")
local wm = word_map(str)
local command = wm[3]
local cmd_table = {}
cmd_table["ls"] = util.option_table(util.read_man("ls"))
local a = parse_command(str, cmd_table, command)
print(a)
--print(inspect(wm))
--print(inspect(command))
--print(inspect(cmd_table))
--print(inspect(a))
