# scale_npc_by_era (EQEmu)

**Era-based NPC scaling with zero DB edits**, plus a **fast zone boot sweep** and **safe respawn/late-spawn scaling** using the Zone Controller.

This plugin scales NPC stats when they appear in a zone, based on the zone’s “era” (Classic → Kunark → Velious → …) as defined by your zone lists.

---

## What this plugin does

### ✅ Core scaling (per NPC)
For each NPC, the plugin:
- figures out the zone era from `%ERA_ZONES`
- classifies the NPC role: `trash`, `named`, or `raid`
- applies your per-era/per-role multipliers from `%ERA_SCALE`
- respects all skip rules (clients/pets/corpses/bots/mercs/aura, merchants/bankers, low HP props, blacklists)

### ✅ Fast “fresh zone” scaling (boot sweep)
On zone startup, the Zone Controller can do a **single sweep** through all NPCs and scale them immediately.

### ✅ Respawn / late-spawn scaling
When an NPC respawns (or spawns later), `global_npc.pl` signals the Zone Controller with the NPC **entity ID** so the controller can safely resolve it to an NPC object and scale it.

---

## What it scales

This plugin can scale:

- **HP** (`max_hp`)
- **Melee damage** (`min_hit`, `max_hit`)
- **AC** (`ac`)
- **ATK / Accuracy** (`atk`, `accuracy`)
- **Resists** (`mr`, `fr`, `cr`, `dr`, `pr`, `cor`)
- **Spell & heal scaling** (`spellscale`, `healscale`)
- **Mana** (`max_mana`)

It also heals the NPC after scaling if it is not engaged.

---

## Install

Place the plugin here:

```
quests/plugins/scale_npc_by_era.pl
```

Then set up the wiring (below).

---

## REQUIRED WIRING (this version)

This plugin version is designed to run in **Zone Controller mode**:

- Zone Controller handles **boot sweep** and **signal scaling**
- global_npc handles **respawn / late spawns** by signaling Zone Controller

> Use this wiring. Don’t also run a second era-scaling system in parallel.

---

## 1) Zone Controller script (The built in Zone Controller ID in every zone is 10)

Create or edit:

```
quests/global/10.pl
```

Add exactly this:

```perl
# quests/global/10.pl

sub EVENT_SPAWN {
    # Starts the boot sweep timer (fast scaling for fresh zones)
    plugin::era_zc_on_spawn($zonesn, $instanceversion);
}

sub EVENT_TIMER {
    # Runs the boot sweep when "__era_boot" fires
    plugin::era_zc_on_timer($timer, $zonesn, $instanceversion);
}

sub EVENT_SIGNAL {
    # Receives an entity id via signal and scales that NPC on-demand
    plugin::era_zc_on_signal($signal, $zonesn, $instanceversion);
}
```

---

## 2) global_npc spawn hook (respawns / late spawns)

Edit:

```
quests/global/global_npc.pl
```

In `EVENT_SPAWN`, add:

```perl
sub EVENT_SPAWN {
    plugin::era_npc_on_spawn($npc, $zonesn, $instanceversion);
}
```

That’s it.

What this does:
- Every NPC spawn calls `era_npc_on_spawn`
- The plugin checks if it **should scale**
- If needed, it `signalwith(10, $eid, 200)` so the controller scales it safely

---

## How it works (in plain English)

### Fresh zone boot
1. Zone controller spawns
2. Plugin sets a short timer (`__era_boot`, default 1 second)
3. When it fires, it loops `GetNPCList()` and scales everything once

### Later spawns / respawns
1. `global_npc.pl` fires EVENT_SPAWN for the NPC
2. `era_npc_on_spawn()` checks skip rules + de-dupes
3. It signals NPC type **10** (your controller) with the NPC **entity id**
4. `era_zc_on_signal()` resolves entity id to a real NPC object and scales it

---

## Tuning difficulty

### 1) Zone → Era mapping (`%ERA_ZONES`)
Edit the zone lists at the top:

```perl
my %ERA_ZONES = (
  classic => [ qw(qeynos qeynos2 freeporte ... ) ],
  kunark  => [ qw(fieldofbone kurn sebilis ... ) ],
  ...
);
```

If a zone isn’t listed, it becomes `default` (no scaling unless you change `%DEFAULT_SCALE`).

---

### 2) Era multipliers (`%ERA_SCALE`)
Each era has per-role blocks:

- `trash` = not raid target and not rare spawn
- `named` = rare spawn
- `raid`  = raid target

Example:

```perl
classic => {
  trash => { hp=>0.50, melee=>0.50, defense=>0.50, atk=>0.50, resist=>0.50, spell=>0.50, mana=>1.00 },
  named => { ... },
  raid  => { ... },
},
```

Meaning:
- **Lower** numbers = easier
- **Higher** numbers = harder

Notes:
- `defense` is used for AC scaling
- `atk` is used for ATK and Accuracy scaling
- `spell` also influences resists if `resist` is not set (fallback logic exists)

---

## Filters / skipping

### NPC blacklist (never scale)
Add NPCTypeIDs here:

```perl
my %ERA_BLACKLIST_NPCID = (
  10      => 1,  # zone_controller type
  2100000 => 1,  # your custom npc
);
```

### Zone blacklist (all versions)
```perl
my %ERA_BLACKLIST_ZONE = (
  poknowledge => 1,
);
```

### Per-zone version blacklist
```perl
my %ERA_BLACKLIST_ZONEVER = (
  # poknowledge => { 1 => 1 },
);
```

### Global version blacklist
This skips all zones of a given instance version:

```perl
our %ERA_GLOBAL_VERSION_BLACKLIST = (
  2 => 1,
);
```

---

## Role filters (enable/disable scaling by role per era)

If you want to disable scaling for certain roles in certain eras:

```perl
my %ERA_ROLE_FILTER = (
  default => { trash => 1, named => 1, raid => 1 },

  # classic => { trash => 1, named => 1, raid => 0 },  # don’t scale classic raids
);
```

If role is `0`, scaling is skipped completely for that NPC.

---

## Debugging

### Plugin debug (main)
At the top of the plugin:

```perl
our $ERA_SCALE_DEBUG //= 1;
```

This prints:
- zone → era → role
- chosen multipliers
- original → new stats

### Zone-controller debug (optional)
Inside the plugin there’s a separate controller debug flag:

```perl
our $ERA_ZC_DEBUG //= 0;
```

Set it to `1` if you want controller-specific logs (boot sweep counts and signal scaling messages).

---

## Common issues

### “Fresh zone scaling is slow”
Use the wiring in this README (Zone Controller mode). The boot sweep is the fast path.

### “NPC doesn’t scale on respawn”
Make sure `global_npc.pl` calls:

```perl
plugin::era_npc_on_spawn($npc, $zonesn, $instanceversion);
```

---

## Files touched

- `quests/plugins/scale_npc_by_era.pl`  (this plugin)
- `quests/global/zone_controller.pl`    (3 small event handlers)
- `quests/global/global_npc.pl`         (1 line inside EVENT_SPAWN)

---

## Minimal “works now” checklist

- [ ] Plugin placed in `quests/plugins/scale_npc_by_era.pl`
- [ ] `10.pl` has EVENT_SPAWN / EVENT_TIMER / EVENT_SIGNAL wired to the plugin
- [ ] `global_npc.pl` calls `plugin::era_npc_on_spawn(...)` in EVENT_SPAWN
- [ ] NPCTypeID 10 is blacklisted (already is in your plugin)
- [ ] Debug enabled while testing (`$ERA_SCALE_DEBUG = 1`)

