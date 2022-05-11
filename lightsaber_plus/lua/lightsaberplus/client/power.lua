forcePowerLineUp = forcePowerLineUp or {}

local forcePowerMoveLeft = cookie.GetNumber("forcePowerMoveLeft", LSP.Config.ForcePrev)
local forcePowerMoveRight = cookie.GetNumber("forcePowerMoveRight", LSP.Config.ForceNext)
local forcePowerCast = cookie.GetNumber("forcePowerCast", LSP.Config.ForceCast)

hook.Add("LS+.Config.Reloaded", "LS+.LoadForceBinds", function()
	forcePowerMoveLeft = cookie.GetNumber("forcePowerMoveLeft", LSP.Config.ForcePrev)
	forcePowerMoveRight = cookie.GetNumber("forcePowerMoveRight", LSP.Config.ForceNext)
	forcePowerCast = cookie.GetNumber("forcePowerCast", LSP.Config.ForceCast)
end)

local cachedMaterials = {}
local selectedPower = 1

net.Receive("saberplus-force-change", function()
	local amt = net.ReadInt(32)
	GLOBAL_FORCE_POOL = amt
end)


surface.CreateFont( "buttonHeader", {
	font = "Arial Black",
	extended = false,
	size = ScreenScale(8),
	weight = 500,
	antialias = true,
} )
surface.CreateFont( "buttonHeader2", {
	font = "Arial Black",
	extended = false,
	size = ScreenScale(8),
	weight = 500,
	antialias = true,
} )
surface.CreateFont( "forceHeader", {
	font = "Arial Black",
	extended = false,
	size = ScreenScale(13),
	weight = 100,
	antialias = true,
} )

surface.CreateFont( "barFont", {
	font = "Arial Black",
	extended = false,
	size = ScreenScale(6),
	weight = 100,
	antialias = true,
} )

function createFrame(w,h)
	local f = vgui.Create( "DFrame" )
	f:SetPos( 100, 100 )
	f:SetSize( w, h)
	f:SetTitle( "" )
	f:SetDraggable( true )
	f:MakePopup()
	f:Center()
	f.Paint = function(self, w, h)
		surface.SetDrawColor( 5, 5, 5, 255 )
		surface.DrawRect( 0, 0, w, h )
	end
	
	return f
end

