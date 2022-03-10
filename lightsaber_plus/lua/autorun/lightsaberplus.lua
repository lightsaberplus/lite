AddCSLuaFile("lightsaberplus/lightsaberplus.lua")
AddCSLuaFile("lightsaberplus_config.lua")
include("lightsaberplus/lightsaberplus.lua")
if SERVER then resource.AddFile("materials/vgui/entities/lightsaber_plus.vmt") end
