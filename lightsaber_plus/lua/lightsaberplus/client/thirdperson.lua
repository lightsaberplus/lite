local removeBones = {
	"ValveBiped.Bip01_Head1",
	"ValveBiped.Bip01_Neck1"
}
-- Shoutout to amp for showing me how to do this. <3
local holdTypes = {
	melee2 		= {up = 1, forward = 6, right = 3},
	ar2 		= {up = 3, forward = 8, right = 2},
	revolver 	= {up = 3, forward = 8, right = 2},
	pistol 		= {up = 3, forward = 8, right = 4},
	smg 		= {up = 3, forward = 8, right = 2},
	shotgun 	= {up = 3, forward = 8, right = -4},
	grenade 	= {up = 3, forward = 11, right = 2},
	rpg 		= {up = 3, forward = 8, right = 0},
	physgun 	= {up = 3, forward = 8, right = -4},
	crossbow 	= {up = 3, forward = 8, right = -4},
	melee 		= {up = 3, forward = 11, right = 2},
	slam 		= {up = 3, forward = 8, right = 2},
	normal 		= {up = 3, forward = 12, right = 2},
	idle 		= {up = 3, forward = 16, right = 2},
	passive		= {up = 3, forward = 16, right = 2},
	fist 		= {up = 3, forward = 8, right = 2},
	knife 		= {up = 3, forward = 8, right = 2},
	duel 		= {up = 3, forward = 8, right = 2},
	camera 		= {up = 3, forward = 8, right = 2},
}

local thirdperson = false
LIGHTSABER_PLUS_3P_LROFF = cookie.GetNumber("LIGHTSABER_PLUS_3P_LROFF", 0)
LIGHTSABER_PLUS_3P_FWOFF = cookie.GetNumber("LIGHTSABER_PLUS_3P_FWOFF", 125)
LIGHTSABER_PLUS_3P_UDOFF = cookie.GetNumber("LIGHTSABER_PLUS_3P_UDOFF", 0)
LIGHTSABER_PLUS_3P_ANGOFF = cookie.GetNumber("LIGHTSABER_PLUS_3P_ANGOFF", 0)

local headPos = Vector(0,0,0)
local headAng = Angle(0,0,0)
local eyesLerp = Angle(0,0,0)

