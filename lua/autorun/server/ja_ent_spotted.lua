---@diagnostic disable: undefined-field
print("Entity spotted module loaded!")

---@diagnostic disable-next-line: param-type-mismatch
local cvJaVoxSpotting = CreateConVar("javox_enable_spotting", "1", FCVAR_ARCHIVE, "Enable JaVox entity spotted actions")

---Checks if entity is something fleshy/alive
---@param ent Entity
---@return boolean
local function isSomething(ent)
    return ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot()
end

hook.Add("KeyPress", "JaVox Aim Spot Feature", function(ply, key)
    if key == IN_ATTACK2 then
        if not cvJaVoxSpotting:GetBool() then
            return
        end

        local aimedAtEntities = ents.FindInCone(ply:EyePos(), ply:GetAimVector(), 5000, math.cos(math.rad(15)))

        for i = 1, #aimedAtEntities do
            if not isSomething(aimedAtEntities[i]) then
                return
            end

            if aimedAtEntities[i]:GetNWBool("JaVox_Spotted", false) then
                return
            end

            if not aimedAtEntities[i].Disposition then return end

            -- if we hate the entity
            if aimedAtEntities[i]:Disposition(ply) == D_HT then
                --- @cast ply Player
                local entityName = aimedAtEntities[i]:GetClass()
                local actionName = "ents.entSpotted." .. entityName
                if entityName and JaVox.Crud:getActionFromModule(ply:GetNWString(JAVOX_PRESET, 'none'), actionName) ~= nil then
                    JaVox.Director:emitActionFromPlayer(ply, actionName)
                else
                    JaVox.Director:emitActionFromPlayer(ply, "ents.entSpottedGeneric")
                end

                aimedAtEntities[i]:SetNWBool("JaVox_Spotted", true)
            end
        end
    end
end)
