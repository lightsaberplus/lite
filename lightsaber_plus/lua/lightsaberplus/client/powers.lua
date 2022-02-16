local cachedMats = {}

local currentPowers = {}
local forcePointer = 1

local emptyCheck = 0
local isEmpty = true

hook.Add("HUDPaint", "sojdimfgmosidfg", function()	
	if (LSP.Config.KillHud) then return end
	local iconS = 50 -- Changing this higher will cause stretching and lowers the quality of the icons.
	local padding = 5
	local borderWidth = 2
	
	local plateW = (iconS * LSP.Config.MaxForcePowers) + ((LSP.Config.MaxForcePowers+1) * padding)
	local plateH = iconS + (padding*2)
	
	
	if #currentPowers < LSP.Config.MaxForcePowers then
		for i=1,LSP.Config.MaxForcePowers do
			currentPowers[i] = "empty"
		end
	end
	
	if emptyCheck <= CurTime() then
		isEmpty = true
		for slot,id in pairs(currentPowers) do
			if !(id == "empty") then
				isEmpty = false
				break
			end
		end
		emptyCheck = CurTime() + 5
	end
	
	if isEmpty then return end
	
	if LSP.Config.ForceHudTeam then
		local teamColor = team.GetColor(LocalPlayer():Team())
		surface.SetDrawColor(teamColor.r, teamColor.g, teamColor.b)
	else
		surface.SetDrawColor(177,17,17)
	end
	
	surface.DrawRect(ScrW()/2 - plateW/2 -borderWidth, ScrH() - plateH - iconS-borderWidth, plateW+(borderWidth*2), plateH+(borderWidth*2))

	surface.SetDrawColor(17,17,17)
	surface.DrawRect(ScrW()/2 - plateW/2, ScrH() - plateH - iconS, plateW, plateH)
	
	cachedMats["hfgjvs/torcom/proficiency-passive-border.png"] = cachedMats["hfgjvs/torcom/proficiency-passive-border.png"] or Material("hfgjvs/torcom/proficiency-passive-border.png")
	cachedMats["hfgjvs/torcom/item_grade_26.png"] = cachedMats["hfgjvs/torcom/item_grade_26.png"] or Material("hfgjvs/torcom/item_grade_26.png")
	cachedMats["hfgjvs/torcom/utility-active-new.png"] = cachedMats["hfgjvs/torcom/utility-active-new.png"] or Material("hfgjvs/torcom/utility-active-new.png")
	cachedMats["hfgjvs/torcom/item_grade_13.png"] = cachedMats["hfgjvs/torcom/item_grade_13.png"] or Material("hfgjvs/torcom/item_grade_13.png")
	
	local offset = 0
	for slot,id in pairs(currentPowers) do
		if id != "empty" then
			local power = getPower(id)
			if power then
				local mat = power.icon
				cachedMats[mat] = cachedMats[mat] or Material(mat)
				surface.SetDrawColor(255, 255, 255, 255)
				surface.SetMaterial(cachedMats[mat])
				surface.DrawTexturedRect(ScrW()/2 - plateW/2 + padding + offset, ScrH() - plateH - iconS + padding, iconS, iconS)
				if slot == forcePointer then
					surface.SetMaterial(cachedMats["hfgjvs/torcom/item_grade_13.png"])
				else
					surface.SetMaterial(cachedMats["hfgjvs/torcom/proficiency-passive-border.png"])
				end
				surface.DrawTexturedRect(ScrW()/2 - plateW/2 + padding + offset, ScrH() - plateH - iconS + padding, iconS, iconS)
			end
		else
			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(cachedMats["hfgjvs/torcom/item_grade_26.png"])
			surface.DrawTexturedRect(ScrW()/2 - plateW/2 + padding + offset, ScrH() - plateH - iconS + padding, iconS, iconS)
			
			if slot == forcePointer then
				surface.SetMaterial(cachedMats["hfgjvs/torcom/item_grade_13.png"])
			else
				surface.SetMaterial(cachedMats["hfgjvs/torcom/proficiency-passive-border.png"])
			end
			surface.DrawTexturedRect(ScrW()/2 - plateW/2 + padding + offset, ScrH() - plateH - iconS + padding, iconS, iconS)
		end
		if LSP.Config.ForcePointer then
			if slot == forcePointer then
				surface.SetDrawColor(255,255,255, 255)
				surface.SetMaterial(cachedMats["hfgjvs/torcom/utility-active-new.png"])
				surface.DrawTexturedRect(ScrW()/2 - plateW/2 + padding + offset + iconS*0.1, ScrH() - plateH - iconS - iconS*0.4, iconS*0.8, iconS*0.8)
			end
		end
		offset = offset + iconS + padding
	end	
end)



