-- hook.Add("AddToolMenuCategories", "CustomCategory", function()
--     spawnmenu.AddToolCategory("Utilities", "JaVox", "#Stuff")
-- end)

hook.Add("PopulateToolMenu", "CustomMenuSettings", function()
    spawnmenu.AddToolMenuOption("Utilities", "JaVox", "JaVox Module Manager", "#JaVox Module Manager", "", "",
        function(panel)
            panel:Clear()

            -- button that runs javox_vox_mgr
            local button = vgui.Create("DButton", panel)
            button:SetText("Open JaVox Manager")
            button.DoClick = function()
                RunConsoleCommand("javox_vox_mgr")
            end

            button:Dock(TOP)
            button:DockMargin(10, 10, 10, 10)
        end)
    spawnmenu.AddToolMenuOption("Utilities", "JaVox", "JaVox Playermodel Binds", "#JaVox Playermodel Binds", "", "",
        function(panel)
            panel:Clear()

            panel:CheckBox("Enable JaVox Playermodel Binds", "javox_should_set_model")

            -- button that runs javox_vox_mgr
            local button = vgui.Create("DButton", panel)
            button:SetText("Open JaVox PM Selector")
            button.DoClick = function()
                RunConsoleCommand("javox_pm_selector")
            end

            button:Dock(TOP)
            button:DockMargin(10, 10, 10, 10)
        end)
end)
