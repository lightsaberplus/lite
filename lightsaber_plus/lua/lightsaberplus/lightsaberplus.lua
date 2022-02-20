LSP = LSP or {
    Version = "0.5",
    Config = {
        Forms = {},
        MaxForce = {},
        TeamForcePowers = {},
        FormOrder = {}
    }
}


hook.Run("LS+.Reload") // Reload specific code blocks at Lua Refresh

function LSP:Initialize()

    local function validateconfig()
        local succ, err = pcall(include, "lightsaberplus_config.lua")
        if succ then
            // err is now the returned table
            table.Merge(LSP.Config, err)
            hook.Run("LS+.Config.Reloaded")
        else
            print("You fucked up your Lightsaberplus Config")
            print(err)
        end
    end

    validateconfig()
    hook.Add("LS+.Reload", "LS+.ReloadConfig", validateconfig)

    local f, dlcs = file.Find("lightsaberplus/dlcs/*", "LUA")
    for _, path in ipairs(dlcs or {}) do
        if file.Exists("lightsaberplus/dlcs/"..path.."/"..path..".lua", "LUA") then
            AddCSLuaFile("lightsaberplus/dlcs/"..path.."/"..path..".lua")
            include("lightsaberplus/dlcs/"..path.."/"..path..".lua")
        end
    end
    hook.Run("LS+.DLCsLoaded")

    // Shared Loading
    for _, file in ipairs(file.Find("lightsaberplus/shared/*", "LUA")) do
        if SERVER then
            AddCSLuaFile("lightsaberplus/shared/"..file)
        end
        include("lightsaberplus/shared/"..file)
    end

    // Serverside Loading
    if SERVER then
        for _, filename in ipairs(file.Find("lightsaberplus/server/*", "LUA")) do
            include("lightsaberplus/server/"..filename)
        end
    end

    // Clientside Loading
    for _, file in ipairs(file.Find("lightsaberplus/client/*", "LUA")) do
        if SERVER then
             AddCSLuaFile("lightsaberplus/client/"..file)
        else
            include("lightsaberplus/client/"..file)
        end
    end

    print("Loaded successfully LS+")
    hook.Run("LS+.FinishedLoading")
end

hook.Add("InitPostEntity", "LS+.Initialize", LSP.Initialize)


