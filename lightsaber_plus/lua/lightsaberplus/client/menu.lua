local tickSize = 16
local lineLength = 64
local linePadding = 8
local uiColor = Color(20, 220, 190) -- blade
local uiColor2 = Color(190, 220, 10) -- quillon
local uiColor3 = Color(177, 0, 0) -- inner
local uiColor4 = Color(177, 0, 177) -- quilloninner
local boxSize = 2

function handleInventory(f, invPanel, inv, left)
    invPanel:Remove()
    local panel = vgui.Create("DScrollPanel", f)
    panel:SetSize(ScrW() * 0.2, ScrH() * 0.75)
    panel:SetPos(25, ScrH() * 0.125)

    panel.Paint = function(s, w, h)
        surface.SetDrawColor(17, 17, 17, 255)
        surface.DrawRect(0, 0, w, h)
    end

    f.inv = panel

    for hash, id in SortedPairsByValue(inv, true) do
        local item = LSP.GetItem(id)

        if item then
            if item.isCrystal then
                local bar = vgui.Create("DPanel", panel)
                bar:SetSize(tickSize * 4, tickSize * 4)
                bar:Dock(TOP)
                bar:DockMargin(0, 0, 0, 10)

                bar.Paint = function(s, w, h)
                    surface.SetDrawColor(35, 35, 35, 255)

                    if item.rarity then
                        local rgb = LSP.Config.Raritys[item.rarity]
                        local r = (rgb.r + 1) / 10
                        local g = (rgb.g + 1) / 10
                        local b = (rgb.b + 1) / 10
                        surface.SetDrawColor(35 + r, 35 + g, 35 + b, 255)
                    end

                    surface.DrawRect(0, 0, w, h)

                    if item.rarity then
                        draw.DrawText(item.name, "xozziesNoodle2", w / 2, ScreenScale(7), LSP.Config.Raritys[item.rarity], TEXT_ALIGN_CENTER)
                        draw.DrawText(item.rarity, "cooldude", w / 2, 5, LSP.Config.Raritys[item.rarity], TEXT_ALIGN_CENTER)
                    else
                        draw.DrawText(item.name, "xozziesNoodle", tickSize * 5, ScreenScale(7), Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)
                    end
                end

                local icon = vgui.Create("DModelPanel", bar)
                icon:SetSize(tickSize * 4, tickSize * 4)
                icon:SetModel(item.mdl)
                icon:Droppable("crystalSlot")
                icon.itemHash = hash
                fixModel(icon)

                icon.Think = function(self)
                    for k, v in pairs(f.bladeInners) do
                        if self:IsDragging() then
                            --v.isShowing = false
                            v:SetPos(9999, 0)
                        else
                            --v.isShowing = true
                        end
                    end

                    for k, v in pairs(f.quillonInners) do
                        if self:IsDragging() then
                            --v.isShowing = false
                            v:SetPos(9999, 0)
                        else
                            --v.isShowing = true
                        end
                    end
                end

                icon.DoClick = function(self)
                    if self.isEquipped then
                        net.Start(self.mode)
                        net.WriteInt(self.id, 32)
                        net.WriteBool(left)
                        net.SendToServer()
                        self:Remove()
                    end
                end
            end

            if item.isInner then
                local bar = vgui.Create("DPanel", panel)
                bar:SetSize(tickSize * 4, tickSize * 4)
                bar:Dock(TOP)
                bar:DockMargin(0, 0, 0, 10)

                bar.Paint = function(s, w, h)
                    surface.SetDrawColor(35, 35, 35, 255)
                    surface.DrawRect(0, 0, w, h)
                    draw.DrawText(item.name, "xozziesNoodle", tickSize * 5, ScreenScale(7), Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)
                end

                local icon = vgui.Create("DModelPanel", bar)
                icon:SetSize(tickSize * 4, tickSize * 4)
                icon:SetModel(item.mdl)
                icon:Droppable("innerSlot")
                icon.itemHash = hash
                fixModel(icon)

                icon.Think = function(self)
                    for k, v in pairs(f.bladeSlots) do
                        if self:IsDragging() then
                            --v.isShowing = false
                            v:SetPos(9999, 0)
                        else
                            --v.isShowing = true
                        end
                    end

                    for k, v in pairs(f.quillionSlots) do
                        if self:IsDragging() then
                            --v.isShowing = false
                            v:SetPos(9999, 0)
                        else
                            --v.isShowing = true
                        end
                    end
                end

                icon.DoClick = function(self)
                    if self.isEquipped then
                        net.Start(self.mode)
                        net.WriteInt(self.id, 32)
                        net.WriteBool(left)
                        net.SendToServer()
                        self:Remove()
                    end
                end
            end
        end
    end
