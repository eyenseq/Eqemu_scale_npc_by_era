# Eqemu_scale_npc_by_era
Scales NPCs up or down by "era" with NO DB changes.

# Era-Based NPC Scaling Plugin for EQEmu

This plugin automatically scales NPC stats based on the **expansion era of the zone**.  
It requires **no database changes** and applies adjustments globally whenever an NPC spawns.

The plugin can scale:

- HP  
- Melee damage  
- AC  
- ATK / Accuracy  
- Resists  
- Spell & heal power  

Each expansion era (Classic → Kunark → Velious → Luclin → PoP → etc.) has simple tuning knobs you can edit.

---

## 📦 Installation

Place the plugin file here:
quests/plugins/scale_npc_by_era.pl


Then add this to your global NPC script:

**`quests/global/global_npc.pl`**

```perl
sub EVENT_SPAWN {
    plugin::scale_npc_by_era();
}
```
That's all you need for the plugin to begin scaling NPCs by zone era.

## 🎛️ Adjusting Difficulty

Inside scale_npc_by_era.pl, each era has a configuration block:
```perl
classic => {
    hp      => 0.40,
    melee   => 0.40,
    defense => 0.50,
    atk     => 0.35,
    resist  => 0.50,
    spell   => 0.50,
},
```

Where:

Lower numbers = easier

Higher numbers = harder

You can fine-tune the difficulty progression across eras easily by editing these values.

## 🚫 NPC Blacklist (Never Scale These)

If there are NPCs that should not be affected (e.g. bosses, special encounters), add their NPCTypeID here:
```perl
my %ERA_BLACKLIST_NPCID = (
    # 28202 => 1,   # Example: NPC
    # 90001 => 1,  # Example: Boss NPC
);
```

Any NPCTypeID listed will spawn unscaled.

## 🛠️ Debugging (Optional)

Enable debug output at the top of the plugin:
```perl
our $ERA_SCALE_DEBUG //= 1;
```

This will print helpful information when NPCs spawn, such as:

Detected zone → era

Original and scaled stats

Applied multipliers

Useful for verifying your configuration.


