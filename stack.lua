


local mt = {}
mt.__index = mt

mt.push = function(stack, elem)
	stack[#stack+1] = elem
end

mt.top = function(stack)
	return stack[#stack]
end

mt.len = function(stack)
	return #stack
end

mt.pop = function(stack)
	stack[#stack] = nil
end



local Stack = function()
	local self = {}
	setmetatable(self, mt)
	return self
end

return Stack



