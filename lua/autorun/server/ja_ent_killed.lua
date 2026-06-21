--- JaVox Entity Kill Module
---
--- Implements:
---     | ents.suggestKill              When an entity is killed, but the player can not see them.
---     | ents.entKillGeneric           When an entity is killed and the player can see it.
---     | ents.entConfirmKillGeneric    When a ragdoll (assumedly dead body) is shot.

local BLACKLISTED = {
    -1,
}

print("Entity kill module loaded!")

local function isSomething(ent)
    return ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot() or ent:IsRagdoll()
end

hook.Add("EntityTakeDamage", "JaVox built-in damage hook", function(target, dmg)
    if target:Health() - dmg:GetDamage() <= 0 then
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
                print("invisible")
                return
            end

            if table.HasValue(BLACKLISTED, dmg:GetAmmoType()) then return end
            if target:IsRagdoll() and ! target:GetNWBool("JaVox_ConfirmedDead", false) then
                JaVox.Director:emitActionFromPlayer(inflictor, "ents.entConfirmKillGeneric") -- TODO: here too with specific.
                -- TODO: if the user wants to treeshake into entKillGeneric they can do that.
                target:SetNWBool("JaVox_ConfirmedDead", true)
                return
            end

            local entityName = target:GetClass()
            local actionName = "ents.specific." .. entityName
            if entityName and JaVox.Crud:getActionFromModule(inflictor:GetNWString(JAVOX_PRESET, 'none'), actionName) ~= nil then
                JaVox.Director:emitActionFromPlayer(inflictor, actionName)
                return
            end

            JaVox.Director:emitActionFromPlayer(inflictor, "ents.entKillGeneric")
        end
    end
end)
