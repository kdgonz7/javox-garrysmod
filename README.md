# JaVOX
# 🚨 NOTICE FOR PVox users: the original repository is NOT archived yet. But this addon is in its final stages and will be released either June 24th, or the 25th.
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

### JaVox Default Actions

```lua
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
```

### JaVox Sub-Objects

- `JaVox.Director`: Manages player audio outputs, anything that is sound-related is here.
- `JaVox.State`: Manages player states. This is what manages priorities (to play a sound after the current one, play and cut this one off, wait to receive another input, or play it randomly.)
- `JaVox.Crud`: Manages CRUD operations for the JaVox system.
- `JaVox.Scheduler/Timeline`: Manages audio placement and playing
- `JaVox.FSBuilder`: The JaVox functionality responsible for building FS-based action packs.
- `JaVox.Speaker`: (module-borne) manages when a player is speaking.

## 🛠️ Action Scripting (v1.1.2+)

JaVox `v1.1.2` introduces the `patterns` field. You can define patterns directly inside your modules or inject them dynamically via `registerModule`.

Instead of manually mapping dozens of individual entity actions, you can now use **Lua string patterns** to route multiple dynamic events into a single, consolidated action.

---

### Example: The Zombie Consolidation

If you have a core voice line configured for `ents.kill.npc_zombie`, you can automatically catch all default zombie variants (like fast and poison variants) and route them to that exact action:

```lua
patterns = {
    -- Redirects all variation zombie kills to the base zombie action
    ["^ents%.kill%.npc_.*zombie"] = "ents.kill.npc_zombie",
}
```

#### How it routes in practice:
- ents.kill.npc_zombie ➡️ ents.kill.npc_zombie (Exact match)
- ents.kill.npc_fastzombie ➡️ ents.kill.npc_zombie (Pattern match)
- ents.kill.npc_poisonzombie ➡️ ents.kill.npc_zombie (Pattern match)

This opens up a large ecosystem scaling, allowing your sound packs to **natively support custom addon entities** without writing a single new line of code.

> ⚠️ PERFORMANCE WARNING: Do not abuse this mechanism. Use it primarily for event consolidation. Exact lookups are instant (O(1) hash lookups), whereas patterns require a sequential evaluation loop. Keep your pattern tables lean and clean!

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
- **JaVox has multiple interfaces for playermodel modification**, and direct access to change your model.
- **ALL** JaVox modules have the ability to be disabled entirely.

### JaVox Module Methods

- `ja_fs_builder.lua` -> a recursive filesystem-based VOX builder that scans directories and maps them to actions (modern way)
- `ja_pvox_builder.lua` -> a flat, one-way translator for old PVOX packs.
- `ja_builder.lua` -> a modern-day builder pattern for creating VOX packs.
- `JaVox:registerModule(id, payload)` -> The "classic" and most feature-dense way of creating a module.

## Credits

- `My Brain` -> building the architecture, understanding data flow, etc.
- `PVox` -> My previous player voiceline addon, much simplier to run and understand, but less performant.
- `TFA-VOX` -> Best to ever do it!
