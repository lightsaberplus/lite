util.AddNetworkString("saberplus-force-change")
util.AddNetworkString("saberplus-spark")
util.AddNetworkString("saberplus-bleed")
util.AddNetworkString("saberplus-beam")
util.AddNetworkString("saberplus-grant-powers")
util.AddNetworkString("saberplus-splode")
util.AddNetworkString("saberplus-cast-power")
util.AddNetworkString("saberplus-send-cooldown")

local meta = FindMetaTable("Player")
local forcePowerFunction = {}
local coolDownManager = {}
local lastForceUp = 0

hook.Add("Think", "0dpfksg", function() -- Force Regeneration
	if lastForceUp <= CurTime() then
		for _,ply in pairs(player.GetAll()) do
			local amt = ply:getMaxForce() / 20
			ply:setForce(ply:getForce() + amt)
		end
		lastForceUp = CurTime() + 10
	end
end)

function LSP.AddPowerFunction(key, data)
	forcePowerFunction[key] = data
end

function getPowerFunction(key)
	return forcePowerFunction[key]
end


function meta:sanitizeAdditiveForce()
	self.additives = self.additives or {}
	self.additives.force = self.additives.force or {}
end

function meta:updateMaxForceAdditive()
	self:sanitizeAdditiveForce()
	local amt = 0
	for _,add in pairs(self.additives.force) do
		amt = amt + add
	end
	self.lastForceAdditive = self.lastForceAdditive or 0
	if self.lastForceAdditive ~= amt then
		self:syncLightsaberPlusData("additiveForce", amt)
	end
end

function meta:addMaxForce(k,v)
	self:sanitizeAdditiveForce()
	self.additives.force[k] = v
end

local nextAdditive = 0
hook.Add("Think", "12j09839trerff", function()
	if nextAdditive <= CurTime() then
		for _,ply in pairs(player.GetAll()) do
			ply:updateMaxForceAdditive()
		end
		nextAdditive = CurTime() + 30
	end
end)

function meta:setForce(amt)
	local max = self:getMaxForce()
	self.forcepool = self.forcepool or 0
	self.forcepool = math.Clamp(amt, 0, max)
	net.Start("saberplus-force-change")
		net.WriteInt(self.forcepool,32)
	net.Send(self)
end

function meta:addForce(amt)
	local max = self:getMaxForce()
	self.forcepool = self.forcepool or 0
	self.forcepool = math.Clamp(self.forcepool + amt, 0, max)
	net.Start("saberplus-force-change")
		net.WriteInt(self.forcepool,32)
	net.Send(self)
end

function meta:useForce(amt)
	local max = self:getMaxForce()
	self.forcepool = self.forcepool or 0
	self.forcepool = math.Clamp(self.forcepool - amt, 0, max)
	net.Start("saberplus-force-change")
		net.WriteInt(self.forcepool,32)
	net.Send(self)
end

function meta:Delay(t,s)
	self.delayTime = self.delayTime or 0
	if self.delayTime <= CurTime() then
		local w = self:GetActiveWeapon()
		if !(s) then
			w.atkTime = CurTime() + t
			if w.isLightsaberPlus then
				w:SetNextAttack( t )
			end
		else
			w:SetNextSecondaryFire( CurTime() + t )
		end
	end
end

function meta:Heal(t)
	local hp = self:Health()
	local max = self:GetMaxHealth()
	self:SetHealth(math.Clamp(hp+t,0,max))
end

function Tesla(t) -- thank you fadmin
	if !(IsValid(t)) then return end
	
	if !(t.telaTime) then t.telaTime = 0 end
	if t.telaTime >= CurTime() then return end
	t.telaTime = CurTime() + 0.33
	
    local effectdata = EffectData()
    effectdata:SetStart(t:GetShootPos())
    effectdata:SetOrigin(t:GetShootPos())
    effectdata:SetScale(1)
    effectdata:SetMagnitude(1)
    effectdata:SetScale(1)
    effectdata:SetRadius(1)
    effectdata:SetEntity(t)
    for i = 1, 10, 1 do
        timer.Simple(1 / i, function()
            util.Effect("TeslaHitBoxes", effectdata, true, true)
        end)
    end
	local rng = math.random(1,3)
	if rng == 1 then
		local Zap = math.random(1,9)
		if Zap == 4 then Zap = 3 end
		t:EmitSound("ambient/energy/zap" .. Zap .. ".wav")
	end
