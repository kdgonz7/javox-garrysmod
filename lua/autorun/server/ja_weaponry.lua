print("JaVox reload module loaded!")

local javox_reload_action_enabled = CreateConVar(
    "javox_reload_action_enabled",
    "1",
    { FCVAR_ARCHIVE, FCVAR_NOTIFY },
    "Enable JaVox reload action"
)

local javox_no_ammo_left_action_enabled = CreateConVar(
    "javox_no_ammo_left_action_enabled",
    "1",
    { FCVAR_ARCHIVE, FCVAR_NOTIFY },
    "Enable JaVox no ammo left action"
)

hook.Add("KeyPress", "JaVox_KeyPress_Reload", function(ply, key)
    if key ~= IN_RELOAD then return end
    if not IsValid(ply) or not ply:Alive() or ply:InVehicle() then return end

    local activeWeapon = ply:GetActiveWeapon()
    if not IsValid(activeWeapon) then return end

    if type(activeWeapon.Clip1) ~= "function" or type(activeWeapon.GetMaxClip1) ~= "function" then
        return
    end

    local clip1 = activeWeapon:Clip1() or 0
    local maxclip1 = activeWeapon:GetMaxClip1() or 0

    if clip1 >= maxclip1 then return end

    local ammoType = activeWeapon.GetPrimaryAmmoType and activeWeapon:GetPrimaryAmmoType() or -1
    local reserveAmmo = ammoType ~= -1 and ply:GetAmmoCount(ammoType) or 0


    if reserveAmmo <= 0 then
        if not javox_no_ammo_left_action_enabled:GetBool() then return end
        JaVox.Director:emitActionFromPlayer(ply, "weaponry.out_of_ammo")
        return
    end

    if not javox_reload_action_enabled:GetBool() then return end

    JaVox.Director:emitActionFromPlayer(ply, "weaponry.reload")
end)

hook.Add("KeyPress", "JaVox No ammo callout when firing", function(ply, key)
    if key == IN_ATTACK then
        if not ply or not ply:IsPlayer() or not ply:Alive() or ply:InVehicle() then
            return
        end

        local activeWeapon = ply:GetActiveWeapon()
        local ammoType = activeWeapon.GetPrimaryAmmoType and activeWeapon:GetPrimaryAmmoType() or -1

        if not IsValid(activeWeapon) then
            return
        end

        if ammoType == -1 or ammoType == 10 then
            return
        end

        if activeWeapon:Clip1() <= 0 and activeWeapon:Clip2() <= 0 then      -- clip 1 primary none | clip 2 reserve none
            JaVox.Director:emitActionFromPlayer(ply, "weaponry.out_of_ammo") -- callout
        end
    end
end)
