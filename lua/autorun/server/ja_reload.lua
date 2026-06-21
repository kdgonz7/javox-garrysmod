print("JaVox reload module loaded!")

hook.Add("KeyPress", "JaVox Key Press Test", function(ply, key)
    if key == IN_RELOAD then
        local activeWeapon = ply:GetActiveWeapon()
        if activeWeapon:Clip1() >= activeWeapon:GetMaxClip1() then
            return
        end

        -- TODO: check for ammo types.
        JaVox.Director:emitActionFromPlayer(ply, "weaponry.reload")
    end
end)
