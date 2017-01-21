local _G = require "_G"
local select = _G.select

local vararg = require "vararg"
local len = vararg.len
local pack = vararg.pack

local tuple = require "tuple"
local index = tuple.index

local Nil = {}

local TupleOf = setmetatable({}, {__mode="v"})

local module = {}

function module.tuple(...)
	local id = index
	for i = 1, len(...) do
		local value = select(i, ...)
		if value == nil then value = Nil end
		id = id[value]
	end
	local tuple = TupleOf[id]
	if tuple == nil then
		tuple = pack(...)
		TupleOf[id] = tuple
	end
	return tuple
end

return module

