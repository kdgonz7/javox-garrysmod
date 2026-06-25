--- @class JaVoxCore
JaVox = JaVox or {
	vox = {},
	binds = {},
	modules = {},
	globals = {}
} -- pure, nude javox.            lol

JaVox.Version = "1.1.2"

JaVox.globals = {
	GlobalThrottleModifier = CreateConVar("javox_global_throttle_modifier", "1.0", { FCVAR_ARCHIVE, FCVAR_NOTIFY },
		"Global throttle modifier for JaVox"),
	GlobalVolumeModifier = CreateConVar("javox_global_volume_modifier", "1.0", { FCVAR_ARCHIVE, FCVAR_NOTIFY },
		"Global volume modifier for JaVox"),
	GlobalPitchModifier = CreateConVar("javox_global_pitch_modifier", "1.0", { FCVAR_ARCHIVE, FCVAR_NOTIFY },
		"Global pitch modifier for JaVox"),
	GlobalReachModifier = CreateConVar("javox_global_reach_modifier", "1.0", { FCVAR_ARCHIVE, FCVAR_NOTIFY },
		"Global reach modifier for JaVox"),
	GlobalDelayModifier = CreateConVar("javox_global_delay_modifier", "1.0", { FCVAR_ARCHIVE, FCVAR_NOTIFY },
		"Global delay modifier for JaVox"),
	PrintEveryActionPlayed = CreateConVar("javox_print_every_action_played", "0", { FCVAR_ARCHIVE, FCVAR_NOTIFY },
		"Print every action played to the console. Useful for debugging state.")
}

local JaVoxLogColor = Color(236, 102, 13)

--- Loads all lua files from a directory glob pattern with consistent logging
--- @param dirName string Directory pattern (e.g., "javoxutil", "javox")
--- @param color Color Color for the log message
--- @param typeOfFile string Type descriptor for logging (e.g., "util", "vox")
--- @return nil
local function loadFileGlob(dirName, color, typeOfFile)
	local files = file.Find(dirName .. "/*.lua", "LUA")
	for _, fname in ipairs(files) do
		local trueFile = string.format("%s/%s", dirName, fname)
		AddCSLuaFile(trueFile)
		include(trueFile)
		MsgC(JaVoxLogColor, "[JAVOX]", color_white, " loaded internal (" .. typeOfFile .. ") module: ", color, trueFile,
			"\n")
	end
end

--- Registers a module with a given payload into the global JaVox object. Note to future developers, or myself:
--- These **have** to be questionable because lua is unsafe and gmod developers just wanna have fun.
--- @param rawName string?
--- @param payload PlayerVoxModule?
--- @return nil|JaVoxError
function JaVox:registerModule(rawName, payload)
	if ! rawName then
		return JaVox:errorWithMessage(
			"Parameter `rawName` required to register pvox module. If not given, we have no identifier.")
	end;
	if ! payload then
		return JaVox:errorWithMessage(string.format(
			"Parameter `payload` required to register module '%s'.", rawName))
	end;

	-- ight. we assume everything is available.
	-- btw. this shit took way longer to figure out than i wanted.
	return JaVox.Crud:setActionModule(rawName, payload)
end

---Registers a lua module. Just a meta way to know if something is running that modifies/uses JaVox. This is optional.
---@param mod JavoLuaModule
function JaVox:registerLuaModule(mod)
	if ! mod then return JaVox:errorWithMessage("register lua module requires payload.") end
	JaVox.modules[mod.name] = mod
end

-- for things like AudioPriority where addons will use it,
-- we will load javoxutil before loading javox/ files,
-- and that's where crud, director, etc. will go.
loadFileGlob("javoxutil", Color(111, 212, 255), "util")
loadFileGlob("javox", Color(111, 212, 255), "vox")
loadFileGlob("javox_pack", Color(111, 212, 255), "VOX Packs")
