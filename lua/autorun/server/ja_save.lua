hook.Add("PlayerSpawn", "JaVox Load", function(player, transition)
    player:SetNWString(JAVOX_PRESET, player:GetPData("javox_preset", "none"))
end)

hook.Add("PlayerDisconnected", "JaVox Save", function(ply)
    ply:SetPData("javox_preset", ply:GetNWString(JAVOX_PRESET, "none"))
end)
