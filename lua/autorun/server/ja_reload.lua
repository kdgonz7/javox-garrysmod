print("JaVox reload module loaded!")

local javox_reload_action_enabled = CreateConVar(
    "javox_reload_action_enabled",
    "1",
    { FCVAR_ARCHIVE, FCVAR_REPLICATED },
    "Enable JaVox reload action"
)

hook.Add("KeyPress", "JaVox Key Press Test", function(ply, key)
    if not javox_reload_action_enabled:GetBool() then
        return
    end

    if key == IN_RELOAD then
        local activeWeapon = ply:GetActiveWeapon()
        if not IsValid(activeWeapon) then
            return
        end

        if activeWeapon:Clip1() >= activeWeapon:GetMaxClip1() then
            return
        end

        -- TODO: check for ammo types.
        JaVox.Director:emitActionFromPlayer(ply, "weaponry.reload")
    end
end)
