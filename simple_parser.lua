
local inspect = require "inspect"
local util = require "util"
local Stack = require "stack"
local Bracket = require "bracket"
local StringReader = require "string_reader"

-- What do I need
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
		local c = str[index]
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
	local c = text[i]
	repeat
		options[#options+1] = c
		i = i+1
		c = text[i]
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
	return StringReader(newtext), len
end


function parse_command(text, option_table, command_obj)
	if option_table[command_obj.word] == nil then
		return nil
	end
	local index = command_obj.pos + command_obj.word:len()
	local stack = Stack()
	local bracket = Bracket(
		{ "{", "(", "[", "\"", "'" },
		{ "}", ")", "[", "\"", "'" }
	)
	local eoc = { "|", "&", ";", "\n" }

	print("bracket", bracket)
	repeat
		local c = text[index]
		if stack:top() == nil and (util.table.contains(eoc, c) or bracket:is_closing(c)) then
			return text
		elseif stack:top() == "'" and c ~= "'" then
			-- NOP
		elseif stack:top() == "\"" and c ~= "\"" then
			-- NOP
		elseif c == "-" and stack:top() == nil then
			if text[index+1] == "-" then
			elseif is_word_char(c) then
				text, len = helper(text, index, option_table[command_obj.word])
				index = index + len -1
			end
		elseif bracket:is_closing(c) and bracket:is_pair(stack:top(), c) then
			stack:pop()
		elseif bracket:is_opening(c) then
			stack:push(c)
		end
		index = index+1
	until index == text:len()
	return text
end

local str = getfilestring("test.sh")
local str_reader = StringReader(str)
local cmd_table = {}
cmd_table["ls"] = util.option_table(util.read_man("ls"))
cmd_table["grep"] = util.option_table(util.read_man("grep"))
print("grep ", inspect(cmd_table["grep"]))
local word_index = 1
local wm = word_map(str_reader)
repeat
	wm = word_map(str_reader)
	local cmd = wm[word_index]
	if util.table.haskey(cmd_table, cmd.word) then
		str_reader = parse_command(str_reader, cmd_table, cmd)
	end
	word_index = word_index +1
until word_index > #wm

print (str_reader)
--print(inspect(wm))
--print(inspect(command))
--print(inspect(cmd_table))
--print(inspect(a))
