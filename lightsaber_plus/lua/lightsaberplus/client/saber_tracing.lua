function runSaberTrace(ply, bladeID, pos, ang, id, length, segments)
	if (LSP.Config.KillDamageMod) then return end
	if !(ply == LocalPlayer()) then return end
	local bladeLength = length or 35
	local segments = segments or LSP.Config.HitScanSegments
	local dist = bladeLength / segments

	ply.bladePos = ply.bladePos or {}
	for i=0,segments do
		local scanID = bladeID..i
		ply.bladePos[scanID] = ply.bladePos[scanID] or {}
		local endPos = pos + ang:Forward() * (dist*i)

		
		if ply.bladePos[scanID].lastPos then
			LSP.AddDebugLines(endPos, ply.bladePos[scanID].lastPos, Color(i*(255/segments),0,250 - i*(255/segments),255))
			local tr = util.TraceLine({
				start = endPos,
				endpos = ply.bladePos[scanID].lastPos,
				filter = {ply}
			})
			if IsValid(tr.Entity) then
				if tr.Entity:IsPlayer() or tr.Entity:IsNPC() or tr.Entity:IsVehicle() or tr.Entity.LFS or tr.Entity:GetClass() == "training_droid" then
					ply.active = ply.active or 0
					if ply.active >= CurTime() then
						tr.Entity.lastHit = tr.Entity.lastHit or 0
						if tr.Entity.lastHit <= CurTime() then
							net.Start("saberplus-saber-sound") --- do the damage to the ent
								net.WriteEntity(tr.Entity)
								net.WriteVector(tr.HitPos)
								net.WriteInt(id,32)
							net.SendToServer()

							LSP.AddDebugLines(endPos, ply.bladePos[scanID].lastPos, Color(255,255,0))

							tr.Entity.lastHit = CurTime() + 0.25
						end
					end
				end
			end
		end
		ply.lastSpark = ply.lastSpark or 0
		local tr = util.QuickTrace( pos, ang:Forward() * bladeLength, {ply, self} )
		
		if tr.HitWorld then
			if ply.lastSpark <= CurTime() then
				local e = EffectData()
				e:SetOrigin(tr.HitPos)
				e:SetAngles(tr.HitNormal:Angle())
				util.Effect( "ManhackSparks", e)
				ply.lastSpark = CurTime() + 0.1
			end
		end
		ply.bladePos[scanID].lastPos = endPos
	end
end
