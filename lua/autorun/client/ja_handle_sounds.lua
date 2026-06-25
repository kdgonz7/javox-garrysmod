-- JaVox sound engine???
-- whatever. all it does is play sounds for players.
-- and has a simple rule: stop last sound before playing a new one.

local activeChannels = {}

net.Receive("JaVoxPlayerPlay", function(len)
    local ply = net.ReadEntity()
    local targetSound = net.ReadString()
    local volume = net.ReadFloat()
    local pitch = net.ReadFloat()
    local dsp = net.ReadInt(32)

    if not IsValid(ply) then return end

    local metadata = activeChannels[ply:EntIndex()]

    if metadata and IsValid(metadata.LatestChannel) then -- no matter what we should clear the last sound, so.
        metadata.LatestChannel:Stop()                    -- there. that should work. maybe
    end

    if not metadata then
        activeChannels[ply:EntIndex()] = {}
        metadata = activeChannels[ply:EntIndex()]
        print("new sound for player: " .. ply:EntIndex())
    end

    local patch = CreateSound(ply, targetSound)

    if dsp ~= -1 then
        ---@cast ply Player
        patch:SetDSP(dsp)
    else
        ---@cast ply Player
        patch:SetDSP(1)
    end

    patch:Play()
    patch:ChangeVolume(volume / 100)
    patch:ChangePitch(pitch)

    metadata.LatestChannel = patch
end)