function createHeaderButton(p, text, x, y, w, h, color, func)
	local b = vgui.Create( "DButton", p)
	b:SetPos( x, y )
	b:SetSize( w, h)
	b:SetText( "" )
	
	b.DoClick = function()
		func()
	end
	
	b.Paint = function(self, w, h)
		surface.SetDrawColor( 23, 23, 23, 255 )
		surface.DrawRect( 0, 0, w, h )
		
		
		
		if self:IsHovered() then
			surface.SetDrawColor( 27, 27, 27, 255 )
			surface.DrawRect( 0, 0, w, h )
			surface.SetDrawColor( color.r, color.g, color.b, 255 )
			surface.DrawRect( 0, h-7, w, 7 )
			
			
		else
			surface.SetDrawColor( color.r, color.g, color.b, 255 )
			surface.DrawRect( 0, h-4, w, 4 )
		end
		
		draw.DrawText( text, "buttonHeader2", w/2 +2, h/4+2, Color( 2, 2, 2, 255 ), TEXT_ALIGN_CENTER )
		draw.DrawText( text, "buttonHeader2", w/2, h/4, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
		
	end
	
	return b
end

function backPanel(p,s)
	local x = vgui.Create("DScrollPanel", p)
	x:SetSize(s,s)
	x:Dock(FILL)
	x.Paint = function(self, w, h)
		surface.SetDrawColor( 177, 0, 0, 255 )
		surface.DrawRect( 0, 0, w, h )
		
		surface.SetDrawColor( 14, 14, 14, 255 )
		surface.DrawRect( 2, 2, w-4, h-4 )
	end
	return x
end

function easyPanel(p,s)
	local x = vgui.Create("DPanel", p)
	x:SetSize(s,s)
	return x
end

function spacer(p,s,t)
	local x = vgui.Create("DScrollPanel", p)
	x:SetSize(s,s)
	x:Dock(t)
	x.Paint = function(self, w, h) end
	return x
end

function innerPanel(p,s)
	local x = vgui.Create("DScrollPanel", p)
	x:SetSize(s,s)
	x:Dock(TOP)
	x.Paint = function(self, w, h)
		surface.SetDrawColor( 24, 24, 24, 255 )
		surface.DrawRect( 0, 0, w, h )
		
		surface.SetDrawColor( 177, 0, 0, 255 )
		surface.DrawRect( w-2, 0, 2, h )
	end
	return x
end

local cachedLerps = {}
local cachedMats = {}

surface.CreateFont( "primaryFont", {font = "Khmer UI Bold", size = ScreenScale(13), weight = 500, antialias = true})
surface.CreateFont( "smallFont", {font = "Khmer UI Bold", size = ScreenScale(9), weight = 500, antialias = true})
surface.CreateFont( "smallFontNormal", {font = "Khmer UI", size = ScreenScale(7), weight = 500, antialias = true})
surface.CreateFont( "mainLevel", {font = "Khmer UI Bold", size = ScreenScale(20), weight = 500, antialias = true})

function lerpBar(key, speed, color, perc, x, y, w, h, mat)
	cachedMats[mat] = cachedMats[mat] or Material(mat)
	cachedLerps[key] = cachedLerps[key] or perc
	cachedLerps[key] = Lerp(FrameTime() * speed, cachedLerps[key], perc)
	render.SetScissorRect(x, y, x + (w*cachedLerps[key]), y+ h, true)
		surface.SetDrawColor(color.r, color.g, color.b, color.a)
			surface.SetMaterial(cachedMats[mat])
		surface.DrawTexturedRect(x, y, w, h)
	render.SetScissorRect(x, y, x+w, y+h, false)
end

function lerpInvertedBar(key, speed, color, perc, x, y, w, h, mat)
	cachedMats[mat] = cachedMats[mat] or Material(mat)
	cachedLerps[key] = cachedLerps[key] or perc
	cachedLerps[key] = Lerp(FrameTime() * speed, cachedLerps[key], perc)
	render.SetScissorRect(x + w - (w * cachedLerps[key]), y, x + w, y+ h, true)
		surface.SetDrawColor(color.r, color.g, color.b, color.a)
			surface.SetMaterial(cachedMats[mat])
		surface.DrawTexturedRect(x, y, w, h)
	render.SetScissorRect(x, y, x+w, y+h, false)
end

function drawBar(color, x, y, w, h, mat)
	cachedMats[mat] = cachedMats[mat] or Material(mat)
	surface.SetDrawColor(color.r, color.g, color.b, color.a)
		surface.SetMaterial(cachedMats[mat])
	surface.DrawTexturedRect(x, y, w, h)
end

local cachedMaterials = {}

surface.CreateFont( "buttonHeader", {
	font = "Arial Black",
	extended = false,
	size = ScreenScale(8),
	weight = 500,
	antialias = true,
} )
surface.CreateFont( "buttonHeader2", {
	font = "Arial Black",
	extended = false,
	size = ScreenScale(8),
	weight = 500,
	antialias = true,
} )
surface.CreateFont( "forceHeader", {
	font = "Arial Black",
	extended = false,
	size = ScreenScale(13),
	weight = 100,
	antialias = true,
} )

surface.CreateFont( "barFont", {
	font = "Arial Black",
	extended = false,
	size = ScreenScale(6),
	weight = 100,
	antialias = true,
} )

bindMaker = bindMaker or nil

function keyBindMaker()
	local Color = Color 
	local color_white = Color(255,255,255,255)
	local color_black = Color(0,0,0,255)
	local color_red = Color(255,0,0,255)
	local color_green = Color(0,255,0,255)

	local surface = surface
	local draw = draw
	local rbox = draw.RoundedBox
	local stext = draw.SimpleText

	if bindMaker then bindMaker:Remove() end

	local f = vgui.Create("DPanel")
	f:SetSize(ScrW()/2,ScrH()/2)
	f:Center()
	f:MakePopup()

	f.Paint = function(self,w,h)
		draw.RoundedBox(0,0,0,w,h,color_black)
	end

	
    local Betaclose = vgui.Create("DButton", f)
    Betaclose:Dock(BOTTOM)
    Betaclose.DoClick = function()
        f:Remove()
    end

/*


    local Betaclose = vgui.Create("DButton", f)
    Betaclose:Dock(BOTTOM)
    Betaclose.DoClick = function()
        f:Close()
    end

	local back = backPanel(f,0)
	
	local bar = innerPanel(back, 64)
	bar:DockMargin(2,2,0,0)
	
	local binder = vgui.Create( "DBinder", bar )
	binder:SetValue(forcePowerMoveLeft)
	binder:SetSize( 128*1.5, 64 )
	binder:Dock(LEFT)
	binder:SetTextColor(Color(0,0,0))
	binder:SetFont("buttonHeader")
	
	binder.Paint = function(self, w, h)
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawRect( 0, 0, w, h )
	end
	
	binder.OnChange = function(n)
		forcePowerMoveLeft = binder:GetValue()
		cookie.Set("forcePowerMoveLeft", binder:GetValue())
		LocalPlayer():EmitSound("UI/buttonclick.wav")
	end
	
	spacer(bar, 20, LEFT)
	
	local title = vgui.Create("DLabel", bar)
	title:SetText("Select Forcepower: Left")
	title:SetFont("buttonHeader")
	title:SizeToContents()
	title:Dock(LEFT)
	
	spacer(back, 10, TOP)
	
	local bar = innerPanel(back, 64)
	bar:DockMargin(2,2,0,0)
	
	local binder = vgui.Create( "DBinder", bar )
	binder:SetValue(forcePowerMoveRight)
	binder:SetSize( 128*1.5, 64 )
	binder:Dock(LEFT)
	binder:SetTextColor(Color(0,0,0))
	binder:SetFont("buttonHeader")
	
	binder.Paint = function(self, w, h)
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawRect( 0, 0, w, h )
	end
	
	binder.OnChange = function(n)
		forcePowerMoveRight = binder:GetValue()
		cookie.Set("forcePowerMoveRight", binder:GetValue())
		LocalPlayer():EmitSound("UI/buttonclick.wav")
	end
	
	spacer(bar, 20, LEFT)
	
	local title = vgui.Create("DLabel", bar)
	title:SetText("Select Forcepower: Right")
	title:SetFont("buttonHeader")
	title:SizeToContents()
	title:Dock(LEFT)
	
	spacer(back, 10, TOP)

	local bar = innerPanel(back, 64)
	bar:DockMargin(2,2,0,0)
	
	local binder = vgui.Create( "DBinder", bar )
	
	if forcePowerCast then binder:SetValue(forcePowerCast) end
	
	binder:SetSize( 128*1.5, 64 )
	binder:Dock(LEFT)
	binder:SetTextColor(Color(0,0,0))
	binder:SetFont("buttonHeader")
	
	binder.Paint = function(self, w, h)
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawRect( 0, 0, w, h )
	end


	binder.OnChange = function(n)
		forcePowerCast = binder:GetValue()
		cookie.Set("forcePowerCast", binder:GetValue())
		LocalPlayer():EmitSound("UI/buttonclick.wav")
	end
	
	spacer(bar, 20, LEFT)
	
	local title = vgui.Create("DLabel", bar)
	title:SetText("Cast Force Power")
	title:SetFont("buttonHeader")
	title:SizeToContents()
	title:Dock(LEFT)
	
	spacer(back, 10, TOP)
	*/
	
	bindMaker = f
end

concommand.Add("powerConfigs", function()
	keyBindMaker()
end)


local hasReadConfigs = false
local lastForceMove = 0
local lastForceUse = 0


local slots = LSP.Config.MaxForcePowers
local size = 64
local spacer = 6
local w,h = ScrW()/2, ScrH()/2


local powerCoolDowns = {}
net.Receive("saberplus-send-cooldown", function()
	local power = net.ReadString()
	local delay = net.ReadFloat()
	powerCoolDowns[power] = CurTime() + delay
end)

hook.Add("Think", "j024tipmdfg2490iop", function()
	if input.IsKeyDown(forcePowerMoveRight) or input.IsMouseDown(forcePowerMoveRight) then
		if lastForceMove <= CurTime() then
			selectedPower = selectedPower + 1
			if selectedPower > slots then
				selectedPower = 1
			end
			lastForceMove = CurTime() + 0.15
		end
	end
	if input.IsKeyDown(forcePowerMoveLeft) or input.IsMouseDown(forcePowerMoveLeft) then
		if lastForceMove <= CurTime() then
			selectedPower = selectedPower - 1
			if selectedPower < 1 then
				selectedPower = slots
			end
			lastForceMove = CurTime() + 0.15
		end
	end
	if input.IsKeyDown(forcePowerCast) or input.IsMouseDown(forcePowerCast) and LocalPlayer():GetNW2Int("forcePool",0) >= 0 then
		if lastForceUse <= CurTime() then
			
			if forcePowerLineUp[selectedPower] then
				powerCoolDowns[forcePowerLineUp[selectedPower]] = powerCoolDowns[forcePowerLineUp[selectedPower]] or 0
				if powerCoolDowns[forcePowerLineUp[selectedPower]] <= CurTime() then
					net.Start("saberplus-cast-power")
						net.WriteString(forcePowerLineUp[selectedPower])
					net.SendToServer()
				end
			end
			
			lastForceUse = CurTime() + 0.1 -- prevent spamming and makes it so everyone has minimum 100ms between casts, making it more balanced.
		end
	end
end)

cachedMaterials["hfgjvs/torcom/proficiency-passive-border.png"] = cachedMaterials["hfgjvs/torcom/proficiency-passive-border.png"] or Material("hfgjvs/torcom/proficiency-passive-border.png")
cachedMaterials["hfgjvs/torcom/item_grade_26.png"] = cachedMaterials["hfgjvs/torcom/item_grade_26.png"] or Material("hfgjvs/torcom/item_grade_26.png")
cachedMaterials["hfgjvs/torcom/utility-active-new.png"] = cachedMaterials["hfgjvs/torcom/utility-active-new.png"] or Material("hfgjvs/torcom/utility-active-new.png")
cachedMaterials["hfgjvs/torcom/item_grade_13.png"] = cachedMaterials["hfgjvs/torcom/item_grade_13.png"] or Material("hfgjvs/torcom/item_grade_13.png")
local emptyCheck = 0
local isEmpty = true
hook.Add("HUDPaint", "joidsfgsdfgsdf", function()
	if (LSP.Config.KillHud) then return end
	local iconS = 50 -- Changing this higher will cause stretching and lowers the quality of the icons.
	local padding = 5
	local borderWidth = 2
	
	local plateW = (iconS * LSP.Config.MaxForcePowers) + ((LSP.Config.MaxForcePowers+1) * padding)
	local plateH = (padding*2.5)
	
	if emptyCheck <= CurTime() then
		isEmpty = true
		for slot,id in pairs(forcePowerLineUp) do
			if id != "empty" then
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
	
	surface.DrawRect(ScrW()/2 - plateW/2 -borderWidth, ScrH() - plateH- iconS-borderWidth, plateW+(borderWidth*2), plateH+ iconS+(borderWidth*2))

	surface.SetDrawColor(17,17,17)
	surface.DrawRect(ScrW()/2 - plateW/2, ScrH() - plateH - iconS, plateW, plateH+ iconS)
	
	local offset = 0
	for i=1,LSP.Config.MaxForcePowers do
		surface.SetDrawColor(255, 255, 255, 255)
		if forcePowerLineUp[i] then
			local power = getPower(forcePowerLineUp[i])
			if power then
				local mat = power.icon
				cachedMaterials[mat] = cachedMaterials[mat] or Material(mat)
				surface.SetMaterial(cachedMaterials[mat])
			end
		else
			surface.SetMaterial(cachedMaterials["hfgjvs/torcom/item_grade_26.png"])
		end
		surface.DrawTexturedRect(ScrW()/2 - plateW/2 + padding + offset, ScrH() - plateH - iconS + padding, iconS, iconS)
		if i == selectedPower then
			surface.SetMaterial(cachedMaterials["hfgjvs/torcom/item_grade_13.png"])
		else
			surface.SetMaterial(cachedMaterials["hfgjvs/torcom/proficiency-passive-border.png"])
		end
		surface.DrawTexturedRect(ScrW()/2 - plateW/2 + padding + offset, ScrH() - plateH - iconS + padding, iconS, iconS)

		if forcePowerLineUp[i] then
			powerCoolDowns[forcePowerLineUp[i]] = powerCoolDowns[forcePowerLineUp[i]] or 0
			if powerCoolDowns[forcePowerLineUp[i]] > CurTime() then
				surface.SetDrawColor(100,5,5,200)
				draw.DrawText(math.Round(powerCoolDowns[forcePowerLineUp[i]] - CurTime(), 1), "barTitleBold", ScrW()/2 - plateW/2 + padding*6 + offset, ScrH() - plateH - iconS + padding*3, color_white, TEXT_ALIGN_CENTER)
				surface.DrawRect(ScrW()/2 - plateW/2 + padding + offset, ScrH() - plateH - iconS + padding, iconS, iconS)
			end
		end
		if LSP.Config.ForcePointer then
			if i == selectedPower then
				surface.SetDrawColor(255,255,255, 255)
				surface.SetMaterial(cachedMaterials["hfgjvs/torcom/utility-active-new.png"])
				surface.DrawTexturedRect(ScrW()/2 - plateW/2 + padding + offset + iconS*0.1, ScrH() - plateH - iconS - iconS*0.4, iconS*0.8, iconS*0.8)
			end
		end
		offset = offset + iconS + padding
	end
end)


colors = {}

function hex(hex)
    local hex = hex:gsub("#","")
	return Color(tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6)))
