# JaVOX

A contextual dialogue engine that originally began as a rewrite of PVox, but expanded into its own audio engine with delays, throttling, a dedicated timeline for incredible performance enhancements, and more.

## JaVox Docs

### Global JV Object

```lua
JaVox = {
	vox = {},
	binds = {},
	modules = {},
} -- pure, nude javox.            lol
```

The JaVox system object rests in both the client and server realms, primarily for proof of existence.

A small breakdown:
- `vox` manages the vox modules.
- `binds` manages playermodel binds
- `modules` manages the lua module system. **Potentially will receive a deletion**

### JaVox Sub-Objects

- `JaVox.Director`: Manages player audio outputs, anything that is sound-related is here.
- `JaVox.State`: Manages player states. This is what manages priorities (to play a sound after the current one, play and cut this one off, wait to receive another input, or play it randomly.)
- `JaVox.Crud`: Manages CRUD operations for the JaVox system.

### JaVox Default Action Modules

- `ja_arc9_jam.lua` -> (beware: slightly spammy) ARC9 weapon jamming support
- `ja_ent_killed.lua` -> Entity kill voicelines
- `ja_ent_spotted.lua` -> Entity spotted voicelines
- `ja_fall_damage.lua` -> Fall damage module
- `ja_shot_pain.lua` -> **NOT IMPLEMENTED** damage module
- `ja_negative.lua` -> Implements a "no" nod by tracking player head movement side to side.
- `ja_nod.lua` -> Implements a "yes" nod by tracking player head movement up and down.
- `ja_reload.lua` -> Implements reloading for weaponry.
- `ja_save.lua` -> Saves player presets (not configurable)

### JaVox Actions

JaVox contains actions that have metadata attached to them. When you run an action, JaVox does a namespace lookup for your action in the format `a.b.c`, where `a` and `b` are both tables that have other tables that can either have tables or action metadata.

Oddly enough, the system allows for homogenous recursive namespace dispatching *alongside* action metadata, meaning you can have:

```json
{
	"action1": {
		"action2": {
			"audioFiles": [],
			"priority": 5,
			// etc.
		},
		// notice how we have audio files here... and in action2?
		// this is weird but works. you should probably separate categories however. That is a user discipline.
		"audioFiles": [],
		"priority": 5,
	}
}
```

Having this flexibility allows for packs to be created easier and faster, with respect to user wishes.

#### What defines an action?

An action, or 'module' as referred to in certain areas, is any table object that contains an `audioFiles` table.

Without an `audioFiles` table, there is no way to determine (other than default properties, which is prevented for best-case reasons) if the table at hand is a module when resolving an action.

### PVox...

The differences are:
- **Inspect module was removed in favor of just encouraging more callout usage**.
- **JaVox is primarily data-driven**, with a focus on providing enough information for variety instead of immediate vocal output.
- *All of JaVox's built-in extensions* (spotting, etc.) **have convars**.
- **JaVox has both `delay` and `throttle`,** meaning that you can not only randomly delay an audio playing, but also delay the subsequent ones too.
- **JaVox exposes pitch, volume, and reach** for granularity and improved creative expression.
- **JaVox boasts a highly-optimized architecture** with shuffled audio used instead of blindsided random calls.
	- **Performant State**: Handles queue swapping, monolithic action management, delaying audio while maintaining perfect state, and shuffling audio for variety
- **JaVox has modules for pinging, visual feedback for spotting entities, as well as feedback for losing entities** after periods of time.
- **JaVox has modules for inferred head nodding (yes/no) by tracking player movements** and nod changes.
- **JaVox has a high-performance timeline to replace timer-based systems entirely.**
- **ALL** JaVox modules have the ability to be disabled entirely.

### JaVox Module Methods

- `ja_fs_builder.lua` -> a recursive filesystem-based VOX builder that scans directories and maps them to actions (modern way)
- `ja_pvox_builder.lua` -> a flat, one-way translator for old PVOX packs.
- `ja_builder.lua` -> a modern-day builder pattern for creating VOX packs.
- `JaVox:registerModule(id, payload)` -> The "classic" and most feature-dense way of creating a module.