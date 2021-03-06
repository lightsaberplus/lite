local keys = {["!"] = true, ["/"] = true, ["."] = true, ["~"] = true, ["["] = true}
local regedFuncs = {}
local isFunc = {}

util.AddNetworkString("ls++-text")

local meta = FindMetaTable("Player")

function meta:text(data)
	net.Start("ls++-text")
		net.WriteCompressedTable(data)
	net.Send(self)
end

function broadcast(data)
	net.Start("ls++-text")
		net.WriteCompressedTable(data)
	net.Broadcast()
end

function regFunc(key, funcs)
    regedFuncs[key] = funcs
    isFunc[key] = true
end

hook.Add("PlayerSay", "420909403vc42", function(ply, text, team)
	local rawText = text
	if string.len(rawText) > 1 then 
		if keys[string.sub(text,1,1)] then
			text = string.sub(text, 2,string.len(text))
			local args = string.Explode(" ", text)
			local cmd = string.lower(args[1]) or "no_command"
			if isFunc[cmd] then
				local canRun = regedFuncs[cmd].canRun(ply, args)
				if canRun then
					regedFuncs[cmd].onRun(ply, args)
				end
				return ""
			end
		end
	end
end)

regFunc("giveitem",{
    onRun = function(ply, args)
        local cmd = args[1]
        local sid = args[2]
        local id = args[3]
        local tar
		if game.SinglePlayer() then
			tar = ply
		else
			for _,v in pairs(player.GetAll()) do
				if v:SteamID64() == sid or v:SteamID() == sid then
					tar = v
					break
				end
			end
        end
		if !IsValid(tar) or !sid or !id then ply:ChatPrint("Command arguements incorrect!") return end
        tar:giveItem(id)
		tar:ChatPrint("You have been given '"..id.."' into your inventory.")
		if tar == ply then return end
		ply:ChatPrint("You have given ".. tar:Nick() .." '"..id.."'")
    end,
    canRun = function(ply, args)
        return ply:IsAdmin() or ply:IsSuperAdmin() -- Lets admins run command.
    end
})