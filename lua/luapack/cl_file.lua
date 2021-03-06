luapack.file = {
	__metatable = false,
	__index = {}
}

local FILE = luapack.file.__index

function FILE:__tostring()
	return self:GetFullPath()
end

function FILE:IsFile()
	return true
end

function FILE:IsDirectory()
	return false
end

function FILE:IsRootDirectory()
	return false
end

function FILE:GetPath()
	return self.path
end

function FILE:GetParent()
	return self.parent
end

function FILE:GetFullPath()
	local paths = {self:GetPath()}
	local parent = self:GetParent()
	while parent ~= nil and not parent:IsRootDirectory() do
		table.insert(paths, 1, parent:GetPath())
		parent = parent:GetParent()
	end

	return table.concat(paths, "/")
end

local CRC_FAIL = -1
local CRC_NOT_CHECKED = 0
local CRC_SUCCESS = 1
function FILE:GetContents()
	local f = self.file
	f:Seek(self.offset)
	local data = f:Read(self.size)
	if data ~= nil then
		data = util.Decompress(data)
	end

	data = data or ""

	if self.crc_checked == CRC_NOT_CHECKED then
		self.crc_checked = tonumber(util.CRC(data)) ~= self.crc and CRC_FAIL or CRC_SUCCESS
	end

	if self.crc_checked == CRC_FAIL then
		error("CRC not matching for file '" .. self:GetFullPath() .. "'")
	end

	return data
end

function FILE:AddFile(name)
	error("not implemented")
end

FILE.AddDirectory = FILE.AddFile
FILE.Get = FILE.AddFile
FILE.GetSingle = FILE.AddFile
FILE.GetList = FILE.AddFile
FILE.GetIterator = FILE.AddFile
FILE.Destroy = FILE.AddFile
