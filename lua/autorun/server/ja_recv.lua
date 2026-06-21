--- JaVox's basic networking listener.
---     Does nothing but ensure callouts from client can pass and call.
--- Client -> Callout Func -> Server calls from player

util.AddNetworkString("JaVox_EmitCallout")

net.Receive("JaVox_EmitCallout", function(len, ply)
    local calloutName = net.ReadString()
    JaVox.Director:emitCalloutFromPlayer(ply, calloutName)
end)
