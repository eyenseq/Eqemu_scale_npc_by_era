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


# There are TWO DIFFERENT methods. One using global_npc.pl the other using zonecontroller.pl. Use ONE NOT BOTH.

**`quests/global/global_npc.pl`**

```perl
sub EVENT_SPAWN {
    plugin::scale_npc_by_era();
}
```
That's all you need for the plugin to begin scaling NPCs by zone era.

**`quests/global/zone_controller.pl`**

```perl

our $ZC_ERA_DEBUG = 0; # zone-controller level debug (separate from plugin’s)

sub EVENT_SPAWN_ZONE {
    # This fires for EVERY NPC spawn in the zone

    # $spawned_entity_id and $spawned_npc_id are set by the engine
    my $ent_id = $spawned_entity_id;
    my $npc_id = $spawned_npc_id;

    my $mob = $entity_list->GetMobID($ent_id);
    return if !$mob;
    return if !$mob->IsNPC();          # safety

    my $npc = $mob->CastToNPC();

    # Let the plugin handle era, trash/named/raid, blacklist, etc.
    plugin::scale_npc_by_era($npc, $zonesn);

    if ($ZC_ERA_DEBUG) {
        quest::debug(
            sprintf(
                "[EraScale-ZC] EVENT_SPAWN_ZONE: scaled npc_type_id=%d ent_id=%d in %s",
                $npc_id, $ent_id, $zonesn
            )
        );
    }
}
```

## 🎛️ Adjusting Difficulty

Inside scale_npc_by_era.pl, each era has a configuration block:
```perl
classic => {
        trash => {
            hp      => 0.40,
            melee   => 0.40,
            defense => 0.50,
            atk     => 0.35,
            resist  => 0.50,
            spell   => 0.50,
            mana    => 1.00,
        },
        named => {
            hp      => 0.40,
            melee   => 0.40,
            defense => 0.50,
            atk     => 0.35,
            resist  => 0.50,
            spell   => 0.50,
            mana    => 1.00,
        },
        raid  => {
            hp      => 0.40,
            melee   => 0.40,
            defense => 0.50,
            atk     => 0.35,
            resist  => 0.50,
            spell   => 0.50,
            mana    => 1.00,
        },
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
## 🚫 ZONE VERSION BLACKLIST

If there is a zone that should not be affected (e.g. permafrost version x), add the zonesn and version here:
```perl
#   poknowledge => { 1 => 1 }  # don't touch version 1 of PoK 
my %ERA_BLACKLIST_ZONEVER = (
    # poknowledge => { 1 => 1 },
    # hateplane   => { 1 => 1 },
);
```
## 🚫 Role filter

Changes how roles are scaled
```perl
#   classic => { trash => 1, named => 1, raid => 0 },   # no Classic raids touched
#   god     => { trash => 0, named => 1, raid => 1 },   # only named+raids in GoD
my %ERA_ROLE_FILTER = (
    default => { trash => 1, named => 1, raid => 1 },

    # classic => { trash => 1, named => 1, raid => 0 },
    # kunark  => { trash => 1, named => 1, raid => 1 },
    # velious => { trash => 1, named => 1, raid => 1 },
    # luclin  => { trash => 1, named => 1, raid => 1 },
    # pop     => { trash => 1, named => 1, raid => 1 },
    # loy     => { trash => 1, named => 1, raid => 1 },
    # ldon    => { trash => 1, named => 1, raid => 1 },
    # god     => { trash => 1, named => 1, raid => 1 },
    # oow     => { trash => 1, named => 1, raid => 1 },
);
```

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


