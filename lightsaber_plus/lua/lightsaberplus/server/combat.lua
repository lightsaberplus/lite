function zapEffect(target)
    local effectdata = EffectData()
    effectdata:SetStart(target:GetShootPos())
    effectdata:SetOrigin(target:GetShootPos())
    effectdata:SetScale(0.9)
    effectdata:SetMagnitude(0.9)
    effectdata:SetScale(1)
    effectdata:SetRadius(1)
    effectdata:SetEntity(target)
    for i = 1, 100, 1 do
        timer.Simple(1 / i, function()									// values under 1/66 are played at the next tick/think
            util.Effect("TeslaHitBoxes", effectdata, true, true)
        end)
    end
    local Zap = math.random(1,9)
    if Zap == 4 then Zap = 3 end
    target:EmitSound("ambient/energy/zap" .. Zap .. ".wav")
end

function doBlockCheck(ply, tar, hitPos)
	local pos = ply:GetPos()
	local ang = ply:GetAngles():Normalize()
	
	--local hit = (hitPos - pos):Angle():Normalize()
	ang = (pos - hitPos):Angle():Normalize()
	
	
	local atk = tar
	local vicPos = ply:GetPos()
	local vicAng = ply:GetAngles() vicAng:Normalize()
	local wepPos = Vector(0,0,0)
	
	if IsValid(inf) then wepPos = inf:GetPos() end
	if IsValid(atk) then wepPos = atk:GetPos() + atk:OBBCenter() end
	
	hit = (wepPos - vicPos):Angle() hit:Normalize()
	local ang = vicAng - hit ang:Normalize()
	
	
	local y = ang.y
	
	local maxCone = 10
	if tar.shouldRiposte then
		if y < 90 and y > -90 then
			if y > maxCone then
				tar:anim( "judge_b_block_right", 1, 0.5 )
			elseif y < -maxCone then
				tar:anim( "h_block_left", 1, 0.5 )
			else
				local cBlock = {"judge_b_block", "h_block"}
				tar:anim( cBlock[math.random(1,#cBlock)], 1, 0.5 )
			end
		else
			tar:anim( "b_reaction_lower", 1, 0.5 )
		end
		
		tar:GetActiveWeapon().lastAttack = CurTime() + 0.5
		tar:GetActiveWeapon().canDamage = 0
		if !ply.riprip then
			if !ply.bounce then
				net.Start("saberplus-block")
					net.WriteVector(hitPos)
				net.SendPVS(hitPos)
			else
				local blocks = {
					"judge_b_block_left",
					"judge_b_block_right",
					"judge_b_block_block",
				}
				
				if not tar:GetActiveWeapon():getsyncLightsaberPlusData("saberOn") then
					blocks = {
						"b_reaction_upper",
						"b_reaction_upper_right",
						"b_reaction_upper_left",
					}
				end
				
				local block = table.Random(blocks)
				tar:anim(block,1,0.3)
			end
			
		else
			ply.bounce = false
			ply.riprip = false
		end
	else
		tar:anim( "b_reaction_lower", 1, 0.5 )
	end
	tar:GetActiveWeapon().lastAttack = CurTime() + 0
	tar:GetActiveWeapon().canDamage = 0
	
	tar:anim( "b_reaction_lower", 1, 1 )
end

function blockEffects(ply, tar, hitPos)
	tar:EmitSound("hfg/weapons/saber/saberblock".. math.random(1,9) ..".mp3")
	local ed = EffectData()
	ed:SetMagnitude(3)
	ed:SetOrigin(hitPos)
	util.Effect("cball_explode", ed)
	tar.canBlock = CurTime() + 0.1
	ply.canBlock = CurTime() + 0.1
	ply:anim("judge_b_block",1,0.5)
	tar:anim("judge_b_block",1,0.5)
end

function doHitEffects(hitPos)
	local edd = EffectData()
	edd:SetOrigin(hitPos)
	util.Effect("BloodImpact", edd)

	local ed = EffectData()
	ed:SetOrigin(hitPos)
	util.Effect("cball_bounce", ed)
end

net.Receive("saberplus-saber-sound", function(len, ply)
	local wep = ply:GetActiveWeapon()
	if not IsValid(wep) then return end
	if not wep.isLightsaberPlus then return end -- bail, we're hacking.
	
	if wep.canDamage <= CurTime() then return end -- bail, we can't attack anymore.
	
	local tar = net.ReadEntity()
	local hitPos = net.ReadVector()
	local id = net.ReadInt(32)
	local pos = ply:GetPos()

	if tar:IsPlayer() and LSP.Config.DontDamageSameTeam and tar:Team() == ply:Team() then
			return
	end

	id = math.Clamp(id, 1, 10) -- no. bad.
	
	local maxDist = LSP.Config.MaxReach or 150
	local maxEntDist = 300

	if tar:IsPlayer() and pos:Distance(tar:GetPos()) >= maxDist then return -- bail, target out of range.
	elseif pos:Distance(tar:GetPos()) >= maxEntDist then return end
	
	tar.absorbTimer = tar.absorbTimer or 0
	if tar.absorbTimer >= CurTime() then return end -- bail, they are absorbing.
	
	ply.currentDamageMultiplier = ply.currentDamageMultiplier or 1 -- ensuring the ply vars.
	
	local item = LSP.GetItem(wep:getsyncLightsaberPlusData("bladeItem"..id, ""))
	if !item then return end
	
	local dmg = item.damage * ply.currentDamageMultiplier
	
	local stm = tar:getsyncLightsaberPlusData("staminaPower", 0)
	tar:syncLightsaberPlusData("staminaPower", math.Clamp(stm - (dmg*LSP.Config.BlockPerc),0, 100))
	tar.staminaDrained = true
	
	ply.targets = ply.targets or {}
	ply.targets[tar:EntIndex()] = ply.targets[tar:EntIndex()] or 0
	
	if ply.targets[tar:EntIndex()] > CurTime() then return end -- already hit them.
	
	local remainingTime = math.Clamp(wep.canDamage - CurTime(), 0.25, 2) -- this gets the remaining time from their attack.
	ply.targets[tar:EntIndex()] = CurTime() + remainingTime
	
	local sounds = {
		"hfg/weapons/saber/saberhit.mp3",
		"hfg/weapons/saber/saberhit1.mp3",
		"hfg/weapons/saber/saberhit2.mp3",
		"hfg/weapons/saber/saberhit3.mp3",
	}
	local snd = table.Random(sounds)
	
	if tar:IsPlayer() or tar:IsNPC() then
		local maxXP = tar:GetMaxHealth() * 0.01
		ply.currentForm = ply.currentForm or LSP.Config.DefaultForm
		ply:addFormXP(ply.currentForm, ply.lastSwing, math.random(1,math.Round(maxXP)))
		ply:addSaberXP(math.random(1,math.Round(maxXP)))
	end
	
	if tar:IsPlayer() then
		tar.shouldRiposte = false
		tar.blockTimer = tar.blockTimer or 0
		if tar.blockTimer >= CurTime() then
			tar.shouldRiposte = true
		end
		
		if IsValid(tar:GetActiveWeapon()) then
			tar.lastSwing = tar.lastSwing or "yeet"
			ply.lastSwing = ply.lastSwing or "yeet"
			tar:GetActiveWeapon().canDamage = tar:GetActiveWeapon().canDamage or 0
			if (ply.lastSwing == tar.lastSwing and tar:GetActiveWeapon().canDamage >= CurTime()) or tar.blockTimer >= CurTime() then
				tar.shouldRiposte = true
				if ply.lastSwing == tar.lastSwing and tar:GetActiveWeapon().canDamage >= CurTime() then
					net.Start("saberplus-riposte")
						net.WriteVector(hitPos)
					net.SendPVS(hitPos)
					ply.riprip = true
				end
			end
		end
		
		if LSP.Config.CombatBlock then
			if tar:GetActiveWeapon().canDamage then
				tar.shouldRiposte = true
				ply.bounce = true
			end
		end
		
		if tar.shouldRiposte then
			blockEffects(ply, tar, hitPos)
		end
		
		doBlockCheck(ply, tar, hitPos)
		doSlow(tar, dmg)
		doHitEffects(hitPos)
		tar:EmitSound(snd)
		tar:EmitSound("physics/body/body_medium_break"..math.random(1,4)..".wav")	
	else
		if tar:IsNPC() then
			local ed = EffectData()
			ed:SetOrigin(hitPos)
			util.Effect( "BloodImpact", ed )
			tar:EmitSound("physics/body/body_medium_break"..math.random(1,4)..".wav")	
			tar:EmitSound(snd)
		end
		
	end
	local stm = tar:getsyncLightsaberPlusData("staminaPower", 0)
	if stm <= 0 or !tar:GetActiveWeapon():getsyncLightsaberPlusData("saberOn")  or !LSP.Config.CombatBlock then
		if !(tar.shouldRiposte) then
			local d = DamageInfo()
			d:SetDamage(dmg)
			d:SetAttacker(ply)
			d:SetDamagePosition(hitPos)
			d:SetInflictor(ply:GetActiveWeapon())
			d:SetDamageForce(Vector(1,1,1))
			tar:TakeDamageInfo(d)
		end
	end
	
	local class = ply:GetActiveWeapon():getsyncLightsaberPlusData("bladeItem"..id, "")
	local item = LSP.GetItem(class)

	if item then
		if item.onHit then
			item.onHit(ply, tar, item)
		end
	end
	
	tar.lastDamaged = CurTime() + LSP.Config.RegenDelay
	ply.lastStaminaDrain = CurTime() + LSP.Config.RegenDelay
end)

hook.Add("PostEntityTakeDamage", "dgko35mihdslfgh", function(ply, dmg,took)
	if took then
		local d = dmg:GetDamage()
		if d >= 1 then
			net.Start("saberplus-hits")
				net.WriteInt(d,32)
				net.WriteVector(dmg:GetDamagePosition())
			net.SendPVS(dmg:GetDamagePosition())
		end
	end
end)

hook.Add( "OnPlayerHitGround", "LS++.NoFallDamage", function( ply, inWater, onFloater, speed )
    if IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon().isLightsaberPlus then
		return true
    end
end )

hook.Add("EntityTakeDamage", "dgkomihdslfgh", function(ply, dmg)
	
	if LSP.Config.KillDamageMod then return end
	
	ply.lastDamaged = CurTime() + LSP.Config.RegenDelay

	if ply:IsNPC() then ply.HasDeathRagdoll = false end
	if !(ply:IsPlayer()) then return end
	
	if IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon().isLightsaberPlus then
		if dmg:GetDamageType() == DMG_FALL then return true end
	end

	if !ply:getsyncLightsaberPlusData("isBlocking") then return end
	local atk = dmg:GetAttacker()
	
	if atk == ply then return end
	
	
	
	local vicPos = ply:GetPos()
	local vicAng = ply:GetAngles() vicAng:Normalize()
	if dmg:GetDamageType() == DMG_BLAST then return end
	if dmg:GetDamageType() == DMG_BURN then return end
	local wepPos = Vector(0,0,0)
	
	if IsValid(inf) then wepPos = inf:GetPos() end
	if IsValid(atk) then wepPos = atk:GetPos() + atk:OBBCenter() end
	
	hit = (wepPos - vicPos):Angle() hit:Normalize()
	local ang = vicAng - hit ang:Normalize() local y = ang.y

	local cone = 45
	local stm = ply:getsyncLightsaberPlusData("staminaPower", 0)
	
	if stm > 0 then
		if (y < 90) and (y > -90) or LSP.Config.Block360 then
			ply.lastReaction = ply.lastReaction or 0
			
			if ply.lastReaction <= CurTime() then
				
				local hasPlayed = false
				
				if y < 45 and y > -45 then
					if !(hasPlayed) then
						ply:anim("b_block_forward_riposte", 1, 0.45)
						hasPlayed = true
					end
				end
				
				if y > 45 then
					if !(hasPlayed) then
						ply:anim("b_block_right_riposte", 1, 0.45)
						hasPlayed = true
					end
				end
				
				if y < -45 then
					if !(hasPlayed) then
						ply:anim("b_block_left_riposte", 1, 0.45)
						hasPlayed = true
					end
				end
				
				if LSP.Config.Block360 and (y > 90 or y < -90) then
					ply:anim("phalanx_a_s1_t1", 1, 0.45)
				end
				
				ply.lastReaction = CurTime() + 0.45
			end
			
			local ed = EffectData()
			ed:SetOrigin(dmg:GetDamagePosition()) //https://cdn.discordapp.com/attachments/762098653937795073/962385427610882139/unknown.png
			util.Effect("cball_bounce", ed)

			ply.lastStaminaDrain = CurTime() + LSP.Config.RegenDelay
			ply:reduceSpeed(50, 0.1)
			ply:SetBloodColor(DONT_BLEED)
			
			
			net.Start("saberplus-block")
				net.WriteVector(dmg:GetDamagePosition())
			net.SendPVS(dmg:GetDamagePosition())
		else
			if LSP.Config.FaceOnBlock then
				ply:SetEyeAngles(ply:EyeAngles() + Angle(0,y,0))
			end
		end
	end
	
	ply.blockTimer = ply.blockTimer or 0
	if ply.blockTimer >= CurTime() and stm > 0 then
		ply.shouldRiposte = true
		net.Start("saberplus-block")
			net.WriteVector(dmg:GetDamagePosition())
		net.SendPVS(dmg:GetDamagePosition())
		ply:syncLightsaberPlusData("staminaPower", math.Clamp(stm - (dmg:GetDamage()*LSP.Config.BlockPerc), 0, 100))
		return true
	end
	
end)


local lastTick = 0
hook.Add("Think", "dijfogsdfg", function()
	if lastTick <= CurTime() then
		for _,ply in pairs(player.GetAll()) do
			ply.lastStaminaDrain = ply.lastStaminaDrain or 0
			ply.lastDamaged = ply.lastDamaged or 0
			if ply.lastDamaged <= CurTime() then
				if ply.lastStaminaDrain <= CurTime() then
					local stm = ply:getsyncLightsaberPlusData("staminaPower", 0)
					ply:syncLightsaberPlusData("staminaPower", math.Clamp(stm + 15,0, 100))
				end
			end
		end
		lastTick = CurTime() + 5
	end
end)

hook.Add("PlayerDeath", "kiodmrfg", function(ply,inf,atk)
	ply:syncLightsaberPlusData("staminaPower", 100)
	ply:ConCommand("stopsound")
end)
