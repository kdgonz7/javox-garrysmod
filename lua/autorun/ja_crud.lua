-- javox common CRUD wrappers. just looks better.

--- @class JaVoxCrud The CRUD (Create, Read, Update, Delete) functionality for JaVox
JaVox.Crud = JaVox.Crud or {}

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
---@param action string?
---@return PlayerVoxAction|JaVoxError?
function JaVox.Crud:getActionFromModule(moduleName, action)
    if ! moduleName then return JaVox:errorWithMessage(string.format("potential access missing module param.")) end
    if ! action then
        JaVox:errorWithMessage(string.format("potential access for '%s' missing action param.",
            moduleName))
    end


    local moduleObj = JaVox.vox[moduleName]
    if ! moduleObj then return JaVox:errorWithMessage(string.format("Module '%s' not found.", moduleName)) end


    ---@diagnostic disable-next-line: param-type-mismatch
    return self:resolve(moduleObj, action)
end

---comment
---@param moduleObj PlayerVoxModule
---@param action string
---@return PlayerVoxAction|JaVoxError?
function JaVox.Crud:resolve(moduleObj, action)
    --- @cast action string
    local actParts = string.Split(action, ".")

    ---comment
    ---@param x any
    ---@return boolean
    local function isModule(x)
        return x and x.priority ~= nil
    end

    -- if it's like
    -- 'reload'
    if isModule(moduleObj.actions[actParts[1]]) then
        ---@diagnostic disable-next-line: return-type-mismatch
        return moduleObj.actions[actParts[1]]
    end

    if #actParts == 1 then
        return JaVox:errorWithMessage("No action of " .. actParts[1] .. " found.")
    end

    -- we either have:
    -- acts.reload
    -- or something like
    -- ''

    local i = 1
    local potentialModule = moduleObj.actions[actParts[i]]

    while i <= #actParts do
        if not potentialModule then return print("failed to resolve " .. action) end
        i = i + 1
        potentialModule = potentialModule[actParts[i]]
        if isModule(potentialModule) then break end
    end

    --- @cast potentialModule PlayerVoxAction
    return potentialModule
end
