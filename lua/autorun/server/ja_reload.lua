print("JaVox reload module loaded!")

hook.Add("KeyPress", "JaVox Key Press Test", function(ply, key)
    if key == IN_RELOAD then
        local activeWeapon = ply:GetActiveWeapon()
        if activeWeapon:Clip1() >= activeWeapon:GetMaxClip1() then
            return
        end

        -- TODO: we can build a jam module using this.
        -- TODO: simple, we hook a loop that checks all like weapons to see if they are GetJammed (ARC9) and ACTUALLY ARE jammed.
        -- TODO: if they are, play that sound. Maybe do it in attack beacuse they click when it jams.
        print(activeWeapon.GetJammed)

        -- TODO: check for ammo types.
        JaVox.Director:emitActionFromPlayer(ply, "weaponry.reload")
    end
end)
