DEBUG = false
local util = require "util"
local Stack = require "stack"
local Bracket = require "bracket"
local StringReader = require "string_reader"
--[[-------------------------------------------------------------------------]]--
function is_word_char(c)
	local word_regex = "[a-zA-Z0-9_-]"
	if type(c) ~= "string" then
		return nil
	end
	return c:match("^" .. word_regex .. "$")
end
--[[-------------------------------------------------------------------------]]--
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
--[[-------------------------------------------------------------------------]]--
function command_pos(filename)
	local str = util.getfilestring(filename)
	local it = str:gmatch("ls")
	local val = nil
	repeat 
		val = it()
	until val == nil
	f:close()
end
--[[-------------------------------------------------------------------------]]--
function getchar(str, index)
	assert(str:len() >= index)
	return str:sub(index, index)
end
--[[-------------------------------------------------------------------------]]--
function make_option_helper(short_options, map)
	local option_helper = {}

	for k,v in pairs(short_options) do
		if map[v] ~= nil then
			option_helper[#option_helper+1] = "--" .. map[v]
		else
			option_helper[#option_helper+1] = "-" .. v
		end
	end
	return option_helper
end
--[[-------------------------------------------------------------------------]]--
function replace_options(text, index, option_map)
	local before = text:sub(0, index-1)
	local options = {}
	local i = index+1
	local c = text[i]
	repeat
		options[#options+1] = c
		i = i+1
		c = text[i]
	until not is_word_char(c)
	local lastchar = c
	local option_helper = make_option_helper(options, option_map)
	local after = text:sub(i, text:len())
	local newtext = before
	if not util.table.empty(option_helper) then
		newtext = newtext .. table.concat(option_helper, " ")
	end
	newtext = newtext .. after
	util.debug(after.text)
	local lendiff = newtext:len() - text:len()
	util.debug("LENDIFF: ", lendiff)
	return newtext, lendiff
end
--[[-------------------------------------------------------------------------]]--
local parse_one = function(text, option_table, word)
	assert(word.word)
	assert(word.pos)
	assert(option_table[word.word] ~= nil)

	local index = word.pos + word.word:len()
	local stack = Stack()
	stack:push("_")
	local len = 0
	local bracket = Bracket(
		{ "{", "(", "[" },
		{ "}", ")", "[" }
	)
	local stringsign = { "'", "\"" }
	local is_stringsign = function(c) return util.table.contains(stringsign, c) end
	local eoc = { "|", "&", ";", "\n" }
	local is_eoc = function(c) return util.table.contains(eoc, c) end
	local whitespace = { " ", "\n", "\t" }
	local is_whitespace = function(c) return util.table.contains(whitespace, c) end

	repeat
		local c = text[index]
		util.debug("c: ", c)
		util.debug("stack: ", stack:top())
		if c == "\\" then
			util.debug("branch a")
			index = index +1
		elseif is_stringsign(stack:top()) and c ~= stack:top() then
			util.debug("branch b")
			-- ignore character
		elseif bracket:is_opening(c) or (is_stringsign(c) and stack:top() ~= c) then
			util.debug("branch c")
			stack:push(c)
		elseif bracket:is_closing(c) or (is_stringsign(c) and stack:top() == c) then
			stack:pop(c)
			util.debug("branch d")
		elseif is_eoc(c) then
			util.debug("branch e")
			return text
		elseif stack:top() == "_" and c == "-" then
			util.debug("branch f")
			if index < 1 then
				util.debug("brach f/1")
				index = index+1
			elseif not is_whitespace(text[index-1]) then
				util.debug("branch f/2")
				index = index+1
			elseif text[index+1] == "-" then
				util.debug("branch f/3")
				index = index+1
			elseif is_word_char(text[index+1]) then
				util.debug("brach f/4")
				text, lendiff = replace_options(text, index, option_table[word.word])
				index = index + lendiff
			end
		end
		index = index+1
	until index == text:len()
	return text
end
--[[-------------------------------------------------------------------------]]--
function parse(text, option_table)
	local str_reader = StringReader(text)
	local word_index = 1
	local wm = nil
	repeat
		wm = word_map(str_reader)
		local cmd = wm[word_index]
		if cmd ~= nil and util.table.haskey(option_table, cmd.word) then
			str_reader = parse_one(str_reader, option_table, cmd)
		end
		word_index = word_index +1
	until word_index > #wm
	return str_reader.text
end
--[[-------------------------------------------------------------------------]]--
return parse

