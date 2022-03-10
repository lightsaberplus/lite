SWEP.PrintName = "Lightsaber"
SWEP.Author = "Lightsaber ++ Team"
SWEP.Category = "Lightsaber ++"

SWEP.Slot = 0
SWEP.SlotPos = 1

SWEP.Spawnable = true
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.Secondary.Automatic = true
SWEP.ViewModel = ""
SWEP.WorldModel = ""

SWEP.isCustomizable = true
SWEP.isLightsaberPlus = true

SWEP.Primary.ClipSize = -1
SWEP.Secondary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Primary.Ammo = "Love"
SWEP.Secondary.Ammo = "Love"

function SWEP:getInt(blade, key, def)
	return self:getsyncLightsaberPlusData(blade..key,def)
end

function SWEP:getString(blade, key, def)
	return self:getsyncLightsaberPlusData(blade..key,def)
end

function SWEP:getColor(blade, key)
	local col = self:getsyncLightsaberPlusData(blade..key,Vector(0,0,0))
	return Color(col.x, col.y, col.z)
end

function SWEP:Initialize()

end

function SWEP:ShouldDropOnDie()
	return false
end