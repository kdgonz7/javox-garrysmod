-- JaVox Scheduler
-- Handles audio delays and play times.
-- Direct replacement for the dual-timer architecture.

---@class QueueItem
---@field targetSound string
---@field startTime number
---@field endTime number
---@field volume number
---@field pitch number
---@field duration number
---@field delay number

---@class PlayerMeta
---@field Queue table<QueueItem>
---@field nextAvailableTime number Defines the time when the next sound can be played.

---@class JaVoxScheduler
---@field Players table<number, PlayerMeta>
JaVox.Scheduler = JaVox.Scheduler or {
    Players = {},
}

function JaVox.Scheduler:ClearQueue(plyEntIndex)
    if not self.Players[plyEntIndex] then return end
    for i = 1, #self.Players[plyEntIndex].Queue do
        Entity(plyEntIndex):StopSound(self.Players[plyEntIndex].Queue[i].targetSound)
    end
    self.Players[plyEntIndex].Queue = {}
    self.Players[plyEntIndex].nextAvailableTime = 0
end

function JaVox.Scheduler:Enqueue(ply, item)
    if not self.Players[ply:EntIndex()] then
        self:EnsureScheduled(ply:EntIndex())
        print("player's career has begun")
    end

    local playerEntry = self.Players[ply:EntIndex()]
    item.startTime = math.max(CurTime(), playerEntry.nextAvailableTime) + (item.delay or 0)

    table.insert(self.Players[ply:EntIndex()].Queue, item)
    self.Players[ply:EntIndex()].nextAvailableTime = item.startTime + item.duration

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
            nextAvailableTime = 0
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
            end

            ply:EmitSound(dq.targetSound, dq.volume, dq.pitch)
        end
    end
end)
