local javox_fall_damage_enabled = CreateConVar("javox_fall_damage_action", "1", { FCVAR_ARCHIVE, FCVAR_REPLICATED },
    "Enable or disable Javox fall damage action")

hook.Add("EntityTakeDamage", "Javox fall damage", function(target, dmg)
    if not javox_fall_damage_enabled:GetBool() then return end
    if not target:IsPlayer() then return end
    if target:Health() - dmg:GetDamage() <= 0 then return end
    if not dmg:IsFallDamage() then return end
    ---@diagnostic disable-next-line: param-type-mismatch
    JaVox.Director:emitActionFromPlayer(target, "self.damage.fall")
end)
