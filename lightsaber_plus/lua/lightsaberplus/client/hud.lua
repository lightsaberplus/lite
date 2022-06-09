local wisp = Material("swrp/wisp.png", "mips smooth")
local leftbar = Material("swrp/leftbar.png")
local rightbar = Material("swrp/rightbar.png")

local staminaLerp = 0
local forceLerp = 0

local barHeight = 10
local barLength = ScrW() * 0.15
local subBarSize = 4

local hits = {}

local function quickDis(a,b,c)
	return a:DistToSqr(b) < c -- pRoBaBlLy nOt OptImIzeD eNouGh (but it will doooo)
end

local function addHit(pos, amt, color)
	local hit = {}
	hit.pos = pos
	hit.offset = 0
	hit.amt = amt
	hit.time = CurTime() + 1
	hit.color = color
	table.insert(hits, hit)
end

local function hitNumbers()
	local function fastText(msg,x,y,c)
		draw.DrawText(msg, "weebs", x, y, c, TEXT_ALIGN_CENTER)
	end

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

hook.Add( "HUDShouldDraw", "HideHUD", function( name )
	if LSP.Config.KillHud then return end
	if name == "CHudAmmo" then return false end
end)

hook.Add("HUDPaint", "soimjdfghdfgh", function()
	if LSP.Config.KillHud then return end
	if LSP.Config.HitNumbers then
		hitNumbers()
	end
end)
saberplusQuickMenu = nil

local buttonData = {}
buttonData["Item List"] = 		{toggle = false, 	mode = nil, 	func = function() RunConsoleCommand("adminv") end,				check = function(ply) return ply:IsAdmin() end}
buttonData["Inventory"] = 		{toggle = false, 	mode = nil, 	func = function() RunConsoleCommand("openinv") end,				check = function(ply) return true end}
buttonData["Switch Form"] = 	{toggle = false, 	mode = nil, 	func = function() formSelection() end,							check = function(ply) return true end}
buttonData["Force Powers"] = 	{toggle = false, 	mode = nil, 	func = function() RunConsoleCommand("forcePowers") end,			check = function(ply) return true end}
buttonData["Force Config"] = 	{toggle = false, 	mode = nil, 	func = function() RunConsoleCommand("powerConfigs") end,		check = function(ply) return true end}
buttonData["Saber Crafter"] = 	{toggle = false, 	mode = nil, 	func = function() RunConsoleCommand("customizeCrystal") end,	check = function(ply) return true end}
buttonData["Scan Lines"] = 		{toggle = true, 	mode = false, 	func = function() RunConsoleCommand("toggleLines") end,			check = function(ply) return true end}

hook.Add("LS+.Config.Reloaded", "LS+.LoadThirdPerson", function()
	if LSP.Config.EnableThirdPersonSys then
		buttonData["Edit 3p"] = 		{toggle = false, 	mode = nil, 	func = function() edit3p() end,									check = function(ply) return true end}
		buttonData["Third Person"] = 	{toggle = true, 	mode = true, 	func = function() RunConsoleCommand("toggleThirdPerson") end,	check = function(ply) return true end}
	else
		buttonData["Third Person"] = nil
		buttonData["Edit 3p"] = nil
	end
end)

surface.CreateFont( "cbutton", {
	font = "LightSaberPlusLight",
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

	saberplusQuickMenu:SetSize( realSize, realSizeT * count + (5*(count+1)))
	saberplusQuickMenu:SetTitle( "" )
	saberplusQuickMenu:SetDraggable(true)
	saberplusQuickMenu:ShowCloseButton(false)
	saberplusQuickMenu.Paint = function(self, w, h)
		surface.SetDrawColor( 5, 5, 5, 255 )
		surface.DrawRect( 0, 0, w, h )
	end
	saberplusQuickMenu:DockPadding(5,5,5,5)
	saberplusQuickMenu:MakePopup()
	saberplusQuickMenu.Opened = SysTime() + 5

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


hook.Add("OnSpawnMenuClose", "okpjdisfokgids", function()
	if  saberplusQuickMenu then
		saberplusQuickMenu:Remove()
	end
end)


hook.Add("SpawnMenuOpen", "LS+.OpenMenu", function()
	if LocalPlayer():GetActiveWeapon() and LocalPlayer():GetActiveWeapon().isLightsaberPlus then
		createQuickMenu()
	return false
	end
end)

surface.CreateFont( "xpbarFont", {
	font = "Trebuchet MS",
	extended = false,
	size = ScreenScale(6),
	weight = 5000,
	antialias = true,
} )


local xpPerc = 0
local from = 0
local cache = 0
hook.Add("HUDPaint", "LS+ XP Bar", function()
	if LSP.Config.KillHud then return end
	local ply = LocalPlayer()
	if !IsValid(ply:GetActiveWeapon()) then return end
	if !ply:GetActiveWeapon().isLightsaberPlus then return end
	local hp, maxhp = math.Clamp(ply:Health(), 0, ply:GetMaxHealth()), ply:GetMaxHealth()
	local lvl = ply:getsyncLightsaberPlusData("saberLevel", 0)
	local xp = ply:getsyncLightsaberPlusData("saberXP", 0)

	local maxW = 600
	local perc = xp / 1000
	xpPerc = Lerp(FrameTime()*6, xpPerc, perc)

	local wide = Lerp(FrameTime()*6, from, perc)
	if from ~= perc then
		if wide ~= perc then
			from = wide
		end
		cache = from
		from = perc
	end

	local curW = maxW * xpPerc


	draw.RoundedBox(10, ScrW()/2 - 300, ScrH()/2 - 520, 605, 18, Color(0, 0, 0, 220)) 
	draw.RoundedBox(10, ScrW()/2 - 296, ScrH()/2 - 517, 600*wide, 12, Color(178, 125, 93, 255))
	draw.SimpleText("" ..lvl, "cbutton", 600, 15, Color(255, 255, 255, 220))
	draw.SimpleText("" ..lvl+1, "cbutton", 1300, 15, Color(255, 255, 255, 220))



	local stm = ply:getsyncLightsaberPlusData("staminaPower", 0)
	draw.RoundedBox(10, ScrW()/2 - 125, ScrH() - 130, 250, 8, Color(0, 0, 0, 220))
	draw.RoundedBox(10, ScrW()/2 - 123, ScrH() - 128, stm*2.46, 4, Color(99, 97, 97, 220))

	draw.RoundedBox(10, ScrW()/2 - 150, ScrH() - 100, 300, 12, Color(0, 0, 0, 220))
	draw.RoundedBox(10, ScrW()/2 - 148, ScrH() - 98, ply:getForce() / ply:getMaxForce() * 296, 8, Color(77, 129, 163, 220))

	draw.RoundedBox(10, ScrW()/13 - 2, ScrH() - 100, 300, 12, Color(0, 0, 0, 220))
	draw.RoundedBox(10, ScrW()/13 , ScrH() - 98, 296 * (hp/maxhp), 8, Color(81, 148, 131, 255))
end)
