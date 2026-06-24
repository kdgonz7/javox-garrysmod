--- JaVox Entity Kill Module
---
--- Implements:
---     | ents.suggestKill              When an entity is killed, but the player can not see them.
---     | ents.entKillGeneric           When an entity is killed and the player can see it.
---     | ents.entConfirmKillGeneric    When a ragdoll (assumedly dead body) is shot.

local BLACKLISTED = {
    -1,
}

local ENABLE_ENTITY_KILL_ACTIONS = CreateConVar("javox_enable_entity_kills", "1",
    { FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE }, "Enable JaVox entity kill actions")

print("Entity kill module loaded!")

local function isSomething(ent)
    return ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot() or ent:IsRagdoll()
end

hook.Add("EntityTakeDamage", "JaVox built-in damage hook", function(target, dmg)
    if target:Health() - dmg:GetDamage() <= 0 then
        if not ENABLE_ENTITY_KILL_ACTIONS:GetBool() then return end

        local inflictor = dmg:GetAttacker()

        if inflictor:GetNWString(JAVOX_PRESET, nil) ~= nil and inflictor:IsPlayer() then
            if ! isSomething(target) then
                return
            end

            if target:IsRagdoll() and target:GetNWBool("JaVox_ConfirmedDead", false) then return end

            -- TODO: make specific things through simple ents.entKill_XXX
            --- @cast inflictor Player
            if ! inflictor:Visible(target) then
                JaVox.Director:emitActionFromPlayer(inflictor, "ents.suggestKill")
                return
            end

            if table.HasValue(BLACKLISTED, dmg:GetAmmoType()) then return end
            if target:IsRagdoll() and ! target:GetNWBool("JaVox_ConfirmedDead", false) then
                JaVox.Director:emitActionFromPlayer(inflictor, "ents.kill.confirm")
                target:SetNWBool("JaVox_ConfirmedDead", true)
                return
            end

            local entityName = target:GetClass()
            local actionName = "ents.kill." .. entityName
            JaVox.Director:emitActionFromPlayer(inflictor, actionName)
        end
    end
end)