end

function colors.background(a) a=a or 255
	local c = hex("#050505")
	return Color(c.r,c.g,c.b,a)
end

function colors.foreground(a) a=a or 255
	local c = hex("#0E0E0E")
	return Color(c.r,c.g,c.b,a)
end

function colors.foreground2(a) a=a or 255
	local c = hex("#171717")
	return Color(c.r,c.g,c.b,a)
end

function colors.white(a) a=a or 255
	local c = hex("#ffffff")
	return Color(c.r,c.g,c.b,a)
end

function colors.primary(a) a=a or 255
	local c = hex("#B10000")
	return Color(c.r,c.g,c.b,a)
end

function colors.bad(a) a=a or 255
	local c = hex("#ea2046")
	return Color(c.r,c.g,c.b,a)
end

function colors.purple(a) a=a or 255
	local c = hex("#9537cb")
	return Color(c.r,c.g,c.b,a)
end



surface.CreateFont( "barTitle", { font = "Verdana", extended = false, size = ScreenScale(6), weight = 500} )
surface.CreateFont( "barTitleBold", { font = "Verdana", extended = false, size = ScreenScale(6), weight = 1500} )
surface.CreateFont( "navTitle", { font = "Verdana", extended = false, size = ScreenScale(13), weight = 3500} )
surface.CreateFont( "barClose", { font = "Verdana", extended = false, size = ScreenScale(10), weight = 2500} )
surface.CreateFont( "graphText", { font = "Verdana", extended = false, size = ScreenScale(4), weight = 200} )


