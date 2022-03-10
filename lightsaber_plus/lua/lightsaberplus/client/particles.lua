function zparticle(ply, ppos, pos)
	ply.emitter = ply.emitter or ParticleEmitter(pos)
	local emitter = ply.emitter
	if emitter then
		emitter:SetPos(pos)
		local part = emitter:Add( "effects/laser_tracer", ppos  )
		if (part) then
			part:SetDieTime( 2 )
			part:SetStartAlpha( 155 )
			part:SetEndAlpha( 0 )
			part:SetStartSize( 2 )
			part:SetEndSize( 1 )
			part:SetGravity( Vector( 0, 0, 0 ) )
			part:SetRoll(math.random(-180,180))
		end
		local part = emitter:Add( "effects/laser_tracer", ppos  )
		if (part) then
			part:SetDieTime( 3 )
			part:SetStartAlpha( 255 )
			part:SetEndAlpha( 0 )
			part:SetStartSize( 3 )
			part:SetEndSize( 3 )
			part:SetGravity( Vector( 0, 0, 0 ) )
			part:SetColor(255,100,10)
			part:SetRoll(math.random(-180,180))
		end
	end
	--emitter:Finish()
end

function spark(tar, ppos, pos)
	local col = tar:GetActiveWeapon():getsyncLightsaberPlusData("rightCrystal", Vector(255,255,255))
	local emitter = ParticleEmitter( pos )
	for i=1,25 do
		if emitter then
			local part = emitter:Add( "effects/energysplash", ppos  )
			if (part) then
				part:SetDieTime( 1 )
				part:SetStartAlpha( 255 )
				part:SetEndAlpha( 0 )
				part:SetStartSize( 1 )
				part:SetEndSize( 0 )
				part:SetGravity( Vector(0,0,-250) )
				part:SetVelocity( VectorRand() * math.random(20,90) )
				part:SetCollide( true )
				part:SetColor( math.Clamp(col.r + 150,0,255), math.Clamp(col.g + 150,0,255), math.Clamp(col.b + 150,0,255) )
				part:SetRoll(math.random(-180,180))
			end
		end
	end
	emitter:Finish()
end
