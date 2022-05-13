surface.CreateFont( "invTitle", {
	font = "LightSaberPlusBold",
	size = ScreenScale(7),
	weight = 50,
	antialias = true,
})
surface.CreateFont( "invTitle2", {
	font = "LightSaberPlusBold",
	size = ScreenScale(7),
	weight = 4500,
	antialias = true,
})

surface.CreateFont( "descTitle", {
	font = "LightSaberPlusBold",
	size = ScreenScale(5),
	weight = 500,
	antialias = true,
})


function inventory()
	if IsValid(INVENTORY_PANEL) then INVENTORY_PANEL:Remove() end
	local w,h = ScrW()*0.4, ScrH()*0.9
	local f = vgui.Create("DFrame")
	f:SetSize(w, h)
	f:SetTitle("")
	f:Center()
	f:MakePopup()
	f:ShowCloseButton(true)
	f.fade = x
	INVENTORY_PANEL = f
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
	f.inv = vgui.Create("DScrollPanel", f)
	f.inv:Dock(FILL)
end

function spacer(x,s,d)
	local bar = vgui.Create("DPanel", x)
	bar:SetSize(s,s)
	bar:Dock(d)
	function bar:Paint() end
	return bar
end

function fixModel(Panel)
	local PrevMins, PrevMaxs = Panel.Entity:GetRenderBounds()
	Panel:SetCamPos(PrevMins:Distance(PrevMaxs)*Vector(0.5, 0.5, 0.5))
	Panel:SetLookAt((PrevMaxs + PrevMins)/2)
end

local invScale = ScreenScale(35)
net.Receive("saberplus-net-inv", function(len, ply)
	if IsValid(INVENTORY_PANEL) then
		local inv = net.ReadCompressedTable()
		local customData = net.ReadCompressedTable()
		for k,m in SortedPairsByValue(inv, true) do
			local v = LSP.GetItem(m)
			if v then
				local bar = vgui.Create("DPanel", INVENTORY_PANEL.inv)
				bar:SetSize(invScale,invScale)
				bar:Dock(TOP)
				function bar:Paint(w,h)
					surface.SetDrawColor(255, 255, 255, 1)
					surface.DrawRect(0, 0, w, h)
				end
				bar.spacer = spacer(INVENTORY_PANEL.inv,10,TOP)

				function bar:OnRemove()
					if IsValid(bar.spacer) then
						bar.spacer:Remove()
					end
				end

				local icon = vgui.Create( "DModelPanel", bar)
				icon:SetSize(invScale,invScale)
				customData[k].mdl = customData[k].mdl or v.mdl
				icon:SetModel(customData[k].mdl)
				icon:Dock(LEFT)
				fixModel(icon)
				spacer(bar,10,LEFT)

				local name = vgui.Create("DLabel", bar)
				customData[k] = customData[k] or {}

				customData[k].name = customData[k].name or v.name
				name:SetText(customData[k].name)

				if v.hasEffect then
					name:SetFont("invTitle2")
					name:SetTextColor(Color(0,255,255))
				elseif v.isSpecial then
					name:SetFont("invTitle2")
					name:SetTextColor(Color(255,255,0))
				else
					name:SetFont("invTitle")
					name:SetTextColor(Color(255,255,255))
				end

				name:SizeToContents()
				name:Dock(LEFT)
				spacer(bar,10,LEFT)

				local desc = vgui.Create("DLabel", bar)

				customData[k].desc = customData[k].desc or v.desc

				desc:SetText(customData[k].desc)
				desc:SetFont("descTitle")
				desc:SizeToContents()
				desc:Dock(LEFT)
				spacer(bar,5,RIGHT)

				local b = vgui.Create("DButton", bar)
				b:SetSize(invScale,invScale)
				b:SetText("Drop")
				b:SetFont("invTitle2")
				b:SetTextColor(Color(255,255,255))

				b:SizeToContents()
				b:Dock(RIGHT)
				b.DoClick = function()
					net.Start("saberplus-net-inv-act")
						net.WriteString(k)
						net.WriteString("drop")
					net.SendToServer()
					bar:Remove()
				end

				function b:Paint(w,h)
					surface.SetDrawColor(177, 0, 0, 255)
					surface.DrawRect(0, h*0.33, w, h*0.35)
				end

				spacer(bar,5,RIGHT)

				for id,func in pairs(v.func or {}) do
					local b = vgui.Create("DButton", bar)
					b:SetSize(invScale,invScale)
					b:SetText(id)
					b:SetFont("invTitle2")
					b:SetTextColor(Color(255,255,255))
					b:SizeToContents()
					b:Dock(RIGHT)
					b.DoClick = function()
						net.Start("saberplus-net-inv-act")
							net.WriteString(k)
							net.WriteString(id)
						net.SendToServer()
					end

					function b:Paint(w,h)
						surface.SetDrawColor(177, 0, 0, 255)
						surface.DrawRect(0, h*0.33, w, h*0.35)
					end
					spacer(bar,5,RIGHT)
				end
			end
		end
	end
end)

