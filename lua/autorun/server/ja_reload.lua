print("JaVox reload module loaded!")

local javox_reload_action_enabled = CreateConVar(
    "javox_reload_action_enabled",
    "1",
    { FCVAR_ARCHIVE, FCVAR_NOTIFY },
    "Enable JaVox reload action"
)

local javox_out_of_ammo_action_enabled = CreateConVar(
    "javox_out_of_ammo_action_enabled",
    "1",
    { FCVAR_ARCHIVE, FCVAR_NOTIFY },
    "Enable JaVox out of ammo action"
)

hook.Add("KeyPress", "JaVox Key Press Test", function(ply, key)
    if key == IN_RELOAD then
        local activeWeapon = ply:GetActiveWeapon()
        if not IsValid(activeWeapon) then
            return
        end

        if activeWeapon:Clip1() >= activeWeapon:GetMaxClip1() then
            return
        end

        if activeWeapon:Clip1() <= 0 then
            if not javox_out_of_ammo_action_enabled:GetBool() then
                return
            end

            JaVox.Director:emitActionFromPlayer(ply, "weaponry.out_of_ammo")
            return
        end

        if not javox_reload_action_enabled:GetBool() then
            return
        end

        -- TODO: check for ammo types.
        JaVox.Director:emitActionFromPlayer(ply, "weaponry.reload")
    end
end)
