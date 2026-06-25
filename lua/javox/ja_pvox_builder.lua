--- This is a module that builds JaVox packs from the old PVox-style filesystem builder.
--- How it works (or will at the time of writing this):
---     All PVOX packs (hopefully) reside in sound/pvox/ and were initially mounted through the `return true` statement in the main module.
---     This module will then process these packs and convert them into the new JaVox format. It will read the
---     MODULE_NAME/
---         actions/
---         callouts/ --> NOTE: to do this i might have to register them as actions... or something. idk.
---
--- It will create the pack by aliasing these default actions:
--- * death -> self.die
--- * enemy_killed -> ents.entKillGeneric
--- * enemy_spotted -> ents.entSpottedGeneric
--- * frag_out -> weaponry.grenade_out
--- * inspect -> self.talkMess
--- * pickup_weapon -> self.pickup.weapon
--- * take_damage -> self.takeDamage
--- * take_damage_in_vehicle -> self.takeDamage

print("JaVox PVOX Loader loaded")

local function loadPVOX()
    print("Loading PVOX packs...")

    local _, dirs = file.Find("sound/pvox/*", "GAME")
    for _, dirname in ipairs(dirs) do
        print("Processing PVOX directory: " .. dirname)
        --- @type PlayerVoxModule
        local moduleInformation = {
            displayName = dirname,
            author = "PVox Generator",
            description = "Converted PVOX pack for " .. dirname,
            actions = {},
            callouts = {},
            tags = { "pvox" }
        }

        local readAllAudioFilesFromDir = function(baseDir, pattern)
            local targetFiles = {}

            -- Case 1: You are using a folder wildcard like "actions/*_spotted/"
            if string.find(baseDir, "%*") then
                local pathParts = string.Explode("/", baseDir)
                local folderPattern = pathParts[#pathParts] == "" and pathParts[#pathParts - 1] or pathParts[#pathParts]

                local rootPath = string.gsub(baseDir, folderPattern .. "/?$", "")
                local _, subDirs = file.Find("sound/" .. rootPath .. "*", "GAME")

                for _, subDir in ipairs(subDirs) do
                    local searchPattern = string.gsub(folderPattern, "%*", ".*")
                    if string.match(subDir, "^" .. searchPattern .. "$") then
                        local fullFolderPath = rootPath .. subDir .. "/"
                        local files, _ = file.Find("sound/" .. fullFolderPath .. "*", "GAME")

                        for _, filename in ipairs(files) do
                            table.insert(targetFiles, fullFolderPath .. filename)
                        end
                    end
                end
            else
                if not string.EndsWith(baseDir, "/") then baseDir = baseDir .. "/" end

                local files, _ = file.Find("sound/" .. baseDir .. "*", "GAME")
                for _, filename in ipairs(files) do
                    table.insert(targetFiles, baseDir .. filename)
                end
            end

            return targetFiles
        end

        moduleInformation.actions = {
            ["weaponry"] = {
                ["reload"] = {
                    priority = AudioPriority.PLAY_ONCE_WITHOUT_DEFERRAL,
                    audioFiles = readAllAudioFilesFromDir("pvox/" .. dirname .. "/actions/reload/"),
                },

                ["grenade_out"] = {
                    priority = AudioPriority.PLAY_ONCE_WITHOUT_DEFERRAL,
                    audioFiles = readAllAudioFilesFromDir("pvox/" .. dirname .. "/actions/frag_out/"),
                },
            },

            ["self"] = {
                ["pickup"] = {
                    ["weapon"] = {
                        priority = AudioPriority.PLAY_ONCE_WITHOUT_DEFERRAL,
                        audioFiles = readAllAudioFilesFromDir("pvox/" .. dirname .. "/actions/pickup_weapon/"),
                    },
                },

                ["damage"] = {
                    priority = AudioPriority.PLAY_ONCE_WITHOUT_DEFERRAL,
                    audioFiles = readAllAudioFilesFromDir("pvox/" .. dirname .. "/actions/take_damage/"),
                    ["fall"] = {
                        priority = AudioPriority.PLAY_ONCE_WITHOUT_DEFERRAL,
                        audioFiles = readAllAudioFilesFromDir("pvox/" .. dirname .. "/actions/take_damage/"),
                    },
                },

                ["die"] = {
                    priority = AudioPriority.PLAY_ONCE_WITHOUT_DEFERRAL,
                    audioFiles = readAllAudioFilesFromDir("pvox/" .. dirname .. "/actions/death/"),
                }
            },

            ["ents"] = {
                ["entSpottedGeneric"] = {
                    priority = AudioPriority.PLAY_ONCE_WITHOUT_DEFERRAL,
                    delay = {
                        min = 0.2,
                        max = 0.9,
                    },

                    audioFiles =
                        readAllAudioFilesFromDir("pvox/" .. dirname .. "/actions/*_spotted/"),

                },

                ["entKillGeneric"] = {
                    priority = AudioPriority.PLAY_ONCE_WITHOUT_DEFERRAL,
                    delay = {
                        min = 0.2,
                        max = 0.9,
                    },

                    audioFiles =
                        readAllAudioFilesFromDir("pvox/" .. dirname .. "/actions/*_killed/"),

                },
            }
        }

        JaVox:registerModule(dirname, moduleInformation)
    end
end

loadPVOX()
