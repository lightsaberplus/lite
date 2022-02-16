local tr = { collisiongroup = COLLISION_GROUP_WORLD }
function util.IsInWorld( pos )
	tr.start = pos
	tr.endpos = pos
	return util.TraceLine( tr ).HitWorld
end

function quickDis(a,b,c)
	return a:DistToSqr(b) < c -- pRoBaBlLy nOt OptImIzeD eNouGh (but it will doooo)
end