function enforceInventory()
	inventory()
	net.Start("saberplus-net-inv")
	net.SendToServer()
end

net.Receive("saberplus-inv-server-open", function()
	enforceInventory()
end)
net.Receive("saberplus-inv-server-close", function()
	if IsValid(INVENTORY_PANEL) then INVENTORY_PANEL:Remove() end
end)

concommand.Add("openInv", function()
	enforceInventory()
end)

concommand.Add("admInv", function()
	inventory()
	if IsValid(INVENTORY_PANEL) then
		local inv = LSP.GetItems()
		for k,v in SortedPairsByMemberValue(inv, "name") do
			local bar = vgui.Create("DPanel", INVENTORY_PANEL.inv)
			bar:SetSize(invScale,invScale)
			bar:Dock(TOP)
			function bar:Paint(w,h)
				surface.SetDrawColor(255, 255, 255, 1)
				surface.DrawRect(0, 0, w, h)
			end

			spacer(INVENTORY_PANEL.inv,10,TOP)

			local icon = vgui.Create( "DModelPanel", bar)
			icon:SetSize(invScale,invScale)
			icon:SetModel(v.mdl or "models/balloons/balloon_dog.mdl")
			icon:Dock(LEFT)
			fixModel(icon)

			spacer(bar,10,LEFT)

			local name = vgui.Create("DLabel", bar)
			name:SetText(v.name)
			name:SetFont("invTitle")
			name:SizeToContents()
			name:Dock(LEFT)
			spacer(bar,10,LEFT)

			local desc = vgui.Create("DLabel", bar)
			desc:SetText(v.desc)
			desc:SetFont("descTitle")
			desc:SizeToContents()
			desc:Dock(LEFT)

			local b = vgui.Create("DButton", bar)
			b:SetSize(invScale,invScale)
			b:SetText(v.id)
			b:SetFont("invTitle")
			b:SetTextColor(Color(255,255,255))
			b:SizeToContents()
			b:Dock(RIGHT)
			b.DoClick = function()
				local m = DermaMenu(true, b)
				m:AddOption( "Copy", function()
					SetClipboardText(v.id)
					chat.AddText(Color(255,255,255), "Copied '",Color(177,0,0), v.id, Color(255,255,255),"' to your clipboard!")
				end )
				m:AddOption( "Give yourself", function() LocalPlayer():ConCommand("say !giveitem "..LocalPlayer():SteamID64().." "..v.id) end )
				local s = m:AddSubMenu("Give")
				for _, p in pairs(player.GetAll()) do
					s:AddOption(p:Name(), function()
						LocalPlayer():ConCommand("say !giveitem "..p:SteamID64().." "..v.id)
					end)
				end
			end

			function b:Paint(w,h)
				surface.SetDrawColor(177, 0, 0, 255)
				surface.DrawRect(0, h*0.33, w, h*0.35)
			end
		end
	end
end)