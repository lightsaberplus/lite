local lightningInner = Material("models/props_combine/tpballglow")
isDebugging = false

local newInnerBlade = Material("hydranew/innerBlade.png")
local newInnerTip = Material("hydranew/innerTip.png")
local newInnerBlade3k = Material("hydranew/innerBlade3k.png")
local newInnerTip3k = Material("hydranew/innerTip3k.png")
local newOuterBlade = Material("hydranew/outterBlade.png")
local newOuterTip = Material("hydranew/outterTip.png")
local newOuterUnder = Material("hydranew/outterUnder.png")
local trailFadeLeft = Material("hydranew/trailFadeLeft.png")
local trailFadeRight = Material("hydranew/trailFadeRight.png")
local test = Material("hydranew/zwei.png")

local glob = {
	Material("hydranew/glob_f1.png"),
	Material("hydranew/glob_f2.png"),
	Material("hydranew/glob_f3.png"),
	Material("hydranew/glob_f4.png"),
	Material("hydranew/glob_f5.png"),
	Material("hydranew/glob_f6.png"),
}

local unstable = {
	Material("hydranew/unstable_f1.png"),
	Material("hydranew/unstable_f2.png"),
	Material("hydranew/unstable_f3.png"),
	Material("hydranew/unstable_f4.png"),
	Material("hydranew/unstable_f5.png"),
	Material("hydranew/unstable_f6.png"),
}

local lightning = {
	Material("hydranew/lightning_f1.png"),
	Material("hydranew/lightning_f2.png"),
	Material("hydranew/lightning_f3.png"),
	Material("hydranew/lightning_f4.png"),
	Material("hydranew/lightning_f5.png"),
	Material("hydranew/lightning_f6.png"),
}

customDebugLines = {}

hook.Add("PostDrawOpaqueRenderables", "dfosmkgsdf5673567375g", function()
	if isDebugging then
		for k,v in pairs(customDebugLines) do
			if v.life >= CurTime() then
				if v.start and v.endpos then
					render.DrawLine(v.start, v.endpos, v.color)
				else
					table.remove(customDebugLines, k)
				end
			else
				table.remove(customDebugLines, k)
			end
		end
	else
		customDebugLines = {}
	end
end)

hook.Add("HUDPaint", "20j8i34rt", function()
	if isDebugging then
		for k,v in pairs(customDebugLines) do
			local p = v.start:ToScreen()
			draw.RoundedBox( 2, p.x-2, p.y-2, 4, 4, Color(255,0,0))
		end
	end
end)

local drawnBlades = {}

local lastCheck = 0
hook.Add("Think", "dfgj98oi242sd345345345", function()
	if lastCheck <= CurTime() then
		for k,v in pairs(drawnBlades) do
			if !IsValid(v.right.player) then
				v.left:Remove()
				v.right:Remove()
			end
		end
		lastCheck = CurTime() + 5
	end
end)

function drawSlice(ply, blade, pos, ang, len)
	local tr = util.TraceLine( {
		start = pos,
		endpos = pos + ang:Up() * -len,
		filter = function() return false end
	})

	if isDebugging then
		local customDebug = {}
		customDebug.start = pos
		customDebug.endpos = tr.HitPos
		customDebug.life = CurTime() + 0.5
		customDebug.color = Color(255,255,0,50)
		table.insert(customDebugLines, customDebug)
	end
	
	if util.IsInWorld(tr.HitPos + tr.Normal:Angle():Up() * -3) then
		ply.lastSlice = ply.lastSlice or {}
		ply.lastSlice[blade] = ply.lastSlice[blade] or Vector(0,0,-99999999)
		if tr.HitWorld then
			zparticle(ply, tr.HitPos, pos)
		end
	end
end

local lerpLengths = {}

