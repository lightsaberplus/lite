local meta = FindMetaTable("Player")

local cachedRunModifiers = {}

function meta:getMaxRun()
	return self.maxRunspeed or 180
end

function meta:getMaxWalk()
	return self.maxWalkspeed or 100
end

function meta:setMaxRun(a)
	self.maxRunspeed = a
end

function meta:setMaxWalk(a)
	self.maxWalkspeed = a
end

function meta:runSpeed(amt)
	self:SetRunSpeed(amt)
	self:SprintDisable()
	self:SprintEnable()
end

function meta:walkSpeed(amt)
	self:SetWalkSpeed(amt)
end

function meta:resetMovespeed()
	self:SetWalkSpeed(self:getMaxWalk())
	self:runSpeed(self:getMaxRun())
end

function meta:deathMoveSpeed()
	self:SetWalkSpeed(120)
	self:runSpeed(230)
end

function doSlow(tar, dmg)
	local curHP = tar:Health()
	local newHP = math.Clamp(curHP-dmg, 0.4, tar:GetMaxHealth())
	local perc = newHP/tar:GetMaxHealth()
	tar:setMaxRun(180 * perc)
	tar:setMaxWalk(100 * perc)
end

function meta:reduceSpeed(amt, len)
	cachedRunModifiers[self:id()] = cachedRunModifiers[self:id()] or {}
	table.insert(cachedRunModifiers[self:id()], {time = CurTime() + len, speed = amt})
	
	local maxSlow = LSP.Config.RunSpeed
	for d,data in pairs(cachedRunModifiers[self:id()]) do
		if data.time > CurTime() then
			if data.speed < maxSlow then
				maxSlow = data.speed
			end
		else
			cachedRunModifiers[self:id()][d] = nil
		end
	end
	
	if maxSlow < LSP.Config.RunSpeed then
		self:runSpeed(maxSlow)
		self:walkSpeed(maxSlow)
	end
end

local lastRunThink = 0
hook.Add("Think", "runspeedMod", function()
	if lastRunThink <= CurTime() then
		for _,ply in pairs(player.GetAll()) do
			cachedRunModifiers[ply:id()] = cachedRunModifiers[ply:id()] or {}
			local maxSlow = LSP.Config.RunSpeed
			for d,data in pairs(cachedRunModifiers[ply:id()]) do
				if data.time > CurTime() then
					if data.speed < maxSlow then
						maxSlow = data.speed
					end
				else
					cachedRunModifiers[ply:id()][d] = nil
				end
			end
			if maxSlow < LSP.Config.RunSpeed then
				ply:runSpeed(maxSlow)
				ply:walkSpeed(maxSlow)
			else
				ply:runSpeed(LSP.Config.RunSpeed)
				ply:walkSpeed(LSP.Config.WalkSpeed)
			end
		end
		lastRunThink = CurTime() + 0.5
	end
end)


local tootsies = {
	"npc/footsteps/hardboot_generic1.wav",
	"npc/footsteps/hardboot_generic2.wav",
	"npc/footsteps/hardboot_generic3.wav",
	"npc/footsteps/hardboot_generic4.wav",
	"npc/footsteps/hardboot_generic5.wav",
	"npc/footsteps/hardboot_generic6.wav",
	"npc/footsteps/hardboot_generic8.wav",
}

hook.Add( "PlayerFootstep", "CustomFootstep", function( ply, pos, foot, sound, volume, rf )
	if LSP.Config.OptimizeFeet then
		local snd = tootsies[math.random(1, table.Count(tootsies))]
		ply:EmitSound(snd)
		return true
	end
end)

hook.Add("PlayerStepSoundTime", "omdisfgsdfg", function(ply, iType, bWalking)
	if LSP.Config.OptimizeFeet then
		local fStepTime = 350
		local fMaxSpeed = ply:GetMaxSpeed()

		if ( iType == STEPSOUNDTIME_NORMAL || iType == STEPSOUNDTIME_WATER_FOOT ) then
		
			if ( fMaxSpeed <= 100 ) then
				fStepTime = 400
			elseif ( fMaxSpeed <= 300 ) then
				fStepTime = 350
			else
				fStepTime = 250
			end
	
		elseif ( iType == STEPSOUNDTIME_ON_LADDER ) then
	
			fStepTime = 450
	
		elseif ( iType == STEPSOUNDTIME_WATER_KNEE ) then
	
			fStepTime = 600
	
		end
	
		-- Step slower if crouching
		if ( ply:Crouching() ) then
			fStepTime = fStepTime + 50
		end
		if ( ply:IsSprinting() ) then
			fStepTime = fStepTime *0.65
		end
	
		return fStepTime*1.5
	
	end
end)














