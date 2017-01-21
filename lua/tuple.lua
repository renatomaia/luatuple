-- Project: Lua Tuple
-- Release: 1.0 alpha
-- Title  : Internalized Tokens that Represent a Tuple of Values
-- Author : Renato Maia <maia@inf.puc-rio.br>


local _G = require "_G"
local select = _G.select
local setmetatable = _G.setmetatable
local tostring = _G.tostring

local table = require "table"
local concat = table.concat
local unpacktab = table.unpack or _G.unpack



-- from a tuple to its values (weak mode == "k")
local WeakKeys = {__mode="k"}
local ParentOf = setmetatable({}, WeakKeys)
local ValueOf = setmetatable({}, WeakKeys)
local SizeOf = setmetatable({}, WeakKeys)

local function pack(tuple)
	local values = {}
	local size = SizeOf[tuple]
	for i = size, 1, -1 do
		tuple, values[i] = ParentOf[tuple], ValueOf[tuple]
	end
	return values
end

local function unpack(tuple)
	return unpacktab(pack(tuple))
end

local function size(tuple)
	return SizeOf[tuple]
end



-- from values to a tuple (weak mode == "kv")
local Tuple = {__mode="kv", __len=size}

function Tuple:__index(value)
	local tuple = setmetatable({}, Tuple)
	ParentOf[tuple] = self
	ValueOf[tuple] = value
	SizeOf[tuple] = SizeOf[self]+1
	self[value] = tuple
	return tuple
end

function Tuple:__call(i)
	if i == nil then return unpack(self) end
	local size = SizeOf[self]
	if i == "#" then return size end
	if i > 0 then i = i-size-1 end
	if i < 0 then
		for _ = 1, -i-1 do
			self = ParentOf[self]
		end
		return ValueOf[self]
	end
end

function Tuple:__tostring()
	local values = {}
	for i = SizeOf[self], 1, -1 do
		self, values[i] = ParentOf[self], tostring(ValueOf[self])
	end
	return "<"..concat(values, ", ")..">"
end

local index = setmetatable({}, Tuple) -- main tuple that represents the empty tuple
SizeOf[index] = 0

local module = {
	index = index,
	unpack = unpack,
	size = size,
}

-- find a tuple given its values
function module.create(...)
	local tuple = index
	for i = 1, select("#", ...) do
		tuple = tuple[select(i, ...)]
	end
	return tuple
end

function module.istuple(value)
	return getmetatable(value) == Tuple
end

function module.totuple(value)
	if getmetatable(value) ~= Tuple then
		value = index[value]
	end
	return value
end

function module.concat(tuple, ...)
	if getmetatable(tuple) ~= Tuple then
		tuple = index[tuple]
	end
	for index = 1, select("#", ...) do
		local other = select(index, ...)
		if getmetatable(other) ~= Tuple then
			tuple = tuple[other]
		else
			for _, value in ipairs(pack(other)) do
				tuple = tuple[value]
			end
		end
	end
	return tuple
end

function module.emptystate()
	if  (_G.next(ParentOf) == nil)
	and (_G.next(ValueOf) == nil)
	and (_G.next(SizeOf) == index and _G.next(SizeOf, index) == nil)
	and (_G.next(index) == nil) then
		return true
	end
	--[[
	local Viewer = _G.require "loop.debug.Viewer"
	Viewer:print("ParentOf ", ParentOf)
	Viewer:print("ValueOf  ", ValueOf)
	Viewer:print("SizeOf   ", SizeOf)
	Viewer:print("index    ", index)
	--]]
	return false
end


return module
