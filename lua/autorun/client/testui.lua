---@diagnostic disable: inject-field

concommand.Add("javox_test_ui", function(ply, cmd, args, argStr)
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
