if SERVER then
    util.AddNetworkString("JaVox_IsNowSpeaking")
    util.AddNetworkString("JaVox_NoLongerSpeaking")
end

if SERVER then
    JaVox.Speaker = JaVox.Speaker or {
        playerSpeakerTable = {}
    }

    net.Receive("JaVox_IsNowSpeaking", function(len, ply)
        local targetPly = net.ReadEntity()
        JaVox.Speaker:StartSpeakTracking(targetPly)
    end)

    net.Receive("JaVox_NoLongerSpeaking", function(len, ply)
        local targetPly = net.ReadEntity()
        JaVox.Speaker:StopSpeakTracking(targetPly)
    end)

    -- Starts tracking a player's voice state.
    function JaVox.Speaker:StartSpeakTracking(ply)
        if CLIENT then return end
        self.playerSpeakerTable[ply:EntIndex()] = true
    end

    -- Stops tracking a player's voice state.
    function JaVox.Speaker:StopSpeakTracking(ply)
        if CLIENT then return end
        self.playerSpeakerTable[ply:EntIndex()] = nil
    end

    -- Returns whether the server currently considers the player to be speaking.
    function JaVox.Speaker:IsSpeaking(ply)
        return self.playerSpeakerTable[ply:EntIndex()] ~= nil
    end
end

if CLIENT then
    local playerShouldStopWhenSpeaking = CreateClientConVar("javox_stop_when_speaking", "1", true, false)

    hook.Add("PlayerStartVoice", "JaVoxStartSpeakTracking", function(ply)
        if not playerShouldStopWhenSpeaking:GetBool() then return end
        net.Start("JaVox_IsNowSpeaking")
        net.WriteEntity(ply)
        net.SendToServer()
    end)

    hook.Add("PlayerEndVoice", "JaVoxStopSpeakTracking", function(ply)
        if not playerShouldStopWhenSpeaking:GetBool() then return end

        net.Start("JaVox_NoLongerSpeaking")
        net.WriteEntity(ply)
        net.SendToServer()
    end)
end
