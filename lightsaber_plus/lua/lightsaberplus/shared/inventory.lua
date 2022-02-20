local items = {}

local function Drop(ply, item, hash)
	ply:StripWeapon(item.class)
	return true
end

local function saberEquip(ply, item, hash)
	local wep = ply:Give(item.class)
	if IsValid(wep) then
		wep.hash = hash
		wep:syncLightsaberPlusData("itemClass", item.id)
		for i = 1,10 do
			local quil = itemGetData(hash, "quillon"..i, "")
			if quil != "" then
				local crystalItem = LSP.GetItem(quil)
				if crystalItem then
					local vec = Vector(crystalItem.color.r, crystalItem.color.g, crystalItem.color.b)
					wep:syncLightsaberPlusData("quillon"..i, vec)
					wep:syncLightsaberPlusData("quillonItem"..i, quil)
				end
			end
		end
		for i = 1,10 do
			local blade = itemGetData(hash, "blade"..i, "")
			if blade != "" then
				local crystalItem = LSP.GetItem(blade)
				if crystalItem then
					local vec = Vector(crystalItem.color.r, crystalItem.color.g, crystalItem.color.b)
					wep:syncLightsaberPlusData("blade"..i, vec)
					wep:syncLightsaberPlusData("bladeItem"..i, blade)
				end
			end
		end
	end
end

local function saberOffHand(ply, item, hash)
	local wep = ply:GetActiveWeapon()
	if IsValid(wep) and wep.hash != hash then
		wep.offhash = hash
		wep:syncLightsaberPlusData("OFFHAND-itemClass", item.id)
		for i = 1,10 do
			local quil = itemGetData(hash, "quillon"..i, "")
			if quil != "" then
				local crystalItem = LSP.GetItem(quil)
				if crystalItem then
					local vec = Vector(crystalItem.color.r, crystalItem.color.g, crystalItem.color.b)
					wep:syncLightsaberPlusData("OFFHAND-quillon"..i, vec)
				end
			end
		end
		for i=1,10 do
			local blade = itemGetData(hash, "blade"..i, "")
			if blade != "" then
				local crystalItem = LSP.GetItem(blade)
				if crystalItem then
					local vec = Vector(crystalItem.color.r, crystalItem.color.g, crystalItem.color.b)
					wep:syncLightsaberPlusData("OFFHAND-blade"..i, vec)
				end
			end
		end
	end
end

local saberFuncs = {
	["Unequip"] = {
		canRun = function(ply, item) return true end,
		onRun = function(ply, item) ply:StripWeapon(item.class) end,
	},
	["Equip"] = {
		canRun = function(ply, item, hash) return true end,
		onRun = saberEquip,
	},
	["Off-Hand"] = {
		canRun = function(ply, item, hash) return true end,
		onRun = saberOffHand,
	},
}

function LSP.AddItem(key, data)
	if (data.isMelee or data.isHilt) and not data.disableOverride then
		data.func = saberFuncs
		data.canDrop = Drop
	end

	data.id = key
	items[key] = data

	if nut then
		local cat = "LS+ | Hilts"

		if data.isCrystal then
			cat = "LS+ | Crystals"
		end

		if data.isInner then
			cat = "LS+ | Inners"
		end

		local ITEM = nut.item.register(key, "base_lightsaberplus", nil, nil, true)
		ITEM.name = data.name
		ITEM.desc = data.desc
		ITEM.category = cat
		ITEM.model = data.mdl
		ITEM.base = "base_lightsaberplus"
	end
end

function LSP.GetItem(key)
	return items[key]
end
function LSP.GetItems()
	return items
end


local crystalModels = {
	["blue"] = Color(0,0,255),
	["cyan"] = Color(0,255,255),
	["green"] = Color(0,255,0),
	["lgreen"] = Color(80,255,80),
	["orange"] = Color(255,100,0),
	["pink"] = Color(255, 75, 255),
	["purple"] = Color(100,0,255),
	["red"] = Color(255,0,0),
	["white"] = Color(255,255,255),
	["yellow"] = Color(255,255,0),
}

function createCrystal(name, wm, dmg, onHit, mtl)
	for crystal,color in pairs(crystalModels) do
		local mdl = crystal..wm
		LSP.AddItem("kyber_crystal_" .. string.lower(name).."_"..mdl, {
			name = name.." Kyber Crystal",
			mdl = "models/"..mdl.."/"..mdl..".mdl",
			desc = "+"..dmg.." DMG",
			color = color,
			bladeMaterial = mtl or "saberplussabers/blades/normal.png",
			glowMaterial = "saberplussabers/glows/normal.png",
			trailMaterialLeft = "saberplussabers/trails/trailFadeLeft.png",
			trailMaterialRight = "saberplussabers/trails/trailFadeRight.png",
			trailMaterialOuterLeft = "saberplussabers/trails/glowLeft.png",
			trailMaterialOuterRight = "saberplussabers/trails/glowRight.png",
			isCrystal = true,
			damage = dmg,
			onHit = onHit,
			func = {},
			canDrop = function() return true end
		})
	end
end

