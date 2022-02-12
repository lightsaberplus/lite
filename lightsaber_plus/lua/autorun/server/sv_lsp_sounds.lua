net.Receive("saberplus-sound-hit", function(len, ply)
	local isVibro = net.ReadBool()
	ply.lastHitSound = ply.lastHitSound or 0
	if ply.lastHitSound <= CurTime() then
		if isVibro then
			ply:EmitSound("hfg/weapons/sword/stab".. math.random(1,4) ..".mp3")
		else
			ply:EmitSound("hfg/weapons/saber/saberbounce".. math.random(1,3) ..".mp3")
		end
		ply.lastHitSound = CurTime() + 0.4
	end
end)