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
            if LocalPlayer():IsAdmin() then
                panel:Help("Settings for killing NPCs or other entities.")
                panel:CheckBox("Enable Entity Kill Lines", "javox_enable_entity_kills")
            end
        end)

    -- Damage Module
    spawnmenu.AddToolMenuOption("JaVox_Main", "JaVox_Modules", "JaVox_Mod_Damage", "Damage", "", "",
        function(panel)
            panel:Clear()
            local ply = LocalPlayer()
            if ply:IsAdmin() then
                panel:Help("Settings for taking or dealing damage.")
                panel:CheckBox("Enable Damage Module", "javox_damage_module_enabled")
            end
        end)

    -- ARC9 Jamming
    spawnmenu.AddToolMenuOption("JaVox_Main", "JaVox_Modules", "JaVox_Mod_ARC9Jam", "ARC9 Weapon Jam", "", "",
        function(panel)
            panel:Clear()
            local ply = LocalPlayer()
            if ply:IsAdmin() then
                panel:Help("Settings for ARC9 weapon malfunctions.")
                panel:CheckBox("Enable ARC9 Jam Lines", "javox_arc9_jam_enabled")
            end
        end)

    -- Spotting
    spawnmenu.AddToolMenuOption("JaVox_Main", "JaVox_Modules", "JaVox_Mod_Spotting", "Spotting", "", "",
        function(panel)
            panel:Clear()
            local ply = LocalPlayer()
            if ply:IsAdmin() then
                panel:Help("Settings for spotting enemies and resetting thresholds.")
                panel:CheckBox("Enable Enemy Spotting", "javox_enable_spotting")
                panel:NumSlider("Reset Threshold", "javox_reset_threshold", 0, 100, 0)
                panel:CheckBox("Enable Lost Actions", "javox_enable_lost")
                panel:Help("")
            end
            -- javox_spotted_lost_animation_duration -> number
            -- javox_spotted_lost_enable_tooltip_text -> boolean
            -- javox_spotted_lost_tooltip_text_duration -> number
            -- javox_spotted_lost_wind_sound -> string
            -- javox_spotted_lost_show_text -> boolean
            -- javox_spotted_lost_show_pings -> string
            panel:Help("Settings for when you lose an enemy - the rest of these are yours!")
            panel:NumSlider("Animation Duration", "javox_spotted_lost_animation_duration", 0, 10, 2)
            panel:CheckBox("Enable Tooltip Text", "javox_spotted_lost_enable_tooltip_text")
            panel:NumSlider("Tooltip Text Duration", "javox_spotted_lost_tooltip_text_duration", 0, 10, 2)
            panel:TextEntry("Wind Sound", "javox_spotted_lost_wind_sound")
            panel:CheckBox("Show Text", "javox_spotted_lost_show_text")
            panel:CheckBox("Show Pings", "javox_spotted_lost_show_pings")
        end)

    -- Fall Damage
    spawnmenu.AddToolMenuOption("JaVox_Main", "JaVox_Modules", "JaVox_Mod_FallDamage", "Fall Damage", "", "",
        function(panel)
            panel:Clear()
            local ply = LocalPlayer()
            if ply:IsAdmin() then
                panel:Help("Settings for falling and impact actions.")
                panel:CheckBox("Enable Fall Damage Actions", "javox_fall_damage_action")
            end
        end)

    -- Frag / Grenades
    spawnmenu.AddToolMenuOption("JaVox_Main", "JaVox_Modules", "JaVox_Mod_Frag", "Frag Grenades", "", "",
        function(panel)
            panel:Clear()
            local ply = LocalPlayer()
            if ply:IsAdmin() then
                panel:Help("Settings for throwing or dodging explosives.")
                panel:CheckBox("Enable Frag Lines", "javox_frag_enable")
            end
        end)

    -- Nods / Gestures
    spawnmenu.AddToolMenuOption("JaVox_Main", "JaVox_Modules", "JaVox_Mod_Nods", "Nods & Gestures", "", "",
        function(panel)
            panel:Clear()
            local ply = LocalPlayer()
            if ply:IsAdmin() then
                panel:Help("Settings for physical head nods and negative responses.")
                panel:CheckBox("Enable Standard Nods", "javox_nod_enabled")
                panel:CheckBox("Enable Negative Nods", "javox_nod_negative_enabled")
                panel:NumSlider("Negative Nod Threshold", "javox_nod_negative_threshold", 0, 10, 2)
            end
        end)

    -- Reloading
    spawnmenu.AddToolMenuOption("JaVox_Main", "JaVox_Modules", "JaVox_Mod_Reload", "Weapon Reloading", "", "",
        function(panel)
            panel:Clear()
            local ply = LocalPlayer()
            if ply:IsAdmin() then
                panel:Help("Settings for reloading weapons.")
                panel:CheckBox("Enable Reload Actions", "javox_reload_action_enabled")
                panel:CheckBox("Enable Out of Ammo Actions", "javox_out_of_ammo_action_enabled")
                panel:CheckBox("Enable No Ammo Left Actions", "javox_no_ammo_left_action_enabled")
            end
        end)

    -- Saving System
    spawnmenu.AddToolMenuOption("JaVox_Main", "JaVox_Modules", "JaVox_Mod_Saving", "Data Saving", "", "",
        function(panel)
            panel:Clear()
            local ply = LocalPlayer()
            if ply:IsAdmin() then
                panel:Help("Settings for data persistence and saving.")
                panel:CheckBox("Enable Module Saving", "javox_saving_enabled")
            end
        end)

    spawnmenu.AddToolMenuOption("JaVox_Main", "JaVox_Modules", "JaVox_Mod_Settings", "Settings", "", "",
        function(panel)
            panel:Clear()
            local ply = LocalPlayer()
            if ply:IsAdmin() then
                panel:Help("Global settings for JaVox.")
                panel:NumSlider("Global Throttle Modifier", "javox_global_throttle_modifier", 0, 2, 2)
                panel:NumSlider("Global Volume Modifier", "javox_global_volume_modifier", 0, 2, 2)
                panel:NumSlider("Global Pitch Modifier", "javox_global_pitch_modifier", 0, 2, 2)
                panel:NumSlider("Global Reach Modifier", "javox_global_reach_modifier", 0, 2, 2)
                panel:NumSlider("Global Delay Modifier", "javox_global_delay_modifier", 0, 2, 2)
                panel:NumSlider("Global Chance Modifier", "javox_global_chance_modifier", 0, 1, 1.0)
            end
        end)
end)
