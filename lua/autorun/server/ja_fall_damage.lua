hook.Add("EntityTakeDamage", "Javox fall damage", function(target, dmg)
    if ! target:IsPlayer() then return end
    if target:Health() - dmg:GetDamage() <= 0 then return end
    if ! dmg:IsFallDamage() then return end

    ---@diagnostic disable-next-line: param-type-mismatch
    JaVox.Director:emitActionFromPlayer(target, "self.fallDamage")
end)
