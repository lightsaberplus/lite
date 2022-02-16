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

function addPowerFunction(key, data)
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
			if w:GetClass() == "weapon_lightsaber" then
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
		if LSP.Config.TeamForcePowers[ply:Team()][id] then
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

hook.Add("LS+.FinishedLoading", "LS+.NormalPowers", function()
	addPowerFunction("Force Block",
		function(ply)
			local wep = ply:GetActiveWeapon()
			if wep:GetClass() == "lightsaber_plus" then
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

	addPowerFunction("Force Leap",
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

	addPowerFunction("Force Heal",
		function(ply)
			ply:Heal(100)
		end
	)

	addPowerFunction("Force Meditate",
		function(ply)
			ply:anim("sit_zen",1,1)
			ply:SetHealth(math.Clamp(ply:Health() + (5), 0, ply:GetMaxHealth()))
			ply:reduceSpeed(0.1, 1.1)
		end
	)

	addPowerFunction("Force Push",
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
	
	addPowerFunction("Force Speed",
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

	addPowerFunction("Mass Disarm",
    function(ply)
        for k,v in pairs(ents.FindInSphere(ply:GetPos(), 300)) do
            if v:IsPlayer() then
                if !(v == ply) then
                    ply:EmitSound("hfg/weapons/force/grip.mp3")
                    ply:anim("wos_cast_choke_armed",1, 1)
                    --ply:reduceSpeed(1, 3)
                    
                    local dropped = v:GetActiveWeapon():GetClass()
                    v:DropWeapon()
                    --tar:reduceSpeed(1, 3)
                    --tar:TakeDamage(ply:NewGetForceLevel()*0.15,ply, ply)
                    for i=1,50 do
                        timer.Simple(i*0.1, function()
                            if i == 50 then
                                v:Give(dropped, true)
                            end
                        end)
                    end
                end
            elseif v:IsNPC() then
                ply:EmitSound("hfg/weapons/force/grip.mp3")
                ply:anim("wos_cast_choke_armed",1, 1)
                --ply:reduceSpeed(1, 3)
                    
                local dropped = v:GetActiveWeapon():GetClass()
                v:DropWeapon()
                --tar:reduceSpeed(1, 3)
                --tar:TakeDamage(ply:NewGetForceLevel()*0.15,ply, ply)

            end
        end
    end
)

addPowerFunction("Force Lightning",
    function(ply)
        local tar = ply:laneTarget(3)
        if IsValid(tar) then
            
            local damage = 5
            local damageType = DMG_SONIC
            -- We are going to use these damage types to determine the color of the lightning.
            -- This is a jank work around so that I don't have to register 30 new effects, we can use just one.
        
            -- DMG_SONIC            Normal Lightning
            -- DMG_BLAST            Green Lightning
            -- DMG_ENERGYBEAM       Red Lightning
            -- DMG_BULLET           Orange Lightning
            -- DMG_DROWN            Blue, Fuzzy.
            -- DMG_PLASMA           White
            -- DMG_SHOCK            Black Cable Rope
            -- DMG_ACID             Force Purple
            -- DMG_SNIPER           Lime
            -- DMG_BUCKSHOT         Black
            -- DMG_DIRECT           Yellow
            -- DMG_BLAST_SURFACE    Dark Blue
            -- DMG_DISSOLVE         Purple/Magenta
            
            -- You shouldn't need to touch anything below.
            ply:anim("wos_cast_lightning_armed", 1, 0.6)
            ply.castingLightning = CurTime() + 0.5
            
            ply:reduceSpeed(1, 0.5)
            
            
            
            local bone = tar:LookupBone("ValveBiped.Bip01_R_Hand")
            local bonePos, boneAng = tar:GetBonePosition(bone or 0)
            
            local pos = tar:GetPos() + Vector(0,0,52)
            
            net.Start("saberplus-bleed")
            net.WriteVector(pos)
            net.WriteVector(pos)
            net.SendPVS(pos)
            tar:TakeDamage(damage * 5)
            tar.lastSound = tar.lastSound or 0
            if tar.lastSound <= CurTime() then
                tar:EmitSound("hfg/weapons/force/lightninghit".. math.random(1,3) ..".mp3")
                ply:EmitSound("hfg/weapons/force/lightning.mp3")
                tar.lastSound = CurTime() + 0.5
            end
            local e = EffectData()
            e:SetOrigin(pos)
            e:SetEntity(ply)
            e:SetDamageType(damageType)
            if saberOn then
                e:SetScale(10)
            end
            util.Effect( "effecthpwrewritelightning", e )
        end
    end
)

addPowerFunction("Mass Lightning",
    function(ply)
        for k,v in pairs(ents.FindInSphere(ply:GetPos(), 300)) do
            if v:IsPlayer() or v:IsNPC() then
                if !(v == ply) then
                    local damage = 1
                    local damageType = DMG_SONIC
                    -- We are going to use these damage types to determine the color of the lightning.
                    -- This is a jank work around so that I don't have to register 30 new effects, we can use just one.
                
                    -- DMG_SONIC            Normal Lightning
                    -- DMG_BLAST            Green Lightning
                    -- DMG_ENERGYBEAM       Red Lightning
                    -- DMG_BULLET           Orange Lightning
                    -- DMG_DROWN            Blue, Fuzzy.
                    -- DMG_PLASMA           White
                    -- DMG_SHOCK            Black Cable Rope
                    -- DMG_ACID             Force Purple
                    -- DMG_SNIPER           Lime
                    -- DMG_BUCKSHOT         Black
                    -- DMG_DIRECT           Yellow
                    -- DMG_BLAST_SURFACE    Dark Blue
                    -- DMG_DISSOLVE         Purple/Magenta
                    
                    -- You shouldn't need to touch anything below.
                    ply:anim("wos_cast_lightning_armed", 1, 0.6)
                    ply.castingLightning = CurTime() + 0.5
                    
                    ply:reduceSpeed(1, 0.5)
                    
                    
                    
                    local bone = v:LookupBone("ValveBiped.Bip01_R_Hand")
                    local bonePos, boneAng = v:GetBonePosition(bone or 0)
                    
                    local pos = v:GetPos() + Vector(0,0,52)
                    
                    net.Start("saberplus-bleed")
                    net.WriteVector(pos)
                    net.WriteVector(pos)
                    net.SendPVS(pos)
                    v:TakeDamage(damage * 5)
                    ply.lastSound = ply.lastSound or 0
                    if ply.lastSound <= CurTime() then
                        ply:EmitSound("hfg/weapons/force/lightninghit".. math.random(1,3) ..".mp3")
                        ply:EmitSound("hfg/weapons/force/lightning.mp3")
                        ply.lastSound = CurTime() + 0.5
                    end
                    local e = EffectData()
                    e:SetOrigin(pos)
                    e:SetEntity(ply)
                    e:SetDamageType(damageType)
                    if saberOn then
                        e:SetScale(10)
                    end
                    util.Effect( "effecthpwrewritelightning", e )
                end
            end
        end
    end
)

addPowerFunction("Force Dash",
    function(ply)
        local isLeft = ply:KeyDown(IN_MOVELEFT)
        local isRight = ply:KeyDown(IN_MOVERIGHT)
        local isBack = ply:KeyDown(IN_BACK)
        if ply:IsOnGround() then
            if isLeft then
                ply:anim("wos_bs_shared_b_shuffle_left", .75, .9)
                timer.Simple(0.2, function()
                    ply:SetPos(ply:GetPos() + Vector(0,0,1))
                    ply:SetVelocity(Vector(0,0,50) + ply:GetRight() * -1500)
                    ply:EmitSound("hfg/weapons/force/jump.mp3")
                end)
            elseif isRight then
                ply:anim("wos_bs_shared_b_shuffle_right", .75, .9)
                timer.Simple(0.2, function()
                    ply:SetPos(ply:GetPos() + Vector(0,0,1))
                    ply:SetVelocity(Vector(0,0,50) + ply:GetRight() * 1500)
                    ply:EmitSound("hfg/weapons/force/jump.mp3")
                end)
            elseif isBack then
                ply:anim("wos_bs_shared_dash", .75, .9)
                timer.Simple(0.2, function()
                    ply:SetPos(ply:GetPos() + Vector(0,0,1))
                    ply:SetVelocity(Vector(0,0,50) + ply:GetForward() * -1500)
                    ply:EmitSound("hfg/weapons/force/jump.mp3")
                end)
            else
                ply:anim("wos_bs_shared_dash", .75, .9)
                timer.Simple(0.2, function()
                    ply:SetPos(ply:GetPos() + Vector(0,0,1))
                    ply:SetVelocity(Vector(0,0,50) + ply:GetForward() * 1500)
                    ply:EmitSound("hfg/weapons/force/jump.mp3")
                end)
            end
        end
    end
)

addPowerFunction("Mass Choke",
    function(ply)
        for k,v in pairs(ents.FindInSphere(ply:GetPos(), 300)) do
            if v:IsPlayer() then
                if !(v == ply) then
                    local tar = v
                    net.Start("saberplus-bleed")
                    net.WriteVector(tar:GetPos() + Vector(0,0,48))
                    net.SendPVS(tar:GetPos() + Vector(0,0,48))
                    
                    ply:EmitSound("hfg/weapons/force/grip.mp3")
                    ply:anim("wos_cast_choke_armed",1, 3)
                    ply:reduceSpeed(1, 3)
                    --tar:SetPos(tar:GetPos() + Vector(0,0,80))
                    tar:anim("wos_force_choke",1, 3)
                    --tar:reduceSpeed(1, 3)
                    --tar:TakeDamage(ply:NewGetForceLevel()*0.15,ply, ply)
                    local d = DamageInfo()
                    local amt = math.random(10,50)
                    d:SetDamage(amt)
                    d:SetAttacker(ply)
                    d:SetInflictor(ply)
                    d:SetDamageType(DMG_SONIC)
                    d:SetDamagePosition(tar:GetPos()+Vector(0,0,48))
                    tar:TakeDamageInfo(d)
                    ply:EmitSound("hfg/player/fallsplat.wav")
                end
            elseif v:IsNPC() then
                --v:anim("wos_force_choke",1, 3)
                ply:EmitSound("hfg/player/fallsplat.wav")
                v:SetPos(v:GetPos() + Vector(0,0,80))
                ply:anim("wos_cast_choke_armed",1, 3)
                v:EmitSound("hfg/weapons/force/grip.mp3")
                v:TakeDamage(50)
            end
        end
    end
)

addPowerFunction("Force Storm",
    function(ply)
        for k,v in pairs(ents.FindInSphere(ply:GetPos(), 300)) do
            if v:IsPlayer() or v:IsNPC() then
                if !(v == ply) then
                    local damage = 1
                    local damageType = DMG_SONIC
                    -- We are going to use these damage types to determine the color of the lightning.
                    -- This is a jank work around so that I don't have to register 30 new effects, we can use just one.
                
                    -- DMG_SONIC            Normal Lightning
                    -- DMG_BLAST            Green Lightning
                    -- DMG_ENERGYBEAM       Red Lightning
                    -- DMG_BULLET           Orange Lightning
                    -- DMG_DROWN            Blue, Fuzzy.
                    -- DMG_PLASMA           White
                    -- DMG_SHOCK            Black Cable Rope
                    -- DMG_ACID             Force Purple
                    -- DMG_SNIPER           Lime
                    -- DMG_BUCKSHOT         Black
                    -- DMG_DIRECT           Yellow
                    -- DMG_BLAST_SURFACE    Dark Blue
                    -- DMG_DISSOLVE         Purple/Magenta
                    
                    -- You shouldn't need to touch anything below.
                    ply:anim("wos_cyber_sn_cydi_idle", 1, 0.6)
                    ply.castingLightning = CurTime() + 0.5
                    
                    ply:reduceSpeed(1, 0.5)
                    
                    
                    
                    local bone = v:LookupBone("ValveBiped.Bip01_Pelvis")
                    local bonePos, boneAng = v:GetBonePosition(bone or 0)
                    
                    local pos = v:GetPos() + Vector(0,0,52)
                    local pos2 = v:GetPos() + Vector(0,0,300)
                    --local pos3 = v:GetPos() + Vector(0,0,300)
                    
                    net.Start("saberplus-bleed")
                    net.WriteVector(pos)
                    net.WriteVector(pos)
                    net.SendPVS(pos)
                    v:TakeDamage(damage * 5)
                    ply.lastSound = ply.lastSound or 0
                    if ply.lastSound <= CurTime() then
                        ply:EmitSound("hfg/weapons/force/lightninghit".. math.random(1,3) ..".mp3")
                        ply:EmitSound("hfg/weapons/force/lightning.mp3")
                        ply.lastSound = CurTime() + 0.5
                    end
                    local e = EffectData()
                    e:SetOrigin(pos2)
                    e:SetEntity(v)
                    e:SetDamageType(damageType)
                    if saberOn then
                        e:SetScale(10)
                    end
                    util.Effect( "effecthpwrewritelightning", e )
                    local pPoint = ply:GetPos() + Vector(0,0,300)
                    local ed = EffectData()
                    ed:SetOrigin( pPoint )
                    ed:SetScale( 3000 )
                    ed:SetEntity(ply)
                    util.Effect( "ThumperDust", ed )
                end
            end
        end
    end
)

addPowerFunction("Electric Judgement",
    function(ply)
        local tar = ply:laneTarget(3)
        if IsValid(tar) then
            
            local damage = 5
            local damageType = DMG_BLAST
            -- We are going to use these damage types to determine the color of the lightning.
            -- This is a jank work around so that I don't have to register 30 new effects, we can use just one.
        
            -- DMG_SONIC            Normal Lightning
            -- DMG_BLAST            Green Lightning
            -- DMG_ENERGYBEAM       Red Lightning
            -- DMG_BULLET           Orange Lightning
            -- DMG_DROWN            Blue, Fuzzy.
            -- DMG_PLASMA           White
            -- DMG_SHOCK            Black Cable Rope
            -- DMG_ACID             Force Purple
            -- DMG_SNIPER           Lime
            -- DMG_BUCKSHOT         Black
            -- DMG_DIRECT           Yellow
            -- DMG_BLAST_SURFACE    Dark Blue
            -- DMG_DISSOLVE         Purple/Magenta
            
            -- You shouldn't need to touch anything below.
            ply:anim("wos_cast_lightning_armed", 1, 0.6)
            ply.castingLightning = CurTime() + 0.5
            
            ply:reduceSpeed(1, 0.5)
            
            
            
            local bone = tar:LookupBone("ValveBiped.Bip01_R_Hand")
            local bonePos, boneAng = tar:GetBonePosition(bone or 0)
            
            local pos = tar:GetPos() + Vector(0,0,52)
            
            net.Start("saberplus-bleed")
            net.WriteVector(pos)
            net.WriteVector(pos)
            net.SendPVS(pos)
            tar:TakeDamage(damage * 5)
            tar.lastSound = tar.lastSound or 0
            if tar.lastSound <= CurTime() then
                tar:EmitSound("hfg/weapons/force/lightninghit".. math.random(1,3) ..".mp3")
                ply:EmitSound("hfg/weapons/force/lightning.mp3")
                tar.lastSound = CurTime() + 0.5
            end
            local e = EffectData()
            e:SetOrigin(pos)
            e:SetEntity(ply)
            e:SetDamageType(damageType)
            if saberOn then
                e:SetScale(10)
            end
            util.Effect( "effecthpwrewritelightning", e )
        end
    end
)

addPowerFunction("Mass Electric Judgement",
    function(ply)
        for k,v in pairs(ents.FindInSphere(ply:GetPos(), 300)) do
            if v:IsPlayer() or v:IsNPC() then
                if !(v == ply) then
                    local damage = 1
                    local damageType = DMG_BLAST
                    -- We are going to use these damage types to determine the color of the lightning.
                    -- This is a jank work around so that I don't have to register 30 new effects, we can use just one.
                
                    -- DMG_SONIC            Normal Lightning
                    -- DMG_BLAST            Green Lightning
                    -- DMG_ENERGYBEAM       Red Lightning
                    -- DMG_BULLET           Orange Lightning
                    -- DMG_DROWN            Blue, Fuzzy.
                    -- DMG_PLASMA           White
                    -- DMG_SHOCK            Black Cable Rope
                    -- DMG_ACID             Force Purple
                    -- DMG_SNIPER           Lime
                    -- DMG_BUCKSHOT         Black
                    -- DMG_DIRECT           Yellow
                    -- DMG_BLAST_SURFACE    Dark Blue
                    -- DMG_DISSOLVE         Purple/Magenta
                    
                    -- You shouldn't need to touch anything below.
                    ply:anim("wos_cast_lightning_armed", 1, 0.6)
                    ply.castingLightning = CurTime() + 0.5
                    
                    ply:reduceSpeed(1, 0.5)
                    
                    
                    
                    local bone = v:LookupBone("ValveBiped.Bip01_R_Hand")
                    local bonePos, boneAng = v:GetBonePosition(bone or 0)
                    
                    local pos = v:GetPos() + Vector(0,0,52)
                    
                    net.Start("saberplus-bleed")
                    net.WriteVector(pos)
                    net.WriteVector(pos)
                    net.SendPVS(pos)
                    v:TakeDamage(damage * 5)
                    ply.lastSound = ply.lastSound or 0
                    if ply.lastSound <= CurTime() then
                        ply:EmitSound("hfg/weapons/force/lightninghit".. math.random(1,3) ..".mp3")
                        ply:EmitSound("hfg/weapons/force/lightning.mp3")
                        ply.lastSound = CurTime() + 0.5
                    end
                    local e = EffectData()
                    e:SetOrigin(pos)
                    e:SetEntity(ply)
                    e:SetDamageType(damageType)
                    if saberOn then
                        e:SetScale(10)
                    end
                    util.Effect( "effecthpwrewritelightning", e )
                end
            end
        end
    end
)

addPowerFunction("Force Drain",
    function(ply)
        local tar = ply:laneTarget(3)
        if IsValid(tar) then
            local damage = 1
            local damageType = DMG_ENERGYBEAM
            -- We are going to use these damage types to determine the color of the lightning.
            -- This is a jank work around so that I don't have to register 30 new effects, we can use just one.
        
            -- DMG_SONIC            Normal Lightning
            -- DMG_BLAST            Green Lightning
            -- DMG_ENERGYBEAM       Red Lightning
            -- DMG_BULLET           Orange Lightning
            -- DMG_DROWN            Blue, Fuzzy.
            -- DMG_PLASMA           White
            -- DMG_SHOCK            Black Cable Rope
            -- DMG_ACID             Force Purple
            -- DMG_SNIPER           Lime
            -- DMG_BUCKSHOT         Black
            -- DMG_DIRECT           Yellow
            -- DMG_BLAST_SURFACE    Dark Blue
            -- DMG_DISSOLVE         Purple/Magenta
            
            -- You shouldn't need to touch anything below.
            ply:anim("wos_cast_lightning_armed", 1, 0.6)
            ply.castingLightning = CurTime() + 0.5
            
            ply:reduceSpeed(1, 0.5)
            
            
            
            local bone = tar:LookupBone("ValveBiped.Bip01_R_Hand")
            local bonePos, boneAng = tar:GetBonePosition(bone or 0)
            
            local pos = tar:GetPos() + Vector(0,0,52)
            
            net.Start("saberplus-bleed")
            net.WriteVector(pos)
            net.WriteVector(pos)
            net.SendPVS(pos)
            tar:TakeDamage(damage * 5)
            ply:Heal(damage * 2.5)
            ply.lastSound = ply.lastSound or 0
            if ply.lastSound <= CurTime() then
                ply:EmitSound("hfg/weapons/force/lightninghit".. math.random(1,3) ..".mp3")
                ply:EmitSound("hfg/weapons/force/lightning.mp3")
                ply.lastSound = CurTime() + 0.5
            end
            local e = EffectData()
            e:SetOrigin(pos)
            e:SetEntity(ply)
            e:SetDamageType(damageType)
            if saberOn then
                e:SetScale(10)
            end
            util.Effect( "effecthpwrewritelightning", e )
        end
    end
)

addPowerFunction("Mass Drain",
    function(ply)
        for k,v in pairs(ents.FindInSphere(ply:GetPos(), 300)) do
            if v:IsPlayer() or v:IsNPC() then
                if !(v == ply) then
                    local damage = 1
                    local damageType = DMG_ENERGYBEAM
                    -- We are going to use these damage types to determine the color of the lightning.
                    -- This is a jank work around so that I don't have to register 30 new effects, we can use just one.
                
                    -- DMG_SONIC            Normal Lightning
                    -- DMG_BLAST            Green Lightning
                    -- DMG_ENERGYBEAM       Red Lightning
                    -- DMG_BULLET           Orange Lightning
                    -- DMG_DROWN            Blue, Fuzzy.
                    -- DMG_PLASMA           White
                    -- DMG_SHOCK            Black Cable Rope
                    -- DMG_ACID             Force Purple
                    -- DMG_SNIPER           Lime
                    -- DMG_BUCKSHOT         Black
                    -- DMG_DIRECT           Yellow
                    -- DMG_BLAST_SURFACE    Dark Blue
                    -- DMG_DISSOLVE         Purple/Magenta
                    
                    -- You shouldn't need to touch anything below.
                    ply:anim("wos_cast_lightning_armed", 1, 0.6)
                    ply.castingLightning = CurTime() + 0.5
                    
                    ply:reduceSpeed(1, 0.5)
                    
                    
                    
                    local bone = v:LookupBone("ValveBiped.Bip01_R_Hand")
                    local bonePos, boneAng = v:GetBonePosition(bone or 0)
                    
                    local pos = v:GetPos() + Vector(0,0,52)
                    
                    net.Start("saberplus-bleed")
                    net.WriteVector(pos)
                    net.WriteVector(pos)
                    net.SendPVS(pos)
                    v:TakeDamage(damage * 5)
                    ply:Heal(damage * 1.5)
                    ply.lastSound = ply.lastSound or 0
                    if ply.lastSound <= CurTime() then
                        ply:EmitSound("hfg/weapons/force/lightninghit".. math.random(1,3) ..".mp3")
                        ply:EmitSound("hfg/weapons/force/lightning.mp3")
                        ply.lastSound = CurTime() + 0.5
                    end
                    local e = EffectData()
                    e:SetOrigin(pos)
                    e:SetEntity(ply)
                    e:SetDamageType(damageType)
                    if saberOn then
                        e:SetScale(10)
                    end
                    util.Effect( "effecthpwrewritelightning", e )
                end
            end
        end
    end
)

addPowerFunction("Force Crush",
    function(ply)
        local tar = ply:laneTarget(3)
        if IsValid(tar) then
            net.Start("saberplus-bleed")
                net.WriteVector(tar:GetPos() + Vector(0,0,48))
            net.SendPVS(tar:GetPos() + Vector(0,0,48))
            
            ply:EmitSound("hfg/weapons/force/grip.mp3")
            ply:anim("wos_cast_choke_armed",1, 3)
            ply:reduceSpeed(1, 3)
            
            
            --tar:TakeDamage(ply:NewGetForceLevel()*0.15,ply, ply)
            local d = DamageInfo()
            local amt = math.random(50,150)
            d:SetDamage(amt)
            d:SetAttacker(ply)
            d:SetInflictor(ply)
            d:SetDamageType(DMG_SONIC)
            d:SetDamagePosition(tar:GetPos()+Vector(0,0,48))
            tar:TakeDamageInfo(d)
            tar:EmitSound("hfg/player/fallsplat.wav")
            if tar:IsPlayer() then
                tar:anim("wos_force_crush",1, 3)
                tar:reduceSpeed(1, 3)
            end
        end
    end
)

addPowerFunction("Force Combust",
    function(ply)
        local tar = ply:laneTarget(3)
        if IsValid(tar) then
            ply:anim("menu_zombie_01",1, 0.75)
            tar:Ignite(10)
            tar:EmitSound("hfg/effects/fireburst.mp3")
            if tar:IsPlayer() then
                local anims = {"b_reaction_left", "b_reaction_lower", "b_reaction_lower_left", "b_reaction_lower_right", "b_reaction_right", "b_reaction_upper", "b_reaction_upper_left", "b_reaction_upper_right" }
                tar:anim(table.Random(anims),1, 0.5)
                tar:reduceSpeed(1, 0.5)
            end
        end
    end
)

addPowerFunction("Mass Combust",
    function(ply)
        local pos = ply:GetPos() + Vector(0,0,2)
        local e = EffectData()
        e:SetOrigin(pos)
        util.Effect( "cball_explode", e )
        
        local e = EffectData()
        e:SetOrigin(pos)
        e:SetMagnitude(10)
        util.Effect( "Explosion", e )
        
        ply:anim("menu_zombie_01",1, 0.75)
        
        for k,v in pairs(ents.FindInSphere(ply:GetPos(), 300)) do
            if v:IsPlayer() then
                if !(v == ply) then
                    local anims = {"b_reaction_left", "b_reaction_lower", "b_reaction_lower_left", "b_reaction_lower_right", "b_reaction_right", "b_reaction_upper", "b_reaction_upper_left", "b_reaction_upper_right" }
                    v:anim(table.Random(anims),1, 0.5)
                    v:reduceSpeed(1, 0.5)
                    
                    v:EmitSound("hfg/effects/fireburst.mp3")
                    v:Ignite(4)
                end
            elseif v:IsNPC() then
                v:EmitSound("hfg/effects/fireburst.mp3")
                v:Ignite(4)
            end
        end
    end
)

addPowerFunction("Force Extinguish",
    function(ply)
        local tar = ply:laneTarget(3)
        ply:anim("seq_preskewer",1, 0.75)
        if IsValid(tar) then
            v:Extinguish()
        end
    end
)

addPowerFunction("Mass Extinguish",
    function(ply)
        ply:anim("seq_preskewer",1, 0.75)
        for k,v in pairs(ents.FindInSphere(ply:GetPos(), 300)) do
            if v:IsPlayer() then
                v:Extinguish()
            elseif v:IsNPC() then
                v:Extinguish()
            end
        end
    end
)

addPowerFunction("Rock Throw",
    function(ply)
        local rocks = {
                    "models/props/CS_militia/militiarock05.mdl",
                }
                
            ply:anim( "walk_magic", 1, 2 )
            for i=1,5 do
                timer.Simple(0.10*i, function()
                    local p = ents.Create("prop_physics")
                    local spread = 10
                    p:SetPos(ply:GetPos() + ply:GetForward()*125 - Vector(math.random(-spread,spread),math.random(-spread,spread),spread))
                    p:SetModel(table.Random(rocks))
                    p:SetAngles(Angle(math.random(-180,180),math.random(-180,180),math.random(-180,180)))
                    p:Spawn()
                    p.isRock = true
                    for i=1,100 do
                        timer.Simple(0.005*i, function()
                            if IsValid(p) then
                                p:SetPos(p:GetPos() + Vector(0,0,1))
                                p:GetPhysicsObject():AddAngleVelocity( Vector(-5,5,0) )
                            end
                        end)
                    end
                    timer.Simple(6, function() if IsValid(p) then p:Remove() end end)
                    timer.Simple(0.7, function() if IsValid(p) then p:GetPhysicsObject():AddVelocity( ply:GetForward()*2500) end end)
                    timer.Simple(0.9, function() if IsValid(p) then p:GetPhysicsObject():AddVelocity( ply:GetForward()*1500) end end)
                    timer.Simple(1.1, function() if IsValid(p) then p:GetPhysicsObject():AddVelocity( ply:GetForward()*1500) end end)
                end)
            end
    end
)

addPowerFunction("Boulder Bash",
    function(ply)
        local rocks = {
            "models/props_wasteland/rockgranite02c.mdl",
            "models/props_wasteland/rockgranite02b.mdl",
        }
        local raisePos = ply:GetPos()
        local plyFor = ply:GetForward()
        ply:SetSequenceOverride( "walk_magic", 1, 2 )
        for i=1,20 do
            timer.Simple(0.1*i, function()
                local p = ents.Create("prop_physics")
                local spread = 20
                p:SetPos(raisePos + plyFor*math.random(250, 300) - Vector(math.random(-spread,spread),math.random(-spread,spread),0))
                p:SetModel(table.Random(rocks))
                p:SetAngles(Angle(math.random(-180,180),math.random(-180,180),math.random(-180,180)))
                p:Spawn()
                p.isRock = true
                for i=1,60 do
                    timer.Simple(0.005*i, function()
                        if IsValid(p) then
                            p:SetPos(p:GetPos() + Vector(0,0,1))
                            p:GetPhysicsObject():AddAngleVelocity( Vector(-5,5,0) )
                        end
                    end)
                end
                timer.Simple(7, function() if IsValid(p) then p:Remove() end end)
            end)
        end
    end
)

addPowerFunction("Chain Lightning",
    function(ply)
        local tar = ply:laneTarget(3)
        if IsValid(tar) then
            
            local damage = 1
            local damageType = DMG_BLAST_SURFACE
            -- We are going to use these damage types to determine the color of the lightning.
            -- This is a jank work around so that I don't have to register 30 new effects, we can use just one.
        
            -- DMG_SONIC            Normal Lightning
            -- DMG_BLAST            Green Lightning
            -- DMG_ENERGYBEAM       Red Lightning
            -- DMG_BULLET           Orange Lightning
            -- DMG_DROWN            Blue, Fuzzy.
            -- DMG_PLASMA           White
            -- DMG_SHOCK            Black Cable Rope
            -- DMG_ACID             Force Purple
            -- DMG_SNIPER           Lime
            -- DMG_BUCKSHOT         Black
            -- DMG_DIRECT           Yellow
            -- DMG_BLAST_SURFACE    Dark Blue
            -- DMG_DISSOLVE         Purple/Magenta
            
            -- You shouldn't need to touch anything below.
            ply:anim("wos_cast_lightning_armed", 1, 0.6)
            ply.castingLightning = CurTime() + 0.5
            
            ply:reduceSpeed(1, 0.5)
            
            
            
            local bone = tar:LookupBone("ValveBiped.Bip01_R_Hand")
            local bonePos, boneAng = tar:GetBonePosition(bone or 0)
            
            local pos = tar:GetPos() + Vector(0,0,52)
            
            net.Start("saberplus-bleed")
            net.WriteVector(pos)
            net.WriteVector(pos)
            net.SendPVS(pos)
            tar:TakeDamage(damage * 5)
            tar.lastSound = tar.lastSound or 0
            if tar.lastSound <= CurTime() then
                tar:EmitSound("hfg/weapons/force/lightninghit".. math.random(1,3) ..".mp3")
                ply:EmitSound("hfg/weapons/force/lightning.mp3")
                tar.lastSound = CurTime() + 0.5
            end
            local e = EffectData()
            e:SetOrigin(pos)
            e:SetEntity(ply)
            e:SetDamageType(damageType)
            if saberOn then
                e:SetScale(10)
            end
            util.Effect( "effecthpwrewritelightning", e )
            for k,v in pairs(ents.FindInSphere(ply:GetPos(), 300)) do
                if v:IsPlayer() or v:IsNPC() then
                    if !(v == ply) then
                        local damage = 1
                        local damageType = DMG_BLAST_SURFACE
                        -- We are going to use these damage types to determine the color of the lightning.
                        -- This is a jank work around so that I don't have to register 30 new effects, we can use just one.
                    
                        -- DMG_SONIC            Normal Lightning
                        -- DMG_BLAST            Green Lightning
                        -- DMG_ENERGYBEAM       Red Lightning
                        -- DMG_BULLET           Orange Lightning
                        -- DMG_DROWN            Blue, Fuzzy.
                        -- DMG_PLASMA           White
                        -- DMG_SHOCK            Black Cable Rope
                        -- DMG_ACID             Force Purple
                        -- DMG_SNIPER           Lime
                        -- DMG_BUCKSHOT         Black
                        -- DMG_DIRECT           Yellow
                        -- DMG_BLAST_SURFACE    Dark Blue
                        -- DMG_DISSOLVE         Purple/Magenta
                        
                        -- You shouldn't need to touch anything below.
                        
                        --tar:reduceSpeed(1, 0.5)
                        
                        
                        
                        local bone = v:LookupBone("ValveBiped.Bip01_R_Hand")
                        local bonePos, boneAng = v:GetBonePosition(bone or 0)
                        
                        local pos = v:GetPos() + Vector(0,0,52)
                        
                        net.Start("saberplus-bleed")
                        net.WriteVector(pos)
                        net.WriteVector(pos)
                        net.SendPVS(pos)
                        v:TakeDamage(damage * 5)
                        tar.lastSound = tar.lastSound or 0
                        if tar.lastSound <= CurTime() then
                            tar:EmitSound("hfg/weapons/force/lightninghit".. math.random(1,3) ..".mp3")
                            tar:EmitSound("hfg/weapons/force/lightning.mp3")
                            tar.lastSound = CurTime() + 0.5
                        end
                        local e = EffectData()
                        e:SetOrigin(pos)
                        e:SetEntity(tar)
                        e:SetDamageType(damageType)
                        util.Effect( "effecthpwrewritelightning", e )
                    end
                end
            end
        end
    end
)

addPowerFunction("Force Leech",
    function(ply)
        local tar = ply:laneTarget(3)
        if IsValid(tar) then
            local damage = 1
            local damageType = DMG_BULLET
            -- We are going to use these damage types to determine the color of the lightning.
            -- This is a jank work around so that I don't have to register 30 new effects, we can use just one.
        
            -- DMG_SONIC            Normal Lightning
            -- DMG_BLAST            Green Lightning
            -- DMG_ENERGYBEAM       Red Lightning
            -- DMG_BULLET           Orange Lightning
            -- DMG_DROWN            Blue, Fuzzy.
            -- DMG_PLASMA           White
            -- DMG_SHOCK            Black Cable Rope
            -- DMG_ACID             Force Purple
            -- DMG_SNIPER           Lime
            -- DMG_BUCKSHOT         Black
            -- DMG_DIRECT           Yellow
            -- DMG_BLAST_SURFACE    Dark Blue
            -- DMG_DISSOLVE         Purple/Magenta
            
            -- You shouldn't need to touch anything below.
            ply:anim("wos_cast_lightning_armed", 1, 0.6)
            ply.castingLightning = CurTime() + 0.5
            
            ply:reduceSpeed(1, 0.5)
            
            
            
            local bone = tar:LookupBone("ValveBiped.Bip01_R_Hand")
            local bonePos, boneAng = tar:GetBonePosition(bone or 0)
            
            local pos = tar:GetPos() + Vector(0,0,52)
            
            net.Start("saberplus-bleed")
            net.WriteVector(pos)
            net.WriteVector(pos)
            net.SendPVS(pos)
            tar:addForce(-damage)
            ply:addForce(damage)
            ply.lastSound = ply.lastSound or 0
            if ply.lastSound <= CurTime() then
                ply:EmitSound("hfg/weapons/force/lightninghit".. math.random(1,3) ..".mp3")
                ply:EmitSound("hfg/weapons/force/lightning.mp3")
                ply.lastSound = CurTime() + 0.5
            end
            local e = EffectData()
            e:SetOrigin(pos)
            e:SetEntity(ply)
            e:SetDamageType(damageType)
            if saberOn then
                e:SetScale(10)
            end
            util.Effect( "effecthpwrewritelightning", e )
        end
    end
)

addPowerFunction("Mass Leech",
    function(ply)
        for k,v in pairs(ents.FindInSphere(ply:GetPos(), 300)) do
            if v:IsPlayer() or v:IsNPC() then
                if !(v == ply) then
                    local damage = 1
                    local damageType = DMG_BULLET
                    -- We are going to use these damage types to determine the color of the lightning.
                    -- This is a jank work around so that I don't have to register 30 new effects, we can use just one.
                
                    -- DMG_SONIC            Normal Lightning
                    -- DMG_BLAST            Green Lightning
                    -- DMG_ENERGYBEAM       Red Lightning
                    -- DMG_BULLET           Orange Lightning
                    -- DMG_DROWN            Blue, Fuzzy.
                    -- DMG_PLASMA           White
                    -- DMG_SHOCK            Black Cable Rope
                    -- DMG_ACID             Force Purple
                    -- DMG_SNIPER           Lime
                    -- DMG_BUCKSHOT         Black
                    -- DMG_DIRECT           Yellow
                    -- DMG_BLAST_SURFACE    Dark Blue
                    -- DMG_DISSOLVE         Purple/Magenta
                    
                    -- You shouldn't need to touch anything below.
                    ply:anim("wos_cast_lightning_armed", 1, 0.6)
                    ply.castingLightning = CurTime() + 0.5
                    
                    ply:reduceSpeed(1, 0.5)
                    
                    
                    
                    local bone = v:LookupBone("ValveBiped.Bip01_R_Hand")
                    local bonePos, boneAng = v:GetBonePosition(bone or 0)
                    
                    local pos = v:GetPos() + Vector(0,0,52)
                    
                    net.Start("saberplus-bleed")
                    net.WriteVector(pos)
                    net.WriteVector(pos)
                    net.SendPVS(pos)
                    v:addForce(-damage)
                    ply:addForce(damage)
                    ply.lastSound = ply.lastSound or 0
                    if ply.lastSound <= CurTime() then
                        ply:EmitSound("hfg/weapons/force/lightninghit".. math.random(1,3) ..".mp3")
                        ply:EmitSound("hfg/weapons/force/lightning.mp3")
                        ply.lastSound = CurTime() + 0.5
                    end
                    local e = EffectData()
                    e:SetOrigin(pos)
                    e:SetEntity(ply)
                    e:SetDamageType(damageType)
                    if saberOn then
                        e:SetScale(10)
                    end
                    util.Effect( "effecthpwrewritelightning", e )
                end
            end
        end
    end
)

addPowerFunction("Force Scream",
    function(ply)
        ply:EmitSound("npc/fast_zombie/fz_scream1.wav")
        ply:anim("zombie_attack_frenzy_original",1, 0.75)
        ply:reduceSpeed(1, 0.5)
        for k,v in pairs(ents.FindInSphere(ply:GetPos(), 200)) do
            if v:IsPlayer() then
                if !(v == ply) then
                    local anims = {"b_reaction_left", "b_reaction_lower", "b_reaction_lower_left", "b_reaction_lower_right", "b_reaction_right", "b_reaction_upper", "b_reaction_upper_left", "b_reaction_upper_right" }
                    v:anim(table.Random(anims),1, 0.3)
                    v:reduceSpeed(1, 0.5)
                    v:TakeDamage(ply:NewGetForceLevel()*0.15,ply, ply)
                end
            end
        end
    end
)

addPowerFunction("Force Teleport",
    function(ply)
        local tr = ply:GetEyeTrace()
        local pos = tr.HitPos
        local norm = tr.HitNormal
        local ppos = ply:GetPos()
        local maxDist = 2000
        ply.lastTeleport = ply.lastTeleport or 0
        local dist = math.Dist(pos.x, pos.y, ppos.x, ppos.y)
        
        if dist <= maxDist then
            local hasShit = false
            for _,v in pairs(ents.FindInSphere(pos,8)) do
                if v:IsPlayer() and !(v == ply) then
                    hasShit = true
                end
            end
            if (hasShit) then
                ply:ChatPrint("Something is blocking you from teleporting here..")
                if ply.lastTeleport <= CurTime() then
                    ply:setCooldown("Force Teleport", 1)
                end
            else
                ply:anim("wos_cast_choke_armed",1, 1)
                timer.Simple(0.25, function()
                    ply:SetPos(pos + norm:Angle():Forward() * 50)
                    ply:EmitSound("ambient/machines/teleport1.wav")
                end)
                ply.lastTeleport = CurTime() + 7.9
            end
        else
            ply:ChatPrint("That is too far away...")
            if ply.lastTeleport <= CurTime() then
                ply:setCooldown("Force Teleport", 1)
            end
        end
    end
)

addPowerFunction("Lightning Shield",
    function(ply)
        ply.absorbTimer = CurTime() + 3
        local bubble = ents.Create("prop_physics")
        local pos = ply:GetPos() + Vector(0,0,52)
        local damageType = DMG_BLAST_SURFACE
        bubble:SetPos(ply:GetPos())
        bubble:SetModel("models/hunter/tubes/tube1x1x2.mdl")
        bubble:Spawn()
        bubble:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
        bubble:SetMaterial("Models/effects/comball_sphere")
        bubble:SetColor(Color(127,0,255))
        local e = EffectData()
        e:SetOrigin(pos)
        e:SetEntity(bubble)
        e:SetDamageType(damageType)
        util.Effect( "effecthpwrewritelightning", e )
        bubble:GetPhysicsObject():EnableMotion(false)
        ply:reduceSpeed(90,3)
        for i=1,30 do
            timer.Simple(i*0.1, function()
                bubble:SetPos(ply:GetPos())
                if i == 30 then
                    bubble:Remove()
                end
            end)
        end
        
    end
)

addPowerFunction("Force Shock",
    function(ply)
        local tar = ply:laneTarget(3)
        if IsValid(tar) then
            
            local damage = 50
            local damageType = DMG_ACID
            -- We are going to use these damage types to determine the color of the lightning.
            -- This is a jank work around so that I don't have to register 30 new effects, we can use just one.
        
            -- DMG_SONIC            Normal Lightning
            -- DMG_BLAST            Green Lightning
            -- DMG_ENERGYBEAM       Red Lightning
            -- DMG_BULLET           Orange Lightning
            -- DMG_DROWN            Blue, Fuzzy.
            -- DMG_PLASMA           White
            -- DMG_SHOCK            Black Cable Rope
            -- DMG_ACID             Force Purple
            -- DMG_SNIPER           Lime
            -- DMG_BUCKSHOT         Black
            -- DMG_DIRECT           Yellow
            -- DMG_BLAST_SURFACE    Dark Blue
            -- DMG_DISSOLVE         Purple/Magenta
            
            -- You shouldn't need to touch anything below.
            ply:anim("wos_cast_lightning_armed", 1, 0.6)
            ply.castingLightning = CurTime() + 0.5
            
            ply:reduceSpeed(1, 0.5)
            tar:reduceSpeed(2, 0.1)
            
            
            
            local bone = tar:LookupBone("ValveBiped.Bip01_Pelvis")
            local bonePos, boneAng = tar:GetBonePosition(bone or 0)
            
            local pos = tar:GetPos() + Vector(0,0,52)
            
            net.Start("saberplus-bleed")
            net.WriteVector(pos)
            net.WriteVector(pos)
            net.SendPVS(pos)
            tar:TakeDamage(damage * 5)
            tar.lastSound = tar.lastSound or 0
            if tar.lastSound <= CurTime() then
                tar:EmitSound("hfg/weapons/force/lightninghit".. math.random(1,3) ..".mp3")
                ply:EmitSound("hfg/weapons/force/lightning.mp3")
                tar.lastSound = CurTime() + 0.5
            end
            local e = EffectData()
            e:SetOrigin(pos)
            e:SetEntity(ply)
            e:SetDamageType(damageType)
            if saberOn then
                e:SetScale(10)
            end
            util.Effect( "effecthpwrewritelightning", e )
        end
    end
)


end)