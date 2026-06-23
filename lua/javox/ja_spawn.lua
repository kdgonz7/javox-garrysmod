hook.Add("PlayerInitialSpawn", "JaVOX Player Spawn Variables", function(player, _)
    -- player is defined right?
    -- right?
    timer.Simple(0.5, function()
        JaVox.Director:ensurePlayerContract(player, 'none')
    end)
end)
