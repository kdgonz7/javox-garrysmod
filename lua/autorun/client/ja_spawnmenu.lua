-- 1. Create a brand new main tab next to Utilities
hook.Add("AddToolMenuTabs", "JaVoxMainTab", function()
    -- spawnmenu.AddToolMenuTab( internalName, displayName, icon )
    spawnmenu.AddToolTab("JaVox_Main", "JaVox", "icon16/sound.png")
end)

-- 2. Create the subcategories inside our new main tab
hook.Add("AddToolMenuCategories", "JaVoxCustomCategories", function()
    -- spawnmenu.AddToolCategory( mainTabInternalName, internalSubName, displayName )
    spawnmenu.AddToolCategory("JaVox_Main", "JaVox_Interfaces", "Interfaces")
    spawnmenu.AddToolCategory("JaVox_Main", "JaVox_Modules", "Modules")
end)

-- 3. Populate everything
hook.Add("PopulateToolMenu", "CustomMenuSettings", function()
    spawnmenu.AddToolMenuOption("JaVox_Main", "JaVox_Interfaces", "JaVox_ModuleManager", "Module Manager", "", "",
        function(panel)
            panel:Clear()
            panel:Help("Manage the core JaVox modules and systems.")

            local button = vgui.Create("DButton", panel)
            button:SetText("Open JaVox Manager")
            button:Dock(TOP)
            button:DockMargin(0, 10, 0, 10)
            button.DoClick = function()
                RunConsoleCommand("javox_vox_mgr")
            end
        end)

    spawnmenu.AddToolMenuOption("JaVox_Main", "JaVox_Interfaces", "JaVox_PMBinds", "Playermodel Binds", "", "",
        function(panel)
            panel:Clear()
            panel:Help("Configure automatic voice lines and settings for specific playermodels.")

            panel:CheckBox("Enable JaVox Playermodel Binds", "javox_should_set_model")

            local button = vgui.Create("DButton", panel)
            button:SetText("Open JaVox PM Selector")
            button:Dock(TOP)
            button:DockMargin(0, 10, 0, 10)
            button.DoClick = function()
                RunConsoleCommand("javox_pm_selector")
            end
        end)


    -- MODULE CONFIG CATEGORY

    -- Entity Kills
    spawnmenu.AddToolMenuOption("JaVox_Main", "JaVox_Modules", "JaVox_Mod_EntityKills", "Entity Kills", "", "",
        function(panel)
            panel:Clear()
            panel:Help("Settings for killing NPCs or other entities.")
            panel:CheckBox("Enable Entity Kill Lines", "javox_enable_entity_kills")
        end)

    -- Damage Module
    spawnmenu.AddToolMenuOption("JaVox_Main", "JaVox_Modules", "JaVox_Mod_Damage", "Damage", "", "",
        function(panel)
            panel:Clear()
            panel:Help("Settings for taking or dealing damage.")
            panel:CheckBox("Enable Damage Module", "javox_damage_module_enabled")
        end)

    -- ARC9 Jamming
    spawnmenu.AddToolMenuOption("JaVox_Main", "JaVox_Modules", "JaVox_Mod_ARC9Jam", "ARC9 Weapon Jam", "", "",
        function(panel)
            panel:Clear()
            panel:Help("Settings for ARC9 weapon malfunctions.")
            panel:CheckBox("Enable ARC9 Jam Lines", "javox_arc9_jam_enabled")
        end)

    -- Spotting
    spawnmenu.AddToolMenuOption("JaVox_Main", "JaVox_Modules", "JaVox_Mod_Spotting", "Spotting", "", "",
        function(panel)
            panel:Clear()
            panel:Help("Settings for spotting enemies and resetting thresholds.")
            panel:CheckBox("Enable Enemy Spotting", "javox_enable_spotting")
            panel:NumSlider("Reset Threshold", "javox_reset_threshold", 0, 100, 0)
        end)

    -- Fall Damage
    spawnmenu.AddToolMenuOption("JaVox_Main", "JaVox_Modules", "JaVox_Mod_FallDamage", "Fall Damage", "", "",
        function(panel)
            panel:Clear()
            panel:Help("Settings for falling and impact actions.")
            panel:CheckBox("Enable Fall Damage Actions", "javox_fall_damage_action")
        end)

    -- Frag / Grenades
    spawnmenu.AddToolMenuOption("JaVox_Main", "JaVox_Modules", "JaVox_Mod_Frag", "Frag Grenades", "", "",
        function(panel)
            panel:Clear()
            panel:Help("Settings for throwing or dodging explosives.")
            panel:CheckBox("Enable Frag Lines", "javox_frag_enable")
        end)

    -- Nods / Gestures
    spawnmenu.AddToolMenuOption("JaVox_Main", "JaVox_Modules", "JaVox_Mod_Nods", "Nods & Gestures", "", "",
        function(panel)
            panel:Clear()
            panel:Help("Settings for physical head nods and negative responses.")
            panel:CheckBox("Enable Standard Nods", "javox_nod_enabled")
            panel:CheckBox("Enable Negative Nods", "javox_nod_negative_enabled")
        end)

    -- Reloading
    spawnmenu.AddToolMenuOption("JaVox_Main", "JaVox_Modules", "JaVox_Mod_Reload", "Weapon Reloading", "", "",
        function(panel)
            panel:Clear()
            panel:Help("Settings for reloading weapons.")
            panel:CheckBox("Enable Reload Actions", "javox_reload_action_enabled")
        end)

    -- Saving System
    spawnmenu.AddToolMenuOption("JaVox_Main", "JaVox_Modules", "JaVox_Mod_Saving", "Data Saving", "", "",
        function(panel)
            panel:Clear()
            panel:Help("Settings for data persistence and saving.")
            panel:CheckBox("Enable Module Saving", "javox_saving_enabled")
        end)
end)
