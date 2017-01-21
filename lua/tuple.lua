-- Project: Lua Tuple
-- Release: 1.0 alpha
-- Title  : Internalized Tokens that Represent a Tuple of Values
-- Author : Renato Maia <maia@inf.puc-rio.br>


local _G = require "_G"
local select = _G.select
local setmetatable = _G.setmetatable
local tostring = _G.tostring

local array = require "table"
local concat = array.concat
local unpacktab = array.unpack



-- from a tuple to its values (weak mode == "k")
local WeakKeys = {__mode="k"}
local ParentOf = setmetatable({}, WeakKeys)
local ValueOf = setmetatable({}, WeakKeys)
local LengthOf = setmetatable({}, WeakKeys)

local function pack(tuple)
	local values = {}
	local length = LengthOf[tuple]
	for i = length, 1, -1 do
		tuple, values[i] = ParentOf[tuple], ValueOf[tuple]
	end
	return values
end

local function unpack(tuple)
	return unpacktab(pack(tuple))
end

local function length(tuple)
	return LengthOf[tuple]
end



-- from values to a tuple (weak mode == "kv")
local Tuple = {__mode="kv", __len=length}

function Tuple:__index(value)
	local tuple = setmetatable({}, Tuple)
	ParentOf[tuple] = self
	ValueOf[tuple] = value
	LengthOf[tuple] = LengthOf[self]+1
	self[value] = tuple
	return tuple
end

function Tuple:__call(i)
	if i == nil then return unpack(self) end
	local length = LengthOf[self]
	if i == "#" then return length end
	if i > 0 then i = i-length-1 end
	if i < 0 then
		for _ = 1, -i-1 do
			self = ParentOf[self]
		end
		return ValueOf[self]
	end
end

function Tuple:__tostring()
	local values = {}
	for i = LengthOf[self], 1, -1 do
		self, values[i] = ParentOf[self], tostring(ValueOf[self])
	end
	return "("..concat(values, ", ")..")"
end

local index = setmetatable({}, Tuple) -- main tuple that represents the empty tuple
LengthOf[index] = 0

local function istuple(value)
	return getmetatable(value) == Tuple
end

local function totuple(value)
	if not istuple(value) then
		return index[value]
	end
	return value
end

local module = {
	index = index,
	istuple = istuple,
	totuple = totuple,
	unpack = unpack,
	len = length,
}

-- find a tuple given its values
function module.create(...)
	local tuple = index
	for i = 1, select("#", ...) do
		tuple = tuple[select(i, ...)]
	end
	return tuple
end

function module.concat(value, ...)
	local tuple = totuple(value)
	for index = 1, select("#", ...) do
		value = select(index, ...)
		if istuple(value) then
			for _, value in ipairs(pack(value)) do
				tuple = tuple[value]
			end
		else
			tuple = tuple[value]
		end
	end
	return tuple
end

function module.emptystate()
	if  (_G.next(ParentOf) == nil)
	and (_G.next(ValueOf) == nil)
	and (_G.next(LengthOf) == index and _G.next(LengthOf, index) == nil)
	and (_G.next(index) == nil) then
		return true
	end
	--[[
	local Viewer = _G.require "loop.debug.Viewer"
	Viewer:print("ParentOf ", ParentOf)
	Viewer:print("ValueOf  ", ValueOf)
	Viewer:print("LengthOf ", LengthOf)
	Viewer:print("index    ", index)
	--]]
	return false
end


return module
