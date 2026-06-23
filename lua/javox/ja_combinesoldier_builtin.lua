--- A builtin module for the Combine Soldier NPC.
--- Here's a few things for me to remember, and for vscode-todo:
--TODO: just to remember this is here.

--- This module is temporarily the de-facto standard for the actions that come with JaVox.
--- It contains the default audio files and callouts for the Combine Soldier.
---
--- Since actions are dynamically dispatched, this module is meant to be a roadmap to add extra actions, all while having
--- audio files built-in to Garry's Mod. However, this will still be put into its own addon later.
---
--- Actions covered so far:
---     | ents.entSpottedGeneric | Called when the Combine Soldier spots an entity.
---     | ents.entKillGeneric    | Called when the Combine Soldier kills an entity.
---     | self.fallDamage        | Called when the Combine Soldier takes fall damage.
---     | callouts.stayalert     | Called when the Combine Soldier stays alert.
---     | callouts.standingby    | Called when the Combine Soldier is standing by.
---     | weaponry.reload        | Called when the Combine Soldier reloads its weapon.
---     | weaponry.grenadeOut    | Called when the Combine Soldier throws a grenade.


-- NOTE TO SELF: this should never occur, since we're in javox/ that means the javox module is loading... well... javox
if ! JaVox then return error("We're having some problems, Capitan Clutch!") end

JaVox:registerModule("combine-soldier-builtin", {
    displayName = "Stock Combine Soldier JaVOX",
    author = "mimi banks",
    description = "Push up, Push up! Combine Soldier builtin VOX module.",
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
                    "npc/combine_soldier/vo/contactconfim.wav", -- note: why does hl2 have a typo?
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
                -- delay = {
                --     min = 0.3,
                --     max = 0.5,
                -- },
                -- throttle = {
                --     after = 1,
                --     min = 2,
                --     max = 4,
                -- },
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
                    after = 1,
                    min = 3,
                    max = 4,
                },
            }
        }
    },
    callouts = {
        ["Stay Alert"] = "callouts.stayalert",
        ["Standing By"] = "callouts.standingby",
    }
})
