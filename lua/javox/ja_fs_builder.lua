--TODO
--- JaVox filesystem constructor
--- with sensible defaults, builds a filesystem-based vox pack for JaVox.
--- registers actions through a given directory, such as javox/packs/mypack1/actions
--- and loads the corresponding audio files. Callouts are handled manually still using the JaVox.Crud API.

JaVox.FSBuilder = JaVox.FSBuilder or {}

local defaults = {
    priority = AudioPriority.PLAY_ONCE_WITHOUT_DEFERRAL,
    volume = 100,
    pitch = 100,
    reach = 100,
    delay = {
        min = 0,
        max = 0.2
    },
    throttle = {
        after = 3,
        min = 2,
        max = 5,
    }
}

--- @class JaVoxFSBuilderOptions
--- @field name string The name of the module.
--- @field path string The path to the module's actions. e.g. "sound/javox/packs/mypack1"
--- @field author string|string[]? The author(s) of the module.
--- @field description string? The description of the module.
--- @field tags string[]? Tags for the module.
--- @field defaults PlayerVoxAction Default values for the module's actions.

--- Builds a vox pack from a filesystem directory.
--- @param options JaVoxFSBuilderOptions
function JaVox.FSBuilder:BuildFromFilesystem(options)
    local moduleName = options.name
    if not moduleName then return JaVox:errorWithMessage("FSBuilder:BuildFromFilesystem requires a name.") end

    local searchPath = options.path
    if not searchPath then return JaVox:errorWithMessage("FSBuilder:BuildFromFilesystem requires a path.") end

    --- @type PlayerVoxModule
    local newModule = {
        displayName = moduleName,
        author = options.author or "Unknown",
        description = options.description or "A JaVox pack.",
        actions = {},
        callouts = {},
        tags = options.tags or {}
    }

    ---Iterate directory and gather audio files, as well as subdirectory actions.
    ---@param currentPath any
    ---@param currentTable any
    local function processDirectory(currentPath, currentTable)
        local subFiles, subDirs = file.Find("sound/" .. currentPath .. "/*", "GAME")
        local audioFiles = {}

        for _, f in ipairs(subFiles) do
            if not file.IsDir(currentPath .. "/" .. f, "GAME") then
                table.insert(audioFiles, currentPath .. "/" .. f)
            end
        end

        if #audioFiles > 0 then
            -- this directory contains audio files, so it's an action.
            -- we don't need to create a sub-table for the action name.
            -- ... the parent has already created a table for us with the correct action name.
            --- @type PlayerVoxAction
            local actionData = {
                audioFiles = audioFiles,
                priority = options.defaults.priority or defaults.priority,
                volume = options.defaults.volume or defaults.volume,
                pitch = options.defaults.pitch or defaults.pitch,
                reach = options.defaults.reach or defaults.reach,
                delay = options.defaults.delay or defaults.delay,
                throttle = options.defaults.throttle or defaults.throttle
            }

            -- put action data into the current table
            for k, v in pairs(actionData) do
                currentTable[k] = v
            end
        end

        -- check directories.
        -- if not table make it.
        -- process that one too.
        for _, dirName in ipairs(subDirs) do
            if not currentTable[dirName] then
                currentTable[dirName] = {}
            end

            processDirectory(currentPath .. "/" .. dirName, currentTable[dirName])
        end
    end

    processDirectory(searchPath, newModule.actions)

    -- After processing, if an action has only one sound, convert it to a string.
    local function simplifyAudioFiles(tbl)
        for _, v in pairs(tbl) do
            if type(v) == "table" then
                if v.audioFiles and #v.audioFiles == 1 then
                    v.audioFiles = v.audioFiles[1]
                elseif v.audioFiles and #v.audioFiles > 0 then
                    -- It's an action, but has multiple files, so we don't simplify, but we also don't recurse further.
                else
                    simplifyAudioFiles(v) -- It's a category, recurse.
                end
            end
        end
    end

    simplifyAudioFiles(newModule.actions)

    JaVox.Crud:setActionModule(moduleName, newModule)
    print(string.format("[JaVox] Built and registered module '%s' from filesystem.", moduleName))
end

-- example usage:
-- JaVox.FSBuilder:BuildFromFilesystem({
--     name = "my_module",
--     path = "path/to/sounds",
--     author = "My Name",
--     description = "A custom sound module.",
--     tags = {"custom", "sounds"}
-- })
