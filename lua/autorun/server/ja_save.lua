hook.Add("PlayerSpawn", "JaVox Load", function(player, transition)
    player:SetNWString(JAVOX_PRESET, player:GetPData("javox_preset", "none"))
end)
