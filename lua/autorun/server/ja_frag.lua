print("Entity frag module loaded!")
-- TODO: configs for all builtin modules.
-- TODO: we love the player.
local GRENADES = {
    10, -- classic HL2
    45, -- arc9 frag
    46  -- arc9 frag
}

local JA_FRAG_ENABLED = CreateConVar("javox_frag_enable", "1", { FCVAR_ARCHIVE, FCVAR_NOTIFY },
    "Enable or disable grenade frag actions.")

hook.Add("KeyPress", "JaVOX Frag Out", function(ply, key)
    if not JA_FRAG_ENABLED:GetBool() then return end

    if key == IN_ATTACK then
        local weap = ply:GetActiveWeapon()
        if ! IsValid(weap) then return end
        if table.HasValue(GRENADES, weap:GetPrimaryAmmoType()) then
            JaVox.Director:emitActionFromPlayer(ply, "weaponry.grenade_out")
        end
    end
end)
