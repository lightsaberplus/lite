local meta = FindMetaTable("Player")
local inventorySet = "inventory2"
local len = string.len
local sub = string.sub
local random = math.random

function scramble(s)
	local n = ""
	for i=1,len(s) do
		local l = len(s)
		if l > 1 then
			local r = random(1,l)
			n = n .. sub(s,r,r)
			s = sub(s, 1, r-1) .. sub(s,r+1, l)
		else
			n = n..s
		end
	end
	return n
end

function generateHash(a,b)
	local h = ""
	local k = scramble("Zuf2txeXAOHqj8ySD4Wo3LbIgnN5vhadpFzPCmB0VQGwK9l1UciRrTMEsJY6k7")
	for i=1,a do
		for l=1,b do
			local r = random(1,len(k))
			h=h..sub(k,r,r)
		end
		h=h.."-"
	end
	return sub(h,1,len(h)-1)
end

function meta:getInv()
	local t = json_decode(self:getData(inventorySet, "[]"))
	local customData = {}
	for hash,id in pairs(t) do
		customData[hash] = {}
		local item = getItem(id)
		if item then
			customData[hash].name = itemGetData(hash, "customName", item.name)
			customData[hash].desc = itemGetData(hash, "customDesc", item.desc)
			customData[hash].mdl = itemGetData(hash, "customModel", item.mdl)
		end
	end
	return t,customData
end

function meta:saveInventory(x)
	local t = json_encode(x)
	self:setData(inventorySet, t)
end

function meta:giveItem(id,newKey)
	if not items[id] then return false end
	local inv = self:getInv()
	newKey = newKey or generateHash(10,5)
	inv[newKey] = id
	self:saveInventory(inv)
	return true
end

function meta:openInv()
	net.Start("saberplus-inv-server-open")
	net.Send(self)
end

function meta:closeInv()
	net.Start("saberplus-inv-server-close")
	net.Send(self)
end

function meta:takeItem(id, hash)
	if not items[id] then return false end
	local inv = self:getInv()
	local removed = false
	if hash then
		inv[hash] = nil
		removed = true
	else
		for key,data in pairs(inv) do
			if data.id == id then
				inv[key] = nil
				removed = true
				break
			end
		end
	end
	if removed then
		self:saveInventory(inv)
	end
	return removed
end

util.AddNetworkString("saberplus-net-inv")
util.AddNetworkString("saberplus-net-inv-act")
util.AddNetworkString("saberplus-inv-server-open")
util.AddNetworkString("saberplus-inv-server-close")

function meta:networkInv()
	local inv,customData = self:getInv()
	net.Start("saberplus-net-inv")
		net.WriteTable(inv)
		net.WriteTable(customData)
	net.Send(self)
end

function spawnLightsaberPlusItem(id, pos, hash)
	hash = hash or generateHash(10,5)
	local world_item = ents.Create("saberplus_item")
	local item = getItem(id)
	world_item.itemClass = id
	world_item.itemHash = hash
	world_item:SetPos(pos)
	
	local customData = itemGetData(hash, "customModel", item.mdl)
	
	world_item:SetModel(customData)
	world_item:Spawn()
	return world_item
end

net.Receive("saberplus-net-inv-act", function(len,ply)
	local hash = net.ReadString()
	local fid = net.ReadString()
	
	local inv = ply:getInv()
	local itemClass = inv[hash]
	local item = getItem(itemClass)

	if item then
		local id = item.id
		if fid == "drop" then
			local canDrop = item.canDrop(ply, item)
			if canDrop then
				ply:takeItem(id, hash)
				spawnLightsaberPlusItem(id, ply:GetPos() + Vector(0,0,48) + ply:GetForward() * 50, hash)
			end
		else
			if item.func[fid] then
				if item.func[fid].canRun(ply, item, hash) then
					item.func[fid].onRun(ply, item, hash)
				end
			end
		end
	end
end)

net.Receive("saberplus-net-inv", function(len,ply)
	ply:networkInv()
end)

function itemGetData(hash, id, def)
	local data = getData(id.."_"..hash, def)
	return data
end

function itemSetData(hash, id, data)
	setData(id.."_"..hash, data)
end
