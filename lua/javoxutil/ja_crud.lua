-- javox common CRUD wrappers. just looks better.

--- @class JaVoxCrud The CRUD (Create, Read, Update, Delete) functionality for JaVox
JaVox.Crud = JaVox.Crud or {}

--- Use `JaVox.Director:registerCallout`. This is an internal function.
---@param moduleName string
---@param calloutName string
---@param calloutAction string
function JaVox.Crud:registerCallout(moduleName, calloutName, calloutAction)
    JaVox.vox[moduleName].callouts[calloutName] = calloutAction
end

---Tries to get an action module (of actions bound to sounds)
---@param modName string?
function JaVox.Crud:getActionModule(modName)
    if ! modName then return JaVox:errorWithMessage("getActionModule requires a module name.") end
    return JaVox.vox[modName];
end

---Tries to set an action module's name and actions.
---@param name string?
---@param actions PlayerVoxModule?
function JaVox.Crud:setActionModule(name, actions)
    if ! name then return JaVox:errorWithMessage("setActionModule requires a module name.") end
    JaVox.vox[name] = actions
end

---Returns `action` from the given `moduleName`. Can potentially return nil so result should be verified.
---@param moduleName string?
---@param action string
---@return PlayerVoxAction|JaVoxError?
function JaVox.Crud:getActionFromModule(moduleName, action, useFallbacks)
    if ! moduleName then return JaVox:errorWithMessage(string.format("potential access missing module param.")) end
    if ! action then
        JaVox:errorWithMessage(string.format("potential access for '%s' missing action param.",
            moduleName))
    end


    local moduleObj = JaVox.vox[moduleName]
    if ! moduleObj then return JaVox:errorWithMessage(string.format("Module '%s' not found.", moduleName)) end

    local redirectedAction = self:resolvePatternMatch(moduleObj, action)
    if redirectedAction then
        action = redirectedAction
    end

    ---@diagnostic disable-next-line: param-type-mismatch
    return self:resolveActions(moduleObj, action, useFallbacks)
end

---comment
---@param moduleObj PlayerVoxModule
---@param action string
---@return PlayerVoxAction|JaVoxError?
function JaVox.Crud:resolveActions(moduleObj, action, fallbackToAbove)
    if fallbackToAbove == nil then fallbackToAbove = true end
    if ! action then return print("action null in resolve") end

    --- @cast action string
    local actParts = string.Split(action, ".")

    ---comment
    ---@param x any
    ---@return boolean
    local function isModule(x)
        -- note: why tf was this not audioFiles to begin with?
        return x and x.audioFiles ~= nil
    end

    local i = 1
    local potentialModule = moduleObj.actions[actParts[i]]
    local fallbackModule = nil

    -- ["self"] ["damage"] ["fall"]
    -- 1        2          3
    -- i starts at 1. if i isn't a module, we fail to resolve it and return.
    -- we increment i.
    -- potentialModule = potentialModule[actParts[i]]
    -- if the potential module is a module, we break out of the loop.
    -- if not, we move to 2
    while i <= #actParts do
        if not potentialModule then                    -- no module in existence
            if fallbackToAbove and fallbackModule then -- if fallback is enabled and we have a fallback module
                return fallbackModule                  -- if we have a fallback module, we can use it
            end

            -- otherwise we fail to resolve the action
            return print("failed to resolve " .. action)
        end

        i =
            i +
            1 -- increment to next part (assume we have a valid action with potentialModule = moduleObj.actions[actParts[i]])

        if isModule(potentialModule) and i > #actParts then
            -- if we have a valid module, and i is already out of bounds, we are done.
            -- we have a module! yay.
            break
        end

        fallbackModule = potentialModule
        -- we move to the next part of the action
        potentialModule = potentialModule[actParts[i]]

        -- if we have a module
        if isModule(potentialModule) then
            -- ok so now we have ["damage"], but not yet ["fall"].
            -- so what do we do? check the next part of the action and see if it's a module.
            if i + 1 > #actParts then
                -- there are no more parts to resolve. we are done.
                break
            end

            -- check the next part of the action
            local potentialChildModule = potentialModule[actParts[i + 1]]

            -- if that's a module, we can jump into it
            if isModule(potentialChildModule) then
                fallbackModule = potentialModule       -- set fallback module to the current module
                potentialModule = potentialChildModule -- change to new potential
                i = i + 1                              -- move to the next part of the action
                continue
            end

            break
        end
    end

    --- @cast potentialModule PlayerVoxAction
    return potentialModule
end

---Returns all callouts from module `name`
---@param name any
---@return string
function JaVox.Crud:resolveCallout(name, calloutName)
    return JaVox.vox[name].callouts[calloutName]
end

--- [[[ CLIENTSIDE ONLY ]]]

---Returns the VOX pack bound to a playermodel.
---@param model string
---@return string|nil
function JaVox.Crud:getPlayermodelBindFor(model)
    if SERVER then return end
    if not model then return end
    if not JaVox.binds then
        JaVox.binds = {}
    end
    return JaVox.binds[string.lower(model)]
end

---Sets the VOX pack bound to a playermodel. Note: this should only be called clientside
---@param model string
---@param pack string
---@return nil
function JaVox.Crud:setPlayermodelBindFor(model, pack)
    if SERVER then return end

    JaVox.binds[model] = pack
end

---Saves the playermodel binds for the given player.
---@param ply Player
function JaVox.Crud:savePlayermodelBinds(ply)
    if SERVER then return end
    if not ply then return end


    ply:SetPData("javox_playermodel_binds", util.TableToJSON(JaVox.binds))
end

---Loads the playermodel binds for the given player.
---@param ply Player
function JaVox.Crud:loadPlayermodelBinds(ply)
    if SERVER then return end
    if not ply then return end

    local binds = ply:GetPData("javox_playermodel_binds")
    if not binds then return end

    JaVox.binds = util.JSONToTable(binds)
end

--- Loops through registered patterns to find a regex match for the action string
---@param moduleObj table
---@param action string
---@return string|nil The redirected action name, or nil if no match
function JaVox.Crud:resolvePatternMatch(moduleObj, action)
    -- note: this one pattern essentially creates a scripting interface for actions.
    -- note: you can intercept just about any action with this system.

    if not moduleObj.patterns then return nil end --- no patterns
    if not action then return nil end

    for pattern, targetAction in pairs(moduleObj.patterns) do -- for pattern in the patterns
        if string.match(action, pattern) then                 -- if action matches
            return targetAction                               -- return
        end
    end

    return nil
end
