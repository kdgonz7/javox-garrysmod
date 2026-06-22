-- ultimately this will be one of the most important javox modules.
-- simply because it's so useful.
-- the director defines the state machine for players to actually use voxes.
-- when you call a vox, you call it through the JaVox helpers... which call the director.
-- the director has specific rules in place to allow players


--- @class JaVoxDirector
JaVox.Director = JaVox.Director or {}

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
    player:SetNWString(JAVOX_PRESET, preset or 'none')
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

    ---cuz it rlly aint
    ---@diagnostic disable-next-line: param-type-mismatch
    self:_emitActionWithPriorityContract(player, actionObject, actionName)
end

---Emits an action from a player. Handles the cases of a list, singular sound, or no sound at all. This should NOT be called by developers. Instead, use `emitActionFromPlayer
---@param player Player
---@param actionObject PlayerVoxAction
function JaVox.Director:_emitActionWithPriorityContract(player, actionObject, name)
    local soundToPlay = nil
    local playerEntIndex = player:EntIndex()

    -- Audio file selector:
    --      Audio files are string -> Use it
    --      Audio files are string[] -> Grab a random one
    -- Designed like this to be extensible and make sense humanly.
    if type(actionObject.audioFiles) == "string" then
        soundToPlay = actionObject.audioFiles
    elseif type(actionObject.audioFiles) == "table" then
        ---@diagnostic disable-next-line: param-type-mismatch
        soundToPlay = JaVox.State:popFromPlayPoolOf(playerEntIndex, actionObject.audioFiles, name)
    end


    -- Important: defines the throttling rule.
    --  If player throttling then end emittion
    --  FIXME: maybe put this in the first function instead
    if JaVox.State:playerIsThrottling(playerEntIndex) then
        return
    end

    if ! soundToPlay then return end
    --- @cast soundToPlay string

    -- god of coding is not watching

    --- Plays selected sound from player, following the delay rules.
    --- @param sound string
    --- @param willDefer boolean
    local function playSelectedFromPlayer(sound, willDefer)
        -- Delay & Chance to not play setup
        --          1 in chanceToNotPlay chance that it won't play (if chanceToNotPlay exists)
        --          Delay is either a random value from min and max from actionObject.delay, or 0, but will be convar-supported for overriding.
        -- TODO: add some convars to have a default if delay not specific. Or just to override.
        local waitTime = (actionObject.delay and math.random(actionObject.delay.min, actionObject.delay.max)) or 0

        -- last one. random chance to not play
        if actionObject.delay.chanceToNotPlay then
            if math.random(actionObject.delay.chanceToNotPlay) == 1 then
                return
            end
        end

        -- if action has throttling attached
        if actionObject.throttle then
            if JaVox.State:playerIsThrottling(playerEntIndex) then
                print("Still going for action", name)
                return
            end

            -- if we are in that a throttle-worthy action, increment throttle points
            -- then check if that's our limit. if so, then we begin throttling (waiting)
            -- and set a timer to clear the throttling.
            if JaVox.State:isThrottlingAction(playerEntIndex, name) then
                JaVox.State:incrementThrottlePoints(playerEntIndex)

                if JaVox.State:playerShouldThrottle(playerEntIndex) then
                    JaVox.State:beginThrottle(playerEntIndex, name, actionObject.throttle)

                    local randomTimeThrottle = math.random(actionObject.throttle.min, actionObject.throttle.max)

                    timer.Simple(randomTimeThrottle, function()
                        JaVox.State:clearThrottle(playerEntIndex)
                    end)

                    return
                end
            else
                JaVox.State:registerThrottlingState(playerEntIndex, name, actionObject.throttle)
            end
        end
        -- throttle check ended.

        -- timer phase:
        --      Call a timer that checks if there's audio playing and there's a plan to defer it.
        --      Stop sound if this should take precedence. Emit the sound, check the duration and set a second timer
        --          to cancel it and run a next one in the queue (if there is one, and if PLAY_ONCE_WITHOUT_DEFERRAL isn't used.)
        timer.Simple(waitTime, function()
            if ! IsValid(player) then return end
            local currentAudio = JaVox.State:getPlayerCurrentAudio(playerEntIndex)

            if willDefer and currentAudio then return end
            if ! willDefer and currentAudio then
                player:StopSound(currentAudio)
            end

            player:EmitSound(
                sound,
                actionObject.reach or 100,
                actionObject.pitch or 100,
                actionObject.volume or 1
            )


            local durationOfSound = SoundDuration(sound)
            if durationOfSound <= 0 then durationOfSound = 1.0 end

            --- These lines of code set the player's current audio, then wait until the end of the projected duration
            --- and then remove that one. It checks for a reserve sound, then plays it, repeating this process.
            JaVox.State:setPlayerCurrentAudio(playerEntIndex, sound)
            timer.Simple(durationOfSound, function()
                if ! IsValid(player) then return end

                JaVox.State:setPlayerCurrentAudio(playerEntIndex, nil)
                local reserve = JaVox.State:getPlayerQueuedNext(playerEntIndex)

                if reserve then
                    JaVox.State:setPlayerQueuedNext(playerEntIndex, nil)
                    playSelectedFromPlayer(reserve, true)
                end
            end)
        end)
    end

    -- Priority selector:
    --      deferral  : will set next in queue if already have one going.
    --      oncew/od  : will ignore any requests until sound is done (no more playing)
    --      immediate : play immediately. do not care.
    --      uniquely  : probably keep track. ??? x
    if actionObject.priority == AudioPriority.PLAY_DEFERRED then
        local currentPlaying = JaVox.State:getPlayerCurrentAudio(playerEntIndex)
        if currentPlaying then
            JaVox.State:setPlayerQueuedNext(playerEntIndex, soundToPlay)
            return
        end

        playSelectedFromPlayer(soundToPlay, true)
    elseif actionObject.priority == AudioPriority.PLAY_ONCE_WITHOUT_DEFERRAL then
        local currentPlaying = JaVox.State:getPlayerCurrentAudio(playerEntIndex)
        if currentPlaying then
            return --- only difference from  this and deferred.
        end

        playSelectedFromPlayer(soundToPlay, true)
    elseif actionObject.priority == AudioPriority.PLAY_IMMEDIATE then
        ---@diagnostic disable-next-line: param-type-mismatch
        playSelectedFromPlayer(soundToPlay, false)
    elseif actionObject.priority == AudioPriority.PLAY_UNIQUELY then
        if JaVox.State:getPlayerLastUnique(playerEntIndex) == name then
            return
        end

        JaVox.State:setPlayerLastUnique(playerEntIndex, name)
        playSelectedFromPlayer(soundToPlay, false)
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

    local eid = player:EntIndex()
    local lastPlayedCallout = JaVox.State:getPlayerLastCallout(eid)

    if lastPlayedCallout ~= nil then
        player:StopSound(lastPlayedCallout)
        JaVox.State:setPlayerLastCallout(eid, nil)
    end

    local playerCurrentPlaying = JaVox.State:getPlayerCurrentAudio(eid)
    if playerCurrentPlaying then
        player:StopSound(playerCurrentPlaying)
        JaVox.State:setPlayerCurrentAudio(eid, nil)
        JaVox.State:setPlayerQueuedNext(eid, nil)
    end

    local playerPreset = player:GetNWString(JAVOX_PRESET, nil)
    if ! playerPreset then
        return
    end

    local callout = JaVox.Crud:getCalloutsFromModule(playerPreset)
    local calloutObj = callout[calloutName];
    if ! calloutObj then return print("No callout called " .. calloutName) end

    ---@diagnostic disable-next-line: undefined-field
    local randomSelection = table.Random(calloutObj.audioFiles)
    player:EmitSound(randomSelection) -- TODO: Volume, pitch, etc. variations. new vary() function to make it easy.
end
