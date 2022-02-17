AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function SWEP:PrimaryAttack()
	local ply = self.Owner
	if LSP.Config.CombatRoll then
		if !ply:IsOnGround() or ply:KeyDown(IN_DUCK) then
			self.lastRoll = self.lastRoll or 0
			self.primaryDelay = self.primaryDelay or 0
			if self.primaryDelay <= CurTime() then
				if self.lastRoll <= CurTime() then
					if !(ply:isAnimating()) then
						if ply:KeyDown(IN_MOVELEFT) then
							ply:anim("roll_left", 1, 0.5)
							ply:SetVelocity(ply:GetRight() * -LSP.Config.RollSpeed)
							ply.forcedRollLeft = CurTime() + 0.5 
						elseif ply:KeyDown(IN_BACK) then
							ply:SetVelocity(ply:GetForward() * -LSP.Config.RollSpeed)
							ply:anim("roll_backward", 1, 0.5)
							ply.forcedRollBack = CurTime() + 0.5 
						elseif ply:KeyDown(IN_MOVERIGHT) then
							ply:SetVelocity(ply:GetRight() * LSP.Config.RollSpeed)
							ply:anim("roll_right", 1, 0.5)
							ply.forcedRollRight = CurTime() + 0.5 
						else
							ply:SetVelocity(ply:GetForward() * LSP.Config.RollSpeed)
							ply:anim("roll_forward", 1, 0.5)
							ply.forcedRoll = CurTime() + 0.5 
						end
					end
					self.primaryDelay = CurTime() + 0.75
					self.lastRoll = CurTime() + LSP.Config.RollDelay
					return
				else
					local tr = ply:GetEyeTrace()
					local pos = tr.HitPos
					local dis = pos:Distance(ply:EyePos())
					if dis <= 25 then
						ply:SetVelocity(Vector(0,0,500))
						timer.Simple(0.5, function()
							ply:SetVelocity(ply:GetForward() * -250)
						end)
						ply:anim("wallflip_back", 1, 1)
						self.primaryDelay = CurTime() + 0.5
					else
						ply:SetVelocity(ply:GetForward() * 300)
						self.primaryDelay = CurTime() + 1
					end
					return
				end
			end
			return
		end
	end
	
	if !(self:isUsable()) then return end
	
	if not self:getsyncLightsaberPlusData("saberOn") then
		return
	end
	
	local class = self:getsyncLightsaberPlusData("itemClass", "eroo")
	local item = LSP.GetItem(class)

	ply.currentForm = ply.currentForm or LSP.Config.DefaultForm
	local form = ply.currentForm
	
	local maxCombo = #LSP.Config.Forms[form].w
	
	if ply:KeyDown(IN_MOVELEFT) then
		maxCombo = #LSP.Config.Forms[form].a
	end
	
	if ply:KeyDown(IN_MOVERIGHT) then
		maxCombo = #LSP.Config.Forms[form].d
	end
	
	if ply:KeyDown(IN_FORWARD) then
		if ply:KeyDown(IN_MOVELEFT) then
			maxCombo = #LSP.Config.Forms[form].wa
		end
		
		if ply:KeyDown(IN_MOVERIGHT) then
			maxCombo = #LSP.Config.Forms[form].wd
		end
	end
	
	
	
	self.canDamage = self.canDamage or 0
	self.lastAttack = self.lastAttack or 0
	if self.lastAttack <= CurTime() then
		self.comboTime = self.comboTime or 0
		self.comboNumber = self.comboNumber or 1
		if self.comboTime <= CurTime() then
			self.comboNumber = 1
		else
			self.comboNumber = self.comboNumber + 1
			if self.comboNumber > maxCombo then
				self.comboNumber = 1
			end
		end
		
		local data = false
		ply.riposteAnim = "h_block"
		if not ply:KeyDown(IN_FORWARD) then
			if ply:KeyDown(IN_MOVELEFT) then
				ply.lastSwing = "a"
				local bitLevel = tonumber(ply:getFormLevel(form, ply.lastSwing))
				if self.comboNumber > bitLevel then
					self.comboNumber = 1
				end
				data = LSP.Config.Forms[form].a[self.comboNumber]
			end
			
			if ply:KeyDown(IN_MOVERIGHT) then
				ply.lastSwing = "d"
				local bitLevel = tonumber(ply:getFormLevel(form, ply.lastSwing))
				if self.comboNumber > bitLevel then
					self.comboNumber = 1
				end
				data = LSP.Config.Forms[form].d[self.comboNumber]
			end
		end
		
		if ply:KeyDown(IN_FORWARD) then
			if ply:KeyDown(IN_MOVELEFT) then
				ply.lastSwing = "wa"
				local bitLevel = tonumber(ply:getFormLevel(form, ply.lastSwing))
				if self.comboNumber > bitLevel then
					self.comboNumber = 1
				end
				data = LSP.Config.Forms[form].wa[self.comboNumber]
			end
		
			if ply:KeyDown(IN_MOVERIGHT) then
				ply.lastSwing = "wd"
				local bitLevel = tonumber(ply:getFormLevel(form, ply.lastSwing))
				if self.comboNumber > bitLevel then
					self.comboNumber = 1
				end
				data = LSP.Config.Forms[form].wd[self.comboNumber]
			end
		end
		
		if data == false then
			ply.lastSwing = "w"
			local bitLevel = tonumber(ply:getFormLevel(form, ply.lastSwing))
			if self.comboNumber > bitLevel then
				self.comboNumber = 1
			end
			data = LSP.Config.Forms[form].w[self.comboNumber]
		end
		local anim = data.anim
		local len = ply:SequenceDuration(ply:LookupSequence(anim)) - data.shave
		local rate = data.rate
		local t = len / rate -- Thanks xozzy for helping figure out division.
		
		t = math.abs(t)
		
		if data.forcedTime then
			t = data.forcedTime
		end
		
		ply:anim(anim, data.rate, t)
		
		if item.isMelee then
			local sounds = {
				"hfg/weapons/sword/swing1.mp3",
				"hfg/weapons/sword/swing2.mp3",
				"hfg/weapons/sword/swing3.mp3",
				"hfg/weapons/sword/swing4.mp3",
			}
			local snd = table.Random(sounds)
			self.Owner:EmitSound(snd)
		end

		if data.speed > 0 then
			ply:reduceSpeed(data.speed, t - 0.25)
		end
		self.comboTime = CurTime() + t + 1
		
		net.Start("saberplus-saber-sound")
			net.WriteFloat(t)
		net.Send(self.Owner)
		--ply:EmitSound(self.sounds[math.random(1,#self.sounds)])
			
		ply.currentDamageMultiplier = data.dmg
		self.canDamage = CurTime() + t + 0.25
		self.lastAttack = CurTime() + t
	end
end

function SWEP:isUsable()
	local found = false
	for i=1,10 do
		local item = self:getsyncLightsaberPlusData("bladeItem"..i,"")
		if item != "" then
			found = true
			break
		end
	end

	local class = self:getsyncLightsaberPlusData("itemClass", "eroo")
	local item = LSP.GetItem(class)

	if item.isMelee then found = true end

	return found
end

function SWEP:SecondaryAttack()
	local blockTime = 0.1
	local class = self:getsyncLightsaberPlusData("itemClass", "eroo")
	local item = LSP.GetItem(class)
	
	if !(self:isUsable()) then return end
	
	if not self:getsyncLightsaberPlusData("saberOn") then
		self:syncLightsaberPlusData("saberOn", true)
		self:SetWeaponHoldType( LSP.Config.Forms[self.Owner:getsyncLightsaberPlusData("saberForm", LSP.Config.DefaultForm)].hold )
		self:SetHoldType( LSP.Config.Forms[self.Owner:getsyncLightsaberPlusData("saberForm", LSP.Config.DefaultForm)].hold )
		self.Owner:EmitSound("hfg/weapons/saber/enemy_saber_on.mp3")
	end
	
	self.Owner.canBlock = self.Owner.canBlock or 0
	self.canDamage = self.canDamage or 0
	if self.Owner.canBlock <= CurTime() then
		if self.canDamage >= CurTime() then
			self.Owner:endAnim()
		end
		
		self.Owner:syncLightsaberPlusData("isBlocking", true)
		self.hasReset = false
		--self.Owner:reduceSpeed(150, blockTime+0.1)
		self.Owner.blockTimer = CurTime() + blockTime
		self.Owner.canBlock = CurTime() + blockTime - 0.01
		self.lastAttack = CurTime() + blockTime
		self.canDamage = 0
		self.comboTime = 0
	end
end

function SWEP:Initialize()
	self:SetWeaponHoldType( "normal" )
	self:SetHoldType( "normal" )
	
	self:SetWeaponHoldType( "normal" )
	self:SetHoldType( "normal" )
	self:syncLightsaberPlusData("saberOn", false)
	
	timer.Simple(0, function()
		local ply = self.Owner
		ply.currentForm = ply.currentForm or LSP.Config.DefaultForm
		local form = ply.currentForm
		
		local saberXP = ply:getSaberXP()
		local saberLevel = ply:getSaberLevel()
		
		ply:syncLightsaberPlusData("saberXP", saberXP)
		ply:syncLightsaberPlusData("saberLevel", saberLevel)
		
		local dirs = {
			"w",
			"a",
			"d",
			"wa",
			"wd",
		}
		
		for i=1,5 do
			local lvl = ply:getFormLevel(ply.currentForm, dirs[i])
			local xp = ply:getFormXP(ply.currentForm, dirs[i])
			
			ply:syncLightsaberPlusData("form_"..form.."_".. dirs[i] .."_lvl", lvl)
			ply:syncLightsaberPlusData("form_"..form.."_".. dirs[i] .."_xp", xp)
			
		end
	end)
	
	self:syncLightsaberPlusData("saberOn", false)
	
end

function SWEP:Reload()
	if !self.noSpam then self.noSpam = 0 end
	if self.noSpam <= CurTime() then
		local class = self:getsyncLightsaberPlusData("itemClass", "eroo")
		local item = LSP.GetItem(class)

		if !(self:isUsable()) then
			self:SetWeaponHoldType( "normal" )
			self:SetHoldType( "normal" )
			self:syncLightsaberPlusData("saberOn", false)
			self.noSpam = CurTime() + 1
			return
		end
		self:syncLightsaberPlusData("saberOn", !self:getsyncLightsaberPlusData("saberOn", false))
		if not self:getsyncLightsaberPlusData("saberOn") then
			self:SetWeaponHoldType( "normal" )
			self:SetHoldType( "normal" )
			if not item.isMelee then
				self.Owner:EmitSound("hfg/weapons/saber/enemy_saber_off.mp3")
			end
		else
			self:SetWeaponHoldType(LSP.Config.Forms[self.Owner:getsyncLightsaberPlusData("saberForm", LSP.Config.DefaultForm)].hold)
			self:SetHoldType(LSP.Config.Forms[self.Owner:getsyncLightsaberPlusData("saberForm", LSP.Config.DefaultForm)].hold)
			if not item.isMelee then
				self.Owner:EmitSound("hfg/weapons/saber/enemy_saber_on.mp3")
			end
		end
		self.noSpam = CurTime() + 1
	end
end

function SWEP:Think()
	
	local ply = self.Owner
	if !(ply.setStats) then
		ply:syncLightsaberPlusData("forcePower", 100)
		ply:syncLightsaberPlusData("staminaPower", 100)
		ply.setStats = true
	end
	ply.canBlock = ply.canBlock or 0
	if !(self.hasReset) then
		if ply.canBlock <= CurTime() then
			ply:syncLightsaberPlusData("isBlocking", false)
			self.hasReset = true
		end
	end
end


function SWEP:Deploy()
	return true
end

function SWEP:Holster()
	return true
end

function SWEP:setInt(blade, key, def)
	self:syncLightsaberPlusData(blade..key,def)
end

function SWEP:setString(blade, key, def)
	self:syncLightsaberPlusData(blade..key,def)
end

function SWEP:setColor(blade, key, val)
	self:syncLightsaberPlusData(blade..key,Vector(val.r,val.g,val.b))
end
