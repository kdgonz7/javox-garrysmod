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

### PVox...

The differences are:
- Inspect module was removed in favor of just encouraging more callout usage.
- The filesystem setup is BASIC (nonexistent rn.), with pre-made settings for the best outputs.