hook.Add("LS+.Config.Reloaded", "LS+.LoadNormalForms", function()
    LSP.Config.FormOrder[1] = "Shii-Cho"
    LSP.Config.FormOrder[2] = "Makashi"

    LSP.Config.Forms["Shii-Cho"] = {
    	desc = "Traditional maneuvers intent on maiming and killing with a focus on disarming an armed foe. Used against superior number of opponenets.",
    	icon = "I",
    	lvl = 0,
    	hold = "melee2",
    	walk = "melee2",
    	idle = "melee2",
    	run = "melee2",
    	a = {
    		{anim = "ryoku_h_left_t2", rate = 0.75, dmg = 1, shave = 0.1, speed = 100},
    		{anim = "ryoku_h_left_t1", rate = 0.75, dmg = 1.1, shave = 0.1, speed = 100, forcedTime = 0.75},
    		{anim = "ryoku_r_left_t1", rate = 1, dmg = 1.2, shave = 0.1, speed = 50},
    	},
    	w = {
    		{anim = "ryoku_r_c4_t2", rate = 1, dmg = 1, shave = 0, speed = 100, forcedTime = 0.85},
    		{anim = "ryoku_r_c4_t1", rate = 1, dmg = 0.75, shave = 0.1, speed = 0},
    		{anim = "ryoku_r_c3_t1", rate = 1, dmg = 1, shave = 0.1, speed = 100},
    		{anim = "ryoku_r_c2_t1", rate = 1, dmg = 1.1, shave = 0.1, speed = 75},
    		{anim = "ryoku_r_c1_t3", rate = 1, dmg = 1.5, shave = 0.1, speed = 50},
    		{anim = "ryoku_r_c5_t1", rate = 1, dmg = 3.5, shave = 0.1, speed = 25},
    	},
    	d = {
    		{anim = "ryoku_h_right_t2", rate = 0.75, dmg = 1, shave = 0.1, speed = 100},
    		{anim = "ryoku_h_right_t1", rate = 0.75, dmg = 1.1, shave = 0.1, speed = 100, forcedTime = 0.75},
    		{anim = "ryoku_r_right_t1", rate = 1, dmg = 1.2, shave = 0.1, speed = 50},
    	},
    	wd = {
    		{anim = "ryoku_h_right_t1", rate = 1, dmg = 1, shave = 0.25, speed = 100},
    		{anim = "ryoku_h_right_t2", rate = 1, dmg = 1.25, shave = 0.25, speed = 75},
    		{anim = "ryoku_r_c1_t3", rate = 1, dmg = 1.5, shave = 0, speed = 25},
    	},
    	wa = {
    		{anim = "ryoku_h_left_t1", rate = 1, dmg = 0.5, shave = 0.1, speed = 0},
    		{anim = "ryoku_r_left_t1", rate = 1, dmg = 1.25, shave = 0, speed = 75, forcedTime = 0.75},
    		{anim = "ryoku_r_c1_t3", rate = 1.25, dmg = 1.5, shave = 0.1, speed = 25},
    	}
    }

    LSP.Config.Forms["Makashi"] = {
    	desc = "Its primary focus on facing a single opponent and the avoidance of being disarmed by an opponent while simultaneously working to disarming them.",
    	icon = "II",
    	lvl = 0,
    	hold = "melee2",
    	walk = "melee2",
    	idle = "melee2",
    	run = "melee2",
    	a = {
    		{anim = "vanguard_b_left_t2", rate = 0.75, dmg = 1, shave = 0.1, speed = 100},
    		{anim = "vanguard_b_left_t2", rate = 0.75, dmg = 1.1, shave = 0.1, speed = 100, forcedTime = 0.75},
    		{anim = "vanguard_b_left_t1", rate = 1, dmg = 1.2, shave = 0.1, speed = 50},
    	},
    	w = {
    		{anim = "pure_h_s1_t1", rate = 1, dmg = 1, shave = 0, speed = 100},
    		{anim = "pure_h_s2_t2", rate = 1, dmg = 0.75, shave = 0.5, speed = 0},
    		{anim = "pure_r_s1_t1", rate = 1, dmg = 1, shave = 0.1, speed = 100},
    		{anim = "pure_h_s2_t1", rate = 1, dmg = 1.1, shave = 0.1, speed = 75},
    		{anim = "pure_h_s1_t2", rate = 1, dmg = 1.5, shave = 0.1, speed = 50},
    		{anim = "pure_h_s1_t3", rate = 1, dmg = 3.5, shave = 0.1, speed = 25},
    	},
    	d = {
    		{anim = "pure_h_right_t1", rate = 0.75, dmg = 1, shave = 0.1, speed = 100},
    		{anim = "pure_r_right_t3", rate = 0.75, dmg = 1.1, shave = 0.1, speed = 100},
    		{anim = "pure_h_right_t2", rate = 1, dmg = 1.2, shave = 0.1, speed = 50},
    	},
    	wd = {
    		{anim = "pure_r_s1_t1", rate = 1, dmg = 1, shave = 0.25, speed = 100},
    		{anim = "pure_r_right_t3", rate = 1, dmg = 1.25, shave = 0.25, speed = 75},
    		{anim = "pure_h_s1_t2", rate = 1, dmg = 1.5, shave = 0, speed = 25},
    	},
    	wa = {
    		{anim = "vanguard_b_left_t2", rate = 1, dmg = 0.5, shave = 0.1, speed = 0},
    		{anim = "vanguard_b_left_t1", rate = 1, dmg = 1.25, shave = 0, speed = 75, forcedTime = 0.75},
    		{anim = "pure_h_s1_t2", rate = 1.25, dmg = 1.5, shave = 0.1, speed = 25},
    	}
    }
end)

hook.Add("LS+.Config.Reloaded", "LS+.DetectGamemode", function()

	local gm = GM or GAMEMODE or {}
	if gm.Name == "Sandbox" then
		LSP.Config.MaxForce[1001] = 100000
		LSP.Config.TeamForcePowers[1001] = {
			["*"] = true
		}
	elseif DarkRP then

	elseif nut then

	end

end)


if true then LSP:Initialize() end