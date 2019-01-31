
local util = require "util" 
local bracket_meta = {}
bracket_meta.__index = bracket_meta

bracket_meta.is_pair = function(bracket, open, close)
	local opening_index = util.table.index(bracket.opening, open)
	local closing_index = util.table.index(bracket.closing, close)
	if opening_index == nil then
		return nil
	elseif closing_index == opening_index then
		return true
	end
	return false
end

bracket_meta.is_opening = function(bracket, sign)
	return util.table.contains(bracket.opening, sign)
end

bracket_meta.is_closing = function(bracket, sign)
	return util.table.contains(bracket.closing, sign)
end


function Bracket(opening, closing)
	if #opening ~= #closing then
		return nil
	end
	local bracket = { opening = opening, closing = closing }
	setmetatable(bracket, bracket_meta)
	return bracket
end

return Bracket
