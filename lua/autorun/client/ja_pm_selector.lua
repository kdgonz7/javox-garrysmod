---@diagnostic disable: inject-field, undefined-field
--- JaVox Playermodel Interface
--- Allows associating different models with different player actions.
--- player.Getallmodels or something to get a list of all models, associated with playermodels, you can select one and select it's association.
--- @type nil|DFrame
local PMSelector = nil
concommand.Add("ja_pm_selector", function(ply, cmd, args)
    if ! JaVox then
        Derma_Message("JaVox is not loaded!", "JaVox error", "OK")
        return
    end

    local myPlayer = LocalPlayer()

    if IsValid(PMSelector) then
        ---@diagnostic disable-next-line: need-check-nil
        PMSelector:MakePopup()
    else
        PMSelector = vgui.Create("DFrame")
        PMSelector:SetSize(ScrW() * 0.65, ScrH() * 0.30)
        PMSelector:SetTitle("JaVox Playermodel Selector")
        PMSelector:Center()
        PMSelector:MakePopup()

        local panelFill = vgui.Create("DPanel", PMSelector)
        panelFill:Dock(FILL)
        panelFill.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(50, 50, 50))
        end

        local helpText = vgui.Create("DLabel", panelFill)
        helpText:Dock(TOP)
        helpText:DockMargin(10, 10, 10, 10)
        helpText:SetText(
            "Select a model to view its details and modify its association. Once you click on a model, you will be given a popup to modify it's association.")
        helpText:SetWrap(true)

        print(panelFill:GetWide()) -- cuz for some fuckass reason this isn't working \
        local panelLeft = vgui.Create("DPanel", panelFill)
        panelLeft:Dock(LEFT)
        panelLeft:SetWide(PMSelector:GetWide() / 2)
        panelLeft:DockMargin(10, 10, 10, 10)

        local panelRight = vgui.Create("DPanel", panelFill)
        panelRight:Dock(FILL)
        panelRight:DockMargin(10, 10, 10, 10)

        local allPlayermodels = player_manager.AllValidModels()
        local icon = vgui.Create("DModelPanel", panelLeft)
        icon:Dock(FILL)
        icon:SetModel("models/player/alyx.mdl")
        icon:SetFOV(120)

        function icon:LayoutEntity(Entity) return end

        function icon.Entity:GetPlayerColor() return Vector(1, 0, 0) end

        local listview = vgui.Create("DListView", panelRight)
        listview:Dock(FILL)
        listview:AddColumn("Model")
        listview:AddColumn("Associated VOX Pack")
        listview:SetMultiSelect(false)
        listview.OnRowSelected = function(self, index, line)
            local model = line:GetColumnText(1)
            icon:SetModel(model)
        end
        -- double clicking row allows modification.
        -- create popup and allow the user to modify the association.
        listview.DoDoubleClick = function(self, index, line)
            local popUp = vgui.Create("DFrame")
            popUp:SetSize(ScrW() * 0.4, ScrH() * 0.2)
            popUp:SetTitle("Modify Association")
            popUp:Center()
            popUp:MakePopup()

            local model = line:GetColumnText(1)
            local currentPack = line:GetColumnText(2)

            local packDropdown = vgui.Create("DComboBox", popUp)
            packDropdown:Dock(TOP)
            packDropdown:SetText(currentPack)
            for id, pack in pairs(JaVox.vox) do
                packDropdown:AddChoice(pack.displayName, id)
            end

            local saveButton = vgui.Create("DButton", popUp)
            saveButton:Dock(BOTTOM)
            saveButton:SetText("Save")
            saveButton.DoClick = function()
                local value = packDropdown:GetValue()

                net.Start("JaVox_SetPlayermodelBind")
                net.WriteString(model)
                net.WriteString(value)
                net.SendToServer()

                -- optimistic rendering + maybe saving?
                JaVox.Crud:setPlayermodelBindFor(myPlayer, model, value)

                popUp:Remove()
                listview:Clear()

                -- reload the listviewer
                for _, model in pairs(allPlayermodels) do
                    local modelsPack = JaVox.Crud:getPlayermodelBindFor(myPlayer, model) or "None"
                    listview:AddLine(model, modelsPack)
                end
            end
        end

        for _, model in pairs(allPlayermodels) do
            local modelsPack = JaVox.Crud:getPlayermodelBindFor(myPlayer, model) or "None"
            listview:AddLine(model, modelsPack)
        end
    end
end)
