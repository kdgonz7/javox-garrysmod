---@diagnostic disable: undefined-field
local ja_arc9_jam_enabled = CreateConVar("javox_arc9_jam_enabled", "1", { FCVAR_ARCHIVE, FCVAR_NOTIFY },
    "Enable or disable JaVox ARC9 jam action.")

hook.Add("KeyPress", "JaVox ARC9 Jam Feature", function(ply, key)
    if not ja_arc9_jam_enabled:GetBool() then return end

    if key == IN_ATTACK or key == IN_RELOAD then
        local activeWeapon = ply:GetActiveWeapon()

        -- get jammed is a function from ARC9... stole it from the code
        -- now we're gonna cheat, check if the weapon is jammed
        if activeWeapon.GetJammed then
            if activeWeapon:GetJammed() then
                JaVox.Director:emitActionFromPlayer(ply, "weaponry.jam")
            end
        end
    end
end)
