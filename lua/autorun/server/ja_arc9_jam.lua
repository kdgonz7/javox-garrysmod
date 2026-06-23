---@diagnostic disable: undefined-field
hook.Add("KeyPress", "JaVox ARC9 Jam Feature", function(ply, key)
    if key == IN_ATTACK then
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
