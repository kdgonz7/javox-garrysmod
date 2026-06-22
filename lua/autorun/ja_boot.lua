hook.Add("Initialize", "JaVox Initialize Function", function()
    if ! JaVox then return error("We're having some problems, Capitan Clutch!") end

    JaVox:registerModule("test", {
        displayName = "Test Module",
        description = "INS2 Voicelines.",
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
                    },

                    throttle = {
                        after = 2,
                        min = 6,
                        max = 7,
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
                    },

                    -- throttle grenadeOut after 1 callout, for ~2 seconds
                    throttle = {
                        after = 1,
                        min = 3,
                        max = 4,
                    },
                },
            },

            ["ents"] = {
                ["entKillGeneric"] = {
                    priority = AudioPriority.PLAY_ONCE_WITHOUT_DEFERRAL,
                    delay = {
                        min = 0.1,
                        max = 0.3,
                        chanceToNotPlay = 2,
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
                        min = 0.1,
                        max = 0.2,
                        chanceToNotPlay = 2,
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
            ["Reloading!"] = "weaponry.reload",
            ["Entity Killed"] = "ents.entKillGeneric",
        }
    })

    JaVox:registerModule("combine-soldier", {
        displayName = "Stock Combine Soldier JaVOX",
        author = "mimi banks",
        description = "Push up, Push up!",
        actions = {
            ["ents"] = {
                ["entSpottedGeneric"] = {
                    priority = AudioPriority.PLAY_ONCE_WITHOUT_DEFERRAL,
                    delay = {
                        min = 0.2,
                        max = 0.9,
                    },

                    audioFiles = {
                        "npc/combine_soldier/vo/contact.wav",
                        "npc/combine_soldier/vo/contactconfim.wav",
                        "npc/combine_soldier/vo/contactconfirmprosecuting.wav",
                    }
                },

                ["entKillGeneric"] = {
                    priority = AudioPriority.PLAY_ONCE_WITHOUT_DEFERRAL,
                    delay = {
                        min = 0.2,
                        max = 0.9,
                    },
                    audioFiles = {
                        "npc/combine_soldier/vo/contained.wav",
                        "npc/combine_soldier/vo/containmentproceeding.wav",
                        "npc/combine_soldier/vo/overwatchreportspossiblehostiles.wav",
                    }
                }
            },
            ["self"] = {
                ["fallDamage"] = {
                    priority = AudioPriority.PLAY_ONCE_WITHOUT_DEFERRAL,
                    audioFiles = {
                        "HL1/fvox/health_dropping.wav",
                        "HL1/fvox/health_dropping2.wav"
                    },
                    delay = {
                        min = 0.2,
                        max = 0.9,
                    },
                    throttle = {
                        after = 2,
                        min = 1,
                        max = 3,
                    }
                }
            },
            ["callouts"] = {
                ["stayalert"] = {
                    priority = AudioPriority.PLAY_ONCE_WITHOUT_DEFERRAL,
                    audioFiles = {
                        "npc/combine_soldier/vo/stayalert.wav",
                        "npc/combine_soldier/vo/stayalertreportsightlines.wav",

                    }
                },
                ["standingby"] = {
                    priority = AudioPriority.PLAY_ONCE_WITHOUT_DEFERRAL,
                    audioFiles = {
                        "npc/combine_soldier/vo/standingby].wav",
                    }
                },
            },
            ["weaponry"] = {
                ["reload"] = {
                    priority = AudioPriority.PLAY_ONCE_WITHOUT_DEFERRAL,
                    audioFiles = {
                        "npc/combine_soldier/vo/coverme.wav",
                        "npc/combine_soldier/vo/cover.wav",
                        "npc/combine_soldier/vo/displace.wav",
                        "npc/combine_soldier/vo/dash.wav",
                    },
                    delay = {
                        min = 0.3,
                        max = 0.5,
                    },
                    throttle = {
                        after = 4,
                        min = 1,
                        max = 2,
                    },
                },

                ["grenadeOut"] = {
                    priority = AudioPriority.PLAY_ONCE_WITHOUT_DEFERRAL,
                    audioFiles = {
                        "npc/combine_soldier/vo/dagger.wav",
                        "npc/combine_soldier/vo/flash.wav",
                        "npc/combine_soldier/vo/displace.wav",
                        "npc/combine_soldier/vo/dash.wav",
                    },
                    delay = {
                        min = 0.3,
                        max = 0.5,
                    },
                    throttle = {
                        after = 4,
                        min = 1,
                        max = 2,
                    },
                }
            }
        },
        callouts = {
            ["Stay Alert"] = "callouts.stayalert",
            ["Standing By"] = "callouts.standingby",
        }
    })
end)
