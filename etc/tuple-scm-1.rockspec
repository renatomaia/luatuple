package = "Tuple"
version = "scm-1"
source = {
	url = "https://github.com/renatomaia/luatuple/archive/master.zip",
	dir = "luatuple-master",
}
description = {
	summary = "Tuple of Values for Lua.",
	detailed = [[
		Tuples is a library that provides support for internalized tokens that
		represent a tuple of Lua values.
	]],
	license = "MIT",
	homepage = "https://github.com/renatomaia/luatuple",
}
dependencies = {
	"lua >= 5.1",
}
build = {
	type = "builtin",
	modules = {
		["tuple.weak"] = "lua/tuple/weak.lua",
		["tuple"] = "lua/tuple.lua",
	},
}
