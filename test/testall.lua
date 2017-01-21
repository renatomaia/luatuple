local array = require "table"
local tuple = require "tuple"

do -- tuple.create
	local w = setmetatable({}, {__mode = "k"})
	local t = {}
	local function f() return t end
	local c = coroutine.create(f)
	local u = assert(io.tmpfile())
	local function checktuple(...)
		local t = tuple.create(...)
		assert(rawequal(t, tuple.create(...)))
		assert(w[t] == nil)
		w[t] = tostring(t)
	end
	u:close()
	checktuple(false)
	checktuple(true)
	checktuple(false, true)
	checktuple(false, 0, "")
	checktuple(0)
	checktuple(0, 0)
	checktuple("")
	checktuple("", "")
	checktuple(1, 2, 3)
	checktuple("a", "b", "c")
	checktuple(t)
	checktuple(f)
	checktuple(c)
	checktuple(u)
	checktuple(t, t)
	checktuple(f, f)
	checktuple(c, c)
	checktuple(u, u)
	checktuple(t, false, t)
	checktuple(f, false, f)
	checktuple(c, false, c)
	checktuple(u, false, u)
	checktuple(t, f, c, u)
	t, f, c, u = nil, nil, nil, nil
	collectgarbage()
	assert(next(w) == nil)
end
