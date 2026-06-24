# JaVOX Callout Engine

JaVox is the next iteration of PVox. It was originally meant to be a write-over that was fully compatible, but then turned into something that became more complex than the original and therefore couldn't be placed within the same bracket.

Do be patient with me, as this is new, so there may be bugs but feel FREE to let me know anywhere, I'll get back ASAP (but remember, it's that time of year almost so bug fixes may slow down...)

## Default Modules

There are a lot of features of JaVox, and it has a pretty standard set of default (inbuilt) modules.

- ARC9 Gun Jamming
- Fall + Entity Damage
- Saving/loading
- Entity killing, kill confirming, and kill suggestment (entity dies but you don't see it)
- Old-school "Frag out!" module
- Nods & Gestures (if you nod UP AND DOWN with your head you will call a "conversational.yes" action!)
- An NPC spotting system (includes personal pings, sound effects, spotting logic, and entity visibility tracking, ALL CONFIGURABLE)
- Basic weapon reloading (compatible with your RELOAD key)

## Features
- **A debug HUD**: to view your playback cycle
- **A custom scheduler to replace old-school timers and spaghetti code**: also improves performance on servers >20 people
- **A structured architecture**: built primarily for voiceline dispatching
- *Multiple ways to build modules**: including support for all of MY (basic) PVox modules.
- **Recursive actions**: you can define self.damage instead of self.damage.fall or self.damage.head and it'll play self.damage for you.
- **Minimal hook usage**: essentially compatible with MOST Garry's Mod addons, not a single hook's return value is overridden.
- **Configuration on the developer side and user side, with more to come**: customization-focused VOX engine, so a majority of modules can be customized and soon convar modifiers for VOICES as well.
- **Interface galore**: two major interfaces for two major features: Playermodel binding and voice pack selection.

# PLEASE READ

To find JaVox information go to the JaVox spawnmenu tool tab. There you'll find the module manager, playermodel assignment, and your list of built-in actions.

## PLANNED modules

- NextBot scared module (from PVox)
- TFA-VOX Extended Actions
- TFA-VOX Packs
- Ledge Hang ActMod
- NZombies

## Credits

- **TFA-VOX**: one of the primary VOX engine players
- **PVOX**: my previous Frankenstein of a project.
- **Those who contributed issues to PVox**: those helped to build this new addon as well.