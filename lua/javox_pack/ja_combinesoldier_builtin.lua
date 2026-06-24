--- A builtin module for the Combine Soldier NPC.
--- Here's a few things for me to remember, and for vscode-todo:
--TODO: just to remember this is here.

--- This module is temporarily the de-facto standard for the actions that come with JaVox.
--- It contains the default audio files and callouts for the Combine Soldier.
---
--- Since actions are dynamically dispatched, this module is meant to be a roadmap to add extra actions, all while having
--- audio files built-in to Garry's Mod. However, this will still be put into its own addon later.
---
--- ## Notes
--- * For actions like self.damage.fall, if you supply self.damage with audio files, then you don't need to provide audio files for self.damage.fall.
--- * If you register a callout into the callout table then you will have to supply an action. (example Ready Weapons references callouts.readyweapons)
---
--- Actions covered so far:
---     | ents.lost                     | Action called when an entity is lost (loses sight of an entity).
---     | ents.spotted.<entClass>       | Action called when an entity is spotted (spots an entity).
---     | ents.kill.<entClass>          | Action called when an entity is killed (kills an entity).
---     | self.damage.fall              | Action called when fall damage is taken.
---     | callouts.stayalert            | Action called when the NPC needs to stay alert.
---     | callouts.standingby           | Action called when the NPC is standing by.
---     | weaponry.reload               | Action called when the weapon is reloaded.
---     | weaponry.grenadeOut           | Action called when a grenade is thrown.
---     | weaponry.jam                  | Action called when the weapon jams.
---     | conversational.yes            | Action called when a "yes" response is detected.
---     | conversational.no             | Action called when a "no" response is detected.
---
--- And even binds some callouts:
---     | callouts.stayalert                | Action bound for stay alert (e.g. "Stay alert, report sidelines").
---     | callouts.standingby               | Action bound for standing by (e.g. "Standing by, report status").
---     | callouts.readyweapons             | Action bound for readying weapons (e.g. "Ready weapons").


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
            -- "lost" is like the post-event of ents.spotted when you lose sight of the entity.
            -- TODO: potentially have a different audio file for each type of entity lost... is that doing too much?
            -- TODO: or i could cascade upward, like if lost.npc_combine_s doesn't exist you just fall back to lost
            ["lost"] = {
                priority = AudioPriority.PLAY_ONCE_WITHOUT_DEFERRAL,
                delay = {
                    min = 0.2,
                    max = 0.4,
                },

                audioFiles = {
                    "npc/combine_soldier/vo/stayalertreportsightlines.wav",
                    "npc/combine_soldier/vo/stayalert.wav",
                    "npc/combine_soldier/vo/standingby.wav",
                    "npc/combine_soldier/vo/targetmyradial.wav",
                    "npc/combine_soldier/vo/lostcontact.wav",
                    "npc/combine_soldier/vo/readyweaponshostilesinbound.wav",
                }
            },

            ["spotted"] = {
                priority = AudioPriority.PLAY_ONCE_WITHOUT_DEFERRAL,
                delay = {
                    min = 0.2,
                    max = 0.3,
                },

                audioFiles = {
                    "npc/combine_soldier/vo/contact.wav",
                    "npc/combine_soldier/vo/contactconfirm.wav",
                    "npc/combine_soldier/vo/contactconfirmprosecuting.wav",
                    "npc/combine_soldier/vo/outbreak.wav",
                    "npc/combine_soldier/vo/outbreakstatusiscode.wav",
                    "npc/combine_soldier/vo/movein.wav",
                    "npc/combine_soldier/vo/engaging.wav",
                },

                -- note: you can now have ["npc_combine_s"] here. it supports it
            },

            ["kill"] = {
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
            ["damage"] = {
                priority = AudioPriority.PLAY_ONCE_WITHOUT_DEFERRAL,
                audioFiles = painFiles,
                delay = {
                    min = 0.1,
                    max = 0.1,
                },

                throttle = {
                    after = 2,
                    min = 1,
                    max = 3,
                },


                ["fall"] = {
                    priority = AudioPriority.PLAY_ONCE_WITHOUT_DEFERRAL,
                    audioFiles = painFiles,
                    delay = {
                        min = 0.1,
                        max = 0.1,
                    },
                    throttle = {
                        after = 2,
                        min = 1,
                        max = 3,
                    },
                }
            },
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
                    "npc/combine_soldier/vo/standingby.wav",
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
                    min = 0.1,
                    max = 0.2,
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
        ["Ready Weapons"] = "callouts.readyweapons",
    }
})
