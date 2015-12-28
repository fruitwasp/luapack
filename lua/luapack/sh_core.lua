luapack = luapack or {}

if CLIENT then
	local suppressLog = true
end

local green = {r = 0, g = 255, b = 0, a = 255}
function luapack.LogMsg(...)
	if CLIENT and suppressLog then return end

	MsgC(green, "[LuaPack] ")
	print(...)
end

local suppressDebug = true
local yellow = {r = 255, g = 255, b = 0, a = 255}
function luapack.DebugMsg(...)
	if suppressDebug then return end

	MsgC(yellow, "[LuaPack] ")
	print(...)
end

function luapack.CanonicalizePath(path)
	path = string.lower(path)
	path = string.gsub(path, "\\", "/")
	path = string.gsub(path, "/+", "/")

	local t = {}
	for str in string.gmatch(path, "([^/]+)") do
		if str == ".." then
			table.remove(t)
		elseif str ~= "." and str ~= "" then
			table.insert(t, str)
		end
	end

	path = table.concat(t, "/")
	return string.match(path, "lua/(.+)$") or (string.match(path, "^gamemodes/(.+)$") or path)
end
