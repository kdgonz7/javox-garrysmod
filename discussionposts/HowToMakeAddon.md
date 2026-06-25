# How to create a VOX pack

No wrangling with tables. Just pure creation.

To create an addon, all you must do is create a file `lua/javox_pack/my_addon.lua` (or `javox_my_addon`) if you wanna be consistent.

```
JaVox.FSBuilder:BuildFromFilesystem({
    name = "BM:S HECU Marine",
    path = "javox/hecumarine",
    author = "mimi banks",
    description = "Black Mesa: Source HECU marine.",
    tags = { "HECU", "bms", "source" },
    defaults = {
        priority = AudioPriority.PLAY_ONCE_WITHOUT_DEFERRAL,
        volume = 100,
        pitch = 100,
        reach = 100,
        delay = {
            min = 0.2,
            max = 0.7
        },
        throttle = {
            min = 2,
            max = 5
        }
    }
})
```

`name` is the name/identifier of your addon. If you don't supply `displayName` (in future updates it will use displayName and name separate), then it'll use this as both your addon's name **AND** identifier. Keep that in mind.

Your defaults are what applies to every single action. Note that these are subject to modifiers, so you don't have to mess with them too much, just set some sensible defaults.

Your `author` and `description` and `tags`: self explanatory.

Your `path` is a path to your sounds in `sound/`

So your addon has a `lua/` directory, and next to it it should have a `sound/` directory. This addon resides in `sound/javox/hecumarine`.

## Actions you can have

This is not an extensive list, some addons have their own, and VOX packs can hook into game events to make their own. Here's a basic list:

TIP: use `javox_print_every_action_played 1` to see all actions being used for EVEN MORE

### the self

- `self.die` - death of player (WIP)
- `self.damage.fall` - fall damage
- `self.damage.<bodygroup>` - damage of bodygroup (`head`, `chest`, etc.)
- `self.talk` - unused yet, but will be used for "inspect" animations, idle chatter, etc.

### weapons

- `weaponry.reload` - reload key pressed
- `weaponry.grenade_out` - grenade throwing
- `weaponry.out_of_ammo` - trying to reload/shoot with no ammo in either clip1 or clip2
- `weaponry.jam` - ARC9 compatible weapon jam event

### entities

- `ents.kill.npc_combine_s` - kill an entity of class `npc_combine_s` (can be any class) (will use `ents.kill` default)
- `ents.kill.confirm` - when you confirm a ragdoll body (will be specific soon) (will use `ents.kill`)
- `ents.kill.suggest` - when an entity you kill is not in your FOV (will **NOT** use `ents.kill` by default)
- `ents.spotted.entClass` - when you spot an entity (has cooldown and time to forget)
- `ents.lost` - when you lose an entity.
