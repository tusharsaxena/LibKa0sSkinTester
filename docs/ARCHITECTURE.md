# Architecture

What Ka0s Skin Tester is, as built. The rules it follows are the Ka0s WoW Addon Standard's; this page
says how this addon meets them.

## Overview

A skin showroom. `/st show` (or `/skintester show`) opens one window that shows the elements a Ka0s skin
(`LibKa0s-Skin-1.0`) can paint, in whichever skin the addon is wearing, so a skin can be judged in one
place. The addon is a skin owner like any adopter: the skin it wears is chosen from the swatch cards
across the top of the showroom, on its own General -> Skin tab or in the first-run skin picker, and every sample it shows is
painted through its own facade (`Skin:For`), through one wrapper that records each primitive used, so
the showroom shows exactly what an adopting addon gets and a test can prove every primitive is on
show. It is a roster addon that is never published on
CurseForge. Purpose, audience and non-goals: [`scope.md`](./scope.md).

## Module Map

One shell, the setup files that wire LibKa0s, the swatch selector, the showroom window with its paint
wrapper and section registry (its footer the library's `W.Footer`, 24 px with no fill, standalone-windows'
*The footer*; AD-89-ST; its title marks the library's `W.HeaderButtons` strip, settings · close,
standalone-windows' *Title-bar controls*; AD-86-ST), twelve section files (Chrome, Controls, Lists, Text, Panels, Overlays,
Addon surfaces, Library widgets, Values, Textures, Faces and widths, HUD faces), and the settings pages with the first-run skin picker. Every file, its job and its load-order constraint:
[`module-map.md`](./module-map.md). The load order itself is
the TOC, where each load-bearing position carries the reason.

### Per-client features

