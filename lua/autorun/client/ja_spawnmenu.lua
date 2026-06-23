-- hook.Add("AddToolMenuCategories", "CustomCategory", function()
--     spawnmenu.AddToolCategory("Utilities", "JaVox", "#Stuff")
-- end)

hook.Add("PopulateToolMenu", "CustomMenuSettings", function()
    spawnmenu.AddToolMenuOption("Utilities", "JaVox", "JaVox Module Manager", "#JaVox Module Manager", "", "",
        function(panel)
            panel:Clear()

            -- button that runs ja_vox_mgr
            local button = vgui.Create("DButton", panel)
            button:SetText("Open JaVox Manager")
            button.DoClick = function()
                RunConsoleCommand("ja_vox_mgr")
            end

            button:Dock(TOP)
            button:DockMargin(10, 10, 10, 10)
        end)
end)
