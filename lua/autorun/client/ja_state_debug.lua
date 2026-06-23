local debug_convar = CreateClientConVar("javox_debug_hud", "0", true, false, "Enables the JaVox Admin State Debugger HUD")

local JaVox_DebugState = nil

net.Receive("JaVox_SendDebugState", function()
    JaVox_DebugState = net.ReadTable()
end)

-- Timer to poll the server for fresh state data once every second
-- ONLY runs if the player is an admin and has the debug HUD turned on
timer.Create("JaVox_DebugState_Updater", 1, 0, function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    if debug_convar:GetBool() and (ply:IsAdmin() or ply:IsSuperAdmin()) then
        net.Start("JaVox_RequestDebugState")
        net.SendToServer()
    end
end)

hook.Add("HUDPaint", "JaVoxDebug", function()
    if not debug_convar:GetBool() then return end

    local ply = LocalPlayer()
    if not (ply:IsAdmin() or ply:IsSuperAdmin()) then return end

    -- if we haven't received data from the server yet
    if not JaVox_DebugState then
        draw.SimpleText("JaVox: Fetching Server State...", "DermaDefault", 15, 15, Color(255, 165, 0))
        return
    end

    draw.RoundedBox(4, 10, 10, 650, 400, Color(0, 0, 0, 200))

    local textY = 20
    draw.SimpleText("--- JaVox Server State Debugger ---", "DermaDefaultBold", 20, textY, Color(34, 197, 94))
    textY = textY + 20

    if table.IsEmpty(JaVox_DebugState) then
        draw.SimpleText("No active player state tracking data on server.", "DermaDefault", 20, textY,
            Color(200, 200, 200))
    else
        -- pretty-print our cached data row-by-row instead of dumping one massive string block
        for plyID, data in pairs(JaVox_DebugState) do
            local lineText = string.format("[%s] (%s) -> Current Audio: %s | Next Audio: %s",
                plyID,
                tostring(data.playerName or "Unknown"),
                tostring(data.currentAudio or "None"),
                tostring(data.nextAudio or "None")
            )
            local _, h = draw.SimpleText(lineText, "DermaDefault", 20, textY, Color(245, 245, 244))

            textY = textY + h + 2
            local nextLine = string.format("[%s] (%s) -> Playpool current action: %s, queue size: %d",
                plyID,
                tostring(data.playerName or "Unknown"),
                tostring(data.playPool.action or "None"),
                tostring(#data.playPool.queue or 0)
            )
            local _, h = draw.SimpleText(nextLine, "DermaDefault", 20, textY, Color(245, 245, 244))
            textY = textY + h + 2

            if textY > 380 then
                draw.SimpleText("... and more players truncated ...", "DermaDefault", 20, textY, Color(255, 100, 100))
                break
            end
        end
    end
end)
