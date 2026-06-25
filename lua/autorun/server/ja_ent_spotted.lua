util.AddNetworkString("JaVox_EntLost")
util.AddNetworkString("JaVox_EntSpotted")

---@diagnostic disable: undefined-field
print("Entity spotted module loaded!")

---@diagnostic disable-next-line: param-type-mismatch
local cvJaVoxSpotting = CreateConVar("javox_enable_spotting", "1", { FCVAR_ARCHIVE, FCVAR_NOTIFY },
    "Enable JaVox entity spotted actions")
---@diagnostic disable-next-line: param-type-mismatch
local cvJaVoxResetThreshold = CreateConVar("javox_reset_threshold", "6", { FCVAR_ARCHIVE, FCVAR_NOTIFY },
    "Distance threshold for resetting spotted flag")
local cvJaVoxSendToAllPlayers = CreateConVar("javox_send_to_all_players", "1", { FCVAR_ARCHIVE, FCVAR_NOTIFY },
    "Send spotted entity notifications to all players")
local cvJaVoxEnableLost = CreateConVar("javox_enable_lost", "1", { FCVAR_ARCHIVE, FCVAR_NOTIFY },
    "Enable JaVox entity lost actions")

--- @class ServerEntQueue A queue that manages spotted entities.
--- @field Entities table<number, EntitySpotMetadata>
---@diagnostic disable-next-line: undefined-global
local ServerEntQueue = ServerEntQueue or {
    Entities = {}
}

---Spot an entity (register them into the queue/state tracker)
---@param ent Entity
---@param spotter Player
function ServerEntQueue:Spot(ent, spotter)
    self.Entities[ent:EntIndex()] = {
        spotted = true,
        lastSeen = CurTime(),
        spotter = spotter
    }
end

--- Is the entity spotted?
--- @param ent Entity
--- @return boolean
function ServerEntQueue:IsSpotted(ent)
    local entIndex = ent:EntIndex()
    return self.Entities[entIndex] and self.Entities[entIndex].spotted
end

---Reset the spotted flag for an entity
---@param ent Entity
---@return nil
function ServerEntQueue:Reset(ent)
    self.Entities[ent:EntIndex()] = nil
end

---Update the last seen time for an entity
---@param ent Entity
---@return nil
function ServerEntQueue:UpdateLastSeen(ent)
    local entIndex = ent:EntIndex()
    if self.Entities[entIndex] then
        self.Entities[entIndex].lastSeen = CurTime()
    end
end

function ServerEntQueue:GetSpotter(ent)
    local entIndex = ent:EntIndex()
    if self.Entities[entIndex] then
        return self.Entities[entIndex].spotter
    end
end

function ServerEntQueue:GetLastSeen(ent)
    local entIndex = ent:EntIndex()
    if self.Entities[entIndex] then
        return self.Entities[entIndex].lastSeen
    end
end

---@class EntitySpotMetadata
---@field spotted boolean
---@field lastSeen number
---@field spotter Player

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
                continue
            end

            if ServerEntQueue:IsSpotted(aimedAtEntities[i]) then
                continue
            end

            if not ply:Visible(aimedAtEntities[i]) then
                continue
            end

            if not aimedAtEntities[i].Disposition then continue end

            -- if we hate the entity
            if aimedAtEntities[i]:Disposition(ply) == D_HT then
                --- @cast ply Player
                local entityName = aimedAtEntities[i]:GetClass()

                JaVox.Director:emitActionFromPlayer(ply, "ents.spotted." .. entityName)

                ServerEntQueue:Spot(aimedAtEntities[i], ply)

                net.Start("JaVox_EntSpotted")
                net.WriteEntity(aimedAtEntities[i])

                if cvJaVoxSendToAllPlayers:GetBool() then -- if settings
                    net.Broadcast()                       -- broadcast it
                else                                      -- otherwise
                    net.Send(ply)                         -- send to the player
                end
            end
        end
    end
end)

-- NEW: when entities that have been spotted are no longer in view after
-- a certain distance threshold is exceeded
---Reset the spotted flag for an entity if it has not been seen in a while
hook.Add("Think", "JaVox_ResetSpottedFlag", function()
    if not cvJaVoxEnableLost:GetBool() then
        return
    end

    local currentTime = CurTime()

    for _, ent in ipairs(ents.GetAll()) do
        if not isSomething(ent) then continue end
        if not ServerEntQueue:IsSpotted(ent) then continue end

        if not ent:Alive() then
            ServerEntQueue:Reset(ent)
            print("entity not alive")
            continue
        end

        local spotter = ServerEntQueue:GetSpotter(ent)

        if ! IsValid(spotter) then
            ServerEntQueue:Reset(ent)
            continue
        end

        if ServerEntQueue:IsSpotted(ent) then      -- ent is registered
            if spotter:Visible(ent) then           -- if visible
                ServerEntQueue:UpdateLastSeen(ent) -- we still see em
                continue
            end

            local timeSinceLastSeen = currentTime - ServerEntQueue:GetLastSeen(ent) -- time since last seen
            if timeSinceLastSeen > cvJaVoxResetThreshold:GetInt() then              -- if time since last seen exceeds threshold
                ServerEntQueue:Reset(ent)                                           -- reset it. we lost em.
                net.Start("JaVox_EntLost")
                net.WriteEntity(ent)
                net.Send(spotter)

                JaVox.Director:emitActionFromPlayer(spotter, "ents.lost") -- emit lost action
                continue
            end
        end
    end
end)
hook.Add("EntityTakeDamage", "JaVox_EntityTakeDamage", function(ent, dmginfo)
    if not isSomething(ent) then return end
    if not ServerEntQueue:IsSpotted(ent) then return end

    if ent:Health() - dmginfo:GetDamage() <= 0 then
        ServerEntQueue:Reset(ent)
    end
end)