hook.Add("CalcView", "CL_Secondpersonz44", function(ply, pos, ang, fov)
	local wep = ply:GetActiveWeapon()
	if !IsValid(wep) then return end
	if IsValid(ply:GetVehicle()) then return end

	if ply:getsyncLightsaberPlusData("crafting", false) then

		local saberPos = ply.rightHilt:GetPos() + ply.rightHilt:GetUp() * -50 + ply.rightHilt:GetRight() * 60  + ply.rightHilt:GetForward() * 20
		local saberAng = Angle(15,ply:GetAngles().y + 180,0)

		//if ply:getsyncLightsaberPlusData("isLeft", false) then
		//	saberPos = ply.leftHilt:GetPos() + ply.leftHilt:GetUp() * -50 + ply.leftHilt:GetRight() * 60  + ply.leftHilt:GetForward() * 20
		//end

		if saberPos.z < ply:GetPos().z + 10 then
			saberPos = Vector(saberPos.x, saberPos.y, ply:GetPos().z + 10)
		end

		if headPos == Vector(0,0,0) then headPos = saberPos end
		if headAng == Angle(0,0,0) then headAng = saberAng end

		local speed = 3

		headPos = LerpVector(FrameTime()*speed, headPos, saberPos)
		headAng = LerpAngle(FrameTime()*speed, headAng, saberAng)

		return {
			origin = headPos,
			angles = headAng,
			fov = 74,
			drawviewer = true
		}
	else
		if headPos != Vector(0,0,0) then headPos = Vector(0,0,0) end
		if headAng != Angle(0,0,0) then headAng = Angle(0,0,0) end
		if LSP.Config.EnableThirdPersonSys then
			local holdType = wep:GetHoldType()

			if !holdTypes[holdType] then return end
			if !wep.isLightsaberPlus then return end

			local eyes = ply:GetAttachment(ply:LookupAttachment("eyes"))
			--local eyes = {Pos = ply:GetPos() + Vector(-5,10,55)}	-- edited 

			local up = holdTypes[holdType].up
			local forward = holdTypes[holdType].forward
			local right = holdTypes[holdType].right

			if thirdperson then
				if headPos == Vector(0,0,0) then headPos = eyes.Pos end
				if headAng == Angle(0,0,0) then headAng = ang + Angle(LIGHTSABER_PLUS_3P_ANGOFF,0,0) end
				local backTrace = util.QuickTrace( eyes.Pos, ply:GetRight() * LIGHTSABER_PLUS_3P_LROFF + ply:GetForward() * -(LIGHTSABER_PLUS_3P_FWOFF+20) + Vector(0,0,LIGHTSABER_PLUS_3P_UDOFF), ents.GetAll())
				local perc = backTrace.Fraction

				local amt = -LIGHTSABER_PLUS_3P_FWOFF * perc
				if util.IsInWorld(headPos) then
					headPos = backTrace.HitPos
				end

				if LSP.Config.CinematicCam then
					headPos = LerpVector(FrameTime()*4, headPos, eyes.Pos + ply:GetRight() * LIGHTSABER_PLUS_3P_LROFF + Vector(0,0,10 - math.Clamp(perc*10,0,3)) + ang:Forward() * amt + Vector(0,0,LIGHTSABER_PLUS_3P_UDOFF))
					headAng = LerpAngle(FrameTime()*6, headAng, ang + Angle(LIGHTSABER_PLUS_3P_ANGOFF,0,0))
				else
					headPos = LerpVector(FrameTime()*20, headPos, eyes.Pos + ply:GetRight() * LIGHTSABER_PLUS_3P_LROFF + Vector(0,0,10 - math.Clamp(perc*10,0,3)) + ang:Forward() * amt + Vector(0,0,LIGHTSABER_PLUS_3P_UDOFF))
					headAng = LerpAngle(FrameTime()*25, headAng, ang + Angle(LIGHTSABER_PLUS_3P_ANGOFF,0,0))
				end

				return {
					origin = headPos,
					angles = headAng,
					fov = 74,
					drawviewer = true
				}
			else
				local view = {
					origin = eyes.Pos + (ply:GetUp() * up) -(ply:GetForward() * forward) + (ply:GetRight() * right),
					angles = ang,
					fov = 95,
					drawviewer = true
				}

				if LSP.Config.FirstPersonRealism then
					if LSP.Config.FirstPersonRealismSmoothed then
						eyesLerp = LerpAngle(FrameTime() * 15, eyesLerp, Angle(eyes.Ang.p, eyes.Ang.y, 0))
					else
						eyesLerp = Angle(eyes.Ang.p, eyes.Ang.y, 0)
					end
					view.angles = eyesLerp
				end
				if LSP.Config.FirstPersonRealismLite then
					if LSP.Config.FirstPersonRealismSmoothed then
						eyesLerp = LerpAngle(FrameTime() * 15, eyesLerp, Angle(ang.p, eyes.Ang.y, 0))
					else
						eyesLerp = Angle(ang.p, eyes.Ang.y, 0)
					end
					view.angles = eyesLerp
				end

				return view
			end
		elseif wep.isLightsaberPlus then
			if GetConVar( "simple_thirdperson_enabled" ):GetBool() then return end
			return {
				origin = ply:EyePos()+ ang:Forward()*15 + ang:Up()*10,
				angles = ang,
				fov = fov,
				drawviewer = true
			}
		end
	end
end)

hook.Add("Think", "CL_Secondperson_44Bonesz", function()
	local ply = LocalPlayer()
	local wep = ply:GetActiveWeapon()
	if LSP.Config.EnableThirdPersonSys and IsValid(wep) and holdTypes[wep:GetHoldType()] and wep.isLightsaberPlus and !thirdperson then
		for _, bone in pairs(removeBones) do
			if (ply:LookupBone(bone)) then
				ply:ManipulateBoneScale(ply:LookupBone(bone), Vector() * 0)
			end
		end
	else
		for _, bone in pairs(removeBones) do
			if (ply:LookupBone(bone)) then
				ply:ManipulateBoneScale(ply:LookupBone(bone), Vector(1,1,1))
			end
		end
	end
end)

concommand.Add("toggleThirdperson", function()
	thirdperson = !thirdperson
end)