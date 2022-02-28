ITEM.name = "Lightsaber+"
ITEM.model = "models/Items/BoxSRounds.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.desc = "If you see this, there's a really big fucking problem."
ITEM.category = "Lightsaber+"

function ITEM:getDesc()
	return self.desc
end
/* --// Keeping this cuz i need it for later lol.
ITEM.functions.consume = {
	name = "Consume",
	tip = "",
	icon = "icon16/heart.png",
	onRun = function(item)

		item.player:EmitSound("npc/barnacle/barnacle_gulp1.wav")
		item.player:getChar():setData("hungerRestore", math.Clamp(item.player:getChar():getData("hungerRestore", 0) + item.hungerRestore,0,100))
		item.player:SetHealth(math.Clamp(item.healthRestore + item.player:Health(),0,item.player:GetMaxHealth()))
		return true
	end,
	onCanRun = function(item)
		local canUse = false

		if item.hungerRestore > 0 or item.healthRestore > 0 then
			canUse = true
		end

		return (!IsValid(item.entity) and canUse)
	end
}
*/