local customDebugLines = {}
local isDebugging = false
function LSP.AddDebugLines(startp, endp, col)
	if isDebugging then
		local customDebug = {}
		customDebug.start = startp
		customDebug.endpos = endp
		customDebug.life = CurTime() + 1
		customDebug.color = col or Color(255,255,0,50)
		table.insert(customDebugLines, customDebug)
	end
end
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
		endpos = pos + ang:Up() * -len
	})

	LSP.AddDebugLines(pos, tr.HitPos)

	if util.IsInWorld(tr.HitPos + tr.Normal:Angle():Up() * -3) then
		ply.lastSlice = ply.lastSlice or {}
		ply.lastSlice[blade] = ply.lastSlice[blade] or Vector(0,0,-99999999)
		if tr.HitWorld then
			zparticle(ply, tr.HitPos, pos)
		end
	end
end

function validateSabers(ply)
	if !(IsValid(ply.rightHilt)) then
		ply.rightHilt = ClientsideModel("models/props_junk/TrafficCone001a.mdl")
	end
	if !(IsValid(ply.leftHilt)) then
		ply.leftHilt = ClientsideModel("models/props_junk/TrafficCone001a.mdl")
	end
	ply.leftHilt.player = ply
	ply.rightHilt.player = ply
	local id = ply:id()

	drawnBlades[id] = {}
	drawnBlades[id].left = ply.leftHilt
	drawnBlades[id].right = ply.rightHilt
end

function craftingPosition(ply, left)
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
			if ply:getsyncLightsaberPlusData("isLeft", false) then
				ply.rightHilt:SetNoDraw(true)
			else
				ply.leftHilt:SetNoDraw(true)
			end
			
			saber:SetParent(saber)
			saber:RemoveEffects(EF_BONEMERGE)
			saber:SetPos(ply.craftingLerpPosition)
			saber:SetAngles(ply.craftingLerpAngle)
		else
			saber:SetParent(ply)
			saber:AddEffects(EF_BONEMERGE)
			hook.Run("LS+.HandleLS", item, ply, saber)
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
			local item = LSP.GetItem(bladeClass)
			
			if item then
				if qVec != Vector(999,999,999) and wep:getsyncLightsaberPlusData("saberOn", false) and not saber:GetNoDraw() then
					if item.effect then
						runEffects(item.effect, ply, blade.Pos, blade.Ang, blade.Ang:Forward(), 35, Color(qVec.r, qVec.g, qVec.b), Color(qVec2.r, qVec2.g, qVec2.b))
					end
					drawBlade(item, wep, ply, drawID, blade.Pos, blade.Ang, 35, Color(qVec.r, qVec.g, qVec.b), Color(qVec2.r, qVec2.g, qVec2.b))
					-- turns the angle to align it to the blade being drawn so we scan the right places
					blade.Ang:RotateAroundAxis(blade.Ang:Right(), -90)
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
			
			if qVec != Vector(999,999,999) and wep:getsyncLightsaberPlusData("saberOn", false) and not saber:GetNoDraw() then
				local quillonClass = wep:getsyncLightsaberPlusData("quillonItem"..id, "")
				local item = LSP.GetItem(quillonClass)

				local len = 4
				local override = hook.Run("LS+.DrawQuillon", blade.Pos, blade.Ang, len, Color(qVec.r, qVec.g, qVec.b),  Color(qVec2.r, qVec2.g, qVec2.b), item, id + 20, ply) or true
				if override then
					render.SetMaterial(mat(item.glowMaterial))
					render.DrawBeam( blade.Pos, blade.Pos + blade.Ang:Forward() * (len), 2, 1, 0, Color(qVec.r, qVec.g, qVec.b) )
					render.SetMaterial(mat(item.bladeMaterial))
					render.DrawBeam( blade.Pos, blade.Pos + blade.Ang:Forward() * (len-0.5), 0.75, 1, 0, Color(qVec2.r, qVec2.g, qVec2.b) )
				end
			end
		end
	end
	return hasDrawn
end

function hideSabers(ply, mode)
	ply.rightHilt:SetNoDraw(mode)
	ply.leftHilt:SetNoDraw(mode)
end

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
	
	local override = hook.Run("LS+.AnimateBlade", item, pos, ang, len, thickness, innerColor) or true
	if override then
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
	
	hook.Run("LS+.EffectBlade", item, pos, ang, len, thickness, innerColor)
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

	if wep:getsyncLightsaberPlusData("saberOn") then
		doSounds(ply, name, pos)
		drawSlice(ply, name, pos, ang, len)
	else
		ply:stopSounds()
	end
	
end


hook.Add("PostDrawTranslucentRenderables", "4222222222222222222222222222g", function()
	if LSP.Config.DrawBlades then
		for _,ply in pairs(player.GetAll()) do
			if ply:Alive() then
				local wep = ply:GetActiveWeapon()
				validateSabers(ply)
				craftingPosition(ply,  wep.getsyncLightsaberPlusData and wep:getsyncLightsaberPlusData("isLeft", false) or false)

				if not IsValid(wep) or not wep.isLightsaberPlus then hideSabers(ply, true) return end

				local class = wep:getsyncLightsaberPlusData("itemClass", "eroo")
				local class2 = wep:getsyncLightsaberPlusData("OFFHAND-itemClass", "ero4")
				local item = LSP.GetItem(class)
				local item2 = LSP.GetItem(class2)
				
				if item and IsValid(wep) and IsValid(ply.rightHilt) and IsValid(ply.leftHilt) then
					hideSabers(ply, false)

					handleLightsaber(ply.rightHilt, ply, wep, item, false)

					if item2 then handleLightsaber(ply.leftHilt, ply, wep, item2, true) end
				
					if not item.isMelee then searchAttachments(ply, wep, ply.rightHilt) end
	
					if item2 then searchAttachments(ply, wep, ply.leftHilt, true)
					else ply.leftHilt:SetNoDraw(true) 
					end

					if not (wep:getsyncLightsaberPlusData("saberOn") or IsValid(SABER_CRAFTING_MENU)) then
						--hideSabers(ply, true)				-- activating this hides the lightsaber if its deavtivated
						ply.bladePos = {}
						ply.blades = {}
						ply:stopSounds()
					end
				end
			end
		end
	end
end)

concommand.Add("toggleLines", function()
	isDebugging = !isDebugging
end)

