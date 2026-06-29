--- @type table<KEY, string>
local PlayerBindData = {}

--- @type table<string, KEY>
local BindActionData = {}

--- note: internal only
local Debounce = 1
local LastTimePressed = 0
local EnableBindings = CreateConVar("javox_enable_binds", "0", { FCVAR_ARCHIVE })

--- @class KeyBinding
--- @field action string

--- When given modPart as weaponry.reload (except for it's a real object, or JSON converted), turn it into `weaponry.reload`.
---
--- ["a"] = {
---     ["b"] = {},
---     ["c"] = {},
--- }
---
--- Dotify returns a table:
---
--- {"a.b", "a.c"}
--- @param modPart table<any>
function Dotify(modPart, currentPath)
    local returnTable = {}
    currentPath = currentPath or ""

    if type(modPart) ~= "table" then return returnTable end

    if modPart.audioFiles ~= nil or modPart.priority ~= nil then
        if currentPath ~= "" then
            table.insert(returnTable, currentPath)
        end
        return returnTable
    end

    -- is stuff
    for name, pload in pairs(modPart) do
        if type(pload) == "table" then
            local newPath = (currentPath == "") and name or (currentPath .. "." .. name)

            local subResults = Dotify(pload, newPath)
            for i = 1, #subResults do
                table.insert(returnTable, subResults[i])
            end
        end
    end

    return returnTable
end

--- This function looks through every single action and builds a frequency table based on which actions are most used.
--- The keys are all the actions that are made by every module
--- The values are all the frequencies.
--- @return table<string, number>
function ConsolidateModulesIntoCommonActions()
    local accumTable = {}

    for _, mod in pairs(JaVox.vox) do
        local dotified = Dotify(mod.actions)
        for i = 1, #dotified do
            local cur = dotified[i]
            accumTable[cur] = (accumTable[cur] or 0) + 1
        end
    end

    return accumTable
end

concommand.Add("javox_open_bind_menu", function(ply, cmd, args, argStr)
    -- Main Menu Frame
    local BindMenu = vgui.Create("DFrame")
    BindMenu:SetSize(650, 400)
    BindMenu:Center()
    BindMenu:SetTitle("JaVox Keybindings")
    BindMenu:MakePopup()

    -- Smooth modern background override
    function BindMenu:Paint(w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(30, 30, 35, 240))                              -- Dark sleek slate
        draw.RoundedBoxEx(8, 0, 0, w, 24, Color(45, 45, 50, 255), true, true, false, false) -- Header
    end

    -- List View
    local ListView = vgui.Create("DListView", BindMenu)
    ListView:Dock(FILL)
    ListView:DockMargin(12, 12, 12, 12)
    ListView:SetMultiSelect(false)

    ListView:AddColumn("Action")
    ListView:AddColumn("Key")
    ListView:AddColumn("Uses")
    ListView:AddColumn("Compatible?")

    local freq = ConsolidateModulesIntoCommonActions()

    local Reload = function()
        ListView:Clear()
        for actionName, amountOfUses in pairs(freq) do
            local supportsCurrent = "No"
            local current = LocalPlayer():GetNWString(JAVOX_PRESET, "none")

            if JaVox.Crud:getActionFromModule(current, actionName, false) then
                supportsCurrent = "Yes"
            end

            ListView:AddLine(
                actionName,
                BindActionData[actionName] and input.GetKeyName(BindActionData[actionName]) or "None",
                amountOfUses,
                supportsCurrent
            )
        end
    end

    Reload()

    local HelpText = vgui.Create("DLabel", BindMenu)
    HelpText:Dock(TOP)
    HelpText:DockMargin(8, 8, 8, 8)
    HelpText:SetWrap(true)
    HelpText:SetTall(50)
    HelpText:SetText(
        "This is the monolithic keybind selector for JaVox. Double click any row to open a keybind selector. Choose a keybind, it will close, and then you can close this window.")

    -- Double click handler
    function ListView:DoDoubleClick(lineID, line)
        local actionName = line:GetColumnText(1)

        -- Binding Popup Frame
        local KeyBind = vgui.Create("DFrame")
        KeyBind:SetSize(280, 160)
        KeyBind:Center()
        KeyBind:SetTitle("Bind: " .. actionName)
        KeyBind:MakePopup()

        function KeyBind:Paint(w, h)
            draw.RoundedBox(8, 0, 0, w, h, Color(35, 35, 40, 255))
            draw.RoundedBoxEx(8, 0, 0, w, 24, Color(50, 50, 55, 255), true, true, false, false)
        end

        -- Binder UI element
        local KeyBinding = vgui.Create("DBinder", KeyBind)
        KeyBinding:Dock(FILL)
        KeyBinding:DockMargin(8, 8, 8, 8)

        -- Clear Button
        local ClearButton = vgui.Create("DButton", KeyBind)
        ClearButton:Dock(BOTTOM)
        ClearButton:DockMargin(8, 0, 8, 8)
        ClearButton:SetTall(35)
        ClearButton:SetText("Clear Binding")

        function ClearButton:DoClick()
            BindActionData[actionName] = nil
            for key, action in pairs(PlayerBindData) do
                if action == actionName then
                    PlayerBindData[key] = nil
                    KeyBinding:SetValue(KEY_NONE)
                end
            end
            LocalPlayer():SetPData("JaVoxBindData", util.TableToJSON(PlayerBindData))
            LocalPlayer():SetPData("JaVoxBindActionData", util.TableToJSON(BindActionData))
            Reload()
            KeyBind:Close()
        end

        if BindActionData[actionName] then
            KeyBinding:SetValue(BindActionData[actionName])
        end

        function KeyBinding:OnChange(num)
            if BindActionData[actionName] then
                PlayerBindData[num] = nil
            end

            BindActionData[actionName] = num
            PlayerBindData[num] = actionName
            LastTimePressed = CurTime()

            LocalPlayer():SetPData("JaVoxBindData", util.TableToJSON(PlayerBindData))
            LocalPlayer():SetPData("JaVoxBindActionData", util.TableToJSON(BindActionData))

            Reload()
            KeyBind:Close() -- Auto-close makes it feel snappy
        end
    end
end)

hook.Add("Think", "JaVoxBinds", function()
    for button, action in pairs(PlayerBindData) do
        if isnumber(button) then
            if input.IsButtonDown(button) and CurTime() - LastTimePressed > Debounce then
                net.Start("JaVox_EmitAction")
                net.WriteString(PlayerBindData[button])
                net.SendToServer()

                LastTimePressed = CurTime()
            end
        end
    end
end)

hook.Add("InitPostEntity", "JaVoxBindLoad", function()
    if IsValid(LocalPlayer()) then
        ---@diagnostic disable-next-line: cast-local-type
        PlayerBindData = util.JSONToTable(LocalPlayer():GetPData("JaVoxBindData", "{}"))
        ---@diagnostic disable-next-line: cast-local-type
        BindActionData = util.JSONToTable(LocalPlayer():GetPData("JaVoxBindActionData", "{}"))
    end
end)
