local meta = FindMetaTable("Player")

local fallingTranslation = {}

fallingTranslation["pistol"] = "swimming_pistol"
fallingTranslation["smg"] = "swimming_smg1"
fallingTranslation["grenade"] = "swimming_grenade"
fallingTranslation["ar2"] = "swimming_ar2"
fallingTranslation["shotgun"] = "swimming_shotgun"
fallingTranslation["rpg"] = "swimming_rpg"
fallingTranslation["physgun"] = "swimming_gravgun"
fallingTranslation["crossbow"] = "swimming_crossbow"
fallingTranslation["melee"] = "swimming_melee"
fallingTranslation["slam"] = "swimming_slam"
fallingTranslation["normal"] = "swimming_all"
fallingTranslation["fist"] = "swimming_fist"
fallingTranslation["melee2"] = "swimming_melee2"
fallingTranslation["passive"] = "swimming_all"
fallingTranslation["knife"] = "swimming_knife"
fallingTranslation["duel"] = "swimming_duel"
fallingTranslation["camera"] = "swimming_camera"
fallingTranslation["magic"] = "swimming_magic"
fallingTranslation["revolver"] = "swimming_revolver"

function meta:killTime(id)
	timer.Remove(id .. self:id())
end

function meta:endAnim()
	self:SetCycle(0)
	self:anim(-1,1,0.01)
	self.lastAnim = 0
	self.sequenceRate = nil
	self:killTime("endTime")
end

function meta:makeTime(id,t)
	timer.Create(id .. self:id(), t, 1, function() self:endAnim(id) end)
end

function meta:isAnimating()
	self.lastAnim = self.lastAnim or 0
	return self.lastAnim >= CurTime()
end

function meta:smoothJumping()
	self.lastAnimJump = self.lastAnimJump or 0
	return self.lastAnimJump >= CurTime()
end

function meta:getAnimTime(s)
	return self:SequenceDuration(self:LookupSequence(s))
end


