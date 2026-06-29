concommand.Add("javox_run_action", function(ply, cmd, args, argStr)
    if not IsValid(ply) then
        return
    end
    if not args or not args[1] or not JaVox then return end

    JaVox.Director:emitActionFromPlayer(ply, argStr)
end)
