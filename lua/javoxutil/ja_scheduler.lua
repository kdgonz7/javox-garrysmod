if SERVER then
    util.AddNetworkString("JaVoxPlayerPlay")
end

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
    local player = self.Players[plyEntIndex]

    -- FIXME: this technically doesn't work. the sound engine wrapper handles it now.
    if player.activeSound then
        Entity(plyEntIndex):StopSound(player.activeSound)
    end

    player.Queue = {}
    player.nextAvailableTime = 0
    player.activeSound = nil
end

function JaVox.Scheduler:Enqueue(ply, item)
    if not self.Players[ply:EntIndex()] then
        self:EnsureScheduled(ply:EntIndex())
        print("player's career has begun")
    end

    local playerEntry = self.Players[ply:EntIndex()]
    item.startTime = math.max(CurTime(), playerEntry.nextAvailableTime) + (item.delay or 0)

    table.insert(self.Players[ply:EntIndex()].Queue, item)

    -- new: use throttle instead of tailEndBreath. have to update elsewhere.
    local tailend = item.throttle and math.random(item.throttle.min, item.throttle.max)
    self.Players[ply:EntIndex()].nextAvailableTime = item.startTime + item.duration +
        ((tailend or 0)) * JaVox.globals.GlobalThrottleModifier:GetFloat()
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

        if CurTime() >= item.startTime then
            local dq = JaVox.Scheduler:Dequeue(entIndex)
            if not dq then continue end
            -- Play the sound or perform the action

            local ply = Entity(entIndex)
            --- @cast ply Player
            if not ply then continue end
            if not ply:IsValid() or not ply:IsConnected() then
                JaVox.Scheduler:ClearFromQueue(entIndex)
                continue
            end

            -- apply the global chance modifier
            -- NOTE: this is here because if you put it in the director, it can be spammed until it plays. brute forced into a deterministic playing.
            -- NOTE: so here, this only plays once when the queue permits, therefore it's safer.
            -- TODO: tell other devs do not put shit in director
            if JaVox.globals.GlobalChanceModifier:GetFloat() < 1.0 then
                if math.random() > JaVox.globals.GlobalChanceModifier:GetFloat() then
                    if JaVox.globals.PrintEveryActionPlayed:GetBool() then
                        print("[JaVox internal] Action chance did not yield good.")
                    end
                    return
                end
            end

            net.Start("JaVoxPlayerPlay")
            net.WriteEntity(ply)
            net.WriteString(dq.targetSound)
            net.WriteFloat(dq.volume)
            net.WriteFloat(dq.pitch)
            net.WriteInt(dq.dsp or -1, 32)
            net.Broadcast()

            ply:EmitSound("common/null.wav", dq.volume, dq.pitch, 1, CHAN_VOICE)

            sound.EmitHint(SOUND_PLAYER, ply:GetPos() + Vector(0, 0, 64), 500, dq.duration or 1.5, ply)
            JaVox.Scheduler.Players[entIndex].activeSound = dq.targetSound
        end
    end
end)
