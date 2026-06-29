-- ultimately this will be one of the most important javox modules.
-- simply because it's so useful.
-- the director defines the state machine for players to actually use voxes.
-- when you call a vox, you call it through the JaVox helpers... which call the director.
-- the director has specific rules in place to allow players


---@class JaVoxDirectorSensibleDefaults
---@field priority AudioPriority
---@field delay DelaySettings
---@field throttle ThrottleSettings

--- @class JaVoxDirector
--- @field sensibleDefaults JaVoxDirectorSensibleDefaults
JaVox.Director = JaVox.Director or {
    sensibleDefaults = {
        priority = AudioPriority.PLAY_ONCE_WITHOUT_DEFERRAL,

        delay = {
            min = 0,
            max = 1
        },

        throttle = {
            after = 1,
            min = 1,
            max = 3,
        }
    }
}

JAVOX_PRESET = "JaVox_Preset"

--- This function will ensure a player has the necessary NW variables. Defines the following:
--- * JaVox_Current -> the current audio (hopefully) playing.
--- * JaVox_Next    -> the next audio to play after current (assuming it is deferred) (monolithic TODO: potentially improve. design choice for now)
--- * JaVox_Preset  -> the player's preset.
--- @param player? Player
--- @param preset? string Optionally, supply a preset
function JaVox.Director:ensurePlayerContract(player, preset)
    if ! player then
        return JaVox:errorWithMessage(string.format(
            'trying to ensure contract for "%s" failed: missing player object.', preset))
    end

    JaVox.State:registerPlayer(player)
end

---Emits an audio action from `player`.
---@param player Player?
---@param actionName string?
---@return JaVoxError?
function JaVox.Director:emitActionFromPlayer(player, actionName)
    if ! player then return JaVox:errorWithMessage("running actions require player object.") end
    if ! actionName then
        return JaVox:errorWithMessage(string.format(
            "Emitting from host '%s' failed beacuse actionname is missing.", player:Nick()))
    end

    local playerPreset = player:GetNWString(JAVOX_PRESET)
    local actionObject = JaVox.Crud:getActionFromModule(playerPreset, actionName)

    if ! actionObject then
        return JaVox:errorWithMessage(string.format("Action from module %s '%s' does not exist.",
            playerPreset, actionName))
    end



    if JaVox:isError(actionObject) then
        --- note to other devs: don't do this, but i've verified above clearly.
        ---@diagnostic disable-next-line: return-type-mismatch
        return actionObject
    end

    if JaVox.globals.PrintEveryActionPlayed:GetBool() then
        print("[JaVox internal] Found action available. Running")
    end

    ---cuz it rlly aint
    ---@diagnostic disable-next-line: param-type-mismatch
    self:_emitActionWithPriorityContract(player, actionObject, actionName)
end

--(actionObject.delay and math.random(actionObject.delay.min, actionObject.delay.max)) or 0
-- basically do this but in one singular function
function JaVox.Director:convertConformingMinMaxesToRandomValue(obj, default)
    -- object is not object, object has no range, and nothing to utilize
    if not obj or not obj.min or not obj.max then
        return math.random(default.min, default.max)
    end

    -- if object is a table, return a random value from its range
    return math.random(obj.min, obj.max)
end