function validateSabers(ply)
	ply.leftHilt = ply.leftHilt or ClientsideModel("models/props_junk/TrafficCone001a.mdl")
	ply.rightHilt = ply.rightHilt or ClientsideModel("models/props_junk/TrafficCone001a.mdl")
	if !(IsValid(ply.rightHilt)) then
		ply.rightHilt = ClientsideModel("models/props_junk/TrafficCone001a.mdl")
	end
	if !(IsValid(ply.leftHilt)) then
		ply.leftHilt = ClientsideModel("models/props_junk/TrafficCone001a.mdl")
	end
	ply.leftHilt.player = ply
	ply.rightHilt.player = ply
	local id = 0
	if ply:IsBot() then
		ply.id = ply.id or "BOT_" .. math.random(11111,99999)
		id = ply.id
	else
		id = ply:id()
	end
	drawnBlades[id] = {}
	drawnBlades[id].left = ply.leftHilt
	drawnBlades[id].right = ply.rightHilt
end

function craftingPosition(ply)
	local bone = ply:LookupBone("ValveBiped.Bip01_R_Hand") or 0
	local pos, ang = ply:GetBonePosition(bone)
	
	pos = pos + ang:Right() * 20 + ang:Forward() * 10
	
	ang:RotateAroundAxis(ang:Right(), 90)
	
	ply.craftingLerpPosition = ply.craftingLerpPosition or Vector(0,0,0)
	ply.craftingLerpAngle = ply.craftingLerpAngle or Angle(0,0,0)
	
	ply.craftingLerpPosition = LerpVector(FrameTime() * 0.5, ply.craftingLerpPosition, pos)
	ply.craftingLerpAngle = LerpAngle(FrameTime() * 0.5, ply.craftingLerpAngle, ang)
end

function handleLightsaber(saber, ply, wep, item, left)
	saber:SetModel(item.mdl)
	saber:SetMaterial(ply:GetMaterial())
	item.bgs = item.bgs or {}
	for k,v in pairs(item.bgs) do
		saber:SetBodygroup(k,v)
	end
	
	if left then
		local bone = ply:LookupBone("ValveBiped.Bip01_L_Hand") or 0
		local pos, ang = ply:GetBonePosition(bone)

		ang:RotateAroundAxis(ang:Forward(), 90)
		ang:RotateAroundAxis(ang:Up(), -90)
		
		pos = pos + ang:Right() * -3 + ang:Up() * 1 + ang:Forward() * -6
		
		saber:SetPos(pos)
		saber:SetAngles(ang)
	else
		if ply:getsyncLightsaberPlusData("crafting", false) then
			if ply:getsyncLightsaberPlusData("isLeft", false) and left then
				ply.rightHilt:SetNoDraw(true)
			else
				ply.leftHilt:SetNoDraw(true)
			end
			
			saber:SetParent(saber)
			saber:RemoveEffects(EF_BONEMERGE)
			saber:SetPos(ply.craftingLerpPosition)
			saber:SetAngles(ply.craftingLerpAngle)
		else
			if item.isMelee then
				local bone = ply:LookupBone("ValveBiped.Bip01_R_Hand") or 0
				local pos, ang = ply:GetBonePosition(bone)
				saber:SetParent(saber)
				saber:RemoveEffects(EF_BONEMERGE)
				saber:SetPos(pos + saber:GetRight() * item.posOffset.x + saber:GetForward() * item.posOffset.y + saber:GetUp() * item.posOffset.z)

				ang:RotateAroundAxis(ang:Right(), item.angOffset.p)
				ang:RotateAroundAxis(ang:Up(), item.angOffset.y)
				ang:RotateAroundAxis(ang:Forward(), item.angOffset.r)
				saber:SetAngles(ang)
				doMeleeHitscan(ply, item)
			else
				saber:SetParent(ply)
				saber:AddEffects(EF_BONEMERGE)
			end
		end
	end
end

local effect = util.Effect

function runEffects(eff, ply, pos, ang, dir, len, color, innerColor)
	if eff == "" then return end
	local ed = EffectData()
	ed:SetOrigin(pos)
	ed:SetNormal(dir)
	ed:SetRadius(len)
	ed:SetEntity(ply)
	ed:SetDamageType(0)
	ed:SetAngles(Angle(color.r, color.g, color.b))
	effect(eff, ed)
end

