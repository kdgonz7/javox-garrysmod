--- JaVox's listener.
--- Client -> Callout Func -> Server calls from player

util.AddNetworkString("JaVox_EmitCallout")
util.AddNetworkString("JaVox_ChangePlayerPreset")

-- /preset/[id]
net.Receive("JaVox_ChangePlayerPreset", function(len, ply)
    local id = net.ReadString()
    ply:SetNWString(JAVOX_PRESET, id)
    JaVox.State:clearPlayerQueue(ply:EntIndex())
end)

-- /callout/emit/[name]
net.Receive("JaVox_EmitCallout", function(len, ply)
    local calloutName = net.ReadString()
    JaVox.Director:emitCalloutFromPlayer(ply, calloutName)
end)