hook.Add("LS+.FinishedLoading", "LS+.LoadItems", function()
	hook.Run("LS+.RegisterItems")
	hook.Add("LS+.Reload", "LS+.LoadItems", function()
		hook.Run("LS+.RegisterItems")
	end)
end)


hook.Add("LS+.RegisterItems", "LS+.DefaultItems", function()

createCrystal("Kathracite", "", 10, function(ply, vic, item)end)
createCrystal("Mephite", "2", 25, function(ply, vic, item)end)
createCrystal("Pontite", "3", 50, function(ply, vic, item)end)

LSP.AddItem("crystal_inner_black", {
	name = "Inner: Black",
	mdl = "models/Items/combine_rifle_ammo01.mdl",
	desc = "Emits a black jet of light.",
	color = Color(0,0,0),
	isInner = true,
	func = {},
	canDrop = function() return true end
})

LSP.AddItem("lightsaber_revan", {
	name = "Lightsaber Hilt: Revan",
	mdl = "models/epangelmatikes/revan/lightsaber_b_opt.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_revanite_eu", {
	name = "Lightsaber Hilt: Revanite",
	mdl = "models/epangelmatikes/revan/lightsaber_a_opt.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_tonfa", {
	name = "Lightsaber Hilt: Tonfa",
	mdl = "models/saberplus/xozz/tonfa.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_tonfaforward", {
	name = "Lightsaber Hilt: Tonfa (Forward)",
	mdl = "models/saberplus/xozz/tonfaforward.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_maulunique", {
	name = "Lightsaber Hilt: Maul Unique",
	mdl = "models/xozz/saberplus/xozzyisthebestcoder.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_maulunique_one", {
	name = "Lightsaber Hilt: New Age Maul",
	mdl = "models/xozz/saberplus/xozzyisthebestcoder_dual.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_maulunique_two", {
	name = "Lightsaber Hilt: New Age Maul (Flipped)",
	mdl = "models/xozz/saberplus/xozzyisthebestcoder_flip.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_calamity", {
	name = "Lightsaber Hilt: Calamity",
	mdl = "models/borth-twin/borth-twin.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_creator", {
	name = "Lightsaber Hilt: Creator",
	mdl = "models/lightsaber2/lightsaber2.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_dauntless", {
	name = "Lightsaber Hilt: Dauntless",
	mdl = "models/unknown/unknown.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_elderpike", {
	name = "Lightsaber Hilt: Elder Pike",
	mdl = "models/donation2/donation2.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_equilibrium", {
	name = "Lightsaber Hilt: Equilibrium",
	mdl = "models/theo/theo.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_tridentdual", {
	name = "Lightsaber Hilt: Dual Trident",
	mdl = "models/trident/trident.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_grandsaber", {
	name = "Lightsaber Hilt: Grand Saber",
	mdl = "models/the grand saber/the grand saber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_legendarypike", {
	name = "Lightsaber Hilt: Legendary Pike",
	mdl = "models/donation4/donation4.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_knowledgeseeker", {
	name = "Lightsaber Hilt: The Knowledge Seeker",
	mdl = "models/the knowledge seeker/the knowledge seeker.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_leadership", {
	name = "Lightsaber Hilt: Leadership",
	mdl = "models/lightsaber/lightsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_guardpike", {
	name = "Lightsaber Hilt: Guard Pike",
	mdl = "models/pike/pike.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus", 
	isHilt = true
})

LSP.AddItem("lightsaber_prototypegauntlet", {
	name = "Lightsaber Hilt: Prototype Gauntlet",
	mdl = "models/gauntlet/gauntlet.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_thepurist", {
	name = "Lightsaber Hilt: The Purist",
	mdl = "models/donation7/donation7.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus", 
	isHilt = true
})

LSP.AddItem("lightsaber_shade", {
	name = "Lightsaber Hilt: Shade",
	mdl = "models/dani/dani.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus", 
	isHilt = true
})

LSP.AddItem("lightsaber_sheen", {
	name = "Lightsaber Hilt: Sheen",
	mdl = "models/lightsaber4/lightsaber4.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus", 
	isHilt = true
})

LSP.AddItem("lightsaber_slayer", {
	name = "Lightsaber Hilt: Slayer Gauntlet",
	mdl = "models/donation gauntlet/donation gauntlet.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus", 
	isHilt = true
})

LSP.AddItem("lightsaber_snake", {
	name = "Lightsaber Hilt: Snake Pike",
	mdl = "models/snake/snake.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus", 
	isHilt = true
})

LSP.AddItem("lightsaber_snake2", {
	name = "Lightsaber Hilt: Dual Snake Pike",
	mdl = "models/snake2/snake2.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus", 
	isHilt = true
})

LSP.AddItem("lightsaber_sorceror", {
	name = "Lightsaber Hilt: Sorceror",
	mdl = "models/dylanxd/dylanxd.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus", 
	isHilt = true
})

LSP.AddItem("lightsaber_gentleman", {
	name = "Lightsaber Hilt: The Gentleman",
	mdl = "models/lightsaber3/lightsaber3.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus", 
	isHilt = true
})

LSP.AddItem("lightsaber_trident", {
	name = "Lightsaber Hilt: The Trident",
	mdl = "models/dante/dante.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_twinsaber", {
	name = "Lightsaber Hilt: Twin Saber",
	mdl = "models/twinsaber/twinsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_valorpike", {
	name = "Lightsaber Hilt: Valor Pike",
	mdl = "models/donation1/donation1.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_weeks", {
	name = "Lightsaber Hilt: Weeks",
	mdl = "models/days/days.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_wither", {
	name = "Lightsaber Hilt: Wither",
	mdl = "models/donation3/donation3.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_training", {
	name = "Lightsaber Hilt: Training Saber",
	mdl = "models/training/training.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_aayla", {
	name = "Lightsaber Hilt: Aayla Secura",
	mdl = "models/starwars/cwa/lightsabers/aaylasecura.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_adigalia", {
	name = "Lightsaber Hilt: Adi Galia",
	mdl = "models/starwars/cwa/lightsabers/adigalia.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_ahsokatano", {
	name = "Lightsaber Hilt: Ahsoka Tano",
	mdl = "models/starwars/cwa/lightsabers/ahsoka.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_byph", {
	name = "Lightsaber Hilt: Byph",
	mdl = "models/starwars/cwa/lightsabers/byph.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_compressor", {
	name = "Lightsaber Hilt: Compressor",
	mdl = "models/starwars/cwa/lightsabers/compressedcrystal.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_darkforce", {
	name = "Lightsaber Hilt: Dark Force Phase 1",
	mdl = "models/starwars/cwa/lightsabers/darkforcephase1.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_darkforce_2", {
	name = "Lightsaber Hilt: Dark Force Phase 2",
	mdl = "models/starwars/cwa/lightsabers/darkforcephase2.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_darkknight", {
	name = "Lightsaber Hilt: Dark Knight Phase 1",
	mdl = "models/starwars/cwa/lightsabers/darkknight1.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_darkknight_2", {
	name = "Lightsaber Hilt: Dark Knight Phase 2",
	mdl = "models/starwars/cwa/lightsabers/darkknight2.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_darksaber", {
	name = "Lightsaber Hilt: Dark Saber",
	mdl = "models/starwars/cwa/lightsabers/darksaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_darksaber_ancient", {
	name = "Lightsaber Hilt: Ancient Dark Saber",
	mdl = "models/starwars/cwa/lightsabers/darksaberancient.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_exile", {
	name = "Lightsaber Hilt: Exile",
	mdl = "models/starwars/cwa/lightsabers/exile.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_felucia", {
	name = "Lightsaber Hilt: Felucian Hilt",
	mdl = "models/starwars/cwa/lightsabers/felucia1.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_felucia_two", {
	name = "Lightsaber Hilt: Ancient Felucian Hilt",
	mdl = "models/starwars/cwa/lightsabers/felucia2.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_forked", {
	name = "Lightsaber Hilt: Forked Hilt",
	mdl = "models/starwars/cwa/lightsabers/forked.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_ganodi", {
	name = "Lightsaber Hilt: Ganodi Hilt",
	mdl = "models/starwars/cwa/lightsabers/ganodi.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_gungan", {
	name = "Lightsaber Hilt: Gungan Hilt",
	mdl = "models/starwars/cwa/lightsabers/gungan.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_gungi", {
	name = "Lightsaber Hilt: Gungi's Hilt",
	mdl = "models/starwars/cwa/lightsabers/gungi.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_jocastanu", {
	name = "Lightsaber Hilt: Jocasta Nu's Hilt",
	mdl = "models/starwars/cwa/lightsabers/jocastanu.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_kashyyyk", {
	name = "Lightsaber Hilt: Kashyyyk Hilt",
	mdl = "models/starwars/cwa/lightsabers/kashyyyk.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_katooni", {
	name = "Lightsaber Hilt: Katooni Hilt",
	mdl = "models/starwars/cwa/lightsabers/katooni.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_kitfisto", {
	name = "Lightsaber Hilt: Kit Fisto's Hilt",
	mdl = "models/starwars/cwa/lightsabers/kitfisto.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_lighsideaffiliation", {
	name = "Lightsaber Hilt: Light Side Hilt",
	mdl = "models/starwars/cwa/lightsabers/lightsideaffiliation.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_luminara", {
	name = "Lightsaber Hilt: Luminara's Hilt",
	mdl = "models/starwars/cwa/lightsabers/luminara.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_petro", {
	name = "Lightsaber Hilt: Petro's Hilt",
	mdl = "models/starwars/cwa/lightsabers/petro.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_pulsating", {
	name = "Lightsaber Hilt: Pulsating Hilt",
	mdl = "models/starwars/cwa/lightsabers/pulsating.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_pulsating_2", {
	name = "Lightsaber Hilt: Ancient Pulsating Hilt",
	mdl = "models/starwars/cwa/lightsabers/pulsatingblue.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_ahsoka_2", {
	name = "Lightsaber Hilt: Ahsoka's Offhand",
	mdl = "models/starwars/cwa/lightsabers/reverseahsoka.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_saesee", {
	name = "Lightsaber Hilt: Saesee Tiin's Saber",
	mdl = "models/starwars/cwa/lightsabers/saeseetiin.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_samurai", {
	name = "Lightsaber Hilt: Samurai Hilt",
	mdl = "models/starwars/cwa/lightsabers/samurai.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_shaakti", {
	name = "Lightsaber Hilt: Shaak Ti's Hilt",
	mdl = "models/starwars/cwa/lightsabers/shaakti.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_sparking", {
	name = "Lightsaber Hilt: Sparkling Saber",
	mdl = "models/starwars/cwa/lightsabers/sparklingcrystal.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_spiralling", {
	name = "Lightsaber Hilt: Spiralling Saber",
	mdl = "models/starwars/cwa/lightsabers/spiralling.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_talz", {
	name = "Lightsaber Hilt: Talz' Saber",
	mdl = "models/starwars/cwa/lightsabers/talz.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_youngling", {
	name = "Lightsaber Hilt: Youngling's Saber",
	mdl = "models/starwars/cwa/lightsabers/training.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_unstable", {
	name = "Lightsaber Hilt: Unstable Hilt",
	mdl = "models/starwars/cwa/lightsabers/unstable.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_ventress", {
	name = "Lightsaber Hilt: Ventress' Hilt",
	mdl = "models/starwars/cwa/lightsabers/ventress.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_zatt", {
	name = "Lightsaber Hilt: Zatt's Hilt",
	mdl = "models/starwars/cwa/lightsabers/zatt.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_zebra", {
	name = "Lightsaber Hilt: Zebra Hilt",
	mdl = "models/starwars/cwa/lightsabers/zebra.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_adascorppole", {
	name = "Lightsaber Hilt: Adas Corp. Pole Saber",
	mdl = "models/swtor/arsenic/lightsabers/adascorppolesaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_antiquesocorrolightsaber", {
	name = "Lightsaber Hilt: Antique Socorroli Lightsaber",
	mdl = "models/swtor/arsenic/lightsabers/antiquesocorrolightsaberbesh.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_antiquesocorrolightsaber_cresh", {
	name = "Lightsaber Hilt: Antique Socorroli Lightsaber Cresh",
	mdl = "models/swtor/arsenic/lightsabers/antiquesocorrolightsabercresh.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_antiquesocorrolightsaber_dorn", {
	name = "Lightsaber Hilt: Antique Socorroli Lightsaber Dorn",
	mdl = "models/swtor/arsenic/lightsabers/antiquesocorrolightsaberdorn.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_antiquesocorrolightsaberstaff", {
	name = "Lightsaber Hilt: Antique Socorroli Staff",
	mdl = "models/swtor/arsenic/lightsabers/antiquesocorrosaberstaffaurek.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_antiquesocorrolightsaberstaff_dorn", {
	name = "Lightsaber Hilt: Antique Socorroli Staff Dorn",
	mdl = "models/swtor/arsenic/lightsabers/antiquesocorrosaberstaffdorn.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_arakydsaber", {
	name = "Lightsaber Hilt: Arakyd Saber",
	mdl = "models/swtor/arsenic/lightsabers/arakydsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_ardentdefender", {
	name = "Lightsaber Hilt: Ardent Defender Dual Saber",
	mdl = "models/swtor/arsenic/lightsabers/ardentdefender'sdualsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_ardentdefender_lightsaber", {
	name = "Lightsaber Hilt: Ardent Defender Lightsaber",
	mdl = "models/swtor/arsenic/lightsabers/ardentdefender'slightsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_artusianlightsaber", {
	name = "Lightsaber Hilt: Artusian Lightsaber",
	mdl = "models/swtor/arsenic/lightsabers/artusianlightsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_artusiansaberstaff", {
	name = "Lightsaber Hilt: Artusian Saber Staff",
	mdl = "models/swtor/arsenic/lightsabers/artusiansaberstaff.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_asharaslightsaber", {
	name = "Lightsaber Hilt: Ashara's Lightsaber",
	mdl = "models/swtor/arsenic/lightsabers/ashara'slightsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_attunedforcelord", {
	name = "Lightsaber Hilt: Attuned Force Lord's Saber Staff",
	mdl = "models/swtor/arsenic/lightsabers/attunedforcelord'ssaberstaff.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_blademastersattenuated", {
	name = "Lightsaber Hilt: Blade Master's Lightsaber",
	mdl = "models/swtor/arsenic/lightsabers/blademaster'sattenuatedlightsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_blademastersattenuated_staff", {
	name = "Lightsaber Hilt: Blade Master's Saber Staff",
	mdl = "models/swtor/arsenic/lightsabers/blademaster'sattenuatedsaberstaff.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_blademastersattenuated_shoto", {
	name = "Lightsaber Hilt: Blade Master's Shoto Blade",
	mdl = "models/swtor/arsenic/lightsabers/blademaster'sattenuatedshoto.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_blademastersattenuated_ancient", {
	name = "Lightsaber Hilt: Ancient Blade Master's Lightsaber",
	mdl = "models/swtor/arsenic/lightsabers/blademaster'slightsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_blademastersattenuatedstaff_ancient", {
	name = "Lightsaber Hilt: Ancient Blade Master's Saber Staff",
	mdl = "models/swtor/arsenic/lightsabers/blademaster'ssaberstaff.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_blademastersattenuatedshoto_ancient", {
	name = "Lightsaber Hilt: Ancient Blade Master's Shoto",
	mdl = "models/swtor/arsenic/lightsabers/blademaster'sshoto.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_challenger", {
	name = "Lightsaber Hilt: Challenger's Saber",
	mdl = "models/swtor/arsenic/lightsabers/challenger'slightsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_cchrysopaz", {
	name = "Lightsaber Hilt: Chrysopaz Saber",
	mdl = "models/swtor/arsenic/lightsabers/chrysopazlightsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_chrysopazsaberstaff", {
	name = "Lightsaber Hilt: Chrysopaz Saber Staff",
	mdl = "models/swtor/arsenic/lightsabers/chrysopazsaberstaff.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_conqueror", {
	name = "Lightsaber Hilt: Conqueror's Saber",
	mdl = "models/swtor/arsenic/lightsabers/conqueror'slightsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_conquerorsaberstaff", {
	name = "Lightsaber Hilt: Conqueror's Saber Staff",
	mdl = "models/swtor/arsenic/lightsabers/conqueror'ssaberstaff.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_coruscalightsaber", {
	name = "Lightsaber Hilt: Coruscant Saber",
	mdl = "models/swtor/arsenic/lightsabers/coruscalightsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_coruscalightsaberstaff", {
	name = "Lightsaber Hilt: Coruscant Saber Staff",
	mdl = "models/swtor/arsenic/lightsabers/coruscasaberstaff.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_custom-builtdoublebladedsaber", {
	name = "Lightsaber Hilt: Ancient Dual Bladed Hilt",
	mdl = "models/swtor/arsenic/lightsabers/custom-builtdoublebladedsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_darkreveriedoublebladedsaber", {
	name = "Lightsaber Hilt: Dark Reverie Double-Bladed Hilt",
	mdl = "models/swtor/arsenic/lightsabers/darkreveriedoublebladedsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_darkseekersdoublebladedsaber", {
	name = "Lightsaber Hilt: Dark Seeker's Staff",
	mdl = "models/swtor/arsenic/lightsabers/darkseeker'sdoublebladedsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_dauntlessavengerslightsaber", {
	name = "Lightsaber Hilt: Dauntless Avenger's Saber",
	mdl = "models/swtor/arsenic/lightsabers/dauntlessavenger'slightsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_defenderlightsaber", {
	name = "Lightsaber Hilt: Ancient Defender's Saber",
	mdl = "models/swtor/arsenic/lightsabers/defender'slightsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_defianttechnographerdualsaber", {
	name = "Lightsaber Hilt: Defiant Technographer's Dual Saber",
	mdl = "models/swtor/arsenic/lightsabers/defianttechnographer'sdualsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_defianttechnographerlgihtsaber", {
	name = "Lightsaber Hilt: Defiant Technographer's Hilt",
	mdl = "models/swtor/arsenic/lightsabers/defianttechnographer'slightsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_defianttechnographerlgihtsabershoto", {
	name = "Lightsaber Hilt: Defiant Technographer's Shoto",
	mdl = "models/swtor/arsenic/lightsabers/defianttechnographer'sshoto.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_derelictlightsaber", {
	name = "Lightsaber Hilt: Derelict Saber",
	mdl = "models/swtor/arsenic/lightsabers/derelictlightsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_derelictsaberstaff", {
	name = "Lightsaber Hilt: Derelict Saber Staff",
	mdl = "models/swtor/arsenic/lightsabers/derelictsaberstaff.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_descendantsheirloomdualsaber", {
	name = "Lightsaber Hilt: Descendant's Heirloom Dual Saber",
	mdl = "models/swtor/arsenic/lightsabers/descendant'sheirloomdualsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_desolatorsstarforgeddualsaber", {
	name = "Lightsaber Hilt: Desolator's Star Forged Dual Saber",
	mdl = "models/swtor/arsenic/lightsabers/desolator'sstarforgeddualsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_despotsdualsaber", {
	name = "Lightsaber Hilt: Despot's Dual Saber",
	mdl = "models/swtor/arsenic/lightsabers/despot'sdualsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_devastatorsdoublebladedlightsaber", {
	name = "Lightsaber Hilt: Devastator's Dual Saber",
	mdl = "models/swtor/arsenic/lightsabers/devastator'sdoublebladedlightsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_diabolistlightsaber", {
	name = "Lightsaber Hilt: Diabolist Saber",
	mdl = "models/swtor/arsenic/lightsabers/diabolistlightsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_dragonpearllightsaber", {
	name = "Lightsaber Hilt: Dragon Pearl Saber",
	mdl = "models/swtor/arsenic/lightsabers/dragonpearllightsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_dragonpearlsaberstaff", {
	name = "Lightsaber Hilt: Dragon Pearl Saber Staff",
	mdl = "models/swtor/arsenic/lightsabers/dragonpearlsaberstaff.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_elegantmodifieddoublebladedsaber", {
	name = "Lightsaber Hilt: Elegant Modified Dual Saber",
	mdl = "models/swtor/arsenic/lightsabers/elegantmodifieddoublebladedsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_etchedduelerdualsaber", {
	name = "Lightsaber Hilt: Etched Dueler's Dual Saber",
	mdl = "models/swtor/arsenic/lightsabers/etchedduelerdualsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_eternalcommandermk-14saberstaff", {
	name = "Lightsaber Hilt: Eternal Commender MK-14 Staff Saber",
	mdl = "models/swtor/arsenic/lightsabers/eternalcommandermk-14saberstaff.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_eternalcommandermk-14lightsaber", {
	name = "Lightsaber Hilt: Eternal Commender MK-14 Saber",
	mdl = "models/swtor/arsenic/lightsabers/eternalcommandermk-4lightsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_exarch'smk-1lightsaber", {
	name = "Lightsaber Hilt: Exarch's MK-1 Saber",
	mdl = "models/swtor/arsenic/lightsabers/exarch'smk-1lightsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_exarch'smk-2lightsaber", {
	name = "Lightsaber Hilt: Exarch's MK-2 Saber",
	mdl = "models/swtor/arsenic/lightsabers/exarch'smk-2lightsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_executioner'slightsaber", {
	name = "Lightsaber Hilt: Executioner's Hilt",
	mdl = "models/swtor/arsenic/lightsabers/executioner'slightsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_exquisitechampiondualsaber", {
	name = "Lightsaber Hilt: Exquisite Champion Dual Saber",
	mdl = "models/swtor/arsenic/lightsabers/exquisitechampiondualsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_fearlessretaliator'slightsaber", {
	name = "Lightsaber Hilt: Fearless Retaliator's Saber",
	mdl = "models/swtor/arsenic/lightsabers/fearlessretaliator'slightsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_fearlessretaliator'ssaberstaff", {
	name = "Lightsaber Hilt: Fearless Retaliator's Saber Staff",
	mdl = "models/swtor/arsenic/lightsabers/fearlessretaliator'ssaberstaff.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_firenodelightsaber", {
	name = "Lightsaber Hilt: Fire Node Saber",
	mdl = "models/swtor/arsenic/lightsabers/firenodelightsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_frontierhunter'sdualsaber", {
	name = "Lightsaber Hilt: Frontier Hunter's Dual Saber",
	mdl = "models/swtor/arsenic/lightsabers/frontierhunter'sdualsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_frontierhunter'slightsaber", {
	name = "Lightsaber Hilt: Frontier Hunter's Saber",
	mdl = "models/swtor/arsenic/lightsabers/frontierhunter'slightsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_geminimk-4lightsaber", {
	name = "Lightsaber Hilt: Gemini MK-4 Saber",
	mdl = "models/swtor/arsenic/lightsabers/geminimk-4lightsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_grantekf11-ddualsaber", {
	name = "Lightsaber Hilt: Grantek F-11D Dual Saber",
	mdl = "models/swtor/arsenic/lightsabers/grantekf11-ddualsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_grantekf11-dsaber", {
	name = "Lightsaber Hilt: Grantek F-11D Saber",
	mdl = "models/swtor/arsenic/lightsabers/grantekf11-dlightsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_herald'spolesaber", {
	name = "Lightsaber Hilt: Herald's Pole Saber",
	mdl = "models/swtor/arsenic/lightsabers/herald'spolesaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_hermit'spolesaber", {
	name = "Lightsaber Hilt: Hermit's Pole Saber",
	mdl = "models/swtor/arsenic/lightsabers/hermit'spolesaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_hiridulightsaber", {
	name = "Lightsaber Hilt: Hiridu Lightsaber",
	mdl = "models/swtor/arsenic/lightsabers/hiridulightsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_hiridusaberstaff", {
	name = "Lightsaber Hilt: Hiridu Saber Staff",
	mdl = "models/swtor/arsenic/lightsabers/hiridusaberstaff.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_ice-jewellightsaber", {
	name = "Lightsaber Hilt: Ice-Jewel Saber",
	mdl = "models/swtor/arsenic/lightsabers/ice-jewellightsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_indomitablevanquisher'ssaberstaff", {
	name = "Lightsaber Hilt: Indomitable Vanquisher's Saber Staff",
	mdl = "models/swtor/arsenic/lightsabers/indomitablevanquisher'ssaberstaff.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_inscrutabledualsaber", {
	name = "Lightsaber Hilt: Inscrutable Dual Saber",
	mdl = "models/swtor/arsenic/lightsabers/inscrutabledualsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_instigator'slightsaber", {
	name = "Lightsaber Hilt: Instigator's Saber",
	mdl = "models/swtor/arsenic/lightsabers/instigator'slightsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_iokathmk-4saberstaff", {
	name = "Lightsaber Hilt: Iokath MK-4 Saber Staff",
	mdl = "models/swtor/arsenic/lightsabers/iokathmk-4saberstaff.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_mytaglightsaber", {
	name = "Lightsaber Hilt: Mytag Saber",
	mdl = "models/swtor/arsenic/lightsabers/mytaglightsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_novalightsaber", {
	name = "Lightsaber Hilt: Nova Saber",
	mdl = "models/swtor/arsenic/lightsabers/novalightsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_occultists'polesabermk1", {
	name = "Lightsaber Hilt: Occultist's Pole Saber",
	mdl = "models/swtor/arsenic/lightsabers/occultists'polesabermk1.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_outlanderlightsaber", {
	name = "Lightsaber Hilt: Outlander Hilt",
	mdl = "models/swtor/arsenic/lightsabers/outlanderlightsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_outlanderlightsaber2", {
	name = "Lightsaber Hilt: Outlander Hilt MK-2",
	mdl = "models/swtor/arsenic/lightsabers/outlanderlightsaber2.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_outlanderpolesaber", {
	name = "Lightsaber Hilt: Outlander Pole Saber",
	mdl = "models/swtor/arsenic/lightsabers/outlanderpolesaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_outlanderpolesaber2", {
	name = "Lightsaber Hilt: Outlander Pole Saber MK-2",
	mdl = "models/swtor/arsenic/lightsabers/outlanderpolesaber2.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_overseer'slightsaber", {
	name = "Lightsaber Hilt: Overseer's Saber Hilt",
	mdl = "models/swtor/arsenic/lightsabers/overseer'slightsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_pitilessraiderlightsaber", {
	name = "Lightsaber Hilt: Pitiless Raider Saber",
	mdl = "models/swtor/arsenic/lightsabers/pitilessraiderlightsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_praetorian'slightsaber", {
	name = "Lightsaber Hilt: Praetorian's Saber",
	mdl = "models/swtor/arsenic/lightsabers/praetorian'slightsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_prophet'sstarforgeddualsaber", {
	name = "Lightsaber Hilt: Prophet's Star Forged Dual Saber",
	mdl = "models/swtor/arsenic/lightsabers/prophet'sstarforgeddualsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_reckoning'sexposedlightsaber", {
	name = "Lightsaber Hilt: Reckoning's Exposed Saber",
	mdl = "models/swtor/arsenic/lightsabers/reckoning'sexposedlightsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_reckoning'sexposedsaberstaff", {
	name = "Lightsaber Hilt: Reckoning's Exposed Saber Staff",
	mdl = "models/swtor/arsenic/lightsabers/reckoning'sexposedsaberstaff.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_redeemer'sstarforgeddualsaber", {
	name = "Lightsaber Hilt: Redeemer's Star Forged Dual Saber",
	mdl = "models/swtor/arsenic/lightsabers/redeemer'sstarforgeddualsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_retribution'sexposedlightsaber", {
	name = "Lightsaber Hilt: Retribution's Exposed Saber",
	mdl = "models/swtor/arsenic/lightsabers/retribution'sexposedlightsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_revanite'smk-1lightsaber", {
	name = "Lightsaber Hilt: Revanite's MK-1 Saber",
	mdl = "models/swtor/arsenic/lightsabers/revanite'smk-1lightsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_revanite'smk-1polesaber", {
	name = "Lightsaber Hilt: Revanite's MK-1 Pole Saber",
	mdl = "models/swtor/arsenic/lightsabers/revanite'smk-1polesaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_revanite'smk-2saber", {
	name = "Lightsaber Hilt: Revanite's MK-2 Saber",
	mdl = "models/swtor/arsenic/lightsabers/revanite'smk-2lightsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_revanite'smk-2polesaber", {
	name = "Lightsaber Hilt: Revanite's MK-2 Pole Saber",
	mdl = "models/swtor/arsenic/lightsabers/revanite'smk-2polesaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_righteousprimevallightsaber", {
	name = "Lightsaber Hilt: Righteous Primeval Saber",
	mdl = "models/swtor/arsenic/lightsabers/righteousprimevallightsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_rishi'slightsabermk-1", {
	name = "Lightsaber Hilt: Rishi's Saber MK-1",
	mdl = "models/swtor/arsenic/lightsabers/rishi'slightsabermk-1.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_rishi'smk-1polesaber", {
	name = "Lightsaber Hilt: Rishi's Pole Saber MK-1",
	mdl = "models/swtor/arsenic/lightsabers/rishi'smk-1polesaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_sateleshan'sdualsaber", {
	name = "Lightsaber Hilt: Satele Shan's Dual Saber",
	mdl = "models/swtor/arsenic/lightsabers/sateleshan'sdualsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_sateleshan'ssparringlightsaber", {
	name = "Lightsaber Hilt: Satele Shan's Sparring Saber",
	mdl = "models/swtor/arsenic/lightsabers/sateleshan'ssparringlightsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_senyatirall'slightsaber-cartel", {
	name = "Lightsaber Hilt: Senya Tirall's Dual Saber",
	mdl = "models/swtor/arsenic/lightsabers/senyatirall'slightsaber-cartel.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_senyatirall'slightsaber-companion", {
	name = "Lightsaber Hilt: Senya Tirall's Saber",
	mdl = "models/swtor/arsenic/lightsabers/senyatirall'slightsaber-companion.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_serenity'sunsealedsaberstaff", {
	name = "Lightsaber Hilt: Serenity's Unsealed Saber Staff",
	mdl = "models/swtor/arsenic/lightsabers/serenity'sunsealedsaberstaff.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_strongholddefender'slightsaber", {
	name = "Lightsaber Hilt: Stronghold Defender's Saber",
	mdl = "models/swtor/arsenic/lightsabers/strongholddefender'slightsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_strongholddefender'ssaberstaff", {
	name = "Lightsaber Hilt: Stronghold Defender's Saber Staff",
	mdl = "models/swtor/arsenic/lightsabers/strongholddefender'ssaberstaff.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_temptedapprentice'sdualsaber", {
	name = "Lightsaber Hilt: Tempted Apprentice's Dual Saber",
	mdl = "models/swtor/arsenic/lightsabers/temptedapprentice'sdualsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_temptedapprentice'ssaber", {
	name = "Lightsaber Hilt: Tempted Apprentice's Saber",
	mdl = "models/swtor/arsenic/lightsabers/temptedapprentice'slightsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_thermallightsabermk-3", {
	name = "Lightsaber Hilt: Thermal Saber MK-3",
	mdl = "models/swtor/arsenic/lightsabers/thermallightsabermk-3.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_thexan'slightsaber", {
	name = "Lightsaber Hilt: Thexan's Saber",
	mdl = "models/swtor/arsenic/lightsabers/thexan'slightsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_tythianlightsaber", {
	name = "Lightsaber Hilt: Tythonian Saber",
	mdl = "models/swtor/arsenic/lightsabers/tythianlightsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_tythianforce-masterlightsaber", {
	name = "Lightsaber Hilt: Tythonian Force-Master's Saber",
	mdl = "models/swtor/arsenic/lightsabers/tythonianforce-master'slightsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_unrelentingaggressordualsaber", {
	name = "Lightsaber Hilt: Unrelenting Aggressor Dual Saber",
	mdl = "models/swtor/arsenic/lightsabers/unrelentingaggressordualsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_unstablearbiter'sdualsaber", {
	name = "Lightsaber Hilt: Unstable Arbiter's Dual Saber",
	mdl = "models/swtor/arsenic/lightsabers/unstablearbiter'sdualsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_unstablearbiter'slightsaber", {
	name = "Lightsaber Hilt: Unstable Arbiter's Saber",
	mdl = "models/swtor/arsenic/lightsabers/unstablearbiter'slightsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_unstablepeacemaker'sdualsaber", {
	name = "Lightsaber Hilt: Unstable Peacemaker's Dual Saber",
	mdl = "models/swtor/arsenic/lightsabers/unstablepeacemaker'sdualsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_unstablepeacemaker'slightsaber", {
	name = "Lightsaber Hilt: Unstable Peacemaker's Saber",
	mdl = "models/swtor/arsenic/lightsabers/unstablepeacemaker'slightsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_vengeance'sunsealedlightsaber", {
	name = "Lightsaber Hilt: Vengeance's Unsealed Saber",
	mdl = "models/swtor/arsenic/lightsabers/vengeance'sunsealedlightsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_vengeance'sunsealedsaberstaff", {
	name = "Lightsaber Hilt: Vengeance's Unsealed Saber Staff",
	mdl = "models/swtor/arsenic/lightsabers/vengeance'sunsealedsaberstaff.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_vigorousbattlerdualsaber", {
	name = "Lightsaber Hilt: Vigorous Battler Dual Saber",
	mdl = "models/swtor/arsenic/lightsabers/vigorousbattlerdualsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_vindicator'slightsaber", {
	name = "Lightsaber Hilt: Vindicator's Saber",
	mdl = "models/swtor/arsenic/lightsabers/vindicator'slightsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_vindicator'ssaberstaff", {
	name = "Lightsaber Hilt: Vindicator's Saber Staff",
	mdl = "models/swtor/arsenic/lightsabers/vindicator'ssaberstaff.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_warden'slightsaber", {
	name = "Lightsaber Hilt: Warden's Saber",
	mdl = "models/swtor/arsenic/lightsabers/warden'slightsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_warmaster'sdoublebladedlightsaber", {
	name = "Lightsaber Hilt: Warmaster's Double Bladed Saber",
	mdl = "models/swtor/arsenic/lightsabers/warmaster'sdoublebladedlightsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_zakuulan'smk-1polesaber", {
	name = "Lightsaber Hilt: Zakuulan's MK-1 Pole Saber",
	mdl = "models/swtor/arsenic/lightsabers/zakuulan'smk-1polesaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_zakuulan'smk-2polesaber", {
	name = "Lightsaber Hilt: Zakuulan's MK-2 Pole Saber",
	mdl = "models/swtor/arsenic/lightsabers/zakuulan'smk-2polesaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_ziostguardian'slightsaber", {
	name = "Lightsaber Hilt: Zoist Guardian's Saber",
	mdl = "models/swtor/arsenic/lightsabers/ziostguardian'slightsaber.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

LSP.AddItem("lightsaber_kylo_ren", {
	name = "Lightsaber Hilt: Kylo Ren",
	mdl = "models/weapons/starwars/w_kr_hilt.mdl",
	desc = "Standard Weapons",
	class = "lightsaber_plus",
	isHilt = true
})

end)