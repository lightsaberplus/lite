local wisp = Material("swrp/wisp.png", "mips smooth")
local leftbar = Material("swrp/leftbar.png")
local rightbar = Material("swrp/rightbar.png")

local staminaLerp = 0
local forceLerp = 0

local barHeight = 10
local barLength = ScrW() * 0.15
local subBarSize = 4

local hits = {}

function fastText(msg,x,y,c)
	draw.DrawText(msg, "weebs", x, y, c, TEXT_ALIGN_CENTER)
end

function addHit(pos, amt, color)
	local hit = {}
	hit.pos = pos
	hit.offset = 0
	hit.amt = amt
	hit.time = CurTime() + 1
	hit.color = color
	table.insert(hits, hit)
end

function animeNumbers() -- weeb fucks
	if table.Count(hits) < 1 then return end
	local pos = LocalPlayer():GetPos()
	for id,hit in pairs(hits) do
		if hit.time >= CurTime() then
			if quickDis(hit.pos,pos,360000) then
				hits[id].offset = Lerp(FrameTime() * 1, hits[id].offset, 100)
				local vec = hit.pos + Vector(0,0,hit.offset)
				local pos = vec:ToScreen()
				fastText(hit.amt,pos.x + 2, pos.y + 2,Color(0,0,0))
				fastText(hit.amt,pos.x,pos.y,hit.color)
			end
		else
			table.remove(hits, id)
		end
	end
end


net.Receive("saberplus-hits", function()
	local amt = net.ReadInt(32)
	local pos = net.ReadVector()
	addHit(pos, "-"..amt, Color(155,0,0))
end)

net.Receive("saberplus-block", function()
	local pos = net.ReadVector()
	addHit(pos, "BLOCKED!", Color(245, 245,255))
end)

net.Receive("saberplus-riposte", function()
	local pos = net.ReadVector()
	addHit(pos, "PARRY!", Color(245, 245,25))
end)







hook.Add("HUDPaint", "soimjdfghdfgh", function()
	if (LSP.Config.KillHud) then return end
	--local ply = LocalPlayer()
	
	--local stm = ply:getsyncLightsaberPlusData("staminaPower", 0)
	--local frc = ply:getForce()

	--staminaLerp = Lerp(FrameTime()*8, staminaLerp, stm)
	--forceLerp = Lerp(FrameTime()*8, forceLerp, frc)
	
	--LSP.Config.MaxForce[ply:Team()] = LSP.Config.MaxForce[ply:Team()] or 0
	
	--local stmPerc = staminaLerp / 100
	--local frcPerc = forceLerp / LSP.Config.MaxForce[ply:Team()]
	
	--draw.RoundedBox( barHeight/2, 10, ScrH() * LSP.Config.HUDPerc, barLength, barHeight, Color(17,17,17,200))
	--draw.RoundedBox( (barHeight-(subBarSize))/2, 10 + (subBarSize/2), ScrH() * LSP.Config.HUDPerc + (subBarSize/2), (barLength - subBarSize)*stmPerc, barHeight-subBarSize, Color(177,177,0))	
	
	--draw.RoundedBox( barHeight/2, 10, ScrH() * LSP.Config.HUDPerc - barHeight, barLength, barHeight, Color(17,17,17,200))
	--draw.RoundedBox( (barHeight-(subBarSize))/2, 10 + (subBarSize/2), ScrH() * LSP.Config.HUDPerc + (subBarSize/2) - barHeight, (barLength - subBarSize)*frcPerc, barHeight-subBarSize, Color(200,50,255))	
	
	
	if LSP.Config.HitNumbers then
		animeNumbers()
	end
end)
saberplusQuickMenu = nil

