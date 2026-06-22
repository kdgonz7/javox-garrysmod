concommand.Add("ja_test_ui", function(ply, cmd, args, argStr)
    if IsValid(MyFrame) then MyFrame:Remove() end

    MyFrame = vgui.Create("DFrame")
    MyFrame:SetPos(ScrH() * 0.5, ScrH() * 0.5)
    MyFrame:SetSize(600, 300)
    MyFrame:SetTitle("Name window")
    MyFrame:SetVisible(true)
    MyFrame:SetDraggable(true)
    MyFrame:ShowCloseButton(true)
    MyFrame:MakePopup()

    local sheet = vgui.Create("DPropertySheet", MyFrame)
    sheet:Dock(FILL)

    local panel = vgui.Create("DPanel", sheet)
    panel:Dock(FILL)
    panel:DockMargin(4, 4, 4, 4)

    local listview = vgui.Create("DListView", panel)
    listview:Dock(FILL)
    listview:AddColumn("Time")
    listview:AddColumn("Date")
    listview:AddColumn("Month")

    listview:AddLine("1:25PM", "6/2/2025", "January")
    listview:AddLine("1:23", "6/223/2025", "March")
    listview:AddLine("1:25PM", "6/21/2025", "April")
    listview:AddLine("1:25PM", "6/22/12025", "May")
    listview:DockMargin(0, 0, 0, 4)

    local configurefinalbutton = vgui.Create("DButton", panel)
    configurefinalbutton:Dock(BOTTOM)
    configurefinalbutton:SetHeight(30)
    configurefinalbutton:SetText("This is a test!")

    configurefinalbutton.DoClick = function()
        local i, line = listview:GetSelectedLine()
        print(line:GetValue(3))
    end

    sheet:AddSheet("List View", panel)
end)


local colorTheme = {
    accentColor = Color(34, 197, 94),
    accentColorDarker = Color(19, 110, 52),
    disabledButton = Color(41, 37, 36),
    disabledButtonDarker = Color(23, 21, 20),
    cardColor = Color(68, 64, 60),
}



concommand.Add("ja_cards_ui", function(ply, cmd, args, argStr)
    if IsValid(MyFrame) then MyFrame:Remove() end

    MyFrame = vgui.Create("DFrame")
    MyFrame:SetPos(ScrH() * 0.5, ScrH() * 0.5)
    MyFrame:SetSize(800, 400)
    MyFrame:SetTitle("Modules")
    MyFrame:SetVisible(true)
    MyFrame:SetDraggable(true)
    MyFrame:ShowCloseButton(true)
    MyFrame:MakePopup()
    MyFrame.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(41, 37, 36))
    end


    local panel = vgui.Create("DScrollPanel", MyFrame)
    panel:Dock(FILL)
    panel:DockMargin(4, 4, 4, 4)

    local sbar = panel:GetVBar()
    sbar:SetWide(8)
    function sbar:Paint(w, h) end

    function sbar.btnUp:Paint(w, h) end

    function sbar.btnDown:Paint(w, h) end

    function sbar.btnGrip:Paint(w, h)
        draw.RoundedBox(4, 2, 0, w - 4, h, colorTheme.accentColor)
    end

    local j = JaVox.vox
    for id, info in pairs(j) do
        local card = vgui.Create("DPanel", panel)
        card:Dock(TOP)
        card:SetHeight(60)
        card:DockMargin(6, 6, 6, 6)
        surface.SetDrawColor(Color(0, 0, 255, 255))
        card:DrawOutlinedRect()
        card.Paint = function(self, w, h)
            local borderW = 3
            draw.RoundedBox(8, 0, 0, w, h, colorTheme.cardColor)
        end

        local label = vgui.Create("DLabel", card)
        label:Dock(LEFT)
        label:DockMargin(20, 10, 0, 10)
        label:SetTextColor(Color(245, 245, 244))
        label:SetText(info.displayName)
        label:SizeToContents()

        local button = vgui.Create("DButton", card)
        button:Dock(RIGHT)
        button:DockMargin(0, 10, 10, 10)
        button:SetText("")
        button.Paint = function(self, w, h)
            local enabled = (LocalPlayer():GetNWString(JAVOX_PRESET, '') == id)
            local colorToUse = enabled and colorTheme.accentColor or colorTheme.disabledButton

            if self:IsHovered() then
                colorToUse = enabled and colorTheme.accentColorDarker or colorTheme.disabledButtonDarker
            end

            draw.RoundedBox(6, 1, 1, w - 2, h - 2, colorToUse)
            draw.SimpleText(enabled and "Enabled" or "Disabled",
                "JaVoxRegular", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        button.DoClick = function()
            net.Start("JaVox_ChangePlayerPreset")
            net.WriteString(id)
            net.SendToServer()
            notification.AddLegacy("Changed your preset to " .. id .. "!", NOTIFY_GENERIC, 3)
        end
    end
end)
