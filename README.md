# Drop Stats | ALiTiS | v.1.2

## Session Loot Tracker for Diablo IV

Drop Stats is a fully featured, standalone overlay plugin that tracks everything you pick up during a session. It runs silently in the background, counting your drops, calculating rates, logging recent loot, and keeping a history of your runs — all displayed in a clean, customizable on-screen overlay.

---

## What It Tracks

### Item Drops by Rarity
Every item that enters your inventory is detected and classified:

- **Rares** (including Ancestral Rares)
- **Legendaries**
- **Uniques**
- **Mythics** — identified by a built-in database of all known Mythic item IDs (Tyrael's Might, Harlequin Crest, Shattered Vow, etc.)
- **Runes** — tracked from your socketable inventory, counting stack sizes

### Currencies
- **Obols** (Murmuring Obols) — only counts gains, ignores spending at the Purveyor
- **Gold** — only counts gold earned, ignores purchases and repairs

All tracking uses a **positive delta** system: the plugin remembers your previous value and only adds the difference when it goes up. Spending gold, using runes, or gambling obols will never reduce your session totals.

---

## Per-Hour Rates

Toggle **Show Rates (/h)** to see live per-hour calculations next to every category. Rates update every 2 seconds and are based on your total session time. For example, if you've found 45 Legendaries in 30 minutes, you'll see `90/h` next to your Legendary count. Large numbers are formatted automatically (e.g., `12.5K/h` for gold).

---

## Peak Rates

When enabled, the plugin tracks the **best per-hour rate** you've achieved for each category during the session. Peak rates begin recording after 10 seconds to avoid misleading spikes from early drops. This lets you see your most productive moments at a glance.

The Peak Rates section appears as a separate block below the main stats with a green bold header.

---

## Recent Drops Feed

A scrolling log of your most recent item drops, showing:

- **Timestamp** — how far into the session the item dropped (formatted as HH:MM:SS)
- **Category tag** — a short label like `LEG`, `UNI`, `MYT`, or `RUN`
- **Item name** — the display name of the item, or the Mythic name from the database

Each entry is color-coded to match its rarity. The log size is configurable (default: 3 entries, adjustable up to 20).

---

## Run History

Mark individual runs using a keybind, and the plugin tracks per-run breakdowns:

- **Duration** of each run
- **Legendaries, Uniques, Mythics** found per run
- **Gold earned** per run
- **Best run highlight** — the run with the highest value score is marked with a green `*` prefix

A live **"NOW"** line shows your current run stats in real time. Runs shorter than 30 seconds are automatically discarded. The plugin stores up to 20 runs and displays a configurable number (default: 2, adjustable up to 10).

### How to Use Runs
1. Start playing — the first run begins automatically
2. Press the **Mark Run** keybind when you finish a run (e.g., between dungeon clears)
3. The current run is saved and a new one starts
4. Check the Run History section to compare your runs

---

## F5 Session Persistence

One of the most important features: **your stats survive F5 reloads**.

Normally, pressing F5 restarts all Lua plugins and wipes all data. Drop Stats solves this by automatically saving your session to a file (`session_save.txt`) every 5 seconds. When the plugin reloads, it reads the file and restores everything:

- All item counts
- Gold, Obols, Runes totals
- Session elapsed time (uptime continues from where it left off)
- Peak rates
- Recent drop log

The save file is stored in the plugin's own root folder, so it works regardless of where the plugin is installed.

### Toggle On/Off
The **"F5 Saves Data"** checkbox in the menu lets you control this behavior:
- **ON (default):** Stats are saved and restored across F5 reloads
- **OFF:** Stats reset on F5, behaving like a normal plugin (the save file is not deleted)

---

## Full Reset

Use the **Reset Session** keybind to completely clear all data:

- All counters go to zero
- Uptime resets
- Peak rates clear
- Drop log clears
- Run history clears
- The save file is also cleared, so an F5 after reset starts fresh

---

## Display Customization

Every visual aspect of the overlay is configurable:

### Position
- **Offset X** (0–4000) — move the overlay horizontally
- **Offset Y** (-200–1500) — move the overlay vertically

### Text
- **Font Size** (12–30, default: 19) — controls all overlay text size
- **Header Gap** (4–10, default: 4) — extra spacing after section headers
- **Line Gap** (0–10, default: 1) — extra spacing between category lines

### Per-Category Control
Each tracked category (Rares, Legendaries, Uniques, Mythics, Runes, Obols, Gold) has its own collapsible settings with:
- **Enable/Disable** — choose which categories appear on the overlay
- **Bold toggle** — render that category in bold text (double-draw for visibility)

By default, **Uniques and Mythics are bold**, making them stand out from regular drops.

### Section Toggles
- **Show Rates (/h)** — display per-hour rates inline
- **Show Uptime** — display session timer
- **Show Peak Rates** — display best rates achieved
- **Show Recent Drops** — display the scrolling drop log
- **Show Run History** — display per-run breakdowns

---

## Color Scheme

Each category has a distinct color for quick visual identification:

| Category | Color |
|----------|-------|
| Rares | Yellow |
| Legendaries | Orange |
| Uniques | White (Bold) |
| Mythics | Pink (Bold) |
| Runes | White |
| Obols | White |
| Gold | Yellow |
| Peak Rates | Green |
| Run History (Best) | Green |
| Section Headers | White (Bold) |

---

## Mythic Detection

The plugin includes a built-in database of all known Mythic item IDs. When a Unique item enters your inventory, the plugin checks its `sno_id` against this database. If it matches, the item is counted as a Mythic instead of a Unique, and its name appears in the drop log.

Currently tracked Mythics:
Tyrael's Might, The Grandfather, Andariel's Visage, Ahavarion Spear of Lycander, Doombringer, Harlequin Crest, Melted Heart of Selig, Ring of Starless Skies, Shroud of False Death, Nesekem the Herald, Heir of Perdition, Shattered Vow.

---

## External API

Drop Stats exposes a global API (`PLUGIN_session_stats`) that other plugins can use to read your session data:

- `get_session()` — returns all current totals and uptime
- `get_rates()` — returns current per-hour rates
- `get_peaks()` — returns peak rate records
- `get_recent_drops(max)` — returns recent drop log entries
- `get_run_history(max)` — returns completed run snapshots
- `get_best_run()` — returns the highest-value run
- `get_current_run()` — returns live current run stats
- `reset()` — triggers a full session reset
- `mark_run()` — marks end of current run
- `is_enabled()` — checks if the plugin is active

This allows other plugins to display or react to your session data without duplicating tracking logic.

---

## Installation

1. Copy the entire `Drop Stats` folder into your scripts directory
2. The folder structure should look like:
```
Drop Stats/
├── main.lua
├── gui.lua
├── core/
│   ├── settings.lua
│   ├── tracker.lua
│   ├── scanner.lua
│   ├── drawing.lua
│   ├── external.lua
│   └── persistence.lua
├── modules/
│   ├── items.lua
│   ├── gold.lua
│   ├── obols.lua
│   ├── runes.lua
│   ├── rates.lua
│   ├── drops.lua
│   └── history.lua
└── data/
    ├── colors.lua
    ├── mythics.lua
    └── rarity.lua
```
3. Press F5 to reload plugins
4. Open the menu and find **Drop Stats | ALiTiS | v.1.0**
5. Check **Enable** and you're ready to go

---

## Requirements

- No dependencies on other plugins — fully standalone
- Works alongside any other plugins without conflicts

---

*Created by ALiTiS*

---

## Pit Counter

Drop Stats automatically detects and counts your Pit of Artificers runs — no keybind or manual input needed.

### How It Works
The plugin monitors your current zone. When you enter a Pit zone (`EGD_MSWK_World_01` or `EGD_MSWK_World_02`), a timer starts. When you leave the Pit (exit, reset, or teleport out), the run is counted and the duration is recorded. Runs shorter than 15 seconds are ignored to prevent false counts from loading screens or accidental entries.

### What It Displays
The Pit line appears after Gold in the overlay, rendered in red bold:

```
Pits        : 5  4.2/h  avg 2m 35s
```

- **Count** — total Pit runs completed this session
- **Per hour** — how many Pits you're clearing per hour (shown after 1 minute)
- **Average time** — average duration of all completed Pits

### Persistence
Pit count and total time are included in the F5 save/restore system. Your Pit stats survive reloads and are cleared on manual reset.

### Toggle
Enable or disable the Pit Counter from the **Tracked Categories** section in the menu. It is enabled by default.

---

## Changelog

### v.1.2
- **Added Meat Tracker** — tracks Meaty Offerings picked up from consumable inventory
- Meat has its own collapsible dropdown with Enable/Bold toggles
- Displayed in red after Obols, with per-hour rate support
- Meat data persists across F5 reloads

### v.1.1
- **Added Pit Counter** — auto-detects Pit of Artificers runs by monitoring zone transitions
- Displays total Pits completed, Pits per hour, and average Pit duration
- Pit data persists across F5 reloads
- Displayed in red bold after Gold in the overlay

### v.1.0
- Initial release
- Track Rares, Legendaries, Uniques, Mythics, Runes, Obols, Gold
- Per-hour rates with peak tracking
- Recent Drops scrolling feed with color-coded entries
- Run History with per-run breakdowns and best run highlight
- F5 Session Persistence with auto-save every 5 seconds
- Per-category Bold toggle for display customization
- Adjustable Font Size, Line Gap, Header Gap, Offset X/Y
- External API for other plugins
- Mythic detection via built-in sno_id database
