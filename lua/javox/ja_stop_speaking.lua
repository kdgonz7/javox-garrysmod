if CLIENT then
    return -- FIXME: in case this doesn't work as expected
end
local playerShouldStopWhenSpeaking = CreateConVar("javox_stop_when_speaking_global", "1", { FCVAR_ARCHIVE, FCVAR_NOTIFY },
    "Whether to stop sounds when a player is speaking.")

hook.Add("Think", "JaVoxStopSpeaking", function()
    if not playerShouldStopWhenSpeaking:GetBool() then return end

    for entIndex, player in pairs(JaVox.Scheduler.Players) do
        local plyEnt = Entity(entIndex)

        if not JaVox.Speaker:IsSpeaking(plyEnt) then
            return
        end

        -- player is speaking. see if they have sound and cancel it.
        if player.activeSound then                            -- if they have an active sound
            if plyEnt and plyEnt:IsValid() then               -- if valid
                plyEnt:StopSound(player.activeSound)          -- stop the active sound
                JaVox.Scheduler:ClearQueue(plyEnt:EntIndex()) -- clear their queue so no other sound plays while talking.
            end
        end
    end
end)