function searchAttachments(ply, wep, saber, left)
	local hasDrawn = false
	for id,att in pairs(saber:GetAttachments() or {}) do
		if string.match( att.name, "blade(%d+)" ) then
			local blade = saber:GetAttachment(att.id)
			local qVec = ply:GetActiveWeapon():getsyncLightsaberPlusData("blade"..id, Vector(999,999,999))
			local qVec2 = ply:GetActiveWeapon():getsyncLightsaberPlusData("bladeInner"..id, Vector(255,255,255))
			
			if left then
				qVec = ply:GetActiveWeapon():getsyncLightsaberPlusData("OFFHAND-blade"..id, Vector(999,999,999))
				qVec2 = ply:GetActiveWeapon():getsyncLightsaberPlusData("OFFHAND-bladeInner"..id, Vector(255,255,255))
			end
			
			local drawID = id
			if left then drawID = id * 50 end
			
			local bladeClass = wep:getsyncLightsaberPlusData("bladeItem"..id, "")
			local item = getItem(bladeClass)
			
			if item then
				if qVec != Vector(999,999,999) and wep:getsyncLightsaberPlusData("saberOn", false) then
					if item.effect then
						runEffects(item.effect, ply, blade.Pos, blade.Ang, blade.Ang:Forward(), 35, Color(qVec.r, qVec.g, qVec.b), Color(qVec2.r, qVec2.g, qVec2.b))
					end
					drawBlade(item, wep, ply, drawID, blade.Pos, blade.Ang, 35, Color(qVec.r, qVec.g, qVec.b), Color(qVec2.r, qVec2.g, qVec2.b))
					local bang = blade.Ang:RotateAroundAxis(blade.Ang:Right(), -90)
					runSaberTrace(ply, drawID, blade.Pos, blade.Ang, id)
				else
					drawBlade(item, wep, ply, drawID, blade.Pos, blade.Ang, 0, Color(qVec.r, qVec.g, qVec.b), Color(qVec2.r, qVec2.g, qVec2.b))
					ply.blades = ply.blades or {}
					ply.bladePos = ply.bladePos or {}
					ply.blades[drawID] = {}
					ply.bladePos[drawID] = {}
				end
			end
			hasDrawn = true
		elseif string.match( att.name, "quillon(%d+)") then
			local blade = saber:GetAttachment(att.id)
			local qVec = ply:GetActiveWeapon():getsyncLightsaberPlusData("quillon"..id, Vector(999,999,999))
			local qVec2 = ply:GetActiveWeapon():getsyncLightsaberPlusData("quillonInner"..id, Vector(255,255,255))
			
			if left then
				qVec = ply:GetActiveWeapon():getsyncLightsaberPlusData("OFFHAND-quillon"..id, Vector(999,999,999))
				qVec2 = ply:GetActiveWeapon():getsyncLightsaberPlusData("OFFHAND-quillonInner"..id, Vector(255,255,255))
			end
			
			if qVec != Vector(999,999,999) then
				local quillonClass = wep:getsyncLightsaberPlusData("quillonItem"..id, "")
				local item = getItem(quillonClass)
				
				drawQuillion(blade.Pos, blade.Ang, 4, Color(qVec.r, qVec.g, qVec.b),  Color(qVec2.r, qVec2.g, qVec2.b), item)
				
				if item then
					if item.effect then
						runEffects(item.effect, ply, blade.Pos, blade.Ang, blade.Ang:Up() * -1, 4, Color(qVec.r, qVec.g, qVec.b), Color(qVec2.r, qVec2.g, qVec2.b))
					end
				end
			end
		end
	end
	return hasDrawn
end

function hideSabers(ply, mode)
	validateSabers(ply)
	ply.rightHilt:SetNoDraw(mode)
	ply.leftHilt:SetNoDraw(mode)
end

local frameTurn = 0
local sparkTurn = 0
local animatedFrame = 1
local sparkFrame = 1
local sparkMax = 30

local cachedMats = {}

function mat(s)
	cachedMats[s] = cachedMats[s] or Material(s, "noclamp smooth")
	return cachedMats[s]
