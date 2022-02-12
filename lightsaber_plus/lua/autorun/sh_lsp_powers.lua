local meta = FindMetaTable("Player")
local forcePowers = {}
local lastRegister = 0

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
	LIGHTSABER_PLUS_MAX_FORCE = LIGHTSABER_PLUS_MAX_FORCE or {}
	LIGHTSABER_PLUS_MAX_FORCE[self:Team()] = LIGHTSABER_PLUS_MAX_FORCE[self:Team()] or 0
	local add = self:getsyncLightsaberPlusData("additiveForce", 0)
	return LIGHTSABER_PLUS_MAX_FORCE[self:Team()] + add
end

function addPower(key, data)
	forcePowers[key] = data
end

function getPower(key)
	return forcePowers[key]
end

function getAllPowers()
	return forcePowers
end

function registerPowers()
	hook.Run("registerForcePowers")

	addPower("Force Push", {
		icon = "hfgjvs/kraken/jedi sage telekinetics/915256278_3961334268.png",
		desc = "Use the force to push your enemy backwards.",
		sound = "hfg/weapons/force/push.mp3",
		cost = 50,
		cooldown = 10,
	})

	addPower("Force Leap", {
		icon = "hfgjvs/kraken/jedi sage balance/140035353_3375790149.png",
		desc = "Use the force to thrust you into the air.",
		sound = "",
		cost = 5,
		cooldown = 0,
	})
	
	addPower("Force Speed", {
		icon = "hfgjvs/kraken/jedi sage telekinetics/4125344648_687080867.png",
		desc = "Use the force to enhance your movement.",
		sound = "hfg/weapons/force/speed.mp3",
		cost = 50,
		cooldown = 6,
	})

	addPower("Force Heal", {
		icon = "hfgjvs/kraken/jedi shad serenity/1955265406_4137656675.png",
		desc = "Heal yourself or others with the force.",
		sound = "hfgjvs/weapon/force/heal.wav",
		cost = 100,
		cooldown = 13,
	})
	
	addPower("Force Meditate", {
		icon = "hfgjvs/kraken/sith mara carnage/3382689195_278360974.png",
		desc = "Use the Force to meditate",
		sound = "hfgjvs/weapon/force/heal.wav",
		cost = 0,
		cooldown = 0,
	})

	addPower("Force Block", {
		icon = "hfgjvs/kraken/jedi shad kinetic combat/3796060180_3054044740.png",
		desc = "Use the Force to block incoming attacks.",
		sound = "",
		cost = 1,
		cooldown = 0,
	})

	addPower("Mass Disarm", {
        icon = "hfgjvs/kraken/sith snip marksmanship/1438540414_102945889.png",
        desc = "Use the Force to disarm all opponents around you.",
        sound = "",
        cost = 150,
        cooldown = 40,
    })
    
    addPower("Force Lightning", {
        icon = "hfgjvs/kraken/sith sorc lightning/1793453090_3884866318.png",
        desc = "Use the Dark Side of the Force to send lightning at an opponent.",
        sound = "",
        cost = 5,
        cooldown = 0,
    })
    
    addPower("Mass Lightning", {
        icon = "hfgjvs/kraken/sith sorc lightning/1990225936_2721229819.png",
        desc = "Use the Dark Side of the Force to send lightning at all opponents in front of you.",
        sound = "",
        cost = 10,
        cooldown = 0,
    })
    
    addPower("Force Dash", {
        icon = "hfgjvs/kraken/jedi guard focus/4173111886_1308476029.png",
        desc = "Use the Force to empower your feet, dashing in the direction you are moving.",
        sound = "",
        cost = 25,
        cooldown = 10,
    })
    
    addPower("Mass Choke", {
        icon = "hfgjvs/kraken/sith jugg immortal/2089844775_255809271.png",
        desc = "Use the Force to strangle all opponents in the vicinity.",
        sound = "",
        cost = 400,
        cooldown = 30,
    })
    
    addPower("Force Storm", {
        icon = "hfgjvs/kraken/sith sorc lightning/3214393208_1078826565.png",
        desc = "Use the Force to create a storm around you, striking all opponents with lightning.",
        sound = "",
        cost = 100,
        cooldown = 0,
    })
    
    addPower("Electric Judgement", {
        icon = "hfgjvs/kraken/jedi sage telekinetics/2345167222_2915837677.png",
        desc = "Use the Light Side of the Force to send lightning at an opponent.",
        sound = "",
        cost = 5,
        cooldown = 0,
    })
    
    addPower("Mass Electric Judgement", {
        icon = "hfgjvs/kraken/jedi shad infiltration/3508054613_728630060.png",
        desc = "Use the Light Side of the Force to send lightning at all opponents in front of you.",
        sound = "",
        cost = 10,
        cooldown = 0,
    })
    
    addPower("Force Drain", {
        icon = "hfgjvs/kraken/jedi shad serenity/3942262603_3557239221.png",
        desc = "Use the Force to drain the life of an opponent.",
        sound = "",
        cost = 7,
        cooldown = 0,
    })
    
    addPower("Mass Drain", {
        icon = "hfgjvs/kraken/jedi shad serenity/3851759035_1068407260.png",
        desc = "Use the Force to drain the life of all opponents in front of you.",
        sound = "",
        cost = 15,
        cooldown = 0,
    })
    
    addPower("Force Leech", {
        icon = "hfgjvs/kraken/jedi shad kinetic combat/1836110798_3560046461.png",
        desc = "Use the Force to leech the force of an opponent.",
        sound = "",
        cost = 7,
        cooldown = 0,
    })
    
    addPower("Mass Leech", {
        icon = "hfgjvs/kraken/sith sorc lightning/3763752854_1400203657.png",
        desc = "Use the Force to leech the force of all opponents in front of you.",
        sound = "",
        cost = 15,
        cooldown = 0,
    })
    
    addPower("Force Crush", {
        icon = "hfgjvs/kraken/sith jugg rage/510070514_1852664711.png",
        desc = "Use the Force to crush the insides of an opponent in front of you.",
        sound = "",
        cost = 300,
        cooldown = 30,
    })
    
    addPower("Force Combust", {
        icon = "hfgjvs/kraken/sith power pyrotech/537050678_3390453646.png",
        desc = "Use the Force to ignite your opponent.",
        sound = "",
        cost = 100,
        cooldown = 10,
    })
    
    addPower("Mass Combust", {
        icon = "hfgjvs/kraken/sith power pyrotech/2463994106_1712820157.png",
        desc = "Use the Force to ignite all living beings around you.",
        sound = "",
        cost = 200,
        cooldown = 20,
    })
    
    addPower("Force Extinguish", {
        icon = "hfgjvs/kraken/sith power shield tech/2463994106_1712820157.png",
        desc = "Use the Force to de-ignite your opponent.",
        sound = "",
        cost = 100,
        cooldown = 10,
    })
    
    addPower("Mass Extinguish", {
        icon = "hfgjvs/kraken/sith oper medicine/4218020749_2637499415.png",
        desc = "Use the Force to de-ignite all living beings around you.",
        sound = "",
        cost = 200,
        cooldown = 20,
    })
    
    addPower("Rock Throw", {
        icon = "hfgjvs/kraken/jedi shad kinetic combat/2368496643_3532115879.png",
        desc = "Use the Force to lift stones around you, throwing them in front of you.",
        sound = "",
        cost = 50,
        cooldown = 20,
    })
    
    addPower("Boulder Bash", {
        icon = "hfgjvs/kraken/jedi shad kinetic combat/386211615_908593090.png",
        desc = "Use the Force to lift a boulder from the ground, throwing it in front of you.",
        sound = "",
        cost = 200,
        cooldown = 20,
    })
    
    addPower("Chain Lightning", {
        icon = "hfgjvs/kraken/sith sorc lightning/1808840957_1276001656.png",
        desc = "Use the Force to send lightning at an opponent, chaining between all opponents near them.",
        sound = "",
        cost = 50,
        cooldown = 0,
    })
    
    addPower("Force Shock", {
        icon = "hfgjvs/kraken/sith sorc lightning/2135032387_850460727.png",
        desc = "Use the Force to send a lightning shock at an opponent.",
        sound = "",
        cost = 200,
        cooldown = 20,
    })
    
    addPower("Force Scream", {
        icon = "hfgjvs/kraken/sith jugg immortal/4260692681_1228577604.png",
        desc = "Use the Force to create a powerful scream, using your voice as a weapon.",
        sound = "",
        cost = 200,
        cooldown = 20,
    })
    
    addPower("Lightning Shield", {
        icon = "hfgjvs/kraken/sith sorc lightning/1595507824_993588341.png",
        desc = "Use the Force to create a shield around you made of Force Lightning.",
        sound = "",
        cost = 100,
        cooldown = 25,
    })
    
    addPower("Force Teleport", {
        icon = "hfgjvs/kraken/jedi shad serenity/1813377647_509697541.png",
        desc = "Use the Force to travel through space, teleporting to where you are looking.",
        sound = "",
        cost = 400,
        cooldown = 50,
    })

end

hook.Add("Think", "dsomifgkldfg", function()
	if lastRegister <= CurTime() then
		registerPowers()
		lastRegister = CurTime() + 30 -- Makes sure they're registered. In case of lua refresh & new powers.
	end
end)














