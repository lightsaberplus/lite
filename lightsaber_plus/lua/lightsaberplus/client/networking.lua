local pmeta = FindMetaTable("Player")
local wmeta = FindMetaTable("Weapon")
local nmeta = FindMetaTable("NPC")

local dataBlobet = {}

net.Receive("saberplus-data-sync", function()
	local id = net.ReadInt(LSP.Config.NetworkBits)
	local data = net.ReadTable()
	dataBlobet[id] = dataBlobet[id] or {}
	dataBlobet[id][id] = data.val
end)

net.Receive("saberplus-wep-data-sync", function()
	local id = net.ReadInt(LSP.Config.NetworkBits)
	local data = net.ReadTable()
	dataBlobet[id] = dataBlobet[id] or {}
	dataBlobet[id][data.key] = data.val
end)

net.Receive("saberplus-force-data-sync", function()
	local id = net.ReadInt(LSP.Config.NetworkBits)
	local data = net.ReadTable()
	dataBlobet[id] = data
end)

net.Receive("saberplus-npc-data-sync", function()
	local id = net.ReadInt(LSP.Config.NetworkBits)
	local data = net.ReadTable()
	dataBlobet[id] = dataBlobet[id] or {}
	dataBlobet[id][data.key] = data.val
end)

function pmeta:getsyncLightsaberPlusData(key, val)
	local id = self:EntIndex()
	dataBlobet[id] = dataBlobet[id] or {}
	dataBlobet[id][key] = dataBlobet[id][key] or val
	return dataBlobet[id][key]
end


function nmeta:getsyncLightsaberPlusData(key, val)
	local id = self:EntIndex()
	dataBlobet[id] = dataBlobet[id] or {}
	dataBlobet[id][key] = dataBlobet[id][key] or val
	return dataBlobet[id][key]
end


function wmeta:getsyncLightsaberPlusData(key, val)
	local id = self:EntIndex()
	dataBlobet[id] = dataBlobet[id] or {}
	dataBlobet[id][key] = dataBlobet[id][key] or val
	return dataBlobet[id][key]
end