end

function openSaberCrafter(inv, quillons, blades, bladeInner, quillonInner, left)
    local ply = LocalPlayer()

    if IsValid(SABER_CRAFTING_MENU) then
        SABER_CRAFTING_MENU.OnRemove = nil
        SABER_CRAFTING_MENU:Remove()
    end

    local w, h = ScrW(), ScrH()
    local f = vgui.Create("Panel")
    f:SetSize(w, h)
    f:Center()
    f:MakePopup()
    f.l = left
    SABER_CRAFTING_MENU = f

    f.OnRemove = function()
        net.Start("saberplus-end-craft-anim")
        net.SendToServer()
    end

    local butt = vgui.Create("DButton", f)
    butt:SetSize(256, 64)
    butt:SetText("Close")
    butt:SetPos(w - 256 - 10, 64)
    butt:SetFont("xozziesNoodle")
    butt:SetTextColor(Color(255, 255, 255))

    butt.DoClick = function()
        f:Remove()
    end

    butt.Paint = function(s, ww, hh)
        surface.SetDrawColor(17, 17, 17, 255)
        surface.DrawRect(0, 0, ww, hh)
        surface.SetDrawColor(177, 0, 0, 255)
        surface.DrawRect(0, 0, ww, 1)
        surface.DrawRect(0, hh - 1, ww, 1)
        surface.DrawRect(0, 0, 1, hh)
        surface.DrawRect(ww - 1, 0, 1, hh)
    end

    hook.Run("SaberCrafter", f, w, h)
    local saber = ply.rightHilt

    if left then
        saber = ply.leftHilt
        f.isLeft = true
    end

    f.Think = function() end
    local positions = {}
    local positions2 = {}
    local positionsInner = {}
    local positionsInner2 = {}
    f.bladeSlots = {}
    f.bladeInners = {}
    f.quillonInners = {}
    f.quillionSlots = {}

    f.Paint = function(s, w, h)
        surface.SetDrawColor(17, 17, 17, 255)
        surface.DrawRect(0, 0, w, 50)
        surface.DrawRect(0, h - 50, w, 50)
        local ply = LocalPlayer()
        local pos = Vector(0, 0, 0)

        for id, att in pairs(saber:GetAttachments() or {}) do
            if string.match(att.name, "blade(%d+)") then
                local blade = saber:GetAttachment(att.id)
                local pos = blade.Pos:ToScreen()

                if IsValid(f.bladeSlots[id]) then
                    surface.SetDrawColor(uiColor.r, uiColor.g, uiColor.b, 255)
                    surface.DrawLine(pos.x, pos.y, pos.x + lineLength, pos.y - lineLength - linePadding)
                    surface.DrawLine(pos.x + lineLength, pos.y - lineLength - linePadding, pos.x + lineLength + lineLength, pos.y - lineLength - linePadding)

                    positions[id] = {
                        x = pos.x + lineLength + lineLength,
                        y = pos.y - lineLength - linePadding
                    }
                end

                surface.SetDrawColor(uiColor3.r, uiColor3.g, uiColor3.b, 255)
                surface.DrawLine(pos.x, pos.y, pos.x + lineLength * 2, pos.y)

                positionsInner[id] = {
                    x = pos.x + lineLength * 2,
                    y = pos.y
                }

                surface.SetDrawColor(uiColor.r, uiColor.g, uiColor.b, 255)
                surface.DrawRect(pos.x - tickSize / 2, pos.y - tickSize / 2, tickSize, tickSize)
            end
        end

        for id, att in pairs(saber:GetAttachments() or {}) do
            if string.match(att.name, "quillon(%d+)") then
                local blade = saber:GetAttachment(att.id)
                local pos = blade.Pos:ToScreen()
                surface.SetDrawColor(uiColor2.r, uiColor2.g, uiColor2.b, 255)
                surface.DrawLine(pos.x, pos.y, pos.x - lineLength, pos.y + lineLength)
                surface.DrawLine(pos.x - lineLength, pos.y + lineLength, pos.x - lineLength - lineLength, pos.y + lineLength)

                positions2[id] = {
                    x = pos.x - lineLength - lineLength,
                    y = pos.y + lineLength
                }

                surface.SetDrawColor(uiColor4.r, uiColor4.g, uiColor4.b, 255)
                surface.DrawLine(pos.x, pos.y, pos.x - lineLength, pos.y - lineLength)
                surface.DrawLine(pos.x - lineLength, pos.y - lineLength, pos.x - lineLength - lineLength, pos.y - lineLength)

                positionsInner2[id] = {
                    x = pos.x - lineLength - lineLength,
                    y = pos.y - lineLength
                }

                surface.SetDrawColor(uiColor2.r, uiColor2.g, uiColor2.b, 255)
                surface.DrawRect(pos.x - tickSize / 4, pos.y - tickSize / 4, tickSize / 2, tickSize / 2)
            end
        end
    end

    for id, att in pairs(saber:GetAttachments() or {}) do
        if string.match(att.name, "blade(%d+)") then
            local dropSlot = vgui.Create("DPanel", f)
            dropSlot:SetSize(tickSize * 4, tickSize * 4)
            dropSlot:SetPos(128, 128)

            dropSlot.Think = function(self)
                positions[id] = positions[id] or {
                    x = 0,
                    y = 0
                }

                dropSlot:SetPos(positions[id].x, positions[id].y - tickSize * 2)
            end

            f.bladeSlots[id] = dropSlot

            dropSlot.Paint = function(s, w, h)
                surface.SetDrawColor(uiColor.r, uiColor.g, uiColor.b, 255)
                surface.DrawRect(0, 0, w, boxSize)
                surface.DrawRect(0, h - boxSize, w, boxSize)
                surface.DrawRect(0, 0, boxSize, h)
                surface.DrawRect(w - boxSize, 0, boxSize, h)
                surface.SetDrawColor(uiColor.r, uiColor.g, uiColor.b, 25)
                surface.DrawRect(0, 0, w, h)
            end

            dropSlot:Receiver('crystalSlot', function(self, panels, isDropped, index, x, y)
                if isDropped and not (panels[1].isEquipped) then
                    self:Clear()
                    panels[1]:SetParent(dropSlot)
                    net.Start("saberplus-crystal-drop-blade")
                    net.WriteString(panels[1].itemHash)
                    net.WriteInt(id, 32)
                    net.WriteBool(left)
                    net.SendToServer()
                    panels[1].mode = "saberplus-crystal-remove-blade"
                    panels[1].id = id
                    panels[1].isEquipped = true
                end
            end, {})

            hasDrawn = true
        end
    end

    for id, att in pairs(saber:GetAttachments() or {}) do
        if string.match(att.name, "blade(%d+)") then
            local dropSlot = vgui.Create("DPanel", f)
            dropSlot:SetSize(tickSize * 4, tickSize * 4)
            dropSlot:SetPos(128, 128)

            dropSlot.Think = function(self)
                positionsInner[id] = positionsInner[id] or {
                    x = 0,
                    y = 0
                }

                dropSlot:SetPos(positionsInner[id].x, positionsInner[id].y - tickSize * 2)
            end

            f.bladeInners[id] = dropSlot

            dropSlot.Paint = function(s, w, h)
                surface.SetDrawColor(uiColor3.r, uiColor3.g, uiColor3.b, 255)
                surface.DrawRect(0, 0, w, boxSize)
                surface.DrawRect(0, h - boxSize, w, boxSize)
                surface.DrawRect(0, 0, boxSize, h)
                surface.DrawRect(w - boxSize, 0, boxSize, h)
                surface.SetDrawColor(uiColor3.r, uiColor3.g, uiColor3.b, 25)
                surface.DrawRect(0, 0, w, h)
            end

            dropSlot:Receiver('innerSlot', function(self, panels, isDropped, index, x, y)
                if isDropped and not (panels[1].isEquipped) then
                    self:Clear()
                    panels[1]:SetParent(dropSlot)
                    net.Start("saberplus-crystal-drop-inner")
                    net.WriteString(panels[1].itemHash)
                    net.WriteInt(id, 32)
                    net.WriteBool(left)
                    net.SendToServer()
                    panels[1].mode = "saberplus-crystal-remove-inner"
                    panels[1].id = id
                    panels[1].isEquipped = true
                end
            end, {})

            hasDrawn = true
        end

        if string.match(att.name, "quillon(%d+)") then
            local dropSlot = vgui.Create("DPanel", f)
            dropSlot:SetSize(tickSize * 4, tickSize * 4)
            dropSlot:SetPos(128, 128)

            dropSlot.Think = function(self)
                positionsInner2[id] = positionsInner2[id] or {
                    x = 0,
                    y = 0
                }

                dropSlot:SetPos(positionsInner2[id].x - lineLength, positionsInner2[id].y - tickSize * 2)
            end

            f.quillonInners[id] = dropSlot

            dropSlot.Paint = function(s, w, h)
                surface.SetDrawColor(uiColor4.r, uiColor4.g, uiColor4.b, 255)
                surface.DrawRect(0, 0, w, boxSize)
                surface.DrawRect(0, h - boxSize, w, boxSize)
                surface.DrawRect(0, 0, boxSize, h)
                surface.DrawRect(w - boxSize, 0, boxSize, h)
                surface.SetDrawColor(uiColor3.r, uiColor3.g, uiColor3.b, 25)
                surface.DrawRect(0, 0, w, h)
            end

            dropSlot:Receiver('innerSlot', function(self, panels, isDropped, index, x, y)
                if isDropped and not (panels[1].isEquipped) then
                    self:Clear()
                    panels[1]:SetParent(dropSlot)
                    net.Start("saberplus-crystal-drop-inner-quillon")
                    net.WriteString(panels[1].itemHash)
                    net.WriteInt(id, 32)
                    net.WriteBool(left)
                    net.SendToServer()
                    panels[1].mode = "saberplus-crystal-remove-inner-quillon"
                    panels[1].id = id
                    panels[1].isEquipped = true
                end
            end, {})

            hasDrawn = true
        end
    end

    for id, att in pairs(saber:GetAttachments() or {}) do
        if string.match(att.name, "quillon(%d+)") then
            local dropSlot = vgui.Create("DPanel", f)
            dropSlot:SetSize(tickSize * 4, tickSize * 4)
            dropSlot:SetPos(128, 128)

            dropSlot.Think = function(self)
                positions2[id] = positions2[id] or {
                    x = 0,
                    y = 0
                }

                dropSlot:SetPos(positions2[id].x - lineLength, positions2[id].y - tickSize * 2)
            end

            f.quillionSlots[id] = dropSlot

            dropSlot.Paint = function(s, w, h)
                surface.SetDrawColor(uiColor2.r, uiColor2.g, uiColor2.b, 255)
                surface.DrawRect(0, 0, w, boxSize)
                surface.DrawRect(0, h - boxSize, w, boxSize)
                surface.DrawRect(0, 0, boxSize, h)
                surface.DrawRect(w - boxSize, 0, boxSize, h)
                surface.SetDrawColor(uiColor2.r, uiColor2.g, uiColor2.b, 25)
                surface.DrawRect(0, 0, w, h)
            end

            dropSlot:Receiver('crystalSlot', function(self, panels, isDropped, index, x, y)
                if isDropped and not (panels[1].isEquipped) then
                    self:Clear()
                    panels[1]:SetParent(dropSlot)
                    net.Start("saberplus-crystal-drop-quillon")
                    net.WriteString(panels[1].itemHash)
                    net.WriteInt(id, 32)
                    net.WriteBool(left)
                    net.SendToServer()
                    panels[1].mode = "saberplus-crystal-remove-quillon"
                    panels[1].id = id
                    panels[1].isEquipped = true
                end
            end, {})

            hasDrawn = true
        end
    end

    local panel = vgui.Create("DScrollPanel", f)
    panel:SetSize(ScrW() * 0.2, ScrH() * 0.75)
    panel:SetPos(25, ScrH() * 0.125)

    panel.Paint = function(s, w, h)
        surface.SetDrawColor(17, 17, 17, 255)
        surface.DrawRect(0, 0, w, h)
    end

    f.inv = panel
    handleInventory(f, panel, inv, left)

    for blade, id in pairs(blades) do
        if id ~= "" then
            local item = LSP.GetItem(id)

            if item then
                local icon = vgui.Create("DModelPanel", f.bladeSlots[blade])
                icon:SetSize(tickSize * 4, tickSize * 4)
                icon:SetModel(item.mdl)
                icon:Droppable("crystalSlot")
                icon.isEquipped = true
                fixModel(icon)
                icon.mode = "saberplus-crystal-remove-blade"
                icon.id = blade

                icon.DoClick = function()
                    net.Start("saberplus-crystal-remove-blade")
                    net.WriteInt(blade, 32)
                    net.WriteBool(left)
                    net.SendToServer()
                    net.Start("saberplus-ping-inv-upd")
                    net.SendToServer()
                    icon:Remove()
                end
            end
        end
    end

    for blade, id in pairs(bladeInner) do
        if id ~= "" then
            local item = LSP.GetItem(id)

            if item then
                local icon = vgui.Create("DModelPanel", f.bladeInners[blade])
                icon:SetSize(tickSize * 4, tickSize * 4)
                icon:SetModel(item.mdl)
                icon:Droppable("crystalSlot")
                icon.isEquipped = true
                fixModel(icon)
                icon.mode = "saberplus-crystal-remove-inner"
                icon.id = blade

                icon.DoClick = function()
                    net.Start("saberplus-crystal-remove-inner")
                    net.WriteInt(blade, 32)
                    net.WriteBool(left)
                    net.SendToServer()
                    net.Start("saberplus-ping-inv-upd")
                    net.SendToServer()
                    icon:Remove()
                end
            end
        end
    end

    for quillon, id in pairs(quillons) do
        if id ~= "" then
            local item = LSP.GetItem(id)

            if item then
                local icon = vgui.Create("DModelPanel", f.quillionSlots[quillon])
                icon:SetSize(tickSize * 4, tickSize * 4)
                icon:SetModel(item.mdl)
                icon:Droppable("crystalSlot")
                icon.isEquipped = true
                fixModel(icon)
                icon.mode = "saberplus-crystal-remove-quillon"
                icon.id = quillon

                icon.DoClick = function()
                    net.Start("saberplus-crystal-remove-quillon")
                    net.WriteInt(quillon, 32)
                    net.WriteBool(left)
                    net.SendToServer()
                    net.Start("saberplus-ping-inv-upd")
                    net.SendToServer()
                    icon:Remove()
                end
            end
        end
    end

    for quillon, id in pairs(quillonInner) do
        if id ~= "" then
            local item = LSP.GetItem(id)

            if item then
                local icon = vgui.Create("DModelPanel", f.quillonInners[quillon])
                icon:SetSize(tickSize * 4, tickSize * 4)
                icon:SetModel(item.mdl)
                icon:Droppable("crystalSlot")
                icon.isEquipped = true
                fixModel(icon)
                icon.mode = "saberplus-crystal-remove-inner-quillon"
                icon.id = quillon

                icon.DoClick = function()
                    net.Start("saberplus-crystal-remove-inner-quillon")
                    net.WriteInt(quillon, 32)
                    net.WriteBool(left)
                    net.SendToServer()
                    net.Start("saberplus-ping-inv-upd")
                    net.SendToServer()
                    icon:Remove()
                end
            end
        end
    end
