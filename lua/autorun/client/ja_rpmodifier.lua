--      JaVox RP Modifier
--   (Recursive Parameter)

local COLOR_BG = Color(45, 45, 48, 255)
local COLOR_PANEL = Color(30, 30, 30, 255)
local COLOR_HEADER = Color(63, 63, 70, 255)
local COLOR_TEXT = Color(240, 240, 240, 255)
local COLOR_ACCENT = Color(0, 122, 204, 255)

concommand.Add("javox_rp_modifier", function(ply, cmd, args, argStr)
    if not JaVox or not JaVox.vox then
        print("[JaVox] Core system not found!")
        return
    end

    local RecursiveParameterMod = vgui.Create("DFrame")
    RecursiveParameterMod:SetSize(900, 600)
    RecursiveParameterMod:SetTitle("")
    RecursiveParameterMod:Center()
    RecursiveParameterMod:MakePopup()
    RecursiveParameterMod:ShowCloseButton(false)

    RecursiveParameterMod.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, COLOR_BG)
        draw.RoundedBoxEx(6, 0, 0, w, 30, COLOR_PANEL, true, true, false, false)
        draw.SimpleText("JaVox RP Modifier", "DermaDefaultBold", 10, 8, COLOR_TEXT, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end

    local CloseBtn = vgui.Create("DButton", RecursiveParameterMod)
    CloseBtn:SetPos(RecursiveParameterMod:GetWide() - 40, 0)
    CloseBtn:SetSize(40, 30)
    CloseBtn:SetText("✕")
    CloseBtn:SetTextColor(Color(200, 200, 200))
    CloseBtn.Paint = function(self, w, h)
        if self:IsHovered() then
            draw.RoundedBoxEx(6, 0, 0, w, h, Color(232, 17, 35), false, true, false, false)
        end
    end
    CloseBtn.DoClick = function() RecursiveParameterMod:Close() end

    local Viewport = vgui.Create("DPanel", RecursiveParameterMod)
    Viewport:Dock(FILL)
    Viewport:DockMargin(8, 8, 8, 8)
    Viewport.Paint = function(self, w, h) end -- Transparent
    local ModuleListView, ModuleEditorView    -- Forward declarations

    local function SwapView(toViewFunc, ...)
        Viewport:Clear()
        toViewFunc(...)
    end

    function ModuleEditorView(mod)
        local TopNav = vgui.Create("DPanel", Viewport)
        TopNav:Dock(TOP)
        TopNav:SetHeight(35)
        TopNav:DockMargin(0, 0, 0, 8)
        TopNav.Paint = function(self, w, h) end

        local BackBtn = vgui.Create("DButton", TopNav)
        BackBtn:Dock(LEFT)
        BackBtn:SetWidth(120)
        BackBtn:SetText("← Back to Modules")
        BackBtn:SetTextColor(COLOR_TEXT)
        BackBtn.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, self:IsHovered() and COLOR_HEADER or COLOR_PANEL)
        end
        BackBtn.DoClick = function()
            SwapView(ModuleListView)
        end

        local ModuleTitle = vgui.Create("DLabel", TopNav)
        ModuleTitle:Dock(FILL)
        ModuleTitle:DockMargin(15, 0, 0, 0)
        ModuleTitle:SetFont("DermaLarge")
        ModuleTitle:SetText("Editing Module: " .. (mod.displayName or mod.name))
        ModuleTitle:SetTextColor(COLOR_TEXT)

        local ModuleActionsTree = vgui.Create("DTree", Viewport)
        ModuleActionsTree:Dock(LEFT)
        ModuleActionsTree:DockMargin(0, 0, 8, 0)
        ModuleActionsTree:SetWidth(280)
        ModuleActionsTree.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, COLOR_PANEL)
        end

        local ModuleActionsConfig = vgui.Create("DScrollPanel", Viewport)
        ModuleActionsConfig:Dock(FILL)
        ModuleActionsConfig.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, COLOR_PANEL)
        end

        local sbar = ModuleActionsConfig:GetVBar()
        sbar:SetWide(8)
        sbar.Paint = function() end
        sbar.btnUp.Paint = function() end
        sbar.btnDown.Paint = function() end
        sbar.btnGrip.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, COLOR_HEADER)
        end

        local function IsArray(t)
            if type(t) ~= "table" then return false end
            local i = 0
            for _ in pairs(t) do
                i = i + 1
                if t[i] == nil then return false end
            end
            return true
        end

        local function RenderConfigItems(Object, prefix, pad)
            for key, value in pairs(Object) do
                local displayKey = prefix ~= "" and (prefix .. "." .. key) or key

                if type(value) == "number" then
                    if string.lower(key) == 'priority' then
                        return
                    end

                    local pnl = vgui.Create("DPanel", ModuleActionsConfig)
                    pnl:Dock(TOP)
                    pnl:DockMargin(pad, 4, 8, 4)
                    pnl:SetHeight(30)
                    pnl.Paint = function() end

                    local slider = vgui.Create("DNumSlider", pnl)
                    slider:Dock(FILL)
                    slider:SetMin(0)
                    if string.lower(key) == "pitch" then
                        slider:SetMax(255)
                    elseif string.lower(key) == "volume" then
                        slider:SetMax(2)
                    else
                        slider:SetMax(100)
                    end
                    slider:SetText(displayKey)
                    slider:SetValue(value)
                    slider:SetDecimals(2)
                    slider.Label:SetTextColor(COLOR_TEXT)
                    slider.OnValueChanged = function(self, val)
                        Object[key] = val
                    end
                elseif type(value) == "string" then
                    local pnl = vgui.Create("DPanel", ModuleActionsConfig)
                    pnl:Dock(TOP)
                    pnl:DockMargin(pad, 4, 8, 4)
                    pnl:SetHeight(30)
                    pnl.Paint = function() end

                    local label = vgui.Create("DLabel", pnl)
                    label:Dock(LEFT)
                    label:SetText(displayKey)
                    label:SetTextColor(COLOR_TEXT)
                    label:SetWidth(150)

                    local textentry = vgui.Create("DTextEntry", pnl)
                    textentry:Dock(FILL)
                    textentry:SetText(value)
                    textentry:SetTextColor(COLOR_TEXT)
                    textentry.Paint = function(self, w, h)
                        draw.RoundedBox(4, 0, 0, w, h, COLOR_BG)
                        self:DrawTextEntryText(COLOR_TEXT, COLOR_ACCENT, COLOR_TEXT)
                    end
                    textentry.OnTextChanged = function(self)
                        Object[key] = self:GetValue()
                    end
                elseif type(value) == "boolean" then
                    local checkbox = vgui.Create("DCheckBoxLabel", ModuleActionsConfig)
                    checkbox:Dock(TOP)
                    checkbox:DockMargin(pad, 6, 8, 6)
                    checkbox:SetChecked(value)
                    checkbox:SetText(displayKey)
                    checkbox:SetTextColor(COLOR_TEXT)

                    checkbox.OnChange = function(self, val)
                        Object[key] = val
                    end
                elseif type(value) == "table" then
                    if IsArray(value) then
                        local sectionLabel = vgui.Create("DLabel", ModuleActionsConfig)
                        sectionLabel:Dock(TOP)
                        sectionLabel:DockMargin(pad, 10, 8, 4)
                        sectionLabel:SetText("↳ Files/Array: " .. displayKey)
                        sectionLabel:SetFont("DermaDefaultBold")
                        sectionLabel:SetTextColor(COLOR_ACCENT)

                        for i, fileStr in ipairs(value) do
                            local pnl = vgui.Create("DPanel", ModuleActionsConfig)
                            pnl:Dock(TOP)
                            pnl:DockMargin(pad + 12, 2, 8, 2)
                            pnl:SetHeight(25)
                            pnl.Paint = function() end

                            local fLabel = vgui.Create("DLabel", pnl)
                            fLabel:Dock(LEFT)
                            fLabel:SetText("[" .. i .. "]")
                            fLabel:SetTextColor(COLOR_TEXT)
                            fLabel:SetWidth(30)

                            local fEntry = vgui.Create("DTextEntry", pnl)
                            fEntry:Dock(FILL)
                            fEntry:SetText(tostring(fileStr))
                            fEntry.Paint = function(self, w, h)
                                draw.RoundedBox(4, 0, 0, w, h, COLOR_BG)
                                self:DrawTextEntryText(COLOR_TEXT, COLOR_ACCENT, COLOR_TEXT)
                            end

                            fEntry.OnTextChanged = function(self)
                                value[i] = self:GetValue()
                            end
                        end
                    else
                        local sectionLabel = vgui.Create("DLabel", ModuleActionsConfig)
                        sectionLabel:Dock(TOP)
                        sectionLabel:DockMargin(pad, 10, 8, 4)
                        sectionLabel:SetText("↳ Group: " .. displayKey)
                        sectionLabel:SetFont("DermaDefaultBold")
                        sectionLabel:SetTextColor(Color(180, 180, 180))

                        RenderConfigItems(value, displayKey, pad + 12)
                    end
                end
            end
        end

        local function AddActionNode(Parent, Name, Object)
            local node = Parent:AddNode(Name)

            local hasSubActions = false
            if type(Object) == "table" and not IsArray(Object) then
                for k, v in pairs(Object) do
                    if type(v) == "table" and not IsArray(v) then
                        hasSubActions = true
                        break
                    end
                end
            end

            if hasSubActions then
                node:SetIcon("icon16/folder.png")
            else
                node:SetIcon("icon16/script.png")
            end

            node.DoClick = function()
                ModuleActionsConfig:Clear()

                local header = vgui.Create("DLabel", ModuleActionsConfig)
                header:Dock(TOP)
                header:DockMargin(12, 12, 12, 16)
                header:SetFont("DermaLarge")
                header:SetText(Name)
                header:SetTextColor(COLOR_TEXT)
                header:SizeToContents()

                if type(Object) == "table" then
                    RenderConfigItems(Object, "", 12)
                end

                local saveBtn = vgui.Create("DButton", ModuleActionsConfig)
                saveBtn:Dock(TOP)
                saveBtn:DockMargin(12, 30, 12, 20)
                saveBtn:SetHeight(35)
                saveBtn:SetText("Save & Sync Full Module Settings")
                saveBtn:SetTextColor(COLOR_TEXT)
                saveBtn:SetFont("DermaDefaultBold")
                saveBtn.Paint = function(self, w, h)
                    draw.RoundedBox(4, 0, 0, w, h, self:IsHovered() and Color(0, 150, 255) or COLOR_ACCENT)
                end

                saveBtn.DoClick = function()
                    net.Start("JaVox_SyncRPModifiers")
                    net.WriteString(mod.name or "")
                    net.WriteTable(mod)
                    net.SendToServer()

                    surface.PlaySound("buttons/button14.wav")
                end
            end

            if not hasSubActions then return end

            for key, value in pairs(Object) do
                if type(value) == "table" and not IsArray(value) then
                    AddActionNode(node, key, value)
                end
            end
        end

        if mod.actions then
            for actionName, action in pairs(mod.actions) do
                AddActionNode(ModuleActionsTree, actionName, action)
            end
        end
    end

    function ModuleListView()
        local ListContainer = vgui.Create("DPanel", Viewport)
        ListContainer:Dock(FILL)
        ListContainer.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, COLOR_PANEL)
        end

        local ModuleList = vgui.Create("DListView", ListContainer)
        ModuleList:Dock(FILL)
        ModuleList:DockMargin(4, 4, 4, 4)
        ModuleList:SetMultiSelect(false)
        ModuleList:AddColumn("Module Key")
        ModuleList:AddColumn("Display Name")
        ModuleList:AddColumn("Description")

        -- Dark theme overrides for DListView
        ModuleList.Paint = function(self, w, h) end
        for _, col in pairs(ModuleList.Columns) do
            col.Header:SetTextColor(COLOR_TEXT)
            col.Header.Paint = function(self, w, h)
                draw.RoundedBox(0, 0, 0, w, h, COLOR_HEADER)
            end
        end

        function ModuleList:DoDoubleClick(lineID, line)
            if not line then return end
            local name = line:GetValue(1)
            local mod = JaVox.vox[name]
            if not mod then return end

            mod.name = name

            SwapView(function()
                ModuleEditorView(mod)
            end)
        end

        -- Populate the list
        for name, mod in pairs(JaVox.vox) do
            local line = ModuleList:AddLine(name, mod.displayName or name, mod.description or "")
            -- Make line text readable in dark mode
            for _, col in pairs(line.Columns) do
                col:SetTextColor(COLOR_TEXT)
            end
        end
    end

    -- Initial load
    ModuleListView()
end)
