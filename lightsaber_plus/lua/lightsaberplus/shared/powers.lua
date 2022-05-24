local meta = FindMetaTable("Player")
local forcePowers = {}

function meta:getForce()
	if SERVER then
		self.forcepool = self.forcepool or 0
		return self.forcepool
	else
		GLOBAL_FORCE_POOL = GLOBAL_FORCE_POOL or 0
		return GLOBAL_FORCE_POOL
	end
end

function meta:getMaxForce()
	LSP.Config.MaxForce[team.GetName(self:Team())] = LSP.Config.MaxForce[team.GetName(self:Team())] or 0
	local add = self:getsyncLightsaberPlusData("additiveForce", 0)
	return LSP.Config.MaxForce[team.GetName(self:Team())] + add
end

function LSP.AddPower(key, data)
	forcePowers[key] = data
end

function getPower(key)
	return forcePowers[key]
end

function getAllPowers()
	return forcePowers
end

hook.Add("LS+.ForcePowers", "LS+.NormalPowers", function()
	LSP.AddPower("Force Push", {
		icon = "hfgjvs/kraken/jedi sage telekinetics/915256278_3961334268.png",
		desc = "Use the force to push your enemy backwards.",
		sound = "hfg/weapons/force/push.mp3",
		cost = 50,
		cooldown = 10,
	})

	LSP.AddPower("Force Leap", {
		icon = "hfgjvs/kraken/jedi sage balance/140035353_3375790149.png",
		desc = "Use the force to thrust you into the air.",
		sound = "",
		cost = 5,
		cooldown = 0,
	})
	
	LSP.AddPower("Force Speed", {
		icon = "hfgjvs/kraken/jedi sage telekinetics/4125344648_687080867.png",
		desc = "Use the force to enhance your movement.",
		sound = "hfg/weapons/force/speed.mp3",
		cost = 50,
		cooldown = 6,
	})

	LSP.AddPower("Force Heal", {
		icon = "hfgjvs/kraken/jedi shad serenity/1955265406_4137656675.png",
		desc = "Heal yourself or others with the force.",
		sound = "hfgjvs/weapon/force/heal.wav",
		cost = 100,
		cooldown = 13,
	})
	
	LSP.AddPower("Force Meditate", {
		icon = "hfgjvs/kraken/sith mara carnage/3382689195_278360974.png",
		desc = "Use the Force to meditate",
		sound = "hfgjvs/weapon/force/heal.wav",
		cost = 0,
		cooldown = 0,
	})

	LSP.AddPower("Force Block", {
		icon = "hfgjvs/kraken/jedi shad kinetic combat/3796060180_3054044740.png",
		desc = "Use the Force to block incoming attacks.",
		sound = "",
		cost = 1,
		cooldown = 0,
	})
end)


hook.Add("LS+.FinishedLoading", "LS+.ForcePowers", function()
	hook.Run("LS+.ForcePowers")
    hook.Add("LS+.Reload", "LS+.ForcePowers", function()
        hook.Run("LS+.ForcePowers")
    end)
end)