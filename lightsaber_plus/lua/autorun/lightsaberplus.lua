function net.WriteCompressedTable(tbl)
	local data = util.TableToJSON(tbl)
	data = util.Compress(data)
	net.WriteInt(#data, 32)
	net.WriteData(data, #data)
end

function net.ReadCompressedTable()
	local num = net.ReadInt(32)
	local data = util.Decompress(net.ReadData(num))
	return util.JSONToTable(data)
end

AddCSLuaFile("lightsaberplus/lightsaberplus.lua")
AddCSLuaFile("lightsaberplus_config.lua")
include("lightsaberplus/lightsaberplus.lua")
if SERVER then resource.AddFile("materials/vgui/entities/lightsaber_plus.vmt") return end 