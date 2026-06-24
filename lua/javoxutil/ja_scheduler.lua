-- JaVox Scheduler
-- Handles audio delays and play times.
-- Direct replacement for the dual-timer architecture.

---@class QueueItem A queue item for the scheduler to play.
---@field targetSound string The sound to be played.
---@field startTime number The time when the sound will start.
---@field endTime number The time when the sound will end.
---@field volume number The volume of the sound.
---@field pitch number The pitch of the sound.
---@field duration number The duration of the sound.
---@field delay number The delay before the sound is played.
---@field tailEndBreath number The duration of the tail end breath after the sound. Adds to the duration.

---@class PlayerMeta
---@field Queue table<QueueItem>
---@field nextAvailableTime number Defines the time when the next sound can be played.
---@field activeSound string|nil Defines the currently playing sound.

---@class JaVoxScheduler
---@field Players table<number, PlayerMeta>
JaVox.Scheduler = JaVox.Scheduler or {
    Players = {},
}

function JaVox.Scheduler:ClearQueue(plyEntIndex)
    if not self.Players[plyEntIndex] then return end
    for i = 1, #self.Players[plyEntIndex].Queue do
        local activeSoundForPlayer = self.Players[plyEntIndex].activeSound
        if not activeSoundForPlayer then continue end
        Entity(plyEntIndex):StopSound(activeSoundForPlayer)
    end
    self.Players[plyEntIndex].Queue = {}
    self.Players[plyEntIndex].nextAvailableTime = 0
    self.Players[plyEntIndex].activeSound = nil
end

function JaVox.Scheduler:Enqueue(ply, item)
    if not self.Players[ply:EntIndex()] then
        self:EnsureScheduled(ply:EntIndex())
        print("player's career has begun")
    end

    local playerEntry = self.Players[ply:EntIndex()]
    item.startTime = math.max(CurTime(), playerEntry.nextAvailableTime) + (item.delay or 0)

    table.insert(self.Players[ply:EntIndex()].Queue, item)
    self.Players[ply:EntIndex()].nextAvailableTime = item.startTime + item.duration + (item.tailEndBreath or 0)

    -- print("Enqueueing item for player", ply:EntIndex())
    -- print("Item start time:", item.startTime)
    -- print("Item duration:", item.duration)
    -- print("Next available time:", playerEntry.nextAvailableTime)
end

function JaVox.Scheduler:Dequeue(plyEntIndex)
    return table.remove(self.Players[plyEntIndex].Queue, 1)
end

function JaVox.Scheduler:Peek(plyEntIndex)
    return self.Players[plyEntIndex].Queue[1]
end

function JaVox.Scheduler:EnsureScheduled(plyEntIndex)
    if not self.Players[plyEntIndex] then
        self.Players[plyEntIndex] = {
            Queue = {},
            nextAvailableTime = 0,
            activeSound = nil
        }
    end
end

function JaVox.Scheduler:IsSpeaking(plyEntIndex)
    if not self.Players[plyEntIndex] then
        return false
    end

    -- if our current time is less than projected end we have audio playing
    return CurTime() < self.Players[plyEntIndex].nextAvailableTime
end

function JaVox.Scheduler:ClearFromQueue(plyEntIndex)
    self.Players[plyEntIndex] = nil
end

-- think:
-- process start times by checking if the current time is greater than or equal to the item's start time.
-- then we pop and play. right?
hook.Add("Think", "JaVoxScheduler", function()
    for entIndex, _ in pairs(JaVox.Scheduler.Players) do
        local item = JaVox.Scheduler:Peek(entIndex)
        if not item then continue end
        -- print("start", item.startTime)
        -- print("currnt", CurTime())

        if CurTime() >= item.startTime then
            local dq = JaVox.Scheduler:Dequeue(entIndex)
            if not dq then continue end
            -- Play the sound or perform the action

            -- print("Play sound:", dq.targetSound)
            -- print("Volume:", dq.volume)
            -- print("Pitch:", dq.pitch)

            local ply = Entity(entIndex)
            if not ply then continue end
            if not ply:IsValid() then
                JaVox.Scheduler:ClearFromQueue(entIndex)
                continue
            end

            ply:EmitSound(dq.targetSound, dq.volume, dq.pitch)
            JaVox.Scheduler.Players[entIndex].activeSound = dq.targetSound
        end
    end
end)
