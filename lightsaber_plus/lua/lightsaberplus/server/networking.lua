util.AddNetworkString("saberplus-stop-saber-sound")
util.AddNetworkString("saberplus-saber-sound")
util.AddNetworkString("saberplus-screenie")
util.AddNetworkString("saberplus-bleed")
util.AddNetworkString("saberplus-sound-hit")
util.AddNetworkString("saberplus-swap-lightsaber-menu")
util.AddNetworkString("saberplus-crystal-drop-blade")
util.AddNetworkString("saberplus-crystal-drop-quillon")
util.AddNetworkString("saberplus-crystal-drop-inner")
util.AddNetworkString("saberplus-crystal-drop-inner-quillon")
util.AddNetworkString("saberplus-start-crystal-cuztom")
util.AddNetworkString("saberplus-crystal-remove-blade")
util.AddNetworkString("saberplus-crystal-remove-quillon")
util.AddNetworkString("saberplus-crystal-remove-inner")
util.AddNetworkString("saberplus-crystal-remove-inner-quillon")
util.AddNetworkString("saberplus-end-craft-anim")
util.AddNetworkString("saberplus-ping-inv-upd")
util.AddNetworkString("saberplus-hits")
util.AddNetworkString("saberplus-block")
util.AddNetworkString("saberplus-riposte")

local meta = FindMetaTable("Player")

function meta:customizeHilt(hash, left)
	local eyes = self:EyeAngles()
	local wep = self:GetActiveWeapon()
	if not wep.isCustomizable then return end
	self:SetEyeAngles(Angle(0,eyes.y,0))
	net.Start("saberplus-start-crystal-cuztom")
		net.WriteCompressedTable(self:getInv())
		local quillons = {}
		for i=1,10 do
			quillons[i] = itemGetData(hash, "quillon"..i, "")
		end
		net.WriteCompressedTable(quillons)
		
		local blades = {}
		for i=1,10 do
			blades[i] = itemGetData(hash, "blade"..i, "")
		end
		net.WriteCompressedTable(blades)
		
		local bladeInners = {}
		for i=1,10 do
			bladeInners[i] = itemGetData(hash, "bladeInner"..i, "")
		end
		net.WriteCompressedTable(bladeInners)
		
		local quillonInners = {}
		for i=1,10 do
			quillonInners[i] = itemGetData(hash, "quillonInner"..i, "")
		end
		net.WriteCompressedTable(quillonInners)
		net.WriteBool(left)
	net.Send(self)
	self:anim("walk_magic",1, 9999999)
	self:syncLightsaberPlusData("crafting", true)
	self:syncLightsaberPlusData("isLeft", left)
end

net.Receive("saberplus-ping-inv-upd", function(len, ply)
	net.Start("saberplus-ping-inv-upd")
		net.WriteCompressedTable(ply:getInv())
	net.Send(ply)
end)

net.Receive("saberplus-end-craft-anim", function(len, ply)
	if ply:getsyncLightsaberPlusData("crafting", false) then
		ply:endAnim()
		ply:syncLightsaberPlusData("crafting", false)
	end
end)

net.Receive("saberplus-crystal-drop-quillon", function(len, ply)
	local hash = net.ReadString()
	local id = net.ReadInt(32)
	local left = net.ReadBool()
	if left then hook.Run("saberplus-crystal-drop-quillon", ply, hash, id) return end
	local inv = ply:getInv()
	local wep = ply:GetActiveWeapon()
	
	if inv[hash] then
		local item = LSP.GetItem(inv[hash])
		if item.isCrystal then
			local wepHash = wep.hash
			wep:syncLightsaberPlusData("quillon"..id, Vector(item.color.r, item.color.g, item.color.b))
			wep:syncLightsaberPlusData("quillonItem"..id, inv[hash])
			
			local currentItem = itemGetData(wepHash, "quillon"..id, "")
			if !(currentItem == "") then
				ply:giveItem(currentItem)
			end
			
			itemSetData(wepHash, "quillon"..id, item.id)
			ply:takeItem(item.id, hash)
			
			ply:customizeHilt(wep.hash)
			
		end
	end
	
end)

net.Receive("saberplus-crystal-remove-blade", function(len, ply)
	local id = net.ReadInt(32)
	local left = net.ReadBool()
	if left then hook.Run("saberplus-crystal-remove-blade", ply, id) return end
	local wep = ply:GetActiveWeapon()
	id = math.Clamp(id,1,10)
	wep:syncLightsaberPlusData("blade"..id, Vector(999,9999,999))
	wep:syncLightsaberPlusData("bladeItem"..id, "")
	wep:syncLightsaberPlusData("saberOn", false)
	local currentItem = itemGetData(wep.hash, "blade"..id, "")
	if !(currentItem == "") then
		ply:giveItem(currentItem)
	end
	itemSetData(wep.hash, "blade"..id, "")
	ply:customizeHilt(wep.hash)
end)

