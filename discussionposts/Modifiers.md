# Modifiers & Delays/Throttles

Modifiers mathematically are simply *enhancers* that the player controls, you have no control over them.

However, when you create packs, you have the ability, no matter how you make one, unless you specifically want your PVox module translated strictly, to choose your own sorts of delays. Because these delays are calculated right before modifying, your delay will **still** be in context of the overall voiceline (cadence isn't lost, unless they make pitch a crazy number...) but the speed at which it happens is different.

🚨🚨🚨 Unless everything is at 0. Then nothing's cooking. And errors are happening.


## Filesystem Builder Options

```lua
JaVox.FSBuilder:BuildFromFilesystem({
    name = "my_module",
    path = "path/to/sounds",
    author = "My Name",
    description = "A custom sound module.",
    tags = { "custom", "sounds" },
    defaults = {
        priority = AudioPriority.PLAY_ONCE_WITHOUT_DEFERRAL,
        volume = 100,
        pitch = 100,
        reach = 100,
        delay = {
            min = 0,
            max = 0.2
        },
        throttle = {
            min = 2,
            max = 5
        }
    }
})
```

When you create a filesystem module like above, you have the option to select defaults. There is where you can add your random variation for your vox pack. Unfortunately, specifying "specific" defaults where you can say "weaponry.reload".delay = {1, 5} is not implemented yet and is honestly kind of an anti-pattern for JaVox as of right now (lies. will be made soon).

FS Packs primarily give you control over *content* and *cadence*, and give the actual voice output to the player.

## Classic

```lua
JaVox:registerModule("combine-soldier-builtin", {
    displayName = "Stock Combine Soldier JaVOX",
    author = "mimi banks",
    description = "Push up, Push up! Combine Soldier builtin VOX module.",
    actions = {...},
    callouts = {},
})
```

In actions, each action you create can have a delay and throttle independent of others.

## PVox

PVox modules don't support delay modification. They can still fall to modifiers though.