-- Damn this is much shorter than it used to be, my how the times change.
local nextReleased = true
local prevReleased = true
local delays = {}

hook.Add("Think", "omlisdfgsdfgs", function()
	if input.IsKeyDown(LSP.Config.ForceNext) then
		if nextReleased then
			forcePointer = forcePointer + 1
			if forcePointer > #currentPowers then
				forcePointer = 1
			end
			nextReleased = false
		end
	else
		nextReleased = true
	end
	if input.IsKeyDown(LSP.Config.ForcePrev) then
		if prevReleased then
			forcePointer = forcePointer - 1
			if forcePointer <= 0 then
				forcePointer = #currentPowers
			end
			prevReleased = false
		end
	else
		prevReleased = true
	end
	
	// Same Code in power.lua Line 395, wtf
	//if input.IsKeyDown(LSP.Config.ForceCast) then
	//	local power = currentPowers[forcePointer]
	//	if power != "empty" then
	//		local pwr = getPower(power)
	//		delays[power] = delays[power] or 0
	//		
	//		if delays[power] <= CurTime() then
	//			net.Start("saberplus-cast-power")
	//				net.WriteString(power)
	//			net.SendToServer()
	//			delays[power] = CurTime() + pwr.delay
	//		end
	//	end
	//end	
end)






