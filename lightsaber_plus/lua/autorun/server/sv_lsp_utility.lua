local meta = FindMetaTable("Player")

function meta:id()
	if self:IsBot() then
		self.id = self.id or "bot_" .. math.random(11111,99999)
		return self.id
	end
	return self:SteamID64() or 0
end

function meta:switchForm(form)
	self.currentForm = form
	self:syncLightsaberPlusData("saberForm", form)
end

function meta:getSaberXP()
	local xp = self:getData("saberXP", 0)
	return xp
end

function meta:getSaberLevel()
	local lvl = self:getData("saberLevel", 0)
	
	if LIGHTSABER_PLUS_NO_LEVEL_REQ then
		lvl = 9999
	end
	
	return lvl
end

function meta:addSaberXP(amt)
	if LIGHTSABER_PLUS_NO_LEVEL_REQ != true then
		local xp = self:getSaberXP()
		if xp+amt >= 1000 then
			self:setData("saberXP", 0)
			self:syncLightsaberPlusData("saberXP", 0)
			local lvl = self:getData("saberLevel", 0)
			self:setData("saberLevel", lvl+1)
			self:syncLightsaberPlusData("saberLevel", lvl+1)
		else
			self:setData("saberXP", xp+amt)
			self:syncLightsaberPlusData("saberXP", xp+amt)
		end
	end
end

function meta:getFormXP(f, dir)
	local xp = self:getData("form_"..f.."_"..dir.."_xp", 0)
	return xp
end

function meta:getFormLevel(f, dir)
	local lvl = self:getData("form_"..f.."_"..dir.."_lvl", 1)
	
	if LIGHTSABER_PLUS_NO_LEVEL_REQ then
		lvl = 9999
	end
	
	return lvl
end

function meta:addFormXP(f,dir,amt)
	if LIGHTSABER_PLUS_NO_LEVEL_REQ != true then
		local id = "form_"..f.."_"..dir
		local xp = self:getFormXP(f, dir)
		if xp+amt >= 1000 then
			self:setData(id.."_xp", 0)
			self:syncLightsaberPlusData(id.."_xp", 0)
			local lvl = self:getData(id.."_lvl", 0)
			self:setData(id.."_lvl", lvl+1)
			self:syncLightsaberPlusData(id.."_lvl", lvl+1)
		else
			self:setData(id.."_xp", xp+amt)
			self:syncLightsaberPlusData(id.."_xp", xp+amt)
		end
	end
end
