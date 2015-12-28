luapack.gamemodeRegister = luapack.gamemodeRegister or gamemode.Register
luapack.weaponsOnLoaded = luapack.weaponsOnLoaded or weapons.OnLoaded
luapack.scripted_entsOnLoaded = luapack.scripted_entsOnLoaded or scripted_ents.OnLoaded

local function removeExtension(filename)
	return string.match(filename, "([^%.]+).lua")
end

local function loadAutorun()
	local files = file.Find("autorun/*.lua", "LUA")
	for i = 1, #files do
		include("autorun/" .. files[i])
	end

	files = file.Find("autorun/client/*.lua", "LUA")
	for i = 1, #files do
		include("autorun/client/" .. files[i])
	end
end

local function loadPostProcess()
	local files = file.Find("postprocess/*.lua", "LUA")
	for i = 1, #files do
		include("postprocess/" .. files[i])
	end
end

local function loadVGUI()
	local files = file.Find("vgui/*.lua", "LUA")
	for i = 1, #files do
		include("vgui/" .. files[i])
	end
end

local function loadMatProxy()
	local files = file.Find("matproxy/*.lua", "LUA")
	for i = 1, #files do
		include("matproxy/" .. files[i])
	end
end

local function loadWeapon(obj)
	local name = obj:IsDirectory() and obj:GetPath() or removeExtension(obj:GetPath())

	SWEP = {
		Base = "weapon_base",
		Primary = {},
		Secondary = {}
	}

	if obj:IsDirectory() then
		SWEP.Folder = obj:GetFullPath()

		local initobj = obj:GetSingle("cl_init.lua")
		if initobj == nil or initobj:IsDirectory() then
			initobj = obj:GetSingle("shared.lua")
		end

		if initobj ~= nil and initobj:IsFile() then
			CompileString(initobj:GetContents(), initobj:GetFullPath())()
		end
	else
		SWEP.Folder = obj:GetParent():GetFullPath()

		CompileString(obj:GetContents(), obj:GetFullPath())()
	end

	weapons.Register(SWEP, name)

	SWEP = nil
end

local function loadWeapons()
	local files, folders = luapack.RootDirectory:Get("weapons/*")
	for i = 1, #files do
		loadWeapon(files[i])
	end

	for i = 1, #folders do
		loadWeapon(folders[i])
	end
end

local function loadEntity(obj)
	local name = obj:IsDirectory() and obj:GetPath() or removeExtension(obj:GetPath())

	ENT = {}

	if obj:IsDirectory() then
		ENT.Folder = obj:GetFullPath()

		local initobj = obj:GetSingle("cl_init.lua")
		if initobj == nil or initobj:IsDirectory() then
			initobj = obj:GetSingle("shared.lua")
		end

		if initobj ~= nil and initobj:IsFile() then
			CompileString(initobj:GetContents(), initobj:GetFullPath())()
		end
	else
		ENT.Folder = obj:GetParent():GetFullPath()

		CompileString(obj:GetContents(), obj:GetFullPath())()
	end

	scripted_ents.Register(ENT, name)

	ENT = nil
end

local function loadEntities()
	local files, folders = luapack.RootDirectory:Get("entities/*")
	for i = 1, #files do
		loadEntity(files[i])
	end

	for i = 1, #folders do
		loadEntity(folders[i])
	end
end

local function loadEffect(obj)
	local name = obj:IsDirectory() and obj:GetPath() or removeExtension(obj:GetPath())

	EFFECT = {}

	if obj:IsDirectory() then
		EFFECT.Folder = obj:GetFullPath()

		local initobj = obj:GetSingle("init.lua")
		if initobj ~= nil and initobj:IsFile() then
			CompileString(initobj:GetContents(), initobj:GetFullPath())()
		end
	else
		EFFECT.Folder = obj:GetParent():GetFullPath()

		CompileString(obj:GetContents(), obj:GetFullPath())()
	end

	effects.Register(EFFECT, name)

	EFFECT = nil
end

local function loadEffects()
	local files, folders = luapack.RootDirectory:Get("effects/*")
	for i = 1, #files do
		loadEffect(files[i])
	end

	for i = 1, #folders do
		loadEffect(folders[i])
	end
end

gamemode.Register = function(gm, name, base)
	luapack.LogMsg("Registering gamemode '" .. name .. "' with base '" .. base .. "'.")

	local ret = luapack.gamemodeRegister(gm, name, base)

	if name == "base" then
		loadAutorun()
		loadPostProcess()
		loadVGUI()
		loadMatProxy()

		-- these use a very simple system, no inheritance, no nothing
		-- let's hope we can load them directly
		-- load them after base just to be safe
		loadEffects()
	end

	return ret
end

function weapons.OnLoaded()
	loadWeapons()
	return luapack.weaponsOnLoaded()
end

function scripted_ents.OnLoaded()
	loadEntities()
	return luapack.scripted_entsOnLoaded()
end
