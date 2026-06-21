hook.Add("Initialize", "JaVox Initialize Function", function()
    if ! JaVox then return error("We're having some problems, Capitan Clutch!") end

    JaVox:registerModule("test", {
        displayName = "Test Module",
        actions = {
            ["weaponry"] = {
                ["reload"] = {
                    priority = AudioPriority.PLAY_ONCE_WITHOUT_DEFERRAL,

                    audioFiles = {
                        "javox/reloading1.wav",
                        "javox/reloading2.wav",
                        "javox/reloading3.wav",
                        "javox/reloading4.wav",
                        "javox/reloading5.wav",
                        "javox/reloading6.wav",
                        "javox/reloading7.wav",
                        "javox/reloading10.wav",
                        "javox/reloading12.wav",
                    },

                    delay = {
                        min = 0.2,
                        max = 0.7,
                    }
                },

                ["grenadeOut"] = {
                    priority = AudioPriority.PLAY_ONCE_WITHOUT_DEFERRAL,
                    audioFiles = {
                        "javox/frag1.wav",
                        "javox/frag2.wav",
                        "javox/frag3.wav",
                        "javox/frag4.wav",
                        "javox/frag5.wav",
                    },

                    delay = {
                        min = 0.3,
                        max = 1,
                    }
                },
            },

            ["ents"] = {
                ["entKillGeneric"] = {
                    priority = AudioPriority.PLAY_ONCE_WITHOUT_DEFERRAL,
                    delay = {
                        min = 0.3,
                        max = 1,
                    },
                    audioFiles = {
                        "javox/target1.wav",
                        "javox/target2.wav",
                        "javox/target3.wav",
                        "javox/target4.wav",
                        "javox/target5.wav",
                        "javox/target6.wav",
                        "javox/target7.wav",
                        "javox/target8.wav",
                        "javox/target9.wav",
                    }
                },

                ["specific"] = {
                    ["npc_metropolice"] = {
                        priority = AudioPriority.PLAY_ONCE_WITHOUT_DEFERRAL,
                        delay = {
                            min = 0.2,
                            max = 0.7
                        },
                        audioFiles = {
                            "javox/fa.wav"
                        }
                    }
                }
            }
        },
        callouts = {
            ["Grenade"] = {
                audioFiles = {
                    "javox/frag1.wav"
                }
            },
            ["Frag"] = {
                audioFiles = {
                    "javox/frag1.wav"
                }
            },
        }
    })
end)
