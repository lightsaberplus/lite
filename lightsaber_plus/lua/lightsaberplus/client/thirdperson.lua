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

LIGHTSABER_PLUS_THIRDPERSON = true
LIGHTSABER_PLUS_3P_LROFF = 0
LIGHTSABER_PLUS_3P_FWOFF = 125
LIGHTSABER_PLUS_3P_UDOFF = 0
LIGHTSABER_PLUS_3P_ANGOFF = 0

local headPos = Vector(0,0,0)
local headAng = Angle(0,0,0)
local is3p = false

local eyesLerp = Angle(0,0,0)

local stPos = Vector(0,0,-9999)
local stAng = Angle(0,0,0)

local thirdpersonConflicted = true

hook.Add("CalcView", "CL_Secondpersonz44", function(ply, pos, ang, fov)
	if LSP.Config.KillViewMods then return end
	thirdpersonConflicted = false
	local wep = ply:GetActiveWeapon()
	
	if !IsValid(wep) then return end
	if IsValid(ply:GetVehicle()) then return end
	
	if ply:getsyncLightsaberPlusData("crafting", false) then
		local handBone = "ValveBiped.Bip01_R_Hand"
		
		local saberPos = ply.rightHilt:GetPos() + ply.rightHilt:GetUp() * -50 + ply.rightHilt:GetRight() * 60  + ply.rightHilt:GetForward() * 20 
		local saberAng = Angle(15,ply:GetAngles().y + 180,0)
		
		if saberPos.z < ply:GetPos().z + 10 then
			saberPos = Vector(saberPos.x, saberPos.y, ply:GetPos().z + 10)
		end
		
		if ply:getsyncLightsaberPlusData("isLeft", false) then
			handBone = "ValveBiped.Bip01_L_Hand"
		end
		
		local bone = ply:LookupBone(handBone)
		local pos, ang = ply:GetBonePosition(bone)
		
		if headPos == Vector(0,0,0) then headPos = saberPos end
		if headAng == Angle(0,0,0) then headAng = saberAng end
		local bone = ply:LookupBone(handBone) or 0
		
		
		local saberPosAdd = saberAng:Right() * 0
		local saberAngAdd = Angle(0,0,0)
		
		
		local speed = 3
		
		headPos = LerpVector(FrameTime()*speed, headPos, saberPos)
		headAng = LerpAngle(FrameTime()*speed, headAng, saberAng)
		
		view = {
			origin = headPos,
			angles = headAng,
			fov = 74,
			drawviewer = true
		}
		return view
	else
		local holdType = wep:GetHoldType()
		
		if !(holdTypes[holdType]) then return end
		if !(wep.isLightsaberPlus or !is3p) then return end
		
		local eyes = {Pos = ply:GetPos() + Vector(0,0,48)} -- its a fix i guess..

		local up = holdTypes[holdType].up
		local forward = holdTypes[holdType].forward
		local right = holdTypes[holdType].right
		
		if LIGHTSABER_PLUS_THIRDPERSON then
			if headPos == Vector(0,0,0) then headPos = eyes.Pos end
			if headAng == Angle(0,0,0) then headAng = ang + Angle(LIGHTSABER_PLUS_3P_ANGOFF,0,0) end
			local backTrace = util.QuickTrace( eyes.Pos, ply:GetRight() * LIGHTSABER_PLUS_3P_LROFF + ply:GetForward() * -(LIGHTSABER_PLUS_3P_FWOFF+20) + Vector(0,0,LIGHTSABER_PLUS_3P_UDOFF), ents.GetAll())
			local perc = backTrace.Fraction
			
			local amt = -LIGHTSABER_PLUS_3P_FWOFF * perc
			local additionSpeed = 0
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
			
			--headPos = stPos
			--headAng = Angle(ang.p,ang.y,0)

			view = {
				origin = headPos,
				angles = headAng,
				fov = 74,
				drawviewer = true
			}
			return view
		else
			local view = {
				origin = eyes.Pos+(ply:GetUp()*up)-(ply:GetForward()*forward)+(ply:GetRight()*right),
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
	end
end)

hook.Add("Think", "CL_Secondperson_44Bonesz", function()
	if LSP.Config.KillViewMods then return end
	local ply = LocalPlayer()
	local wep = ply:GetActiveWeapon()
	if (IsValid(wep) && holdTypes[wep:GetHoldType()] && (wep.isLightsaberPlus)  && (!LIGHTSABER_PLUS_THIRDPERSON) ) or (is3p) then
		for _, bone in pairs(removeBones) do
			if (ply:LookupBone(bone)) then
				ply:ManipulateBoneScale(ply:LookupBone(bone), Vector()*0)
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
	is3p = !is3p
	LIGHTSABER_PLUS_THIRDPERSON = !LIGHTSABER_PLUS_THIRDPERSON
end)

hook.Add("HUDPaint", "sdomirfgh", function()
	if thirdpersonConflicted and not LSP.Config.KillViewMods then
		draw.DrawText("Lightsaber+ has detected 'CalcView' override. Try removing any third person addons.", "TargetID", ScrW() * 0.5, ScrH() * 0.25, Color(255,5,5,255), TEXT_ALIGN_CENTER)
	end
end)