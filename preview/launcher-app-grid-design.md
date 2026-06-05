# App Launcher Grid — Design

**Date:** 2026-06-05
**Status:** Approved (visual mockup validated in browser)
**Surface:** `modules/AppLauncherPanel.qml` + `components/applauncher/`

## Overview

Today the app launcher shows **nothing** until you type — an empty 560px panel with
just a search field. This adds a **grid empty-state**: when the search field is empty,
the panel shows a tabbed grid of apps. Typing still overrides everything with the
existing vertical fuzzy-search results list (unchanged behaviour).

The empty-state has two tabs:

- **Pinned & Frequent** (default) — a *Pinned* section (user-curated) followed by a
  *Frequent* section (auto-ranked by launch frecency).
- **All Apps** — every installed app, A–Z.

Validated against an interactive mockup built on the real `launcher.html` design
language; this spec captures the agreed behaviour.

## Goals

- Useful zero-keystroke launching: pinned + most-used apps visible on open.
- Browse-all fallback without searching.
- Keep the existing search experience byte-for-byte where possible.
- Self-contained — no new external binaries; reuse `AppSearch`/`DesktopEntries`.

## Non-goals (YAGNI)

- Drag-to-reorder pins (pin order = order pinned; unpin removes). 
- Categories/folders, app groups, or per-app context menus beyond pin/unpin.
- Configurable cell density — ships fixed at **Icon + name, 4 columns**.
- Recent-files / actions / calculator-style query providers.

## Decisions (locked)

| Decision | Choice |
|---|---|
| Cell style | Icon + name, **4 columns** (fixed) |
| Empty-state structure | Tabs: `Pinned & Frequent` (default) + `All Apps` |
| Default tab layout | Two labeled sections: *Pinned*, then *Frequent* |
| Pin interaction | **Both** right-click context toggle **and** a hover pin button |
| Frequency source | **Track launch counts + last-launched** ourselves (frecency) |

## UX behaviour

### Layout (empty search field)

```
┌───────────────────────────────────────────────┐
│ 🔍  search applications…                  esc  │   query row (unchanged)
├───────────────────────────────────────────────┤
│  Pinned & Frequent   |   All Apps              │   tab strip
│                                                 │
│  PINNED ─────────────────────────────────────  │   section label
│   ▢        ▢        ▢        ▢                  │   4-col grid
│  Firefox  Term     VS Code  Files               │
│                                                 │
│  FREQUENT ───────────────────────────────────  │
│   ▢        ▢        ▢        ▢                  │
│  Spotify  Slack    Mail     Settings            │
├───────────────────────────────────────────────┤
│  PINNED & FREQUENT        ↑↓←→ ⇥ ↵             │   footer (context hints)
└───────────────────────────────────────────────┘
```

Grid area scrolls vertically when taller than its cap (~`panel.height * 0.56`),
matching the existing results-list cap idiom. The panel's `implicitHeight`
animates between states via the existing `Behavior on implicitHeight`.

### Cell

A cell is an icon tile (44×44, rounded, hairline border) with the app name beneath
(12px, single line, elided). Selection/hover raises the tile background to
`surfaceContainerHigh`, hot-borders it, and shows a 2px accent edge — same visual
vocabulary as the current search row.

Pinned cells show a small accent **pin dot** in the top-right. On hover, a clickable
**pin button** appears in the corner (toggles pinned). Right-click anywhere on the
cell also toggles pinned.

### Search overrides the grid

When `AppLauncher.query.length >= 1`: hide the tab strip + grid, show the existing
`ListView` of `AppLauncherItem` rows exactly as today. Clearing the query (or `Esc`
while non-empty) returns to the grid. No change to fuzzy matching.

### Keyboard model

Mirrors the current launcher's focus dance:

- Search field holds focus on open (existing fade-in timer).
- **Type** → search mode.
- **Down** from the search field → move selection into the grid (select index 0).
- In the grid: **←/→** move by one cell; **↑/↓** move by one row. Selection flows
  across the Pinned→Frequent section boundary as one continuous column-aligned grid
  (each section starts on a fresh row, so row math is exact). **↑** from the top row
  returns focus to the search field.
- **Tab** toggles between the two tabs (works whenever the grid is shown).
- **Enter** launches the selected cell.
- **Esc** clears a non-empty query, else closes the panel.

Implementation note: model the grid as a `rows` structure (array of cell-index rows)
built from the visible sections; navigation preserves the current column when moving
between rows and across the section boundary. Fixed 4-column width makes this
deterministic.

### Mouse model

- Hover a cell → it becomes the selection.
- Click → launch.
- Hover pin button / right-click → pin or unpin.
- Click the scrim (outside the panel) → close (unchanged).

### Edge / empty states

- **No pinned apps:** hide the *Pinned* label + grid; *Frequent* fills the tab.
- **No usage yet (fresh):** hide the *Frequent* section.
- **Default tab fully empty** (no pins, no launches): show a centered one-line hint —
  *"Pin apps or launch a few — they'll show up here. Press ⇥ for All Apps."*