end

function meta:sanitizeCooldowns(id)
	coolDownManager[self:id()] = coolDownManager[self:id()] or {}
	coolDownManager[self:id()][id] = coolDownManager[self:id()][id] or 0
end

function meta:getCooldown(id)
	self:sanitizeCooldowns(id)
	return coolDownManager[self:id()][id]
end

function meta:globalCooldown(amt)
	for id,_ in pairs(forcePowerFunction) do
		self:sanitizeCooldowns(id)
		coolDownManager[self:id()][id] = CurTime() + amt
		net.Start("saberplus-send-cooldown")
			net.WriteString(id)
			net.WriteFloat(amt)
		net.Send(self)
	end
end

function meta:setCooldown(id, amt)
	self:sanitizeCooldowns(id)
	
	local newTime = CurTime() + amt
	if newTime > coolDownManager[self:id()][id] then
		coolDownManager[self:id()][id] = CurTime() + amt
		net.Start("saberplus-send-cooldown")
			net.WriteString(id)
			net.WriteFloat(amt)
		net.Send(self)
	end
end

function meta:laneTarget(dist)
	local tar = nil
	for i=-dist,-1 do
		for k,v in pairs (ents.FindInSphere(self:GetPos()+self:EyeAngles():Forward()*(100*math.abs(i)),75)) do
			if v:IsPlayer() then
				if v:Alive() then
					if !(v == self) then
						tar = v
						break
					end
				end
			end
		end
	end
	return tar
end

function meta:laneTarget2(dist)
	local tar = nil
	for i=-dist,-1 do
		for k,v in pairs (ents.FindInSphere(self:GetPos()+self:EyeAngles():Forward()*(100*math.abs(i)),150)) do
			if v:IsPlayer() then
				if v:Alive() then
					if !(v == self) then
						tar = v
						break
					end
				end
			end
		end
	end
	return tar
end

function meta:laneTarget3(dist)
	local tar = nil
	for i=-dist,-1 do
		self:SetPos(self:GetPos()+self:EyeAngles():Forward()*(50*math.abs(i)) + Vector(0,0,3))
		for k,v in pairs (ents.FindInSphere(self:GetPos()+self:EyeAngles():Forward()*(50*math.abs(i)),75)) do
			if v:IsPlayer() then
				if v:Alive() then
					if !(v == self) then
						tar = v
						break
					end
				end
			end
		end
	end
	return tar
end

function meta:laneTargetAll(dist)
	local tar = nil
	for i=-dist,-1 do
		for k,v in pairs (ents.FindInSphere(self:GetPos()+self:EyeAngles():Forward()*(100*math.abs(i)),75)) do
			if v.LFS or v:GetClass() == "prop_physics" or v:IsPlayer() then
				if !(v == self) then
					tar = v
					break
				end
			end
		end
	end
	return tar
end

function meta:eachTargetAll(dist,func)
	for i=-dist,-1 do
		for k,v in pairs (ents.FindInSphere(self:GetPos()+self:EyeAngles():Forward()*(100*math.abs(i)),75)) do
			if v.LFS or v:GetClass() == "prop_physics" or v:IsPlayer() then
				if !(v == self) then
					func(self, v)
				end
			end
		end
	end
end

function meta:eachTarget(dist,func)
	local hasHits = {}
	for i=-dist,-1 do
		for k,v in pairs (ents.FindInSphere(self:GetPos()+self:EyeAngles():Forward()*(100*math.abs(i)),125)) do
			if v:IsPlayer() then
				if not hasHits[v:id()] then
					if !(v == self) then
						hasHits[v:id()] = true
						func(self, v)
					end
				end
			end
		end
	end
end

net.Receive("saberplus-grant-powers", function(len, ply)
	local tar = net.ReadEntity()
	local id = net.ReadString()
	local knows = net.ReadBool()
	if ply:canTarget(tar) then
		if ply == tar then
			--tar:text({white, "Get another staff member to do your powers. This stops abuse."})
			--return
		end
		if knows then
			tar:text({white, "You may now use " , Color(0,255,255), id})
			ply:text({white, "You have given ", Color(177,0,0), tar:Nick(), white, " force power ", Color(0,255,255), id})
		else
			tar:text({white, "You can no longer use ", Color(0,255,255), id})
			ply:text({white, "You have taken ", Color(177,0,0), tar:Nick(), white, "'s force power ", Color(0,255,255), id})
		end
		tar:getChar():setData("power_"..id, knows, false, player.GetAll())
		
	else
		ply:text({white, "You can't target them!"})
	end
end)

