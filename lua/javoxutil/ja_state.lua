--- @class JaVoxState
--- @field players table<number, JaVoxState.PlayerInfo>
JaVox.State = JaVox.State or {
    players = {}
}

--- @class JaVoxState.PlayerInfo
--- @field playerName string
--- @field currentAudio string?
--- @field nextAudio string?
--- @field lastUniqueSound string?
--- @field callout JaVoxState.CalloutInfo
--- @field playPool PlayPool
--- @field throttleState JaVoxState.ThrottleState

--- @class JaVoxState.CalloutInfo
--- @field lastCallout string?

--- @class JaVoxState.ThrottleState
--- @field isThrottling boolean
--- @field actionThrottling string?
--- @field throtBudgMax number? How many times to play before throt
--- @field throtBudgCur number? How many times have we played this action

---@class PlayPool
---@field action string?
---@field queue string[]

---Registers a player into the current JaVox State Machine. Manages current audio, next play audio, etc.
---@param player Player?
function JaVox.State:registerPlayer(player)
    if ! player then return JaVox:errorWithMessage("Registerplayer missing player.") end

    self.players[player:EntIndex()] = {
        playerName = player:Nick(),
        currentAudio = nil,
        nextAudio = nil,
        lastUniqueSound = nil,

        callout = {
            lastCallout = nil
        },

        playPool = {
            action = nil,
            queue = {},
        },

        throttleState = {
            isThrottling = false,
        }
    }
end

--- Returns a player's current audio, or none if there isn't any audio playing.
--- @param playerIndex number
--- @return string?
function JaVox.State:getPlayerCurrentAudio(playerIndex)
    return self.players[playerIndex].currentAudio
end

--- Sets a player's current audio
--- @param playerIndex number
--- @param sound string?
function JaVox.State:setPlayerCurrentAudio(playerIndex, sound)
    self.players[playerIndex].currentAudio = sound
end

--- Sets a player's queued next audio.
---@param playerIndex number
---@param sound string?
function JaVox.State:setPlayerQueuedNext(playerIndex, sound)
    self.players[playerIndex].nextAudio = sound
end

--- Returns a player's next audio (if any)
---@param playerIndex number
---@return string?
function JaVox.State:getPlayerQueuedNext(playerIndex)
    return self.players[playerIndex].nextAudio
end

---Sets a player's last unique sound
---@param playerIndex number
---@param sound string
function JaVox.State:setPlayerLastUnique(playerIndex, sound)
    self.players[playerIndex].lastUniqueSound = sound;
end

--- Returns a player's last unique audio (if any)
---@param playerIndex number
---@return string?
function JaVox.State:getPlayerLastUnique(playerIndex)
    return self.players[playerIndex].lastUniqueSound
end

---Sets a player's last callout
---@param playerIndex number
---@param callout string?
function JaVox.State:setPlayerLastCallout(playerIndex, callout)
    self.players[playerIndex].callout.lastCallout = callout
end

---Returns a player's last callout
---@param playerIndex number
---@return string?
function JaVox.State:getPlayerLastCallout(playerIndex)
    return self.players[playerIndex].callout.lastCallout
end

---Inserts an audio voice line into the play pool of `playerIndex`.
---@param playerIndex number
---@param sound string
function JaVox.State:insertIntoPlayPool(playerIndex, sound)
    table.insert(self.players[playerIndex].playPool, sound)
end

---Begins keeping track of player throttle state
---@param playerIndex number
---@param action string
---@param throttleSettings ThrottleSettings
function JaVox.State:registerThrottlingState(playerIndex, action, throttleSettings)
    self.players[playerIndex].throttleState = {
        isThrottling = false,
        actionThrottling = action,
        throtBudgCur = 0,
        throtBudgMax = throttleSettings.after
    }
end

---Begins throttling a player's action at action.
---@param playerIndex number
---@param action string
---@param throttleSettings ThrottleSettings
function JaVox.State:beginThrottle(playerIndex, action, throttleSettings)
    self.players[playerIndex].throttleState = {
        isThrottling = true,
        actionThrottling = action,
        throtBudgMax = throttleSettings.after,
        throtBudgCur = 0,
    }
    --[[ NOTE: existing code if above doesn't work.
    .isThrottling = true
    self.players[playerIndex].throttleState.actionThrottling = action
    self.players[playerIndex].throttleState.throtBudgMax = throttleSettings.after
    self.players[playerIndex].throttleState.throtBudgCur = 0
    ]]
end

function JaVox.State:endThrottle(playerIndex)
    self:clearThrottle(playerIndex)
end

function JaVox.State:clearThrottle(playerIndex)
    self.players[playerIndex].throttleState = {
        isThrottling = false,
    }
end

function JaVox.State:playerIsThrottling(playerIndex)
    return self.players[playerIndex].throttleState.isThrottling
end

function JaVox.State:isThrottlingAction(playerIndex, action)
    return self.players[playerIndex].throttleState.actionThrottling == action
end

function JaVox.State:incrementThrottlePoints(playerIndex)
    self.players[playerIndex].throttleState.throtBudgCur = self.players[playerIndex].throttleState.throtBudgCur + 1
end

function JaVox.State:playerShouldThrottle(playerIndex)
    return self.players[playerIndex].throttleState.throtBudgCur == self.players[playerIndex].throttleState.throtBudgMax
end

---Pops and returns a **RANDOM** sound from the play pool of playerIndex.
---
---Will reset the queue IF a different action is being played.
---
---If there are no more sounds left,
---it will replace the pool with new sounds from `withSounds` and shuffle. This function is safe to call without
---population prior.
---@param playerIndex number
---@param withSounds string[]
---@param forAction string
---@return string
function JaVox.State:popFromPlayPoolOf(playerIndex, withSounds, forAction)
    if self.players[playerIndex].playPool.action ~= forAction then
        self.players[playerIndex].playPool.queue = {}
        self.players[playerIndex].playPool.action = forAction
    end

    --- wtf?
    local pool = self.players[playerIndex].playPool.queue

    if #pool == 0 then
        -- self.players[playerIndex].playPool.queue
        table.CopyFromTo(withSounds, pool)
        table.Shuffle(pool)
    end

    return table.remove(pool, #pool)
end

function JaVox.State:clearPlayerQueue(playerIndex)
    table.Empty(self.players[playerIndex].playPool.queue)
end