end

function drawBlade(item, wep, ply, name, pos, ang, tarLen, color, innerColor)
	ply.blades = ply.blades or {}
	if !(item) then return end

	local thickness = 1.5
	local thicknessInner = 1
	local fadeLength = LSP.Config.SaberTrailSpeed
	local fadeSep = 5
	
	ang:RotateAroundAxis(ang:Right(), 90)
	
	
	-- Trail Sanity
	if LSP.Config.SaberTrail then
		ply.blades[name] = ply.blades[name] or {}
		ply.blades[name].pos = ply.blades[name].pos or pos
		ply.blades[name].ang = ply.blades[name].ang or ang
		
		ply.blades[name].pos2 = ply.blades[name].pos2 or pos
		ply.blades[name].ang2 = ply.blades[name].ang2 or ang
	end
	-------------------------
	
	
	
	-- Lerp'd Length Management
	ply.lengths = ply.lengths or {}
	ply.lengths[name] = ply.lengths[name] or {}
	ply.lengths[name].len = ply.lengths[name].len or 0
	ply.lengths[name].len = Lerp(FrameTime() * 6, ply.lengths[name].len, tarLen)
	local len = ply.lengths[name].len
	--if IsValid(SABER_CRAFTING_MENU) and item then len = 35 end
	if len < 1 then return end
	-------------------------
	
	
	
	
	
	-- The blade being drawn.
	render.SetMaterial(mat(item.glowMaterial))
	render.DrawBeam( pos + ang:Up() * 1.5, pos + ang:Up() * -(len+1.5), thickness*3, 1, 0, color )
	
	if item.animatedBlade then
		frameTurn = frameTurn or 0
		if frameTurn <= CurTime() then
			animatedFrame = animatedFrame + 1
			if animatedFrame >= item.bladeFrames then animatedFrame = 1 end
			frameTurn = CurTime() + 0.1
		end
		render.SetMaterial(mat("saberplussabers/blades/animated/" .. item.animatedBlade .. "_f" .. animatedFrame ..".png"))
		render.DrawBeam( pos, pos + ang:Up() * -len, thickness, 1, 0, innerColor )
	else
		render.SetMaterial(mat(item.bladeMaterial))
		render.DrawBeam( pos, pos + ang:Up() * -len, thickness, 1, 0, innerColor )
	end
	-------------------------
	
	
	-- Saber Trailing.
	if LSP.Config.SaberTrail then
		if pos:Distance(ply.blades[name].pos2) > 1.5 then
			render.SetMaterial(mat(item.trailMaterialOuterLeft))
			render.DrawQuad(pos, pos, ply.blades[name].pos2 + ply.blades[name].ang2:Up() * -(len+1.5), pos + ang:Up() * -(len+1.5),  color)

			render.SetMaterial(mat("saberplussabers/basic/white.png"))
			render.DrawQuad(pos, pos, ply.blades[name].pos + ply.blades[name].ang:Up() * -len, pos + ang:Up() * -len,  innerColor)


			render.SetMaterial(mat(item.trailMaterialOuterRight))
			render.DrawQuad(pos, pos, pos + ang:Up() * -(len+1.5), ply.blades[name].pos2 + ply.blades[name].ang2:Up() * -(len+1.5), color)
			
			render.SetMaterial(mat("saberplussabers/basic/white.png"))
			render.DrawQuad(pos, pos, pos + ang:Up() * -len, ply.blades[name].pos + ply.blades[name].ang:Up() * -len, innerColor)
		end
	end
	-------------------------
	
	
	-- Animated Effects
	if item.effectFrames then
		sparkTurn = sparkTurn or 0
		if sparkTurn <= CurTime() then
			sparkFrame = sparkFrame + 1
			if sparkFrame >= sparkMax then
				sparkFrame = 1
				sparkMax = item.effectfrequenzy and item.effectfrequenzy or math.random(90,220)
			end
			sparkTurn = CurTime() + 0.01
		end
		if sparkFrame < item.effectFrames then
			render.SetMaterial(mat("saberplussabers/effects/animated/" .. item.animatedEffect .. "_f" .. sparkFrame ..".png"))
			render.DrawBeam( pos, pos + ang:Up() * -len, thickness*2.5, 1, 0.01, innerColor )
		end
	end
	-------------------------
	
	
	-- Dynamic Lighting
	if wep:getsyncLightsaberPlusData("saberOn") or SABER_CRAFTING_MENU and tarLen > 1 then
		local dlight = DynamicLight( ply:EntIndex() * 1000 * name )
		if ( dlight ) then
			dlight.pos = pos + ang:Up() * -((len/2))
			dlight.r = color.r
			dlight.g = color.g
			dlight.b = color.b
			dlight.brightness = 0.1
			dlight.Decay = 1000
			dlight.Size = 512
			dlight.DieTime = CurTime() + 0.1
		end
	end
	-------------------------
	
	-- Trail Updating
	if LSP.Config.SaberTrail then
		ply.blades[name].pos = LerpVector(FrameTime() * fadeLength, ply.blades[name].pos, pos)
		ply.blades[name].ang = LerpAngle(FrameTime() * fadeLength, ply.blades[name].ang, ang)

		ply.blades[name].pos2 = LerpVector(FrameTime() * (fadeLength-fadeSep), ply.blades[name].pos2, pos + ang:Up() * -1)
		ply.blades[name].ang2 = LerpAngle(FrameTime() * (fadeLength-fadeSep), ply.blades[name].ang2, ang)
	end
	-------------------------
	
	
	
	
	
	
	
	
	
	if wep:getsyncLightsaberPlusData("saberOn") then
		doSounds(ply, name, pos)
		drawSlice(ply, name, pos, ang, len)
	else
		ply:stopSounds()
	end
	
