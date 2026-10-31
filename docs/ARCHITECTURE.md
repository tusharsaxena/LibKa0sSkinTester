# Architecture

What Ka0s Skin Tester is, as built. The rules it follows are the Ka0s WoW Addon Standard's; this page
says how this addon meets them.

## Overview

A skin showroom. `/st` (or `/skintester`) opens one window that shows the elements a Ka0s skin
(`LibKa0s-Skin-1.0`) can paint, in whichever skin the addon is wearing, so a skin can be judged in one
place. The addon is a skin owner like any adopter: the skin it wears is chosen from the swatch cards
across the top of the showroom, on its own General -> Skin tab or in the first-run skin picker, and every sample it shows is
painted through its own facade (`Skin:For`), through one wrapper that records each primitive used, so
the showroom shows exactly what an adopting addon gets and a test can prove every primitive is on
show. It is a roster addon that is never published on
CurseForge. Purpose, audience and non-goals: [`scope.md`](./scope.md).

## Module Map

One shell, the setup files that wire LibKa0s, the swatch selector, the showroom window with its paint
wrapper and section registry, twelve section files (Chrome, Controls, Lists, Text, Panels, Overlays,
Addon surfaces, Library widgets, Values, Textures, Faces and widths, HUD faces), and the settings pages with the first-run skin picker. Every file, its job and its load-order constraint:
[`module-map.md`](./module-map.md). The load order itself is
the TOC, where each load-bearing position carries the reason.

## Settings Schema

One schema (`settings/Schema.lua`) drives the panel, the `/st list|get|set|reset` CLI and the
defaults, over one write seam, `NS.SchemaRuntime.Set` (LibKa0s-Schema-1.0, or the host stub in
`settings/SchemaSetup.lua`). Rows: the composed Master controls (`enabled`, `scale`, `alpha`, the
session-only `state.debugConsole`, the global `global.minimap.shown`), the eight Skin tab rows
(`skin.source`, `skin.skin`, the overrides `skin.font` and `skin.texture`, the font outline `skin.outline`, the Scope's `skin.ignorePanel`,
`skin.ignoreFonts`, and the picker's `skin.pickerSeen`) and the ten Sample controls rows (`sample.*`, on their own page and read
by nothing). The one piece of state outside the seam is the showroom window's
position, `db.global.windows.LibKa0sSkinTesterShowroom`, written only by `NS.Windows.Save` from the
window's drag stop and cleared by `NS.Windows.Forget` (Reset position), both in `core/Util.lua`.
Every path, default and the migration seam: [`schema.md`](./schema.md).

## Message Bus

None. Nothing crosses a module boundary as a message: the sections register with the showroom by
direct call (`NS.Showroom.AddSection`), below the `architecture-§4` threshold. A skin change reaches
the showroom, the selector and the Values, Textures and Addon surfaces sections through the skin
engine's own `OnLooksChanged` notification, not a bus message.

## Slash Commands

`/st` and the alias `/skintester`, dispatched by LibKa0s-Slash-1.0 from the ordered `COMMANDS` table
in `settings/Slash.lua`: the reserved verbs (`skin` among them), plus `show`, the showroom toggle, and `widths`, the width probe. At login a `/st` held
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

## Known Limitations

- With another installed addon that vendors a newer LibKa0s, LibStub runs that copy's files, so the
  showroom shows that copy's skins. While every Ka0s addon vendors the same tag they are identical.
- EllesmereUI's paint is one-way: leaving the EllesmereUI source after it painted needs a reload
  (the library's reload popup says so). For the same reason the swatch selector has no EllesmereUI
  card.
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
| `settings-panel.md` | The panel tree, the General page's tabs, the Sample controls page, and the write seam |
| `data-flow.md` | A skin pick (card, tab or `/st set`) to a repainted showroom; `/st` to an open window; login |
| `common-tasks.md` | Recipes for the changes made most often here |

### Conditional (documentation-§3, Tier 2)

| Doc | Status | Trigger |
|---|---|---|
| `slash-dispatch.md` | Present | 15 commands in `COMMANDS`, over the eight-command threshold |
| `debug.md` | Present | The diagnostics report (`/st diagnostics`, debug-logging-§14); never Not applicable |
| `profiles.md` | Present | The Profiles sub-page (`settings/Profiles.lua`) is a profile control in the options UI |
| `perf-analysis/README.md` | Present | The performance harness is wired (`core/PerfSetup.lua`) |
| `midnight-quirks.md` | Not applicable | The addon carries no client-version workaround of its own |
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

### Files over the 1500-line cap

The `layout-§1` census: every authored `.lua` file this repository tracks that is over the 1500-line
cap, with its terminal state. Vendored code (`libs/`, `tests/_kit/`) is out of scope.

Nothing is over the cap today. `tests/_kit/test_layout_cap.lua` holds this census to the tree on every
run.
