util.AddNetworkString("JaVox_RequestDebugState")
util.AddNetworkString("JaVox_SendDebugState")

net.Receive("JaVox_RequestDebugState", function(len, ply)
    if not IsValid(ply) or not (ply:IsAdmin() or ply:IsSuperAdmin()) then return end
    local stateToSend = JaVox and JaVox.State and JaVox.State.players or {}

    net.Start("JaVox_SendDebugState")
    net.WriteTable(stateToSend)
    net.Send(ply)
end)
