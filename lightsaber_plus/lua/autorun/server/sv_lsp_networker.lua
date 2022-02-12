util.AddNetworkString("saberplus-data-sync")
util.AddNetworkString("saberplus-wep-data-sync")
util.AddNetworkString("saberplus-npc-data-sync")
util.AddNetworkString("saberplus-saber-sound-hd")
util.AddNetworkString("saberplus-force-data-sync")
util.AddNetworkString("lightsaber+ form swap")


net.Receive("lightsaber+ form swap", function(len, ply)
	local fm = net.ReadString()
	local form = LIGHTSABER_PLUS_FORMS[fm]
	if form then
		if form.whitelisted then
			local whitelisted = ply:getsyncLightsaberPlusData("whitelistedForm_"..form, "false")
			if whitelisted == "false" then
				ply:text({Color(255,0,0), "You do not have the whitelist for this!"})
			else
				ply:switchForm(fm)
				ply:text({Color(0,255,0), "You have changed your form."})
			end
		else
			local lvl = ply:getsyncLightsaberPlusData("saberLevel", 0)
			if lvl >= form.lvl then
				ply:switchForm(fm)
				ply:text({Color(0,255,0), "You have changed your form."})
			else
				ply:text({Color(255,0,0), "Level too low to use this form."})
			end
		end
	else
		ply:text({Color(255,0,0), "Form Missing!"})
	end
end)

local pmeta = FindMetaTable("Player")
local wmeta = FindMetaTable("Weapon")
local nmeta = FindMetaTable("NPC")

function pmeta:syncLightsaberPlusData(key, val)
	self.syncedData = self.syncedData or {}
	self.syncedData[key] = val
	net.Start("saberplus-wep-data-sync")
		net.WriteInt(self:EntIndex(), LIGHTSABER_PLUS_NETWORK_BITS)
		net.WriteTable({key=key,val=val})
	net.Broadcast()
	
end

function wmeta:syncLightsaberPlusData(key, val)
	self.syncedData = self.syncedData or {}
	self.syncedData[key] = val
	net.Start("saberplus-wep-data-sync")
		net.WriteInt(self:EntIndex(), LIGHTSABER_PLUS_NETWORK_BITS)
		net.WriteTable({key=key,val=val})
	net.Broadcast()
end

function nmeta:syncLightsaberPlusData(key, val)
	self.syncedData = self.syncedData or {}
	self.syncedData[key] = val
	net.Start("saberplus-wep-data-sync")
		net.WriteInt(self:EntIndex(), LIGHTSABER_PLUS_NETWORK_BITS)
		net.WriteTable({key=key,val=val})
	net.Broadcast()
end

function pmeta:getsyncLightsaberPlusData(key, val)
	self.syncedData = self.syncedData or {}
	self.syncedData[key] = self.syncedData[key] or val
	return self.syncedData[key]
end

function wmeta:getsyncLightsaberPlusData(key, val)
	self.syncedData = self.syncedData or {}
	self.syncedData[key] = self.syncedData[key] or val
	return self.syncedData[key]
end

function nmeta:getsyncLightsaberPlusData(key, val)
	self.syncedData = self.syncedData or {}
	self.syncedData[key] = self.syncedData[key] or val
	return self.syncedData[key]
end

function wmeta:forceSync(tar)
	self.syncedData = self.syncedData or {}
	if !(self.syncedData == {}) then
		net.Start("saberplus-force-data-sync")
			net.WriteInt(self:EntIndex(), LIGHTSABER_PLUS_NETWORK_BITS)
			net.WriteTable(self.syncedData)
		net.Send(tar)
	end
end

function pmeta:forceSync(tar)
	self.syncedData = self.syncedData or {}
	if !(self.syncedData == {}) then
		net.Start("saberplus-force-data-sync")
			net.WriteInt(self:EntIndex(), LIGHTSABER_PLUS_NETWORK_BITS)
			net.WriteTable(self.syncedData)
		net.Send(tar)
	end
end

function nmeta:forceSync(tar)
	self.syncedData = self.syncedData or {}
	if !(self.syncedData == {}) then
		net.Start("saberplus-force-data-sync")
			net.WriteInt(self:EntIndex(), LIGHTSABER_PLUS_NETWORK_BITS)
			net.WriteTable(self.syncedData)
		net.Send(tar)
	end
end

local sanityMaker = 0
hook.Add("Think", "inuodfgosidfgs", function()
	if sanityMaker <= CurTime() then
		for _,ply in pairs(player.GetAll()) do
			if !(ply.sanitizedLightsaberPlus) then
				for k,ent in pairs(ents.GetAll()) do
					if ent:IsPlayer() or ent:IsNPC() or ent:IsWeapon() then
						ent:forceSync(ply)
					end
				end
				ply.sanitizedLightsaberPlus = true
			end
		end
		sanityMaker = CurTime() + 30 -- scan for new players every 30s.
	end
end)