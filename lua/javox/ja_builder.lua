local ModBuilder = {}
ModBuilder.__index = ModBuilder

---comment
---@param id string
---@return PlayerVoxModule
function JaVox.CreateModule(id)
    local self = setmetatable({}, ModBuilder)

    --- @cast self PlayerVoxModule
    self.actions = {}
    self.callouts = {}
    self.description = ""
    self.author = ""
    self.displayName = ""

    JaVox.vox[id] = self

    return self
end

---comment
---@param name string
---@return table
function ModBuilder:SetDisplayName(name)
    self.displayName = name
    return self
end

function ModBuilder:SetDescription(description)
    self.description = description
    return self
end

function ModBuilder:SetAuthor(name)
    self.author = name
    return self
end

function ModBuilder:SetAuthors(listOfAuthors)
    self.author = listOfAuthors
    return self
end

function ModBuilder:RegisterCallout(calloutName, internalAction)
    self.callouts[calloutName] = internalAction
    return self
end

function ModBuilder:RegisterAction(actionName, config)
    self.actions[actionName] = {
        audioFiles = config.audioFiles or {},
        priority = config.priority or AudioPriority.PLAY_ONCE_WITHOUT_DEFERRAL,
        delay = config.delay,
        throttle = config.throttle,
        volume = config.volume,
        reach = config.reach,
        pitch = config.pitch,
    }

    return self
end