function overrideAnimation()
	function GAMEMODE:UpdateAnimation(ply, vel, speed)
		local l = vel:Length()
		local mv = 1

		if l > 0.2 then mv = l / speed end

		local r = math.min(mv, 1)
		local w = ply:WaterLevel()
		local g = ply:IsOnGround()

		if w >= 2 then
			r = math.min(r,0.6)
		elseif !g and l > 1000 then
			r = 0.15
		end

		ply:SetPlaybackRate(ply.sequenceRate or r)

		if CLIENT then
			GAMEMODE:GrabEarAnimation(ply)
			GAMEMODE:MouthMoveAnimation(ply) -- These are pretty boring
		end

		if (ply:InVehicle()) then
			local v = ply:GetVehicle()
			if CLIENT then
				local vv = v:GetVelocity()
				local f = v:GetUp()
				local d = f:Dot(Vector(0,0,1))
				ply:SetPoseParameter( "vertical_velocity", ( d < 0 and d or 0 ) + f:Dot(vv) * 0.004 )
			end
		end
	end

	function meta:anim( s, r, t ) -- seq, rate, time
		self:SetCycle(0)
		self.override = true
		if !s then
			if SERVER then
				self:endAnim()
			end
			return
		end

		self.animTime = CurTime() + t

		if !t then
			t = self:getAnimTime(s) - 0.15 -- Tinker with this.
		end

		if SERVER then
			self:killTime("endTime")
			self:networkAnim(s,r,t)
			if t > 0 then
				self:makeTime("endTime",t)
			end
		end

		self.lastAnim = CurTime() + t
		self.lastAnimJump = CurTime() + t + 0.1
		return t -- allows us to see how long we're going to play for.
	end

	local old = GAMEMODE.CalcMainActivity
	function GAMEMODE:CalcMainActivity(ply, v)
		local p = ply:GetActiveWeapon()
		if not p or not p.isLightsaberPlus then
			return old(self, ply, v)
		end
		ply.m_bWasOnGround = ply:IsOnGround()
		ply.m_bWasNoclipping = ( ply:GetMoveType() == MOVETYPE_NOCLIP and !ply:InVehicle() )

		self.animTime = self.animTime or 0

		local fm = ply:getsyncLightsaberPlusData("saberForm", LSP.Config.DefaultForm)

		local animType = {run = "run_all", idle = "walk_knife", walk = "walk_knife"}

		animType = LSP.Config.Forms[fm]

		ply.mode = ACT_MP_STAND_IDLE

		ply.sequence = -1

		local len = v:Length2DSqr()
		if len > 22500 then ply.mode = ACT_MP_RUN
		elseif len > 0.25 then ply.mode = ACT_MP_WALK
		end -- are we moving?

		if ply:getsyncLightsaberPlusData("isLimping", false) then
			ply.sequence = ply:LookupSequence( "zombie_walk_02" )
		end

		if !IsValid(ply:GetActiveWeapon()) then return ply.mode, ply.sequence end
		local wep = ply:GetActiveWeapon()

		if ( wep:getsyncLightsaberPlusData("saberOn") ) then
			if ( len > 22500 ) then
				ply.sequence = ply:LookupSequence( animType.run )
			else
				if len == 0 then
					ply.sequence = ply:LookupSequence( animType.idle )
				else
					ply.sequence = ply:LookupSequence( animType.walk )
				end
			end
		end

		local isGrounded = ply:IsOnGround()

		local ht = wep:GetHoldType() or "knife"
		if ht == "normal" then ht = "knife" end
		if ht == "smg" then ht = "smg1" end

		if !isGrounded then

			if !ply.hasSetJumpTime then
				ply.jumpTime = CurTime() + 0.8
				ply.hasSetJumpTime = true
				ply.swimFall = false
			end

			if ply.jumpTime >= CurTime() then
				ply.sequence = ply:LookupSequence("jump_" .. ht)
			else
				ply.swimFall = true
				ply.tickFrame = false

				if IsValid(wep) then
					local holdType = fallingTranslation[wep:GetHoldType()] or "swimming_all"
					ply.sequence = ply:LookupSequence(holdType)
				else
					ply.sequence = ply:LookupSequence("balanced_jump")
				end

			end

		end

		if isGrounded then
			if ply.hasSetJumpTime then
				if ply.swimFall then
					ply.landTimer = CurTime() + 0.5
				else
					ply.landTimer = CurTime() + 0.2
				end
				ply.hasSetJumpTime = false
			end
			ply.landTimer = ply.landTimer or 0
			if ply.landTimer >= CurTime() then
				if ply.swimFall then
					if !ply.tickFrame then
						ply:SetCycle(0)
						if SERVER then
							ply.isRolling = CurTime() + 0.5
						end
						ply.tickFrame = true
					end
				else
					ply.sequence = ply:LookupSequence("cwalk_" .. ht)
				end
			end
		end

		if ply:Crouching() and isGrounded then
			ply.sequence = ply:LookupSequence("cwalk_" .. ht)
		end

		if ply:getsyncLightsaberPlusData("isBlocking", false) and len <= 155  then
			ply.sequence = ply:LookupSequence("walk_knife")
		end

		if !ply:InVehicle() and ply:GetMoveType() == MOVETYPE_NOCLIP then
			if ply:Crouching() then
				ply.sequence = ply:LookupSequence("sit_zen")
			else
				if IsValid(wep) then
					local holdType = fallingTranslation[wep:GetHoldType()] or "swimming_all"
					ply.sequence = ply:LookupSequence(holdType)
				else
					ply.sequence = ply:LookupSequence("swimming_all")
				end
			end
		end

		if ply:InVehicle() then
			return ply.mode, ply:LookupSequence("sit")
		end

		if ply.customAnim and ply.customAnim > -1 then ply.sequence = ply.customAnim end

		return ply.mode, ply.sequence
	end
	if CLIENT then
		net.Receive( "saberplus-net-anim", function(len, ply)
			local ent = net.ReadEntity()
			local s = net.ReadString()
			local r = net.ReadFloat()
			local t = net.ReadFloat()
			ent:SetCycle(0)
			ent.customAnim = ent:LookupSequence(s)
			ent.animTime = t or 1
			ent.sequenceRate = r
			ent.override = true
		end)
	end
end

hook.Add( "PostGamemodeLoaded", "fdgher6u465u46u", function()
	timer.Simple(5, overrideAnimation)
end)

