--- JaVox's listener.
--- Client -> Callout Func -> Server calls from player

util.AddNetworkString("JaVox_EmitCallout")
util.AddNetworkString("JaVox_ChangePlayerPreset")
util.AddNetworkString("JaVox_SetPlayermodelBind")

-- /preset/[id]
net.Receive("JaVox_ChangePlayerPreset", function(len, ply)
    local id = net.ReadString()
    ply:SetNWString(JAVOX_PRESET, id)
    -- FIXME: all entindex calls will be replaced with steamid64
    JaVox.State:clearPlayerQueue(ply:EntIndex())
    -- this ...should... save the preset to the player's data
    ply:SetPData("javox_preset", ply:GetNWString(JAVOX_PRESET, "none"))
end)

-- /callout/emit/[name]
net.Receive("JaVox_EmitCallout", function(len, ply)
    local calloutName = net.ReadString()
    JaVox.Director:emitCalloutFromPlayer(ply, calloutName)
end)

-- /playermodel/bind/[model]/[pack]
net.Receive("JaVox_SetPlayermodelBind", function(len, ply)
    local model = net.ReadString()
    local pack = net.ReadString()
    JaVox.Crud:setPlayermodelBindFor(ply, model, pack)
    -- i wonder if playermodels should be player-specific?
    -- that makes the most sense, right?
    -- for example, each player could have their own set of playermodels and their associated VOX packs.
    -- yeah. that's what ima do.


    PrintTable(JaVox)
end)