function drawBox(x,y,w,h,c)
	surface.SetDrawColor( c.r, c.g, c.b, c.a or 255 )
	surface.DrawRect( x, y, w, h )
end

function drawText(font,text,x,y,dir,c)
	draw.DrawText( text, font, x, y, c, dir )
end

function createFrame()
	local f = vgui.Create( "DFrame" )
	f:SetSize( ScrW() * 0.6, ScrH() * 0.8 )
	f:Center()
	f:SetTitle( "" )
	f:SetDraggable( true )
	f:MakePopup()
	f.Paint = function(s, w, h)
		drawBox(0, 0, w, h, colors.primary())
		drawBox(2, 2, w-4, h-4, colors.background())
	end
	return f
end

function createPanel(panel,x,y,w,h,dock,color)
	local p = vgui.Create( "DPanel", panel )
	p:SetSize( w, h )
	if dock then
		p:Dock(dock)
		p:DockMargin(10,10,10,10)
	else
		p:SetPos(w,h)
	end
	p.Paint = function(s, w, h)
		if color then
			drawBox(0, 0, w, h, color)
		end
	end
	return p
end

function createScrollPanel(panel,x,y,w,h,dock,color)
	local p = vgui.Create( "DScrollPanel", panel )
	p:SetSize( w, h )
	if dock then
		p:Dock(dock)
		p:DockMargin(10,10,10,10)
	else
		p:SetPos(w,h)
	end
	p.Paint = function(s, w, h)
		if color then
			drawBox(0, 0, w, h, color)
		end
	end
	return p
