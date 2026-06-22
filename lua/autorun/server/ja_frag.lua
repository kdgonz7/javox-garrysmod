print("Entity frag module loaded!")
-- TODO: configs for all builtin modules.
-- TODO: we love the player.
local GRENADES = {
    10, -- classic HL2
    45, -- arc9 frag
    46  -- arc9 frag
}

hook.Add("KeyPress", "JaVOX Frag Out", function(ply, key)
    if key == IN_ATTACK then
        local weap = ply:GetActiveWeapon()
        if ! IsValid(weap) then return print("Not valid") end
        if table.HasValue(GRENADES, weap:GetPrimaryAmmoType()) then
            JaVox.Director:emitActionFromPlayer(ply, "weaponry.grenadeOut")
        end
    end
end)