local buttonData = {}
buttonData["Item List"] = 		{toggle = false, 	mode = nil, 	func = function() RunConsoleCommand("adminv") end,				check = function(ply) return ply:IsAdmin() end}
buttonData["Inventory"] = 		{toggle = false, 	mode = nil, 	func = function() RunConsoleCommand("openinv") end,				check = function(ply) return true end}
buttonData["Edit 3p"] = 		{toggle = false, 	mode = nil, 	func = function() edit3p() end,									check = function(ply) return true end}
buttonData["Switch Form"] = 	{toggle = false, 	mode = nil, 	func = function() formSelection() end,							check = function(ply) return true end}
buttonData["Force Powers"] = 	{toggle = false, 	mode = nil, 	func = function() RunConsoleCommand("forcePowers") end,			check = function(ply) return true end}
buttonData["Force Config"] = 	{toggle = false, 	mode = nil, 	func = function() RunConsoleCommand("powerConfigs") end,		check = function(ply) return true end}
buttonData["Saber Crafter"] = 	{toggle = false, 	mode = nil, 	func = function() RunConsoleCommand("customizeCrystal") end,	check = function(ply) return true end}
buttonData["Third Person"] = 	{toggle = true, 	mode = true, 	func = function() RunConsoleCommand("toggleThirdPerson") end,	check = function(ply) return true end}
buttonData["Scan Lines"] = 		{toggle = true, 	mode = false, 	func = function() RunConsoleCommand("toggleLines") end,			check = function(ply) return true end}

surface.CreateFont( "cbutton", {
	font = "Arial Black",
	extended = false,
	size = ScreenScale(8),
	weight = 500,
	antialias = true,
})

function createQuickMenu()
	local realSize = 256
	local realSizeT = 64
	if IsValid(saberplusQuickMenu) then saberplusQuickMenu:Remove() end
	saberplusQuickMenu = vgui.Create("DFrame")
	saberplusQuickMenu:SetPos( ScrW() - realSize - 5, ScrH()/2 - realSize )
	
	local count = table.Count(buttonData)
	
	saberplusQuickMenu:SetSize( realSize, realSizeT * count + (5*(count+1))) -- weeee
	saberplusQuickMenu:SetTitle( "" )
	saberplusQuickMenu:SetDraggable(true)
	saberplusQuickMenu:ShowCloseButton(false)
	saberplusQuickMenu.Paint = function(self, w, h)
		surface.SetDrawColor( 5, 5, 5, 255 )
		surface.DrawRect( 0, 0, w, h )
	end
	saberplusQuickMenu:Hide()
	saberplusQuickMenu:SetMouseInputEnabled(false)
	saberplusQuickMenu:DockPadding(5,5,5,5)
	
	for name,data in pairs(buttonData) do
		local check = data.check(LocalPlayer())
		if check then
			local b = vgui.Create( "DButton", saberplusQuickMenu)
			b:SetPos(0, 0)
			b:SetSize(realSize, realSizeT)
			b:Dock(TOP)
			b:SetText("")
			b.DoClick = function()
				local mode = buttonData[name].mode
				buttonData[name].mode = !mode
				data.func()
			end
			local color = Color(200,55,235)
			
			b.Paint = function(self, w, h)
				if buttonData[name].toggle then
					if buttonData[name].mode then
						color = Color(0,200,0)
					else
						color = Color(177,0,0)
					end
				end
				
				surface.SetDrawColor(23, 23, 23, 255)
				surface.DrawRect(0, 0, w, h)
				if self:IsHovered() then
					surface.SetDrawColor(27, 27, 27, 255)
					surface.DrawRect(0, 0, w, h)
					surface.SetDrawColor(color.r, color.g, color.b, 255)
					surface.DrawRect( 0, h-7, w, 7 )
				else
					surface.SetDrawColor(color.r, color.g, color.b, 255)
					surface.DrawRect(0, h-4, w, 4)
				end
				draw.DrawText(name, "cbutton", w/2 +2, h/4+2, Color( 2, 2, 2, 255 ), TEXT_ALIGN_CENTER)
				draw.DrawText(name, "cbutton", w/2, h/4, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER)
			end
			
			local s = vgui.Create( "DPanel", saberplusQuickMenu)
			s:SetSize(realSize,5)
			s:Dock(TOP)
			s.Paint = function()end
		end
	end
