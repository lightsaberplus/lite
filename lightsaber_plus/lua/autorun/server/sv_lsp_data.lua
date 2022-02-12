local meta = FindMetaTable("Player")

function meta:id()
	return self:SteamID64() or 0
end

function json_decode(j)
	return util.JSONToTable(j)
end
function json_encode(t)
	return util.TableToJSON(t)
end

local dataExists = false
function createDataTable()
	if !(dataExists) then
		sql.Query([[CREATE TABLE IF NOT EXISTS dataPack(key VARCHAR(255) NOT NULL PRIMARY KEY, val LONGTEXT);]])
		
		dataExists = true
	end
end

local TOTALLY_SAFER_SAVE_DATA = {}
function meta:getData(key, val)
	createDataTable()
	local id = self:id()
	TOTALLY_SAFER_SAVE_DATA[id] = TOTALLY_SAFER_SAVE_DATA[id] or {}
	
	if !(TOTALLY_SAFER_SAVE_DATA[id][key]) then
		local data = sql.Query("SELECT val FROM dataPack WHERE key = '" .. id .. "_" .. key .. "';")
		if data then
			TOTALLY_SAFER_SAVE_DATA[id][key] = data[1].val
		else
			TOTALLY_SAFER_SAVE_DATA[id][key] = val
		end
	end
	
	return TOTALLY_SAFER_SAVE_DATA[id][key]
end

function meta:setData(key, val)
	createDataTable()
	local id = self:id()
	sql.Query("DELETE FROM dataPack WHERE key = '" .. id .. "_" .. key .. "';")
	sql.Query("INSERT INTO dataPack(key, val) VALUES('" .. id .. "_" .. key .. "', '" .. sql.SQLStr(val, true) .. "');")
	TOTALLY_SAFER_SAVE_DATA[id] = TOTALLY_SAFER_SAVE_DATA[id] or {}
	TOTALLY_SAFER_SAVE_DATA[id][key] = val
end

function getData(key, val)
	createDataTable()
	if !(TOTALLY_SAFER_SAVE_DATA[key]) then
		local data = sql.Query("SELECT val FROM dataPack WHERE key = '" .. key .. "';")
		if data then
			TOTALLY_SAFER_SAVE_DATA[key] = data[1].val
		else
			TOTALLY_SAFER_SAVE_DATA[key] = val
		end
	end
	
	return TOTALLY_SAFER_SAVE_DATA[key]
end

function setData(key, val)
	createDataTable()
	sql.Query("DELETE FROM dataPack WHERE key = '" .. key .. "';")
	sql.Query("INSERT INTO dataPack(key, val) VALUES('" .. key .. "', '" .. sql.SQLStr(val, true) .. "');")
	TOTALLY_SAFER_SAVE_DATA[key] = val
end

hook.Add("PlayerDisconnected", "lookitssoeasy..", function(ply)
	table.remove(TOTALLY_SAFER_SAVE_DATA, ply:id()) -- look a one line fix for nutscripts stupid lag.
end)
hook.Add("PlayerInitialSpawn", "lookisdafsdf.", function(ply)
	TOTALLY_SAFER_SAVE_DATA[ply:id()] = {}
end)

































