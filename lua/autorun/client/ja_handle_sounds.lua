local activeChannels = {}

net.Receive("JaVoxPlayerPlay", function(len)
    local ply = net.ReadEntity()
    local targetSound = net.ReadString()
    local volume = net.ReadFloat()
    local pitch = net.ReadFloat()

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

    sound.PlayFile("sound/" .. targetSound, "3d noplay", function(channel, errorID, errorName)
        if not IsValid(channel) then
            print("Failed to play sound: " .. errorName)
            print("Error ID: " .. errorID)
            print("sound: sound/" .. targetSound)

            activeChannels[ply:EntIndex()] = nil
            print("cleared active channel for player: " .. ply:EntIndex())
            hook.Remove("Think", channel)
            return
        end

        channel:SetVolume(volume / 100)
        channel:SetPlaybackRate(pitch / 100)
        channel:Play()
        metadata.LatestChannel = channel

        hook.Add("Think", channel, function()
            if not IsValid(ply) or not ply:Alive() then
                hook.Remove("Think", channel)
                return
            end

            channel:SetPos(ply:GetPos())
        end)
    end)
end)
