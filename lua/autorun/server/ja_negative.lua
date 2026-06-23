local SHAKE_WINDOW = 0.3       -- time window to complete the head shake
local SHAKE_THRESH = 22        -- minimum yaw change (degrees) to count as a deliberate move
local SHAKE_COUNT_REQUIRED = 3 -- l > r > l
local SHAKE_THROTTLE = 2.0     -- no spamming javox

local NEGATIVE_NOD_ENABLED = CreateConVar("javox_negative_nod_enabled", "1", { FCVAR_ARCHIVE },
    "Enable head nod detection for negative responses")

-- tracking data for all players on the server
---@diagnostic disable-next-line: undefined-global
local playerShakeData = playerShakeData or {}

hook.Add("Think", "JaVox_DetectServerHeadShake", function()
    if not NEGATIVE_NOD_ENABLED:GetBool() then return end

    local currentTime = CurTime()

    for _, ply in ipairs(player.GetAll()) do
        if not IsValid(ply) or not ply:Alive() then continue end

        local plyID = ply:SteamID64() or ply:UserID()
        local currentYaw = ply:EyeAngles().y -- Yaw is left/right (-180 to 180)

        -- Initialize tracking data if it doesn't exist for this player
        if not playerShakeData[plyID] then
            playerShakeData[plyID] = {
                lastYaw = currentYaw,
                lastDir = 0,
                history = {},
                lastPeakYaw = currentYaw,
                nextAllowedShake = 0
            }
            continue
        end

        local data = playerShakeData[plyID]
        if currentTime < data.nextAllowedShake then continue end

        -- handle the -180 to 180 degree snap boundary
        local yawDiff = currentYaw - data.lastYaw
        if yawDiff > 180 then yawDiff = yawDiff - 360 elseif yawDiff < -180 then yawDiff = yawDiff + 360 end

        local peakDiff = currentYaw - data.lastPeakYaw
        if peakDiff > 180 then peakDiff = peakDiff - 360 elseif peakDiff < -180 then peakDiff = peakDiff + 360 end

        for i = #data.history, 1, -1 do
            if currentTime - data.history[i] > SHAKE_WINDOW then
                table.remove(data.history, i)
            end
        end

        if math.abs(peakDiff) > SHAKE_THRESH then
            local currentDir = (yawDiff > 0) and 1 or -1

            if data.lastDir ~= 0 and currentDir ~= data.lastDir then
                table.insert(data.history, currentTime)
                data.lastPeakYaw = currentYaw

                if #data.history >= SHAKE_COUNT_REQUIRED then
                    data.history = {}
                    data.nextAllowedShake = currentTime + SHAKE_THROTTLE

                    JaVox.Director:emitActionFromPlayer(ply, "conversational.no")
                end
            end

            data.lastDir = currentDir
        elseif math.abs(yawDiff) < 0.01 then
            data.lastDir = 0
            data.lastPeakYaw = currentYaw
        end

        data.lastYaw = currentYaw
    end
end)

-- Clean up memory when a player leaves the server
hook.Add("PlayerDisconnected", "JaVox_CleanShakeData", function(ply)
    local plyID = ply:SteamID64() or ply:UserID()
    if playerShakeData[plyID] then
        playerShakeData[plyID] = nil
    end
end)
