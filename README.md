# JaVOX

A modern, secure VOX addon for Garry's Mod, built on the shoulders of the **PVox** addon.

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
- Ping system WIP