net.Receive("saberplus-crystal-remove-inner", function(len, ply)
	local id = net.ReadInt(32)
	local left = net.ReadBool()
	if left then hook.Run("saberplus-crystal-remove-inner", ply, id) return end
	local wep = ply:GetActiveWeapon()
	id = math.Clamp(id,1,10)
	wep:syncLightsaberPlusData("bladeInner"..id, Vector(999,999,999))
	local currentItem = itemGetData(wep.hash, "bladeInner"..id, "")
	if !(currentItem == "") then
		ply:giveItem(currentItem)
	end
	itemSetData(wep.hash, "bladeInner"..id, "")
	ply:customizeHilt(wep.hash)
end)

net.Receive("saberplus-crystal-remove-inner-quillon", function(len, ply)
	local id = net.ReadInt(32)
	local left = net.ReadBool()
	if left then hook.Run("saberplus-crystal-remove-inner-quillon", ply, id) return end
	local wep = ply:GetActiveWeapon()
	id = math.Clamp(id,1,10)
	wep:syncLightsaberPlusData("quillonInner"..id, Vector(999,999,999))
	local currentItem = itemGetData(wep.hash, "quillonInner"..id, "")
	if !(currentItem == "") then
		ply:giveItem(currentItem)
	end
	itemSetData(wep.hash, "quillonInner"..id, "")
	ply:customizeHilt(wep.hash)
end)

net.Receive("saberplus-crystal-remove-quillon", function(len, ply)
	local id = net.ReadInt(32)
	local left = net.ReadBool()
	if left then hook.Run("saberplus-crystal-remove-quillon", ply, id) return end
	local wep = ply:GetActiveWeapon()
	id = math.Clamp(id,1,10)
	wep:syncLightsaberPlusData("quillon"..id, Vector(999,999,999))
	local currentItem = itemGetData(wep.hash, "quillon"..id, "")
	if !(currentItem == "") then
		ply:giveItem(currentItem)
	end
	itemSetData(wep.hash, "quillon"..id, "")
	ply:customizeHilt(wep.hash)
end)

net.Receive("saberplus-crystal-drop-blade", function(len, ply)
	local hash = net.ReadString()
	local id = net.ReadInt(32)
	local left = net.ReadBool()
	if left then hook.Run("saberplus-crystal-drop-blade", ply, hash, id) return end
	local inv = ply:getInv()
	local wep = ply:GetActiveWeapon()

	if inv[hash] then
		local item = LSP.GetItem(inv[hash])
		if item.isCrystal then
			local wepHash = wep.hash
			wep:syncLightsaberPlusData("blade"..id, Vector(item.color.r, item.color.g, item.color.b))
			wep:syncLightsaberPlusData("bladeItem"..id, inv[hash])
			local currentItem = itemGetData(wepHash, "blade"..id, "")
			if !(currentItem == "") then
				ply:giveItem(currentItem)
			end

			itemSetData(wepHash, "blade"..id, item.id)
			ply:takeItem(item.id, hash)
			ply:customizeHilt(wep.hash)
		end
	end
end)

net.Receive("saberplus-crystal-drop-inner", function(len, ply)
	local hash = net.ReadString()
	local id = net.ReadInt(32)
	local left = net.ReadBool()
	if left then hook.Run("saberplus-crystal-drop-inner", ply, hash, id) return end
	local inv = ply:getInv()
	local wep = ply:GetActiveWeapon()

	if inv[hash] then
		local item = LSP.GetItem(inv[hash])
		if item.isInner then
			local wepHash = wep.hash
			wep:syncLightsaberPlusData("bladeInner"..id, Vector(item.color.r, item.color.g, item.color.b))
			
			local currentItem = itemGetData(wepHash, "bladeInner"..id, "")
			if !(currentItem == "") then
				ply:giveItem(currentItem)
			end
			
			itemSetData(wepHash, "bladeInner"..id, item.id)
			ply:takeItem(item.id, hash)
			ply:customizeHilt(wep.hash)
		end
	end
end)

net.Receive("saberplus-crystal-drop-inner-quillon", function(len, ply)
	local hash = net.ReadString()
	local id = net.ReadInt(32)
	local left = net.ReadBool()
	if left then hook.Run("saberplus-crystal-drop-inner-quillon", ply, hash, id) return end
	local inv = ply:getInv()
	local wep = ply:GetActiveWeapon()

	if inv[hash] then
		local item = LSP.GetItem(inv[hash])
		if item.isInner then
			local wepHash = wep.hash
			wep:syncLightsaberPlusData("quillonInner"..id, Vector(item.color.r, item.color.g, item.color.b))

			local currentItem = itemGetData(wepHash, "quillonInner"..id, "")
			if !(currentItem == "") then
				ply:giveItem(currentItem)
			end

			itemSetData(wepHash, "quillonInner"..id, item.id)
			ply:takeItem(item.id, hash)
			ply:customizeHilt(wep.hash)
		end
	end
end)

net.Receive("saberplus-swap-lightsaber-menu", function(len, ply)
	local mode = net.ReadBool()
	if mode then
		if ply:GetActiveWeapon().offhash then
			ply:customizeHilt(ply:GetActiveWeapon().offhash, true)
		end
	else
		ply:customizeHilt(ply:GetActiveWeapon().hash)
	end
end)

concommand.Add("customizeCrystal", function(ply, cmd, args)
	if IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon().isLightsaberPlus and ply:GetActiveWeapon().isCustomizable then
		ply:customizeHilt(ply:GetActiveWeapon().hash)
	end
end)
