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
---     | ents.entSpottedGeneric    | Called when the Combine Soldier spots an entity.
---     | ents.entKillGeneric       | Called when the Combine Soldier kills an entity.
---     | self.fallDamage           | Called when the Combine Soldier takes fall damage.
---     | callouts.stayalert        | Called when the Combine Soldier stays alert.
---     | callouts.standingby       | Called when the Combine Soldier is standing by.
---     | weaponry.reload           | Called when the Combine Soldier reloads its weapon.
---     | weaponry.grenadeOut       | Called when the Combine Soldier throws a grenade.
---     | weaponry.jam              | Called when the Combine Soldier's weapon jams.
---     | ents.lost                 | Called when the Combine Soldier loses sight of an entity.
---     | conversational.yes        | Called when the nod module detects a "yes" response.
---     | conversational.no         | Called when the nod module detects a "no" response.


-- NOTE TO SELF: this should never occur, since we're in javox/ that means the javox module is loading... well... javox
if ! JaVox then return error("We're having some problems, Capitan Clutch!") end

local painFiles = {
    "npc/combine_soldier/pain1.wav",
    "npc/combine_soldier/pain2.wav",
    "npc/combine_soldier/pain3.wav",
}

JaVox:registerModule("combine-soldier-builtin", {
    displayName = "Stock Combine Soldier JaVOX",
    author = "mimi banks",
    description = "Push up, Push up! Combine Soldier builtin VOX module.",
    actions = {
        ["conversational"] = {
            ["yes"] = {
                priority = AudioPriority.PLAY_IMMEDIATE,
                audioFiles = {
                    "npc/combine_soldier/vo/copy.wav",
                    "npc/combine_soldier/vo/copythat.wav",
                    "npc/combine_soldier/vo/affirmative.wav",
                    "npc/combine_soldier/vo/affirmative2.wav",
                    "npc/combine_soldier/vo/echo.wav",
                    "npc/combine_soldier/vo/sightlineisclear.wav",
                },

                delay = {
                    min = 0.1,
                    max = 0.2,
                },

                throttle = {
                    after = 5,
                    min = 1,
                    max = 1,
                }
            },

            ["no"] = {
                priority = AudioPriority.PLAY_IMMEDIATE,
                audioFiles = {
                    "npc/combine_soldier/vo/confirmsectornotsterile.wav",
                    "npc/combine_soldier/vo/sectorisnotsecure.wav",
                },
                delay = {
                    min = 0.1,
                    max = 0.2,
                },
                throttle = {
                    after = 5,
                    min = 1,
                    max = 1,
                }
            },
        },

        ["ents"] = {
            -- "lost" is like the post-event of entSpottedGeneric when you lose sight of the entity.
            -- TODO: potentially have a different audio file for each type of entity lost... is that doing too much?
            -- TODO: or i could cascade upward, like if lost.npc_combine_s doesn't exist you just fall back to lost
            ["lost"] = {
                priority = AudioPriority.PLAY_ONCE_WITHOUT_DEFERRAL,
                delay = {
                    min = 0.2,
                    max = 0.9,
                },

                audioFiles = {
                    "npc/combine_soldier/vo/stayalertreportsightlines.wav",
                    "npc/combine_soldier/vo/stayalert.wav",
                    "npc/combine_soldier/vo/standingby].wav",
                    "npc/combine_soldier/vo/targetmyradial.wav",
                    "npc/combine_soldier/vo/lostcontact.wav",
                    "npc/combine_soldier/vo/readyweaponshostilesinbound.wav",
                }
            },

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
                    "npc/combine_soldier/vo/outbreak.wav",
                    "npc/combine_soldier/vo/outbreakstatusiscode.wav",
                    "npc/combine_soldier/vo/movein.wav",
                    "npc/combine_soldier/vo/engaging.wav",
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
                    "npc/combine_soldier/vo/targetcompromisedmovein.wav",
                }
            }
        },

        ["self"] = {
            ["fallDamage"] = {
                priority = AudioPriority.PLAY_ONCE_WITHOUT_DEFERRAL,
                audioFiles = painFiles,
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

            ["readyweapons"] = {
                priority = AudioPriority.PLAY_ONCE_WITHOUT_DEFERRAL,
                audioFiles = {
                    "npc/combine_soldier/vo/readyweapons.wav",
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
                    after = 1,
                    min = 2,
                    max = 4,
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
                    after = 1,
                    min = 3,
                    max = 4,
                },
            },

            -- Called when an ARC9 weapon jams.
            ["jam"] = {
                priority = AudioPriority.PLAY_IMMEDIATE,
                audioFiles = {
                    "npc/combine_soldier/vo/callhotpoint.wav",
                    "npc/combine_soldier/vo/callcontacttarget1.wav",
                    "npc/combine_soldier/vo/alert1.wav",
                    "npc/combine_soldier/vo/coverhurt.wav",
                },
                delay = {
                    min = 0.3,
                    max = 0.5,
                },
                throttle = {
                    after = 1,
                    min = 2,
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
