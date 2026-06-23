---@meta

--- @enum AudioPriority
AudioPriority = {
	--- The action will play after a current one finishes. Used for things like reloading.
	PLAY_DEFERRED = 1,

	--- The action will override the current playing one, and play.
	PLAY_IMMEDIATE = 2,

	--- The action will play once, and prevent execution if it was just played.
	PLAY_UNIQUELY = 4,

	--- The action will play, and ignore any input until completed (or estimated completion, if sound files are not compatible)
	--- this is the `default` sound option on all of the filesystem-based actions.
	PLAY_ONCE_WITHOUT_DEFERRAL = 5,
}

--- @class PlayerVoxAction A playervox action contains a name and audiofiles, bound to by the PlayerVox object.
--- @field audioFiles string|string[]? The audio files of this action. Can be singular, or multiple.
--- @field priority AudioPriority? The priority of the sound. See [AudioPriority]
--- @field volume number? The volume of the sound. Default should be `100`.
--- @field pitch number? Pitch modification for the sound. (0-255)
--- @field reach number? How far the sound reaches. Default 100.
--- @field delay DelaySettings? How much the sound should delay.
--- @field throttle ThrottleSettings? Settings for defining a sound's throttle action.

--- @class ThrottleSettings
--- @field min number The minimum amount of time it will throttle for.
--- @field max number The maximum amount of time it will throttle for.
--- @field after number How many calls of this particular action does it take to require throttling?
--- @field willAffectOtherActions boolean? Will this throttle affect the calling of other actions?

--- @class DelaySettings
--- @field min number The minimum time it should take to play an audio.
--- @field max number The maximum time it should take to play an audio.
--- @field chanceToNotPlay number? The chance that the audio just won't play.

--- The JaVOX core defines modules and playermodel binds. Each action can be defined through modules, which are bits of code that are
--- meant to execute jaVox upon a particular action.
--- @class JaVoxCore
--- @field vox table<string, PlayerVoxModule>
--- @field binds table<string, string>
--- @field modules table<string, JavoLuaModule>


--- @class PlayerVoxModule Defines a JaVox player vocal module.
--- @field displayName string The display name of the module
--- @field author string | string[] ? The author(s) of the Vox module.
--- @field description string? The description of the Vox itself. (game it's from, etc.)
--- @field actions table<string, PlayerVoxAction|any> The actions that can be ran by this module. Functions provide abstractions to access these. Note that actions are designed to be expanded upon, and follow an `any in any out` architecture. A vox module can define an abstract vocal execution and have another addon of the same owner run it.
--- @field callouts table<string, string>
--- @field tags? string[] Tags for the module.

--- @class JavoLuaModule
--- @field name string
--- @field description string

--- @class JaVoxError
--- @field errorId string The error's Id. (JAV_NO_MODULE)
--- @field errorMessage string The error's message.

--- @class Bind
--- @field module string
