local DamageModuleEnabled = CreateConVar("javox_damage_module_enabled", "1", { FCVAR_ARCHIVE, FCVAR_NOTIFY },
    "Enable the damage module for JaVox.")


hook.Add("EntityTakeDamage", "JaVox_Damage", function(ent, dmginfo)
    if not DamageModuleEnabled:GetBool() then return end

    local victim = ent
    if ! IsValid(victim) or ! victim:IsPlayer() then return end

    --- @cast victim Player
    if victim:Health() <= 0 then
        JaVox.Director:emitActionFromPlayer(victim, "self.death")
    end
end)

local HITGROUPS = {
    [HITGROUP_HEAD] = 'head',
    [HITGROUP_CHEST] = 'chest',
    [HITGROUP_STOMACH] = 'stomach',
    [HITGROUP_LEFTARM] = 'leftarm',
    [HITGROUP_RIGHTARM] = 'rightarm',
    [HITGROUP_LEFTLEG] = 'leftleg',
    [HITGROUP_RIGHTLEG] = 'rightleg',
    [HITGROUP_GEAR] = 'gear'
}

hook.Add("ScalePlayerDamage", "JaVox_ScaleDamage", function(ply, hitgroup)
    if not DamageModuleEnabled:GetBool() then return end

    --- @cast ply Player
    local scale = HITGROUPS[hitgroup]
    if not scale then return end

    JaVox.Director:emitActionFromPlayer(ply, "self.damage." .. scale)
end)
