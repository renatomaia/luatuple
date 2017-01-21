local tuples = require "tuple"
local tuple = tuples.create

local wtuples = require "tuple.weak"
local wtuple = wtuples.create
local setwkey = wtuples.setkey
local getwkey = wtuples.getkey

local vtuples = require "tuple.vararg"
local vtuple = vtuples.tuple

local function newvalue(label)
	--[[
	return setmetatable({}, { __tostring = function() return label end })
	--[=[]]
	return label
	--]=]
end

local function collectall()
	local after = collectgarbage("count")
	repeat
		local before = after
		collectgarbage()
		after = collectgarbage("count")
	until after >= before
	return after
end

local function emptymodules(what)
	if what == "no" then
		assert(not tuples.emptystate() or not wtuples.emptystate())
	else
		assert(tuples.emptystate() and wtuples.emptystate())
	end
end

do
	print("\n--- Table ------------------------------------------------------\n")
emptymodules()
	local map = {}
	map[tuple(1,2,3)        ] = "%(1, 2, 3%)"
	map[tuple("A","B","C")  ] = "%(A, B, C%)"
	map[tuple({},{},{})     ] = "%(table: 0x%x+, table: 0x%x+, table: 0x%x+%)"
	map[tuple(true,{},false)] = "%(true, table: 0x%x+, false%)"
collectall()
	assert(map[tuple(1,2,3)      ] == "%(1, 2, 3%)")
	assert(map[tuple("A","B","C")] == "%(A, B, C%)")
	for tuple, value in pairs(map) do
		assert(string.match(tostring(tuple), value))
		map[tuple] = nil
	end
collectall()
emptymodules()
end

do
	print("\n--- Weak Values ------------------------------------------------\n")
emptymodules()
	local map = setmetatable({}, {__mode="v"})
	local A,B,C = newvalue("a"), newvalue("b"), newvalue("c")
	local strong = newvalue("strong")
	map[tuple(1,2,3)        ] = "strong"
	map[tuple(A,B,C)        ] = "strong"
	map[tuple({},{},{})     ] = "strong"
	map[tuple(true,{},false)] = "strong"
	map[tuple(3,2,1)        ] = strong
	map[tuple(C,B,A)        ] = strong
	map[tuple(false,{},true)] = strong
	map[tuple("A","B","C")  ] = {}
	map[tuple({},{},{})     ] = {}
	map[tuple(true,{},false)] = {}
collectall()
	assert(map[tuple(1,2,3)] == "strong")
	assert(map[tuple(A,B,C)] == "strong")
	assert(map[tuple(3,2,1)] == strong)
	assert(map[tuple(C,B,A)] == strong)
	for tuple, value in pairs(map) do
		assert(tostring(value) == "strong")
		if type(tuple(2)) == "table" then
			map[tuple] = nil
		end
	end
	map[tuple(1,2,3)] = nil
	map[tuple(A,B,C)] = nil
	map[tuple(3,2,1)] = nil
	map[tuple(C,B,A)] = nil
	assert(next(map) == nil)
collectall()
emptymodules()
end

do
	print("\n--- Weak Keys --------------------------------------------------\n")
emptymodules()
	local map = setmetatable({}, {__mode="k"})
	setwkey(map, wtuple(1,2,3)        , "1,2,3")
	setwkey(map, wtuple({},{},{})     , "{},{},{}")
	setwkey(map, wtuple(true,{},false), "true,{},false")
collectall()
	assert(getwkey(map, wtuple(1,2,3)) == "1,2,3")
	do
		local tuple, value = next(map)
		assert(value == "1,2,3")
		assert(tuple(1) == 1)
		assert(tuple(2) == 2)
		assert(tuple(3) == 3)
		assert(next(map, tuple) == nil)
	end
	setwkey(map, wtuple(1,2,3), nil)
collectall()
emptymodules()
end

do
	print("\n--- Weak Table -------------------------------------------------\n")
