JaVox.FSBuilder:BuildFromFilesystem({
    name = "my_module",
    path = "path/to/sounds",
    author = "My Name",
    description = "A custom sound module.",
    tags = { "custom", "sounds" },
    defaults = {
        priority = AudioPriority.PLAY_ONCE_WITHOUT_DEFERRAL,
        volume = 100,
        pitch = 100,
        reach = 100,
        delay = {
            min = 0,
            max = 0.2
        },
        throttle = {
            min = 2,
            max = 5
        }
    },

    -- patterns are new ways to redirect actions based on regex matching
    patterns = {
        ["^ents%.kill%.npc_.*zombie"] = "ents.kill.zombie",
    }
})