end

hook.Add("Think", "okpjdisfokgids", function()
	if not IsValid(saberplusQuickMenu) then
		createQuickMenu()
	end
end)

hook.Add("OnContextMenuOpen", "jmoidsfgd", function()
	saberplusQuickMenu:Show()
	saberplusQuickMenu:MakePopup()
end)

hook.Add("OnContextMenuClose", "jtyijrty", function()
	saberplusQuickMenu:Hide()
	saberplusQuickMenu:SetMouseInputEnabled(false)
end)




surface.CreateFont( "xpbarFont", {
	font = "Trebuchet MS",
	extended = false,
	size = ScreenScale(6),
	weight = 5000,
	antialias = true,
} )


function drawOutlineBar(t, x, y, w, h, p)
	local space = 1
	local lineS = 1
	surface.SetDrawColor(255,255,255,15)
    surface.DrawRect(x-lineS,y-space-lineS,w+(lineS*2),lineS)
    surface.DrawRect(x-lineS,y+h+space,w+(lineS*2),lineS)
	surface.DrawRect(x-lineS-space,y-lineS-space,lineS,h+space+lineS+lineS+lineS)
	surface.DrawRect(x+w+space,y-lineS-space,lineS,h+space+lineS+lineS+lineS)
	surface.SetDrawColor(255,255,255,200)
    surface.DrawRect(x,y,w*p,h)
	draw.DrawText(math.Round(p*100).."%", "xpbarFont", x+w, y+h+5, Color(255,255,255,155), TEXT_ALIGN_RIGHT)
	draw.DrawText(t, "xpbarFont", x, y+h+5, Color(255,255,255,155), TEXT_ALIGN_LEFT)
end



local xpPerc = 0
hook.Add("HUDPaint", "LS+ XP Bar", function()
	local ply = LocalPlayer()
	if !IsValid(ply:GetActiveWeapon()) then return end
	if ply:GetActiveWeapon():GetClass() != "lightsaber_plus" then return end
	local lvl = ply:getsyncLightsaberPlusData("saberLevel", 0)
	local xp = ply:getsyncLightsaberPlusData("saberXP", 0)
	
	local maxW = 600
	local perc = xp / 1000
	
	xpPerc = Lerp(FrameTime()*6, xpPerc, perc)
	
	local curW = maxW * xpPerc
	
	drawOutlineBar("Player Level: " ..lvl, ScrW()/2 - 300, 20, maxW, 15, perc)
	
	local stm = ply:getsyncLightsaberPlusData("staminaPower", 0)
	drawOutlineBar("Stamina: " .. stm .. " / " .. 100, 25, ScrH() * LSP.Config.HUDPerc - 50, 200, 15, stm / 100)
	drawOutlineBar("Force: " .. ply:getForce() .. " / " .. ply:getMaxForce(), 25, ScrH() * LSP.Config.HUDPerc, 200, 15, ply:getForce() / ply:getMaxForce())
	
	local directions = {
		"w",
		"a",
		"d",
		"wa",
		"wd",
	}
	
	local lang = {}
	lang.w = "Lunge"
	lang.a = "Left"
	lang.wa = "D. Left"
	lang.d = "Right"
	lang.wd = "D. Right"
	
	for i=1,5 do
		local dir = directions[i]
		local form = ply:getsyncLightsaberPlusData("currentForm", LSP.Config.DefaultForm)
		
		local lvl = ply:getsyncLightsaberPlusData("form_"..form.."_"..dir.."_lvl", 0)
		local xp = ply:getsyncLightsaberPlusData("form_"..form.."_"..dir.."_xp", 0)
		
		local maxW = 200
		local perc = xp / 1000
		
		xpPerc = Lerp(FrameTime()*6, xpPerc, perc)
		
		local curW = maxW * xpPerc
		if lvl != 9999 then
			drawOutlineBar(lang[dir] ..": " ..lvl, ScrW() - 225, 20 + (45*(i-1)), maxW, 15, perc)
		end
	end
	
end)