end

function createTextPanel(text,panel,x,y,w,h,dock,color)
	local p = vgui.Create( "DPanel", panel )
	p:SetSize( w, h )
	if dock then
		p:Dock(dock)
		p:DockMargin(10,10,10,10)
	else
		p:SetPos(w,h)
	end
	p.Paint = function(s, w, h)
		drawBox(0, 0, w, h, color)
		drawText("barTitle",text,ScreenScale(5),h*0.5 - (ScreenScale(6)/2),TEXT_ALIGN_LEFT,colors.white())
	end
	return p
end

function graphData(panel,payload,r)
	local p = vgui.Create( "DPanel", panel )
	p:Dock(FILL)
	local biggestData = 0
	for _,dataSet in ipairs(payload) do
		for i=1,#dataSet.data do
			if dataSet.data[i] > biggestData then biggestData = dataSet.data[i] end
		end
	end
	
	
	p.Paint = function(s, w, h)
		local ratio = r
		local scale = biggestData * 1.1 / h
		for _,dataSet in ipairs(payload) do
			for i=1,#dataSet.data-1 do
				local d = dataSet.data[i+1] / scale
				local pd = (dataSet.data[i] or 0) / scale
				local polyGon = {}
				polyGon[#polyGon+1] = {x = (i-1) * (w/(ratio-1)), y = h}
				polyGon[#polyGon+1] = {x = (i-1) * (w/(ratio-1)), y = h - pd}
				polyGon[#polyGon+1] = {x = (i)     * (w/(ratio-1)), y =  h - d}
				polyGon[#polyGon+1] = {x = (i)     * (w/(ratio-1)), y =  h}
				surface.SetDrawColor( dataSet.color.r, dataSet.color.g, dataSet.color.b, dataSet.color.a )
				draw.NoTexture()
				surface.DrawPoly( polyGon )
				
				local polyGon2 = {}
				local density = 2
				polyGon2[#polyGon2+1] = {x = (i-1) * (w/(ratio-1)), y = h - (pd)}
				polyGon2[#polyGon2+1] = {x = (i-1) * (w/(ratio-1)), y = h - (pd+density)}
				polyGon2[#polyGon2+1] = {x = (i)     * (w/(ratio-1)), y =  h - (d+density)}
				polyGon2[#polyGon2+1] = {x = (i)     * (w/(ratio-1)), y =  h - (d)}
				surface.SetDrawColor( dataSet.color.r, dataSet.color.g, dataSet.color.b, 255 )
				draw.NoTexture()
				surface.DrawPoly( polyGon2 )
			end
		end

		for i=1,ratio do
			drawBox(w/ratio * i, 0, 1, h, colors.white(1))
		end
		for i=1,10 do
			drawBox(0, h/10 * i, w, 1, colors.white(1))
		end
		
		local max = 10
		local canDraw = false
		for i=1,max do
			if canDraw then
				drawText("graphText",tostring(((i-1)*(biggestData/max))),2,h - ((i-1)*(h/max)) - (ScreenScale(4)),TEXT_ALIGN_LEFT,colors.white())
			end
			canDraw = !canDraw
		end
		
		local canDraw2 = true
		for i=1,ratio do
			if canDraw2 then
				drawText("graphText",tostring(-ratio + (i-1)),(w/ratio) * (i-1),h - (ScreenScale(4)),TEXT_ALIGN_LEFT,colors.white())
			end
			canDraw2 = !canDraw2
		end
		drawText("graphText",tostring(0),w - ScreenScale(4/2),h - (ScreenScale(4)),TEXT_ALIGN_LEFT,colors.white())
	end
	return p
end

function createBox(text,panel,x,y,w,h,dock)
	local box = createPanel(panel,x,y,w,h,dock,colors.foreground())
	local topBar = createTextPanel(text,box,x,y,w,ScreenScale(14),TOP,colors.foreground2())
	topBar:DockMargin(0,0,0,0)
	return box
end

function createModal(text, body, color)
	local p = vgui.Create( "DPanel", body )
	p:SetSize( 0, ScreenScale(15) )
	p:Dock(TOP)
	p:DockMargin(10,10,10,10)
	p.Paint = function(s, w, h)
		drawBox(0, 0, w, h, color)
		drawText("barTitleBold",text,w*0.025,h*0.5 - (ScreenScale(5)/2),TEXT_ALIGN_LEFT,colors.white())
	end
	
	local x = vgui.Create( "DButton", p )
	x:SetSize( ScreenScale(15), ScreenScale(15) )
	x:Dock(RIGHT)
	x:SetText("")
	x:DockMargin(0,0,0,0)
	x.Paint = function(s, w, h)
		drawText("barClose","X",w/2,h*0.5 - (ScreenScale(10)/2),TEXT_ALIGN_CENTER,colors.foreground(200))
	end
	x.DoClick = function()
		p:Remove()
	end
end

function createModal2(text, body, color, func)
	local p = vgui.Create( "DButton", body )
	p:SetSize( 0, ScreenScale(15) )
	p:Dock(TOP)
	p:DockMargin(10,10,10,10)
	p.Paint = function(s, w, h)
		drawBox(0, 0, w, h, color)
		drawText("barTitleBold",text,w*0.025,h*0.5 - (ScreenScale(5)/2),TEXT_ALIGN_LEFT,colors.white())
	end
	p:SetText("")
	p.DoClick = function()
		func()
	end
end

function openNewPowers(f, mode)
	local a = "You can learn more about force bar crafting by talking with other players. Our power system allows for combinations and complete customization!"
	local body = createScrollPanel(f,0,0,0,0,FILL)
	local fw,fh = f:GetSize()

	local row = createPanel(body,0,0,0,fh*0.60,TOP)
	row:DockMargin(0,0,0,0)
	local rowCount = 2
	local rw = fw-(10*((rowCount*2) +3))

	local rowWid = rw*0.75
	local gg = rowWid /10
	local gg2 = rw /10
	local pows = createBox("Force Powers", row,0,0,rowWid,0,LEFT,colors.foreground())
	local det = createBox("Details", row,0,0,rw*0.25,0,LEFT,colors.foreground())
	local bar = createBox("Your Force Power Bar", body,0,0,0,fh*0.16,TOP,colors.foreground())
	
	local detailIcon =  vgui.Create( "DImage", det )
	detailIcon:SetSize(rw*0.25,rw*0.25)
	detailIcon:Dock(TOP)
	detailIcon:SetImage("hfgjvs/torcom/logo-icon.png")
	
	local detailTitle =  vgui.Create( "DLabel", det )
	detailTitle:SetText("Lightsaber+ Force Powers")
	detailTitle:SetFont("barTitleBold")
	detailTitle:DockMargin(5,5,5,5)
	detailTitle:SizeToContents()
	detailTitle:Dock(TOP)
	
	local detailDesc =  vgui.Create( "RichText", det )
	detailDesc:SetFontInternal("barTitleBold")
	detailDesc:DockMargin(5,5,5,5)
	detailDesc:Dock(FILL)
	detailDesc:SetText(a)
	
	local powerList = vgui.Create("DPanelList", pows)
	powerList:Dock(FILL)
	powerList:EnableVerticalScrollbar(true)
	powerList:EnableHorizontal(true)
	powerList.Paint = function(me)
		//draw.RoundedBox(8,0,0,me:GetWide(),me:GetTall(),Color(220,0,0,90))
	end
	
	for i=1,slots do
		local slot = vgui.Create("DButton", bar)
		slot:SetSize(gg2,gg2)
		slot:SetPos((i-1)*gg2,0)
		slot:SetText("")
		slot:Dock(LEFT)
		
		local tbl = forcePowerLineUp
		if tbl then
			slot.Power = forcePowerLineUp[i]
		end
		
		if i==1 then slot:DockMargin(10,0,0,0) end
		slot.Paint = function(s,w,h)
			local power = forcePowerLineUp[i]
			if power then
				local tbl = getPower(power)
				surface.SetDrawColor(255,255,255)
				if !(cachedMaterials[tbl.icon]) then
					cachedMaterials[tbl.icon] = Material(tbl.icon) // sneaky optimization =3
				end
				surface.SetMaterial(cachedMaterials[tbl.icon])
				surface.DrawTexturedRect(0,0,w,h)
			else
				surface.SetDrawColor(255,255,255)
				local m = "hfgjvs/torcom/item_grade_26.png"
				if !(cachedMaterials[m]) then
					cachedMaterials[m] = Material(m) // sneaky optimization =3
				end
				surface.SetMaterial(cachedMaterials[m])
				surface.DrawTexturedRect(0,0,w,h)
			end
			
		end
		
		slot:Receiver("Hotbar", function(me, panels, dropped)
			if !dropped then return end
			local panel = panels[1]
			
			local power = panel.Power
			forcePowerLineUp[i] = power
			me.Power = power
		end)
		
		slot.DoClick = function(me)
			local power = me.Power
			if !power then return end
			forcePowerLineUp[i] = nil
			me.Power = nil
		end
		
		
		
		slot.OnCursorEntered = function(me)
			local power = me.Power
			if !power then return end
			local tbl = getPower(power)
			detailIcon:SetImage(tbl.icon)
			detailTitle:SetText(power)
			detailTitle:SizeToContents()
			detailDesc:SetText(tbl.desc)
		end
		
		slot.OnCursorExited = function(me)
			detailIcon:SetImage("hfgjvs/torcom/logo-icon.png")
			detailTitle:SetText("LightsaberPlus")
			detailTitle:SizeToContents()
			detailDesc:SetText(a)
		end
		
		
		
	end
	
	local ply = LocalPlayer()
	
	local hasPowers = {}
	local badPowers = {}
	
	for id,data in pairs(getAllPowers()) do
		local canSee = false
		LSP.Config.TeamForcePowers[ply:Team()] = LSP.Config.TeamForcePowers[ply:Team()] or {}

		if LSP.Config.TeamForcePowers[ply:Team()][id] or LSP.Config.TeamForcePowers[ply:Team()]["*"] then
			canSee = true
		end
		
		if canSee then
			hasPowers[id] = data
		else
			badPowers[id] = data
		end
		
	end
	for id,data in pairs(hasPowers) do
		local b = vgui.Create("DButton", pows)
		b:SetText("")
		b:SetSize(gg,gg)
		b.Power = id
		b:Droppable("Hotbar")
		
		b.OnCursorEntered = function(me)
			detailIcon:SetImage(data.icon)
			detailTitle:SetText(id)
			detailTitle:SizeToContents()
			detailDesc:SetText(data.desc)
		end
		
		b.OnCursorExited = function(me)
			detailIcon:SetImage("hfgjvs/torcom/logo-icon.png")
			detailTitle:SetText("LightsaberPlus")
			detailTitle:SizeToContents()
			detailDesc:SetText(a)
		end

		b.Paint = function(s,w,h)
			surface.SetDrawColor(255,255,255)
			if !(cachedMaterials[data.icon]) then
				cachedMaterials[data.icon] = Material(data.icon) // sneaky optimization =3
			end
			surface.SetMaterial(cachedMaterials[data.icon])
			surface.DrawTexturedRect(0,0,w,h)
		end
		
		powerList:AddItem(b)
	end
	
	for id,data in pairs(badPowers) do
		local b = vgui.Create("DButton", pows)
		b:SetText("")
		b:SetSize(gg,gg)
		b.Power = id
		
		b.OnCursorEntered = function(me)
			detailIcon:SetImage(data.icon)
			detailTitle:SetText(id)
			detailTitle:SizeToContents()
			detailDesc:SetText(data.desc)
		end
		
		b.OnCursorExited = function(me)
			detailIcon:SetImage("hfgjvs/torcom/logo-icon.png")
			detailTitle:SetText("LightsaberPlus")
			detailTitle:SizeToContents()
			detailDesc:SetText(a)
		end

		b.Paint = function(s,w,h)
			surface.SetDrawColor(255,255,255)
			if !(cachedMaterials[data.icon]) then
				cachedMaterials[data.icon] = Material(data.icon) // sneaky optimization =3
			end
			surface.SetMaterial(cachedMaterials[data.icon])
			surface.DrawTexturedRect(0,0,w,h)
			
			surface.SetDrawColor(177,0,0,155)
			surface.DrawRect(0,0,w,h)
		end
		
		powerList:AddItem(b)
	end
	

	return body
end

function createNavBar(f)
	local box = createPanel(f,0,0,0,ScreenScale(16),TOP,colors.foreground2())
	local p = vgui.Create( "DPanel", box )
	p:Dock(FILL)
	p.Paint = function(s, w, h)
		drawText("navTitle", "LightsaberPlus Sabers", ScreenScale(3), h*0.5 - (ScreenScale(13)/2), TEXT_ALIGN_LEFT, colors.white())
	end
	// DASHBOARD | INFORMATION | PLAYER MANAGER | SETTINGS
end

function openNewForcePowerMenu()
	local f = createFrame()
	createNavBar(f)
	local page = openNewPowers(f, true)
end


concommand.Add("forcePowers", function()
	 openNewForcePowerMenu()
end)