The addon serves Retail and WoW Forever (clients-§1; the roster's Clients value is `Retail · Forever`).
**All features serve both clients.** No module, settings page or tab, slash verb, launcher entry, key
binding or event registration carries a `clients` declaration, and the addon never asks which client it
is on. It paints LibKa0s widgets and reads no game data, so it ships no seed list (clients-§5). The
headless suite runs under both kit profiles (clients-§6), and the kit's missing-globals suite checks the
tracked source against both clients' API sets.

## Settings Schema

One schema (`settings/Schema.lua`) drives the panel, the `/st list|get|set|reset` CLI and the
defaults, over one write seam, `NS.SchemaRuntime.Set` (LibKa0s-Schema-1.0, or the host stub in
`settings/SchemaSetup.lua`). Rows: the composed Master controls (`enabled`, `scale`, `alpha`, the
session-only `state.debugConsole`, the global `global.minimap.shown`), the eight Skin tab rows
(`skin.source`, `skin.skin`, the overrides `skin.font` and `skin.texture`, the font outline `skin.outline`, the Scope's `skin.ignorePanel`,
`skin.ignoreFonts`, and the picker's `skin.pickerSeen`). The one piece of state outside the seam is the showroom window's
position, `db.global.windows.LibKa0sSkinTesterShowroom`, written only by `NS.Windows.Save` from the
window's drag stop and cleared by `NS.Windows.Forget` (Reset position), both in `core/Util.lua`.
Every path, default and the migration seam: [`schema.md`](./schema.md).

## Message Bus

None. Nothing crosses a module boundary as a message: the sections register with the showroom by
direct call (`NS.Showroom.AddSection`), below the `architecture-§4` threshold. A skin change reaches
the showroom, the selector and the Values, Textures, Faces and widths, HUD faces and Addon surfaces
sections through the skin engine's own `OnLooksChanged` notification, not a bus message.

## Slash Commands

`/st` and the alias `/skintester`, dispatched by LibKa0s-Slash-1.0 from the ordered `COMMANDS` table
in `settings/Slash.lua`: the reserved verbs (`skin` among them), plus `show`, the showroom toggle, and `widths`, the width probe, a report written to the debug console through `D:Report` (LibKa0s#79). At login a `/st` held
by another addon is left to it (`NS.CheckSlashCollision`), and this addon keeps `/skintester`. Every
verb and what it answers while disabled: [`slash-dispatch.md`](./slash-dispatch.md).

## Event Subscriptions

None. The addon registers no game event: the showroom opens when the player asks, the skin engine
repaints on a skin change, and AceDB's three profile callbacks (`OnProfileChanged`,
`OnProfileCopied`, `OnProfileReset`) are its only subscriptions. `NS.SafeRegisterEvent` is published
for the first event the addon ever needs (events-frames-taint-§1).

## Taint Notes

Nothing here is secure. The showroom is a plain frame (standalone-windows), opened and closed and
repainted in combat freely; the key binding clicks a plain hidden button. The settings panel's open is
refused in combat by the library (options-ui-§2), and a page shown in combat is locked by it.
`UISpecialFrames` is written once, at the first show, never at load.

### Title-bar marks (LibKa0s#86, AD-86-ST)

The showroom is the one window this addon builds with a title bar. Its marks are `W.HeaderButtons`'
(`modules/Showroom.lua`, `buildMarks`): left to right settings · close, with this addon's folder as
`owner`. The close is Core's `MakeCloseButton` (three arguments, built by the strip) and hides the
showroom. The settings mark opens this addon's settings through the opener its launcher registered
(`spec.settings` nil, Core's `OpenSettings(addonName)`, which calls `NS.addon:OpenSettings`). It passes
no `hideOnSettings`: the showroom sits in MEDIUM, under the settings panel, and the Skin tab is meant to
be read beside it. With no library widgets the close alone is placed by hand, as before. The confirm
popup and the sample tooltip in the Overlays section are specimens, not this addon's windows, and carry
no title marks. The Addon surfaces section's `SettingsFrameTemplate` miniature
(`modules/ShowroomOwner.lua`, `stockWindow`) is a specimen too: it has a title and the template's own
`ClosePanelButton` (its click cleared), shown to be skinned, and is deliberately not given a
`W.HeaderButtons` strip.

The Library widgets section's `W.DragHandle` is a specimen of the widget, not a strip of this addon's
(it moves its own cell and has no display behind it). It passes neither `settings` nor `onClose`, so it
shows the strip the library builds by default: from LibKa0s v1.107.0 (WidgetsDragHandle 15) that is the
`?` and the settings mark, in the window header's tints, and no X, since there is no display to close.
It never passes `settings = false`. A host can still opt out of the gear that way, but the specimen exists
to show the library's default strip, which has the gear on by default since the owner's 2026-11-19 ruling
(AF-WVR-ST, pinned in `tests/test_showroom_widgets.lua`).

### Tooltip placement (LibKa0s#92, AD-92-ST)

standalone-windows' *Tooltip placement* binds every tooltip this addon places itself. There is one:
the Overlays section's sample tooltip (`modules/ShowroomOverlays.lua`, `placeTip`), a frame of this
addon's shown on hover of "Hover me". The button is a control in the showroom's content, so it is a
**body** element: the frame is shown, then placed by `LibKa0s-Tooltip-1.0`'s `PlaceBeside` against the
showroom window (`R.Frame()`, a group of one: nothing docks to it), right of the window and else left,
its top level with the button's top, `TIP_GAP` off, `comparisons = false` (it is no item tooltip). When
the placers cannot read the geometry it takes `PlaceAttached`, then a plain `BOTTOM` on the button's
`TOP` + `TIP_GAP`. It used to sit on the button's top-right corner, 4 px off, the corner offset the rule
rules out. No code of this addon anchors a tooltip at the cursor or follows it (pinned by the AD-92-ST
cases in `tests/test_showroom.lua`).

Placed by the library, through its own placers, and so not this addon's to move: the showroom's
title marks (`W.HeaderButtons`, chrome, above the mark), the Library widgets specimens (the
`W.DragHandle` strip, the `W.ContextMenu` cascade's entries, the line chart's hover), the skin picker's
toolbar and the minimap button's tooltip (`PlaceLauncher`).

Left where they are, outside the rule's reach (*What it does not bind*):

| Tooltip | Why it stays |
|---|---|
| The settings pages' row tooltips and the header's Reset all settings tooltip (`settings/`) | Pages inside Blizzard's Settings canvas, which options-ui governs. |
| The launcher's options menu entries (`core/LauncherSetup.lua`) | A `MenuUtil.CreateContextMenu` menu: the client's menu code places its tooltips. |
| The Addon surfaces section's `SettingsFrameTemplate` miniature and other Blizzard-template specimens (`modules/ShowroomOwner.lua`) | They raise no tooltip of this addon's; any tooltip on them is the client's own frame. |

## Known Limitations

- With another installed addon that vendors a newer LibKa0s, LibStub runs that copy's files, so the
  showroom shows that copy's skins. While every Ka0s addon vendors the same tag they are identical.
- EllesmereUI's paint is one-way: leaving the EllesmereUI source after it painted needs a reload
  (the library's reload popup says so). For the same reason the swatch selector has no EllesmereUI
  card; a Source dropdown beside the cards switches the source instead.
- After a `/st` collision, the help text and the landing page still name `/st`.

## Documentation map

Every `.md` under `docs/` appears in exactly one table below (`documentation-§3`). Frozen and
generated directories are named once each and never enumerated per run: `docs/audits/`,
`docs/reviews/`, `docs/automated-tests/`, `docs/revendor/`, `docs/perf-analysis/`.

### Required (documentation-§3, Tier 1)

| Doc | Covers |
|---|---|
| `scope.md` | What the showroom is for, who uses it, and what it deliberately is not |
| `module-map.md` | Every non-vendored file, its responsibility, and its load-order constraint |
| `schema.md` | The persisted shape, every default, the window position and the migration seam |
| `settings-panel.md` | The panel tree, the General page's tabs, and the write seam |
| `data-flow.md` | A skin pick (card, tab or `/st set`) to a repainted showroom; `/st` to an open window; login |
| `common-tasks.md` | Recipes for the changes made most often here |

### Conditional (documentation-§3, Tier 2)

| Doc | Status | Trigger |
|---|---|---|
| `slash-dispatch.md` | Present | 17 commands in `COMMANDS`, over the eight-command threshold |
| `debug.md` | Present | The diagnostics report (`/st diagnostics`, debug-logging-§14); never Not applicable |
| `profiles.md` | Present | The Profiles sub-page (`settings/Profiles.lua`) is a profile control in the options UI |
| `perf-analysis/README.md` | Present | The performance harness is wired (`core/PerfSetup.lua`) |
| `midnight-quirks.md` | Present | Always: carries the vendored client-quirks catalog (client-quirks-§1), then the addon's own section, which is empty |
| `forever-quirks.md` | Present | Clients `Retail · Forever`: carries the vendored forever-quirks catalog (forever-quirks-§1), then the addon's own section, which is empty |
| `compat-layer.md` | Not applicable | No compat family: the addon makes no deprecated or version-variant client call outside LibKa0s's majors (compat's applicability condition), so there is no `core/Compat.lua` |
| `message-bus.md` | Not applicable | No messages defined (see `## Message Bus`) |
| `known-limitations.md` | Not applicable | `## Known Limitations` is well under the spill threshold |
| `taint.md` | Not applicable | `## Taint Notes` is well under the spill threshold |

### Verification and record

| Doc | Covers |
|---|---|
| `testing.md` | How to run the harness and lint; the green commit gate |
| `smoke-tests.md` | The in-game smoke-test suite |
| `test-cases.md` | The generated case inventory (authoritative pass count) |
| `performance.md` | The addon's performance page |
| `automated-tests/README.md` | What the automated-test record is and how to produce it |
| `automated-tests/RESULTS.md` | One row per run; generated, never hand-edited |

### Addon-specific (documentation-§3, Tier 3)

None yet.

## Documented deviations

The **single home** for a ratified deviation from the Ka0s WoW Addon Standard (`documentation-§3`). A
deviation not in this table is not ratified. **Re-check trigger** is the condition that ends it.

| Rule | What differs | Why | Decided | Re-check trigger |
|---|---|---|---|---|
| `options-ui-§1` | **Route (b), not the SHOULD route (a), for `enabled` on a library-absent load.** Without LibKa0s the Master controls block is not composed (the hollow composer), so `enabled` has no schema row and the seam refuses the row-less path. No `writeThrough` list is passed, and `/st enable` and `/st disable` print `<verb> is unavailable: the LibKa0s library did not load.` instead (`settings/Slash.lua`), with no Lua error, no write and no acknowledgment. | The tester is born from the same settings runtime as Ka0s WhatGroup, which took this route under its owner's ruling (WhatGroup#22); a skin tester with no skin library has nothing to enable, so the switch it would gain shows nothing. | 2026-10-26 | A report of a library-absent install that needs the switch, or `options-ui-§1` raising (a) to a MUST |
| `slash-commands-§7` | **Step 1 pins `R_on` empty, and step 6 (no handler runs on a fire) has nothing to fire.** The conformance suite asks for a non-empty registration set while enabled, torn down to empty by the stand-down. This addon registers no event, message or bucket, so `tests/test_disabled.lua` asserts `R_on` is empty enabled and disabled alike, and step 6 is not applicable. The library's own EllesmereUI watcher frame (`Skin.__euiEventFrame`) is excluded, because it is LibKa0s's registration, not this addon's. | The showroom is a window the player opens: it watches nothing. Inventing a registration to tear down would be test theater. The stand-down is still real: the window closes and every route back to the screen refuses. | 2026-10-26 | The first event, message or bucket this addon registers: step 1 turns red, and its teardown arrives with it |
| `skinning-§3`, `skinning-§9` | **Ignore settings panel defaults to off** (`skin.ignorePanel = false`, `defaults/Profile.lua`). The standard has it on in every profile, so a settings panel stays stock until the player clears it. No migration writes it: a profile that stored `true` keeps it, and one that left the box at the old ticked default takes the new one, since AceDB never stored it. The Skin tab's "Copy to every Ka0s addon..." still carries this addon's Scope to the others as the library does, but another addon's copy or Apply to all never writes this addon's Scope: it registers with `keepScope = true` (LibKa0s Skin minor 17, `core/SkinSetup.lua`; SF1-ST). Every other Ka0s addon keeps the standard's default. | The tester is the skin showroom. Its "(Scope: panel)" samples (AceGUI Dropdown, Ka0sMedia_Font, Ka0sMedia_Statusbar, the TreeGroup) go through PaintAce, which paints nothing while the panel is ignored, so with the box on by default they showed stock and hid the very skin they exist to show (smoke round 1, item 1). Owner's answer 4 of smoke round 2 (2026-11-17, SR2-STP), reversing ruling R8 of 2026-11-10 (QFE-ST2), which had reversed R4-ST1 of 2026-11-03: "The Skin Tester exists to show skinning, so stock samples by default defeat its purpose." | 2026-11-17 | The standard letting a showroom or developer addon default the Scope off, or the showroom's AceGUI samples moving to a window paint, which ends the need |
| `standalone-windows` (*Which marks a window owes, and where they go*, v2.115.0) | **The Skin showroom, this addon's primary window, carries no lock mark.** Its header carries the settings mark and the close (`W.HeaderButtons`, `modules/Showroom.lua`), and no `lock` / `unlock` extra. | A developer tool with no lock concept: the showroom is always draggable by its title bar (its dropped position is remembered through `NS.Windows`, and the settings panel's Reset position forgets it), and it has no *Locked* setting, `/st lock` verb or launcher *Locked* entry for a mark to toggle. Owner waiver of 2026-11-19 (Ka0sAddonsCommonTasks `docs/2026-11-19-ADOPTION_FEEDBACK/inputs/OWNER_FEEDBACK.md`, the HUD header rulings; AF-WVR-ST). | 2026-11-19 | The showroom gaining a locked setting (a *Locked* row, a `/st lock` verb or a launcher *Locked* entry), or its position persistence growing past the remembered drop into anything a lock would guard |

### Files over the 1500-line cap

The `layout-§1` census: every authored `.lua` file this repository tracks that is over the 1500-line
cap, with its terminal state. Vendored code (`libs/`, `tests/_kit/`) is out of scope.

Nothing is over the cap today. `tests/_kit/test_layout_cap.lua` holds this census to the tree on every
run.
