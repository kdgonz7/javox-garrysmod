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
---@field last string?

---Registers a player into the current JaVox State Machine. Manages current audio, next play audio, etc.
---@param player Player?
function JaVox.State:registerPlayer(player)
    if ! player then return JaVox:errorWithMessage("Registerplayer missing player.") end

    self.players[player:SteamID64()] = {
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
            last = nil
        },

        throttleState = {
            isThrottling = false,
        }
    }
end

--- Returns a player's current audio, or none if there isn't any audio playing.
--- @param playerIndex string
--- @return string?
function JaVox.State:getPlayerCurrentAudio(playerIndex)
    return self.players[playerIndex].currentAudio
end

--- Sets a player's current audio
--- @param playerIndex string
--- @param sound string?
function JaVox.State:setPlayerCurrentAudio(playerIndex, sound)
    self.players[playerIndex].currentAudio = sound
end

--- Sets a player's queued next audio.
---@param playerIndex string
---@param sound string?
function JaVox.State:setPlayerQueuedNext(playerIndex, sound)
    self.players[playerIndex].nextAudio = sound
end

--- Returns a player's next audio (if any)
---@param playerIndex string
---@return string?
function JaVox.State:getPlayerQueuedNext(playerIndex)
    return self.players[playerIndex].nextAudio
end

---Sets a player's last unique sound
---@param playerIndex string
---@param sound string
function JaVox.State:setPlayerLastUnique(playerIndex, sound)
    self.players[playerIndex].lastUniqueSound = sound;
end

--- Returns a player's last unique audio (if any)
---@param playerIndex string
---@return string?
function JaVox.State:getPlayerLastUnique(playerIndex)
    return self.players[playerIndex].lastUniqueSound
end

---Sets a player's last callout
---@param playerIndex string
---@param callout string?
function JaVox.State:setPlayerLastCallout(playerIndex, callout)
    self.players[playerIndex].callout.lastCallout = callout
end

---Returns a player's last callout
---@param playerIndex string
---@return string?
function JaVox.State:getPlayerLastCallout(playerIndex)
    return self.players[playerIndex].callout.lastCallout
end

---Begins keeping track of player throttle state
---@param playerIndex string
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
---@param playerIndex string
---@param action string
---@param throttleSettings ThrottleSettings
function JaVox.State:beginThrottle(playerIndex, action, throttleSettings)
    self.players[playerIndex].throttleState = {
        isThrottling = true,
        actionThrottling = action,
        throtBudgMax = throttleSettings.after,
        throtBudgCur = 0,
    }
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
    if not self.players[playerIndex] or not self.players[playerIndex].throttleState then
        return
    end

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

--- Pops and returns a random sound from the player's play pool.
---
--- If the requested action changes, the pool is reset for that action.
--- When the pool is empty, it is refilled from `withSounds` and shuffled.
--- The last played sound is avoided when possible.
---@param playerIndex string
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
        table.CopyFromTo(withSounds, pool)
        table.Shuffle(pool)
    end

    local sound = table.remove(pool, #pool)

    if sound == self.players[playerIndex].playPool.last and #pool > 0 then
        table.insert(pool, 1, sound)
        sound = table.remove(pool, #pool)
    end

    self.players[playerIndex].playPool.last = sound
    return sound
end

function JaVox.State:clearPlayerQueue(playerIndex)
    table.Empty(self.players[playerIndex].playPool.queue)
end