end

function drawQuillion(pos, ang, len, color, innerColor, item)
	render.SetMaterial(mat(item.glowMaterial))
	render.DrawBeam( pos, pos + ang:Up() * -(len), 2, 1, 0, color )
	render.SetMaterial(mat(item.bladeMaterial))
	render.DrawBeam( pos, pos + ang:Up() * -(len-0.5), 0.75, 1, 0, innerColor )
end

hook.Add( "PostDrawTranslucentRenderables", "4222222222222222222222222222g", function(ply)
	if LSP.Config.DrawBlades then
		for _,ply in pairs(player.GetAll()) do
			if ply:Alive() then
				validateSabers(ply)
				craftingPosition(ply)
				local wep = ply:GetActiveWeapon()
				if not IsValid(wep) then return end
				local class = wep:getsyncLightsaberPlusData("itemClass", "eroo")
				local class2 = wep:getsyncLightsaberPlusData("OFFHAND-itemClass", "ero4")
				local item = getItem(class)
				local item2 = getItem(class2)
				
				if item and IsValid(wep) and IsValid(ply.rightHilt) and IsValid(ply.leftHilt) and wep.isLightsaberPlus then
					hideSabers(ply, false)
					
					handleLightsaber(ply.rightHilt, ply, wep, item, false)
					if item2 then handleLightsaber(ply.leftHilt, ply, wep, item2, true) end
					
					local bone = ply:LookupBone("ValveBiped.Bip01_R_Hand") or 0
					local pos, ang = ply:GetBonePosition(bone)
					if not item.isMelee then
						searchAttachments(ply, wep, ply.rightHilt)
					end
					if item2 then searchAttachments(ply, wep, ply.leftHilt, true) else ply.leftHilt:SetNoDraw(true) end
					
					if !(wep:getsyncLightsaberPlusData("saberOn") or IsValid(SABER_CRAFTING_MENU)) then
						--hideSabers(ply, true)
						ply.bladePos = {}
						ply.blades = {}
						ply:stopSounds()
					end
					
					if not wep.isLightsaberPlus then
						hideSabers(ply, true)
					end
				else
					hideSabers(ply, true)
				end
			end
		end
	end
end)

concommand.Add("toggleLines", function()
	isDebugging = !isDebugging
end)