---Emits an action from a player. Handles the cases of a list, singular sound, or no sound at all. This should NOT be called by developers. Instead, use `emitActionFromPlayer
---@param player Player
---@param actionObject PlayerVoxAction
function JaVox.Director:_emitActionWithPriorityContract(player, actionObject, name)
    local soundToPlay = nil
    local playerEntIndex = player:SteamID64()

    -- Audio file selector:
    --      Audio files are string -> Use it
    --      Audio files are string[] -> Grab a random one
    -- Designed like this to be extensible and make sense humanly.
    if type(actionObject.audioFiles) == "string" then
        soundToPlay = actionObject
            .audioFiles -- TODO: will i reference another action, will it recursively call? Answer: Yes, it will.
    elseif type(actionObject.audioFiles) == "table" then
        ---@diagnostic disable-next-line: param-type-mismatch
        soundToPlay = JaVox.State:popFromPlayPoolOf(playerEntIndex, actionObject.audioFiles, name)
    end


    -- Important: defines the throttling rule.
    --  If player throttling then end emittion
    --  FIXME: maybe put this in the first function instead
    if JaVox.State:playerIsThrottling(playerEntIndex) then
        return print("throttling")
    end

    if JaVox.globals.PrintEveryActionPlayed:GetBool() then
        print("[JaVox internal] Found action available. Running")
    end

    if ! soundToPlay then return end
    --- @cast soundToPlay string

    -- Delay & Chance to not play setup
    --          1 in chanceToNotPlay chance that it won't play (if chanceToNotPlay exists)
    --          Delay is either a random value from min and max from actionObject.delay, or 0, but will be convar-supported for overriding.
    -- TODO: add some convars to have a default if delay not specific. Or just to override.

    -- TODO: there are now multiple delays. Throttle + tailEndBreath.
    -- TODO: ultimately i have to remove one because they both serve similar purposes
    local waitTime = JaVox.Director:convertConformingMinMaxesToRandomValue(
        actionObject.delay,
        JaVox.Director.sensibleDefaults.delay
    )

    -- last one. random chance to not play
    if actionObject.delay and actionObject.delay.chanceToNotPlay then
        if math.random(actionObject.delay.chanceToNotPlay) == 1 then
            return
        end
    end

    if JaVox.globals.PrintEveryActionPlayed:GetBool() then
        print("[JaVox internal] All checks passed.")
    end

    local durationOfSound = SoundDuration(soundToPlay)
    if durationOfSound <= 0 then durationOfSound = 1.0 end

    -- new time architecture:
    local queueItem = {
        targetSound = soundToPlay,
        volume = (actionObject.volume or 100) * JaVox.globals.GlobalVolumeModifier:GetFloat(),
        pitch = (actionObject.pitch or 100) * JaVox.globals.GlobalPitchModifier:GetFloat(),
        duration = durationOfSound ~= 60 and durationOfSound or 1.5,
        delay = waitTime * JaVox.globals.GlobalDelayModifier:GetFloat(),
        throttle = actionObject.throttle or {
            min = 1,
            max = 3,
        },
        dsp = actionObject.dsp or -1
    }

    actionObject.priority = actionObject.priority or JaVox.Director.sensibleDefaults.priority

    if JaVox.globals.PrintEveryActionPlayed:GetBool() then
        print("Playing action: " .. name)
        PrintTable(queueItem)
    end

    JaVox.Scheduler:EnsureScheduled(player:EntIndex())

    -- Priority selector:
    --      deferral  : will set next in queue
    --      oncew/od  : will ignore any requests until sound is done (no more playing)
    --      immediate : play immediately. do not care.
    --      uniquely  : probably keep track. ??? x
    if actionObject.priority == AudioPriority.PLAY_DEFERRED then
        JaVox.Scheduler:Enqueue(player, queueItem)
    elseif actionObject.priority == AudioPriority.PLAY_ONCE_WITHOUT_DEFERRAL then
        if JaVox.Scheduler:IsSpeaking(player:EntIndex()) then
            return
        end

        JaVox.Scheduler:Enqueue(player, queueItem)
    elseif actionObject.priority == AudioPriority.PLAY_IMMEDIATE then
        JaVox.Scheduler:ClearQueue(player:EntIndex())
        JaVox.Scheduler:Enqueue(player, queueItem)
    elseif actionObject.priority == AudioPriority.PLAY_UNIQUELY then
        JaVox.Scheduler:ClearQueue(player:EntIndex())
        -- FIXME: how the FUCK is this supposed to work with the scheduler?
    end
end

---Emits a simple callout from a player.
---@param player Player
---@param calloutName string
---@return JaVoxError?
function JaVox.Director:emitCalloutFromPlayer(player, calloutName)
    if ! player then return JaVox:errorWithMessage("running callouts require player object.") end
    if ! calloutName then
        return JaVox:errorWithMessage(string.format(
            "Emitting callout from host '%s' failed beacuse calloutName is missing.", player:Nick()))
    end

    local preset = player:GetNWString(JAVOX_PRESET, nil)
    if ! preset then return end

    local calloutResolution = JaVox.Crud:resolveCallout(preset, calloutName)
    self:emitActionFromPlayer(player, calloutResolution)
end

---Registers a callout link to an action in `toMod.`
---@param toMod string E.g. test
---@param calloutName string E.g. "Reloading!"
---@param calloutInternal string E.g. weaponry.reload
function JaVox.Director:registerCallout(toMod, calloutName, calloutInternal)
    JaVox.Crud:registerCallout(toMod, calloutName, calloutInternal)
end