end

net.Receive("saberplus-start-crystal-cuztom", function()
    local inv = net.ReadCompressedTable()
    local quillons = net.ReadCompressedTable()
    local blades = net.ReadCompressedTable()
    local bladesInner = net.ReadCompressedTable()
    local quillonInner = net.ReadCompressedTable()
    local left = net.ReadBool()
    openSaberCrafter(inv, quillons, blades, bladesInner, quillonInner, left)
end)

net.Receive("saberplus-ping-inv-upd", function()
    local inv = net.ReadCompressedTable()
    handleInventory(SABER_CRAFTING_MENU, SABER_CRAFTING_MENU.inv, inv, SABER_CRAFTING_MENU.l)
end)

function formSelection()
    
    local scrw, scrh = ScrW(), ScrH()
    local w, h = scrw * 0.3, scrh * 0.75
    local vc = vgui.Create
    local drawText = draw.SimpleText
    local rboxx = draw.RoundedBox
    local color_white = Color(255, 255, 255, 255)
    local color_darkbg = Color(19, 14, 24)
    local color_darkbg2 = Color(22, 21, 24)

    local f = vgui.Create("DPanel")
    f:SetSize(w, h)
    f:Center()
    f:MakePopup()

    function f:Paint(w, h)
        rboxx(15,0, 0, w, h, color_darkbg)
    end
    
    f.inv = vgui.Create("DScrollPanel", f)
    f.inv:Dock(FILL)
    f.inv:DockMargin(0, 0, 0, 2.5)
    local sbar = f.inv:GetVBar()
    sbar:SetSize(5,0)
    sbar:SetHideButtons( true )
    function sbar.btnGrip:Paint(w, h) draw.RoundedBoxEx(14,0,0,w,h,Color(183,0,255),false,false,false,true) end
    function sbar:Paint(w, h) draw.RoundedBoxEx(14,0,0,w,h,Color(46,46,46),false,false,false,true) end
    function sbar.btnUp:Paint(w, h) return end
    function sbar.btnDown:Paint(w, h) return end

    for _, form in pairs(LSP.Config.FormOrder) do
        local data = LSP.Config.Forms[form]
        local p = vgui.Create("DPanel", f.inv)
        p:SetTall(100)
        p:Dock(TOP)
        p:DockMargin(5, 5,5,5)

        p.Paint = function(s, w, h)            
            local clr = Color(255, 255, 255)
            
            rboxx(90,0,0,w,h,Color(46,13,56))
            rboxx(90,2, 2, w-4, h-4, color_darkbg2)
         --   rboxx(100,0,5,w/2-200,h-15,Color(255,255,255,255))
           -- draw.DrawText(data.icon, "form", w / 2 - 237, h / 2 - 30, Color(177, 2, 2), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        local l1 = vgui.Create("DLabel", p)
        l1:SetText("")
        l1:Dock(LEFT)
        l1:DockMargin(5, 5, 0,5)
        l1:SetWide(100)

        l1.Paint = function(s, w, h)
            rboxx(100,0,0,w,h,Color(46,13,56))
            rboxx(100,2,2,w-4,h-4,Color(28,26,26))
            draw.DrawText(data.icon, "form", w / 2, h / 2 - 30, Color(177, 2, 2), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        local l2 = vgui.Create("DLabel", p)
        l2:SetText("")
        l2:Dock(LEFT)
        l2:DockMargin(0, 0, 0,0)
        l2:SetWide(ScrW()*0.5)

        l2.Paint = function(s, w, h)
            draw.DrawText(form, "xozziesNoodle3", 25, s:GetTall()/2-40, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
          --  draw.DrawText(data.desc, "xozziesNoodle2", 25, 40, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        end
        
        local desc = vgui.Create("DPanel", p)
        desc:SetPos(ScrW()*0.067,ScrH()*0.042)
        desc:SetSize(ScrW()*0.18,50)
        desc.Paint = nil

        local description = vgui.Create( "RichText", desc )
        description:Dock( FILL )
        description:AppendText(data.desc)


        local get = vgui.Create("DButton", p)
        get:SetText("")
        get:Dock(RIGHT)
        get:DockMargin(0,10,10,10)
        get:SetWide(70)
        local getted = false
        get.Paint = function(s, w, h)
            draw.RoundedBoxEx(100,0,0,w,h,Color(46,13,56),false,true,false,true)
            draw.RoundedBoxEx(100,2,2,w-4,h-4,Color(28,26,26),false,true,false,true)
            draw.DrawText("➧", "form", w / 2, h / 2 - 30, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        get.DoClick = function()
            net.Start("lightsaber+ form swap")
            net.WriteString(form)
            net.SendToServer()
            f:Remove()
        end
        


        
/*

        spacer(f.inv, 10, TOP)
        local icon = vgui.Create("DPanel", p)
        icon:SetSize(130, 130)
        icon:Dock(LEFT)

        icon.Paint = function(s, w, h)
            surface.SetDrawColor(4, 4, 4, 255)
            surface.DrawRect(0, 0, w, h)
            draw.DrawText(data.icon, "form", w / 2, h / 2 - (90 / 2), Color(177, 2, 2), TEXT_ALIGN_CENTER)
        end

        local deet = vgui.Create("DPanel", p)
        deet:SetSize(130, 130)
        deet:Dock(FILL)

        deet.Paint = function(s, w, h)
            draw.DrawText(form, "xozziesNoodle2", 10, 20, Color(240, 240, 240), TEXT_ALIGN_LEFT)
            draw.DrawText(data.desc, "cooldude", 20, 20 + ScreenScale(7), Color(240, 240, 240), TEXT_ALIGN_LEFT)
        end

        local b = vgui.Create("DButton", p)
        b:SetSize(150, 75)
        b:SetText("Select Form")
        b:SetFont("invTitle2")
        b:SetTextColor(Color(255, 255, 255))
        b:SetPos(410, 95)

        b.DoClick = function()
            net.Start("lightsaber+ form swap")
            net.WriteString(form)
            net.SendToServer()
            f:Remove()
        end

        function b:Paint(w, h)
            surface.SetDrawColor(177, 0, 0, 255)
            surface.DrawRect(0, h * 0.33, w, h * 0.35)
        end
        */
    end
    
    local bottom = vgui.Create("DPanel", f)
    bottom:SetTall(scrh*0.075)
    bottom:Dock(BOTTOM)
    bottom.Paint = nil

        local close = vc("DButton", bottom)
        close:Dock(FILL)
        close:DockMargin(scrw*0.01,10,10,scrw*0.01)
        close:SetText("")
        close.DoClick = function()
            f:Remove()
        end
        local speed = 7
        local barStatus = 0 
        close.Paint = function(self,w,h)
            local tc = Color(255,255,255,255)
            if self:IsHovered() then 
                barStatus = math.Clamp(barStatus + speed * FrameTime(), 0, 1)
            else
                barStatus = math.Clamp(barStatus - speed * FrameTime(), 0, 1)
            end
            if self:IsHovered() then 
                tc = Color(250,0,0,255)
            end
            rboxx(100,0,0,w,h,Color(46,13,56))
            rboxx(100,2,2,w-4,h-4,color_darkbg)
            if self:IsHovered() then
                rboxx(100,0 + ScrW() * 0.17 * (1 - barStatus),0,w * barStatus,h,Color(46,13,56))
            end
            
            drawText("Close", "form", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        end

end

function edit3p()
    local w, h = ScrW() * 0.2, ScrH() * 0.34
    local f = vgui.Create("DFrame")
    f:SetSize(w, h)
    f:SetTitle("")
    f:Center()
    f:MakePopup()
    f:ShowCloseButton(true)

    function f:Paint(w, h)
        surface.SetDrawColor(25, 25, 25, 255)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(177, 2, 2, 255)
        surface.DrawRect(0, 0, w * 0.05, 1)
        surface.SetDrawColor(177, 2, 2, 255)
        surface.DrawRect(0, 0, 1, h * 0.1)
        surface.SetDrawColor(177, 2, 2, 255)
        surface.DrawRect(w - 1, 0, 1, h * 0.1)
        surface.SetDrawColor(177, 2, 2, 255)
        surface.DrawRect(w * 0.95, 0, w * 0.05, 1)
        surface.SetDrawColor(177, 2, 2, 255)
        surface.DrawRect(0, 0, w * 0.05, 1)
        surface.SetDrawColor(177, 2, 2, 255)
        surface.DrawRect(0, 0, 1, h * 0.1)
        surface.SetDrawColor(177, 2, 2, 255)
        surface.DrawRect(w - 1, 0, 1, h * 0.1)
        surface.SetDrawColor(177, 2, 2, 255)
        surface.DrawRect(w * 0.95, 0, w * 0.05, 1)
        surface.SetDrawColor(177, 2, 2, 255)
        surface.DrawRect(0, h - 1, w * 0.05, 1)
        surface.SetDrawColor(177, 2, 2, 255)
        surface.DrawRect(0, h * 0.9, 1, h * 0.1)
        surface.SetDrawColor(177, 2, 2, 255)
        surface.DrawRect(w - 1, h * 0.9, 1, h * 0.1)
        surface.SetDrawColor(177, 2, 2, 255)
        surface.DrawRect(w * 0.95, h - 1, w * 0.05, 1)
    end

    f.inv = vgui.Create("DScrollPanel", f)
    f.inv:Dock(FILL)
    local slide = vgui.Create("DNumSlider", f.inv)
    slide:SetSize(64, 64)
    slide:Dock(TOP)
    slide:SetText("Shoulder Offset")
    slide:SetMin(-50)
    slide:SetMax(50)
    slide:SetDecimals(0)
    slide:SetValue(LIGHTSABER_PLUS_3P_LROFF)

    slide.OnValueChanged = function(self, value)
		cookie.Set("LIGHTSABER_PLUS_3P_LROFF", value)
        LIGHTSABER_PLUS_3P_LROFF = value
    end

    local slide = vgui.Create("DNumSlider", f.inv)
    slide:SetSize(64, 64)
    slide:Dock(TOP)
    slide:SetText("Forward Offset")
    slide:SetMin(20)
    slide:SetMax(250)
    slide:SetDecimals(0)
    slide:SetValue(LIGHTSABER_PLUS_3P_FWOFF)

    slide.OnValueChanged = function(self, value)
		cookie.Set("LIGHTSABER_PLUS_3P_FWOFF", value)
        LIGHTSABER_PLUS_3P_FWOFF = value
    end

    local slide = vgui.Create("DNumSlider", f.inv)
    slide:SetSize(64, 64)
    slide:Dock(TOP)
    slide:SetText("Vertical Offset")
    slide:SetMin(-60)
    slide:SetMax(30)
    slide:SetDecimals(0)
    slide:SetValue(LIGHTSABER_PLUS_3P_UDOFF)

    slide.OnValueChanged = function(self, value)
		cookie.Set("LIGHTSABER_PLUS_3P_UDOFF", value)
        LIGHTSABER_PLUS_3P_UDOFF = value
    end

    local slide = vgui.Create("DNumSlider", f.inv)
    slide:SetSize(64, 64)
    slide:Dock(TOP)
    slide:SetText("Angle Offset")
    slide:SetMin(-45)
    slide:SetMax(45)
    slide:SetDecimals(0)
    slide:SetValue(LIGHTSABER_PLUS_3P_ANGOFF)

    slide.OnValueChanged = function(self, value)
		cookie.Set("LIGHTSABER_PLUS_3P_ANGOFF", value)
        LIGHTSABER_PLUS_3P_ANGOFF = value
    end

    spacer(f.inv, 10, TOP)
    local cb = vgui.Create("DCheckBoxLabel", f.inv)
    cb:SetSize(64, 64)
    cb:SetText("Cinematic Mode")
    cb:Dock(TOP)
    cb:SetValue(LSP.Config.CinematicCam)
    cb:SizeToContents()

    cb.OnChange = function(self, value)
        LSP.Config.CinematicCam = not LSP.Config.CinematicCam
    end
end