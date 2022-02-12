local pmeta = FindMetaTable("Player")
local wmeta = FindMetaTable("Weapon")
local nmeta = FindMetaTable("NPC")

local dataBlobet = {}
local netLogger = 0
local logNet = false -- dev tools.

net.Receive("saberplus-data-sync", function()
	local id = net.ReadInt(LIGHTSABER_PLUS_NETWORK_BITS)
	local data = net.ReadTable()
	dataBlobet[id] = dataBlobet[id] or {}
	dataBlobet[id][id] = data.val
	if logNet then netLogger = netLogger + 1 end
end)

net.Receive("saberplus-wep-data-sync", function()
	local id = net.ReadInt(LIGHTSABER_PLUS_NETWORK_BITS)
	local data = net.ReadTable()
	dataBlobet[id] = dataBlobet[id] or {}
	dataBlobet[id][data.key] = data.val
	if logNet then netLogger = netLogger + 1 end
end)

net.Receive("saberplus-force-data-sync", function()
	local id = net.ReadInt(LIGHTSABER_PLUS_NETWORK_BITS)
	local data = net.ReadTable()
	dataBlobet[id] = data
	if logNet then netLogger = netLogger + 1 end
end)

net.Receive("saberplus-npc-data-sync", function()
	local id = net.ReadInt(LIGHTSABER_PLUS_NETWORK_BITS)
	local data = net.ReadTable()
	dataBlobet[id] = dataBlobet[id] or {}
	dataBlobet[id][data.key] = data.val
	if logNet then netLogger = netLogger + 1 end
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

hook.Add("HUDPaint", "ojdifgdsfg", function()
	if logNet then
		draw.DrawText("NET: "..netLogger, "Trebuchet24", ScrW()/2, 55, Color(255,0,0), TEXT_ALIGN_CENTER)
	end
end)

concommand.Add("resetNetLogger", function()
	netLogger = 0
end)