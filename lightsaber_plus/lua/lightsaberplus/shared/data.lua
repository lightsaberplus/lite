local meta = FindMetaTable("Player")
function meta:id()
	if self:IsBot() then
		self.id = self.id or "bot_" .. math.random(11111,99999)
		return self.id
	end
	return self:SteamID64() or 0
end