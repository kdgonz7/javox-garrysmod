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
                        chanceToNotPlay = 4,
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

                ["entSpottedGeneric"] = {
                    priority = AudioPriority.PLAY_ONCE_WITHOUT_DEFERRAL,
                    delay = {
                        min = 0.2,
                        max = 0.9,
                    },
                    audioFiles = {
                        "javox/contact1.wav",
                        "javox/contact2.wav",
                        "javox/contact3.wav",
                        "javox/contact4.wav",
                        "javox/contact5.wav",
                        "javox/contact6.wav",
                        "javox/contact7.wav",
                        "javox/contact8.wav",
                        "javox/contact9.wav",
                        "javox/contact10.wav",
                        "javox/contact11.wav",
                        "javox/contact12.wav",
                        "javox/contact13.wav",
                        "javox/contact14.wav",
                    }
                }
            },

            ["self"] = {
                ["fallDamage"] = {
                    priority = AudioPriority.PLAY_ONCE_WITHOUT_DEFERRAL,
                    delay = {
                        min = 0.05,
                        max = 0.1,
                        chanceToNotPlay = 3,
                    },
                    audioFiles = {
                        "javox/wounded1.wav",
                        "javox/wounded2.wav",
                        "javox/wounded3.wav",
                        "javox/wounded4.wav",
                        "javox/wounded5.wav",
                        "javox/wounded6.wav",
                        "javox/wounded7.wav",
                        "javox/wounded8.wav",
                        "javox/wounded9.wav",
                        "javox/wounded10.wav",
                        "javox/wounded11.wav",
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
    JaVox:registerModule("test2", {
        displayName = "Test Module 2",
        actions = {},
        callouts = {}
    })
    JaVox:registerModule("test3", {
        displayName = "Test Module 23",
        actions = {},
        callouts = {}
    })
    JaVox:registerModule("test3", {
        displayName = "Test Module 24",
        actions = {},
        callouts = {}
    })

    JaVox:registerModule("test24", {
        displayName = "Test Modu12312le 2",
        actions = {},
        callouts = {}
    })
    JaVox:registerModule("test13133", {
        displayName = "Test Module231132 23",
        actions = {},
        callouts = {}
    })
    JaVox:registerModule("test1313133", {
        displayName = "Test Modul131313e 24",
        actions = {},
        callouts = {}
    })
end)
