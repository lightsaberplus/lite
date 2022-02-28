util.AddNetworkString("saberplus-net-anim")
local meta = FindMetaTable("Player")


function meta:networkAnim(s,r,t)
	self.sequence = self:LookupSequence(s) or -1
	self.animTime = t
	self.sequenceRate = r
	self:SetCycle(0)
	
	net.Start("saberplus-net-anim")
		net.WriteEntity(self)
		net.WriteString(s)
		net.WriteFloat(r or 1)
		net.WriteFloat(t or 1)
	net.Broadcast()
end