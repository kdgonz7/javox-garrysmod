--- JaVox's listener.
--- Client -> Callout Func -> Server calls from player

util.AddNetworkString("JaVox_EmitCallout")
util.AddNetworkString("JaVox_ChangePlayerPreset")
-- util.AddNetworkString("JaVox_SetPlayermodelBind")

-- /preset/[id]
net.Receive("JaVox_ChangePlayerPreset", function(len, ply)
    local id = net.ReadString()
    ply:SetNWString(JAVOX_PRESET, id)
    -- FIXME: all entindex calls will be replaced with steamid64
    JaVox.State:clearPlayerQueue(ply:SteamID64())
    -- this ...should... save the preset to the player's data
    ply:SetPData("javox_preset", ply:GetNWString(JAVOX_PRESET, "none"))
end)

-- /callout/emit/[name]
net.Receive("JaVox_EmitCallout", function(len, ply)
    local calloutName = net.ReadString()
    JaVox.Director:emitCalloutFromPlayer(ply, calloutName)
end)

-- /action/emit/[name]
net.Receive("JaVox_EmitAction", function(len, ply)
    local actionName = net.ReadString()
    JaVox.Director:emitActionFromPlayer(ply, actionName)
end)