net.Receive("saberplus-cast-power", function(len, ply)
	local id = net.ReadString()
	local power = getPower(id) or false
	if power and ply:Alive() then
		local cost = power.cost
		local canUse = false
		LSP.Config.TeamForcePowers[ply:Team()] = LSP.Config.TeamForcePowers[ply:Team()] or {}
		if LSP.Config.TeamForcePowers[ply:Team()][id] or LSP.Config.TeamForcePowers[ply:Team()]["*"] then
			canUse = true
		end

		if canUse and (ply:getForce() >= cost) then
			if ply:getCooldown(id) <= CurTime() then
				ply:setCooldown(id, power.cooldown)
				ply:EmitSound(power.sound)
				getPowerFunction(id)(ply)
				ply:useForce(cost)
			end
		end
	end
end)

hook.Add("LS+.ForcePowers", "LS+.NormalPowerFunctions", function()
	LSP.AddPowerFunction("Force Block",
		function(ply)
			local wep = ply:GetActiveWeapon()
			if wep.isLightsaberPlus then
				local blockTime = 0.5
				if !(wep:isUsable()) then return end
				if not wep.isOn then
					wep:syncLightsaberPlusData("saberOn", true)
					wep:SetWeaponHoldType(LSP.Config.Forms[ply:getsyncLightsaberPlusData("saberForm", LSP.Config.DefaultForm)].hold)
					wep:SetHoldType(LSP.Config.Forms[ply:getsyncLightsaberPlusData("saberForm", LSP.Config.DefaultForm)].hold)
					ply:EmitSound("hfg/weapons/saber/enemy_saber_on.mp3")
				end
				
				ply.canBlock = ply.canBlock or 0
				wep.canDamage = wep.canDamage or 0
				if ply.canBlock <= CurTime() then
					if wep.canDamage >= CurTime() then
						ply:endAnim()
					end
					
					ply:syncLightsaberPlusData("isBlocking", true)
					wep.hasReset = false
					ply:reduceSpeed(175, blockTime+0.1)
					ply.blockTimer = CurTime() + blockTime
					ply.canBlock = CurTime()
					wep.lastAttack = CurTime() + blockTime
					wep.canDamage = 0
					wep.comboTime = 0
				end
			end
		end
	)

	LSP.AddPowerFunction("Force Leap",
		function(ply)
			local force = ply:getForce()
			local castpower = 300
			local forwardPower = 100
			
			ply.lastJump = ply.lastJump or 0
			ply.lastBoost = ply.lastBoost or 0
			ply.rootBoost = ply.rootBoost or 0
			
			ply.antiBhopBypass = CurTime() + 3
			
			
			if ply:IsOnGround() then
				ply:SetPos(ply:GetPos()+Vector(0,0,3))
			end
			
			local boosted = false
			if ply:IsOnGround() or ply.lastJump <= CurTime() then
				ply.jumpAnim = CurTime() + 0.5
				ply:anim("judge_a_run",1,2.5)
				if ply:KeyDown(IN_BACK) then
					ply:SetVelocity( ply:GetForward() * -forwardPower + Vector(0,0,castpower))
				elseif ply:KeyDown(IN_MOVELEFT) then
					ply:SetVelocity( ply:GetRight() * -forwardPower + Vector(0,0,castpower))
				elseif ply:KeyDown(IN_MOVERIGHT) then
					ply:SetVelocity( ply:GetRight() * forwardPower + Vector(0,0,castpower))
				else
					ply:SetVelocity( ply:GetAimVector() * forwardPower + Vector(0,0,castpower))
				end
				boosted = true
				ply.rootBoost = CurTime() + 1.5
				ply.lastBoost = CurTime() + 1
				ply:EmitSound("hfg/weapons/force/jump.mp3")
			else
				if ply.lastBoost >= CurTime() and ply.rootBoost >= CurTime() then
					castpower = 75
					ply:SetVelocity( ply:GetAimVector() * forwardPower/2 + Vector(0,0,castpower))
					ply.lastBoost = CurTime() + 0.25 + (ply:Ping()/1000)
					if ply:KeyDown(IN_JUMP) then
						local tr = util.QuickTrace(ply:GetPos(), ply:GetForward() * - 75, {ply})
						if tr.Fraction < 1 then
							ply:SetVelocity( tr.HitNormal * 750 + Vector(0,0,300))
							if IsValid(tr.Entity) then
								tr.Entity:SetVelocity( tr.HitNormal * -2000 + Vector(0,0,-100))
							end
						end
						local tr = util.QuickTrace(ply:GetPos(), ply:GetForward() * 75, {ply})
						if tr.Fraction < 1 then
							ply:SetVelocity( tr.HitNormal * 750 + Vector(0,0,300))
							if IsValid(tr.Entity) then
								tr.Entity:SetVelocity( tr.HitNormal * -2000 + Vector(0,0,-100))
							end
						end
						local tr = util.QuickTrace(ply:GetPos(), ply:GetRight() * - 75, {ply})
						if tr.Fraction < 1 then
							ply:SetVelocity( tr.HitNormal * 750 + Vector(0,0,300))
							if IsValid(tr.Entity) then
								tr.Entity:SetVelocity( tr.HitNormal * -2000 + Vector(0,0,-100))
							end
						end
						local tr = util.QuickTrace(ply:GetPos(), ply:GetRight() * 75, {ply})
						if tr.Fraction < 1 then
							ply:SetVelocity( tr.HitNormal * 750 + Vector(0,0,300))
							if IsValid(tr.Entity) then
								tr.Entity:SetVelocity( tr.HitNormal * -2000 + Vector(0,0,-100))
							end
						end
					end
					boosted = true
				else
					boosted = true
					ply:setCooldown("Force Leap", 7)
				end
			end
			
			if !(boosted) then
				timer.Simple(0, function()
					ply:setCooldown("Force Leap", 0.1)
				end)
			else
				ply.slowedDown = false
				ply.needsLand = true
			end
			
			for i=1,50 do
				timer.Simple(0.05*i, function()
					if ply.needsLand then
						if ply:IsOnGround() then
							ply:anim("cwalk_dual",1, 0.3)
							ply.needsLand = false
						end
					end
				end)
			end

			timer.Simple(1, function()
				if ply.lastBoost <= CurTime() and !ply.slowedDown then
					for i=1,7 do
						timer.Simple(0.1*i, function()
							if ply.jumpAnim <= CurTime() then
								ply.jumpAnim = CurTime() + 2
								if !(ply:IsOnGround()) then
									ply:anim("jump",1,2)
								end
							end
							ply:SetVelocity( ply:GetVelocity() * Vector(-0.05*i,-0.05*i,-0.05*i) )
						end)
					end
					ply.slowedDown = true
				end
			end)
			
			ply.lastJump = CurTime() + 5
			
		end
	)

	LSP.AddPowerFunction("Force Heal",
		function(ply)
			ply:Heal(100)
		end
	)

	LSP.AddPowerFunction("Force Meditate",
		function(ply)
			ply:anim("sit_zen",1,1)
			ply:SetHealth(math.Clamp(ply:Health() + (5), 0, ply:GetMaxHealth()))
			ply:reduceSpeed(0.1, 1.1)
		end
	)

	LSP.AddPowerFunction("Force Push",
		function(ply)
			ply:anim("seq_baton_swing",1,0.5)
			timer.Simple(0.2, function()
				ply:eachTargetAll(5, function(ply, tar)
					if tar:IsPlayer() then
						if tar:IsOnGround() then
							tar:SetVelocity(ply:GetForward() * 600)
						else
							tar:SetVelocity(ply:GetForward() * 300)
						end
					else
						tar:GetPhysicsObject():AddVelocity(ply:GetForward() * 800 + Vector(0,0,200))
					end
				end)
			end)
		end
	)
	
	LSP.AddPowerFunction("Force Speed",
		function(ply)
			ply:runSpeed(LSP.Config.RunSpeed*3)
			ply:walkSpeed(LSP.Config.WalkSpeed*3)
			ply:setCooldown("Force Jump", 5)
			ply:setCooldown("Force Leap", 5)
			ply.runBypass = CurTime() + 3
			timer.Simple(1, function()
				ply:runSpeed(LSP.Config.RunSpeed)
				ply:walkSpeed(LSP.Config.WalkSpeed)
			end)
		end
	)
end)