- **All Apps** always has content (all installed entries).

## Architecture

Follows existing conventions: service owns state, module is the surface, reusable
pieces live under `components/applauncher/`.

### New files

- **`components/applauncher/AppGrid.qml`** — the empty-state view. Owns the tab strip,
  section labels, the grid(s) of cells, the row-based keyboard navigation model, and
  the "launch selected" / "move into search field" signals. Reads its lists from the
  `AppLauncher` service. Single clear purpose: render + navigate the grid.
- **`components/applauncher/AppGridCell.qml`** — one app cell: icon tile, name, pin
  dot, hover pin button, selection visuals. Emits `launch()` and `togglePin()`.
  Depends only on its `item` (a desktop entry) + `selected` bool.

### Changed files

- **`modules/AppLauncherPanel.qml`** — in `contentColumn`, between the search row and
  the footer: show `AppGrid` when `AppLauncher.query.length === 0`, else the existing
  `resultsList`. Wire `AppGrid` signals: "up past top row" → `searchField.forceActiveFocus()`;
  Down from field → focus the grid. Footer hints become context-aware (grid vs search).
  Route the search-row launch through `AppLauncher.launch(entry)` so usage is recorded.
- **`services/AppLauncher.qml`** — becomes the single source of launcher data:
  - existing `query` / `results` (unchanged search path),
  - `readonly property list pinnedApps` — desktop entries for `Preferences.pinnedApps`,
    in pin order,
  - `readonly property list frequentApps` — top-N (8) by frecency, excluding pinned,
  - `readonly property list allApps` — `AppSearch.list` sorted A–Z,
  - `function launch(entry)` — record usage (count++/lastLaunched), then run the app,
    including the existing `runInTerminal` handling. **All** launch sites call this.
  - `function togglePin(entry)` — add/remove the entry id in `Preferences.pinnedApps`.
- **`services/Preferences.qml`** — two new persisted properties (see below).

### Existing `AppLauncherItem.qml`

Unchanged visually; its click/Enter path routes through `AppLauncher.launch(entry)`
instead of calling `entry.execute()` directly, so search launches also feed frecency.

## Data model & persistence

App identity key = `DesktopEntry.id` (stable, already deduped by `AppSearch.list`).

Add to `Preferences.qml`, following the established pattern (property on the
`Singleton` root **and** on `defaultAdapter`, assigned in **both** `onLoaded` and
`onLoadFailed`):

```qml
// root
property var appUsage: ({})   // { [appId]: { count: int, last: <epoch ms> } }
property var pinnedApps: []    // [appId, ...] ordered

// defaultAdapter
property var appUsage: ({})
property var pinnedApps: []

// onLoaded:  root.appUsage = defaultAdapter.appUsage; root.pinnedApps = defaultAdapter.pinnedApps;
// onLoadFailed (first-run defaults): both = empty {} / [].
```

**Mutation must reassign, not mutate in place** (the README desync warning): to record
a launch, build a new object/array and assign it to *both* `root.*` and
`defaultAdapter.*` (the adapter assignment triggers `writeAdapter` via
`onAdapterUpdated`). Helper functions on `Preferences` (e.g. `recordLaunch(id)`,
`setPinned(id, bool)`) keep this in one place; `AppLauncher` calls them.

### Frecency ranking

`frequentApps` = all apps with `count > 0`, excluding pinned ids, sorted by score
desc (tiebreak: count desc, then name asc), capped at 8:

```
score = count * recencyWeight(now - last)
recencyWeight: ≤1 day → 4 ; ≤3 days → 3 ; ≤7 days → 2 ; ≤30 days → 1.5 ; else → 1
```

Simple, explainable, no decay timers. Recomputed as a binding off `appUsage`.

## Animations

Reuse what exists: the panel open scale/translate/opacity, the search-field fade-in
timer, and `Behavior on implicitHeight` (handles smooth resize when switching tabs or
toggling between grid and results). Cell hover/selection use the same 120ms color
behaviours as `AppLauncherItem`. Tab-switch underline can use a short translate/opacity
on the active-tab indicator.

## Testing / verification

No test suite exists; this is a visual QML shell. Verify by running `qs` and:

1. Open launcher (empty) → Pinned & Frequent tab shows with sections.
2. Arrow-navigate the grid incl. crossing the section boundary; Up from top row
   returns to the search field; Tab switches tabs; Enter launches.
3. Right-click and hover-pin toggle pins; pinned app moves to Pinned section and
   persists across a shell restart (check `~/.cache/quickshell_preferences.json`).
4. Launch several apps; confirm they surface in Frequent ranked sensibly and persist.
5. Type a query → grid hides, existing results list behaves exactly as before;
   clear → grid returns.
6. Fresh-profile path (empty `appUsage`/`pinnedApps`) shows the empty hint and
   All Apps still works.

## Open questions

None blocking. Pin reordering and cell-density preference are deliberately deferred.
