local JaVoxSavingEnabled = CreateConVar("javox_saving_enabled", "1", { FCVAR_ARCHIVE, FCVAR_NOTIFY },
    "Enable JaVox saving")

hook.Add("PlayerSpawn", "JaVox Load", function(player, transition)
    if not JaVoxSavingEnabled:GetBool() then return end
    player:SetNWString(JAVOX_PRESET, player:GetPData("javox_preset", "none"))
end)
