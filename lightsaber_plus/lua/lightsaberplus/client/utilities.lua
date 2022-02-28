local tr = { collisiongroup = COLLISION_GROUP_WORLD }
function util.IsInWorld( pos )
	tr.start = pos
	tr.endpos = pos
	return util.TraceLine( tr ).HitWorld
end