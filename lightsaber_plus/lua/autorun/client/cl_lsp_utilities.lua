local tr = { collisiongroup = COLLISION_GROUP_WORLD }
function util.IsInWorld( pos )
	tr.start = pos
	tr.endpos = pos
	return util.TraceLine( tr ).HitWorld
end

function quickDis(a,b,c)
	return a:DistToSqr(b) < c -- pRoBaBlLy nOt OptImIzeD eNouGh (but it will doooo)
end



concommand.Add("getTeam", function()
	chat.AddText(Color(0,255,0), "You are Team #", Color(0,255,255), tostring(LocalPlayer():Team()))
end)


