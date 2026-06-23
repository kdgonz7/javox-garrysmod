local NOD_WINDOW = 0.3       -- time window for nod
local NOD_THRESH = 15        -- min difference
local NOD_COUNT_REQUIRED = 3 -- number of direction changes to trigger (e.g., up -> down -> up)

local NOD_ENABLED = CreateConVar("javox_nod_enabled", "1", { FCVAR_ARCHIVE }, "Enable head nod detection")

-- Table to store tracking data for each player
---@diagnostic disable-next-line: undefined-global
local playerNodData = playerNodData or {}

hook.Add("Think", "Vox_DetectHeadNod", function()
    if not NOD_ENABLED:GetBool() then return end

    local currentTime = CurTime()

    for _, ply in ipairs(player.GetAll()) do
        if not ply:Alive() then continue end

        local plyID = ply:SteamID64() or ply:UserID()
        local currentPitch = ply:EyeAngles().p

        -- tracking data if it doesn't exist
        if not playerNodData[plyID] then
            playerNodData[plyID] = {
                lastPitch = currentPitch,
                lastDir = 0,  -- -1 for up, 1 for down, 0 for still
                history = {}, -- Holds timestamps of direction changes
                lastPeakPitch = currentPitch
            }
            continue
        end

        local data = playerNodData[plyID]
        local pitchDiff = currentPitch - data.lastPitch

        -- Clean up expired nods from the history window
        for i = #data.history, 1, -1 do
            if currentTime - data.history[i] > NOD_WINDOW then
                table.remove(data.history, i)
            end
        end

        -- Check if the player has moved their head significantly
        if math.abs(currentPitch - data.lastPeakPitch) > NOD_THRESH then
            local currentDir = (pitchDiff > 0) and 1 or -1

            -- If they reversed direction (e.g., stopped looking up and started looking down)
            if data.lastDir ~= 0 and currentDir ~= data.lastDir then
                table.insert(data.history, currentTime)
                data.lastPeakPitch = currentPitch

                if #data.history >= NOD_COUNT_REQUIRED then
                    JaVox.Director:emitActionFromPlayer(ply, "conversational.yes")
                    data.history = {}
                end
            end

            data.lastDir = currentDir
        elseif math.abs(pitchDiff) < 0.01 then
            data.lastDir = 0
            data.lastPeakPitch = currentPitch
        end

        data.lastPitch = currentPitch
    end
end)
