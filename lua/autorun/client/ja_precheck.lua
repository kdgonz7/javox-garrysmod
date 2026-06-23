---@diagnostic disable: inject-field

hook.Add("InitPostEntity", "JaVOX Compatibility", function()
    timer.Simple(1, function()
        if PVox then
            print("PVOX INSTALLED")

            ---@class DFrame
            local Frame = vgui.Create("DFrame")
            Frame:SetPos(ScrW() * 0.25, ScrH() * 0.25)
            Frame:SetSize(800, 400)
            Frame:DockPadding(32, 32, 32, 32)
            Frame:SetTitle("Incompatibility Found")
            Frame:SetVisible(true)
            Frame:SetDraggable(true)
            Frame:ShowCloseButton(true)
            Frame:MakePopup()

            function Frame:Paint(w, h)
                draw.RoundedBox(8, 0, 0, w, h, Color(12, 17, 29, 185))
            end

            local Content = vgui.Create("DPanel", Frame)
            Content:Dock(FILL)

            function Content:Paint(w, h)
                draw.RoundedBox(4, 0, 0, w, h, Color(12, 17, 29, 255))
            end

            local HeaderZone = vgui.Create("DPanel", Content)
            HeaderZone:Dock(TOP)
            HeaderZone:SetHeight(200)
            HeaderZone:DockMargin(0, 0, 0, 12)
            function HeaderZone:Paint(w, h) end

            local IncLabel = vgui.Create("DLabel", HeaderZone)
            IncLabel:SetFont("Trebuchet24")
            IncLabel:SetText("You have PVox, which is incompatible with JaVox.")
            IncLabel:SizeToContents()
            IncLabel:SetContentAlignment(5)
            IncLabel:Dock(FILL)
            IncLabel:SetHeight(120)
            IncLabel:DockMargin(0, 0, 0, 4)

            local Options = vgui.Create("DPanel", Content)
            Options:Dock(FILL)
            function Options:Paint() end

            local RecLabel = vgui.Create("DLabel", Options)
            RecLabel:Dock(TOP)
            RecLabel:SetText(
                "Recommended action: Disable/Uninstall PVox and only use JaVox.")
            RecLabel:SizeToContents()
            RecLabel:SetContentAlignment(5)
            RecLabel:DockMargin(0, 0, 0, 8)

            local Button = vgui.Create("DButton", Options)
            Button:Dock(TOP)
            Button:DockMargin(64, 0, 64, 0)
            Button:SetFont("Trebuchet24")
            Button:SetText("Open PVox Page")
            Button:SetTextColor(Color(214, 211, 209))
            Button.DoClick = function()
                Frame:Close()
                gui.OpenURL("https://steamcommunity.com/sharedfiles/filedetails/?id=3301865764")
            end

            function Button:Paint(w, h)
                draw.RoundedBox(4, 0, 0, w, h, Color(63, 63, 70))
            end
        end
    end)
end)