function powerMenu()
	local powers = getPowers()
	
	local iconS = 50
	local padding = 5
	local plateW = (iconS * LSP.Config.MaxForcePowers) + ((LSP.Config.MaxForcePowers+1) * padding)
	local plateH = iconS + (padding*2)
	
	local w,h = plateW, ScrH()*0.5
	local f = vgui.Create("DFrame")
	f:SetSize(w, h)
	f:SetTitle("")
	f:Center()
	f:MakePopup()
	f:ShowCloseButton(true)
	
	function f:Paint(w,h)
		surface.SetDrawColor(25, 25, 25, 255)
		surface.DrawRect(0, 0, w, h)
		
		surface.SetDrawColor(177, 2, 2, 255)
		surface.DrawRect(0, 0, w*0.05, 1)
		
		surface.SetDrawColor(177, 2, 2, 255)
		surface.DrawRect(0, 0, 1, h*0.1)
		
		surface.SetDrawColor(177, 2, 2, 255)
		surface.DrawRect(w-1, 0, 1, h*0.1)
		
		surface.SetDrawColor(177, 2, 2, 255)
		surface.DrawRect(w*0.95, 0, w*0.05, 1)
		
		surface.SetDrawColor(177, 2, 2, 255)
		surface.DrawRect(0, 0, w*0.05, 1)
		surface.SetDrawColor(177, 2, 2, 255)
		surface.DrawRect(0, 0, 1, h*0.1)
		surface.SetDrawColor(177, 2, 2, 255)
		surface.DrawRect(w-1, 0, 1, h*0.1)
		surface.SetDrawColor(177, 2, 2, 255)
		surface.DrawRect(w*0.95, 0, w*0.05, 1)
		surface.SetDrawColor(177, 2, 2, 255)
		surface.DrawRect(0, h-1, w*0.05, 1)
		surface.SetDrawColor(177, 2, 2, 255)
		surface.DrawRect(0, h*0.9, 1, h*0.1)
		surface.SetDrawColor(177, 2, 2, 255)
		surface.DrawRect(w-1, h*0.9, 1, h*0.1)
		surface.SetDrawColor(177, 2, 2, 255)
		surface.DrawRect(w*0.95, h-1, w*0.05, 1)
		
	end
	
	local bottomBar = vgui.Create("DScrollPanel", f)
	bottomBar:SetSize(plateW, ScrH()*0.5 - plateH - 50)
	bottomBar:SetPos(0,25)
	bottomBar.Paint = function(s,w,h)
		surface.SetDrawColor(7,7,7, 255)
		surface.DrawRect(0, 0, w, h)
	end
	
	local rowBank = {}
	local ps = table.Count(powers)
	local mx = LSP.Config.MaxForcePowers
	local rows = math.ceil(ps/mx)

	for i=1,rows do
		local row = vgui.Create("DPanel", bottomBar)
		row:SetSize(iconS,iconS)
		row:Dock(TOP)
		row.Paint = function() end
		rowBank[i] = row
	end
	
	local curCount = 0
	local curRow = 1
	
	for id,pwr in pairs(powers) do
		local r = rowBank[curRow]
		
		local p = vgui.Create("DPanel", r)
		p:SetSize(padding,padding)
		p:Dock(LEFT)
		p.Paint = function() end
			
		local p = vgui.Create("DPanel", r)
		p:SetSize(iconS, iconS)
		p:Dock(LEFT)
		p:Droppable("yeh")
		p.id = id
		p.Paint = function(s,w,h)
			cachedMats[pwr.icon] = cachedMats[pwr.icon] or Material(pwr.icon)
			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(cachedMats[pwr.icon])
			surface.DrawTexturedRect(0, 0, w, h)
			
		end
		
		curCount = curCount + 1
		if curCount >= LSP.Config.MaxForcePowers then
			curCount = 0
			curRow = curRow + 1
		end
	end
	
	local bottomBar = vgui.Create("DPanel", f)
	bottomBar:SetSize(plateW, plateH-padding-padding)
	bottomBar:SetPos(0,ScrH()*0.5 - plateH)
	bottomBar.Paint = function(s,w,h)
		surface.SetDrawColor(17,17,17, 255)
		surface.DrawRect(0, 0, w, h)
	end
	bottomBar:CenterHorizontal(0.5)
	
	for i=1,LSP.Config.MaxForcePowers do
		local p = vgui.Create("DPanel", bottomBar)
		p:SetSize(padding,padding)
		p:Dock(LEFT)
		p.Paint = function() end
			
		local p = vgui.Create("DButton", bottomBar)
		p:SetSize(iconS, iconS)
		p:Dock(LEFT)
		p:Receiver("yeh", function(self, panels, dropped, cmd, x, y)
			if dropped then
				currentPowers[i] = panels[1].id
				isEmpty = false
			end
		end)
		p:SetText("")
		p.DoClick = function()
			currentPowers[i] = "empty"
		end
		p.Paint = function(s,w,h)
			local id = currentPowers[i]
			local power = getPower(id)
			
			if id != "empty" then
				cachedMats[power.icon] = cachedMats[power.icon] or Material(power.icon)
				surface.SetDrawColor(255, 255, 255, 255)
				surface.SetMaterial(cachedMats[power.icon])
				surface.DrawTexturedRect(0, 0, w, h)
			else
				cachedMats["hfgjvs/torcom/item_grade_26.png"] = cachedMats["hfgjvs/torcom/item_grade_26.png"] or Material("hfgjvs/torcom/item_grade_26.png")
				surface.SetDrawColor(255, 255, 255, 255)
				surface.SetMaterial(cachedMats["hfgjvs/torcom/item_grade_26.png"])
				surface.DrawTexturedRect(0, 0, w, h)
			end
		end
	end
end




