---@diagnostic disable: inject-field
-- TODO: descriptions, authors, tags. not hard.

local MyFrame
local colorTheme = {
    accentColor = Color(34, 197, 94),
    accentColorDarker = Color(19, 110, 52),
    disabledButton = Color(41, 37, 36),
    disabledButtonDarker = Color(23, 21, 20),
    cardColor = Color(68, 64, 60),
    textRegular = Color(245, 245, 244),
    textRegularDarker = Color(212, 212, 212),
}

concommand.Add("javox_vox_mgr", function(ply, cmd, args, argStr)
    if IsValid(MyFrame) then MyFrame:Remove() end

    MyFrame = vgui.Create("DFrame")
    MyFrame:SetPos(ScrH() * 0.25, ScrH() * 0.25)
    MyFrame:SetSize(ScrW() * 0.45, ScrH() * 0.50)
    MyFrame:SetTitle("JaVox Manager")
    MyFrame:SetVisible(true)
    MyFrame:SetDraggable(true)
    MyFrame:ShowCloseButton(true)
    MyFrame:MakePopup()
    MyFrame.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(41, 37, 36))
    end
    local myModules = vgui.Create("DLabel", MyFrame)
    myModules:Dock(TOP)
    myModules:DockMargin(10, 10, 0, 10)
    myModules:SetTextColor(colorTheme.textRegular)
    myModules:SetText("My Modules")
    myModules:SetFont("JaVoxLarger")
    myModules:SizeToContents()

    local headerLabel = vgui.Create("DLabel", MyFrame)
    headerLabel:Dock(TOP)
    headerLabel:DockMargin(10, 10, 0, 10)
    headerLabel:SetTextColor(colorTheme.textRegular)
    headerLabel:SetText("Select a module to enable or disable it. You can only have one module enabled at a time.")
    headerLabel:SetFont("JaVoxRegular")
    headerLabel:SizeToContents()


    local panel = vgui.Create("DScrollPanel", MyFrame)
    panel:Dock(FILL)
    panel:DockMargin(4, 4, 4, 4)

    local sbar = panel:GetVBar()
    sbar:SetWide(8)
    function sbar:Paint(w, h) end

    ---@diagnostic disable-next-line: undefined-field
    function sbar.btnUp:Paint(w, h) end

    ---@diagnostic disable-next-line: undefined-field
    function sbar.btnDown:Paint(w, h) end

    ---@diagnostic disable-next-line: undefined-field
    function sbar.btnGrip:Paint(w, h)
        draw.RoundedBox(8, 2, 0, w - 4, h, colorTheme.accentColor)
    end

    local j = JaVox and JaVox.vox or {}
    for id, info in pairs(j) do
        local card = vgui.Create("DPanel", panel)
        card:Dock(TOP)
        card:SetHeight(80)
        card:DockMargin(6, 6, 6, 6)
        card.Paint = function(self, w, h)
            draw.RoundedBox(8, 0, 0, w, h, colorTheme.cardColor)
        end

        local titleAndAuthrsEtc = vgui.Create("DPanel", card)
        titleAndAuthrsEtc:Dock(FILL)
        titleAndAuthrsEtc:DockMargin(10, 10, 0, 10)
        titleAndAuthrsEtc.Paint = function() end

        local label = vgui.Create("DLabel", titleAndAuthrsEtc)
        label:Dock(TOP)
        label:DockMargin(20, 10, 0, 0)
        label:SetTextColor(colorTheme.textRegular)
        label:SetText(info.displayName)
        label:SizeToContents()
        label:SetFont("JaVoxRegular")

        local author = info.author or "Author"
        if type(author) == 'table' then
            if table.IsEmpty(author) then
                author = "Various Authors"
            else
                ---@diagnostic disable-next-line: param-type-mismatch
                author = table.concat(info.author, ", ")
            end
        end

        local label2 = vgui.Create("DLabel", titleAndAuthrsEtc)
        label2:Dock(TOP)
        label2:DockMargin(20, 0, 0, 0)
        label2:SetTextColor(colorTheme.textRegularDarker)
        label2:SetText(string.format("By %s", author))
        label2:SizeToContents()
        label2:SetFont("JaVoxSmaller")

        local label3 = vgui.Create("DLabel", titleAndAuthrsEtc)
        label3:Dock(TOP)
        label3:DockMargin(20, 0, 0, 0)
        label3:SetTextColor(colorTheme.textRegularDarker)
        label3:SetText(info.description or "No description supplied")
        label3:SizeToContents()
        label3:SetFont("JaVoxSmallest")

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

            surface.PlaySound("ui/buttonclick.wav")
            notification.AddLegacy("Changed your preset to " .. id .. "!", NOTIFY_GENERIC, 3)
        end
    end
end)