emptymodules()
	local map = setmetatable({}, {__mode="kv"})
	local A,B,C = newvalue("a"), newvalue("b"), newvalue("c")
	local strong = newvalue("strong")
	setwkey(map, wtuple(1,2,3)        , "strong")
	setwkey(map, wtuple(A,B,C)        , "strong")
	setwkey(map, wtuple({},{},{})     , "strong")
	setwkey(map, wtuple(true,{},false), "strong")
	setwkey(map, wtuple(3,2,1)        , strong)
	setwkey(map, wtuple(C,B,A)        , strong)
	setwkey(map, wtuple(false,{},true), strong)
	setwkey(map, wtuple("A","B","C")  , {})
	setwkey(map, wtuple({},{},{})     , {})
	setwkey(map, wtuple(true,{},false), {})
collectall()
	assert(getwkey(map, wtuple(1,2,3)) == "strong")
	assert(getwkey(map, wtuple(A,B,C)) == "strong")
	assert(getwkey(map, wtuple(3,2,1)) == strong)
	assert(getwkey(map, wtuple(C,B,A)) == strong)
	for tuple, value in pairs(map) do
		assert(tostring(value) == "strong")
		assert(type(tuple(2)) ~= "table")
	end
	setwkey(map, wtuple(1,2,3), nil)
	setwkey(map, wtuple(3,2,1), nil)
	setwkey(map, wtuple(A,B,C), nil)
	setwkey(map, wtuple(C,B,A), nil)
collectall()
emptymodules()
end

do
	print("\n--- Vararg Tuples --------------------------------------------\n")
	do
		local A,B,C = newvalue("A"), newvalue("B"), newvalue("C")
		t1 = vtuple(A,B,C)
		local v1,v2,v3 = t1()
		assert(v1 == A)
		assert(v2 == B)
		assert(v3 == C)
		assert(t1(1) == A)
		assert(t1(2) == B)
		assert(t1(3) == C)
		assert(t1("#") == 3)
		assert(select("#", t1()) == 3)
	end
	collectall()
	emptymodules("no")
	do
		local A,B,C = t1()
		t2 = vtuple(A,B,C)
		assert(rawequal(t1, t2))
	end
	collectall()
	emptymodules("no")
	do
		local A,B = t1()
		t3 = vtuple(A,B)
		local v1,v2 = t3()
		assert(v1 == A)
		assert(v2 == B)
		assert(t3(1) == A)
		assert(t3(2) == B)
		assert(t3("#") == 2)
		assert(select("#", t3()) == 2)
		assert(not rawequal(t1, t3))
	end
	collectall()
	emptymodules("no")
	do
		local A,B = t1()
		t4 = vtuple(A,B,nil)
		local v1,v2,v3 = t4()
		assert(v1 == A)
		assert(v2 == B)
		assert(v3 == nil)
		assert(t4(1) == A)
		assert(t4(2) == B)
		assert(t4(3) == nil)
		assert(t4("#") == 3)
		assert(select("#", t4()) == 3)
		assert(not rawequal(t1, t4))
		assert(not rawequal(t3, t4))
	end
	collectall()
	emptymodules("no")
	do
		local A,B = t1()
		t5 = vtuple(A,B,nil)
		assert(rawequal(t4, t5))
	end
	collectall()
	emptymodules("no")
	do
		t6 = vtuple(nil,nil,nil)
		local v1,v2,v3 = t6()
		assert(v1 == nil)
		assert(v2 == nil)
		assert(v3 == nil)
		assert(t6(1) == nil)
		assert(t6(2) == nil)
		assert(t6(3) == nil)
		assert(t6("#") == 3)
		assert(select("#", t6()) == 3)
	end
	t1str = tostring(t1)
	t3str = tostring(t3)
	t4str = tostring(t4)
	t6str = tostring(t6)
	A,B,C = t1()
	t1,t2,t3,t4,t5,t6 = nil,nil,nil,nil,nil,nil
	collectall()
	emptymodules()
	do
		--local A,B,C = newvalue("A"), newvalue("B"), newvalue("C")
		local compares = {
			[t1str] = vtuple(A,B,C),
			[t3str] = vtuple(A,B),
			[t4str] = vtuple(A,B,nil),
			[t6str] = vtuple(nil,nil,nil),
		}
		for oldstr, tuple in pairs(compares) do
			if oldstr == tostring(tuple) then
				print(oldstr.." was reallocated in the same old address")
			else
				print(oldstr.." was reallocated in "..tostring(tuple))
			end
		end
		--A,B,C = nil,nil,nil
	end
end

