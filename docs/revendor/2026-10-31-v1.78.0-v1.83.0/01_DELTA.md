Delta: LibKa0s v1.78.0 -> v1.83.0 (span: v1.78.0 v1.79.0 v1.80.0 v1.81.0 v1.82.0 v1.83.0)

# 01 — Delta (consolidated span)

Written 2026-10-31 by item FX-ST-DOCS of the findings remediation
(`Ka0sAddonsCommonTasks/docs/2026-10-31-FINDINGS_REMEDIATION/`). This addon has vendored six LibKa0s
tags and given none of them a bundle; this span records them (the revendor command's step 3h). It
writes no copy: `libs/LibKa0s/` and `tests/_kit/` stay as they are, at v1.83.0.

## The listing

The standards audit's re-vendor walk, run from the repo root. `docs/revendor/` did not exist, so
there is no horizon and the walk covers the whole history:

```sh
tag_at() { git show "$1:CLAUDE.md" 2>/dev/null |
  grep -oE 'Bundles \[LibKa0s\]\([^)]*\) v[0-9]+\.[0-9]+\.[0-9]+' |
  grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | head -1; }
{ git log --format=%H -- libs/LibKa0s tests/_kit
  git log --format=%H -- CLAUDE.md | while read -r c; do
    [ "$(tag_at "$c")" != "$(tag_at "$c^")" ] && echo "$c"; done
} | while read -r c; do tag_at "$c"; done | sed '/^$/d' | sort -uV
```

Output, with nothing recorded to subtract:

```
v1.78.0
v1.79.0
v1.80.0
v1.81.0
v1.82.0
v1.83.0
```

## The commits that carried them

- v1.78.0: `50bf43b` the scaffold, then ten commits changing the payload for the tag's re-cuts,
  `3eed31f` to `ce468f9`: eight re-vendors, plus `4f2b793` (SF-40) and `792d1cf` (SF-46).
- v1.79.0: `81fe27b`, two branch-head re-vendors `b31f021` and `4540e17`, then the tag at `6e2a0af`.
- v1.80.0: `b832aff`.
- v1.81.0: `15cc034`.
- v1.82.0: `7eab05c`.
- v1.83.0: `339b847`, then the re-cuts at `d176f04` and `1fab9f1`.

## What moved across the span

`git diff --stat v1.78.0 v1.83.0 -- LibKa0s testkit` in the library: 73 files, 8581 insertions, 608
deletions. `tests/_kit/` went from kit revision 43 to 46.

Per-file minors, v1.78.0 -> v1.83.0, new files marked:

| File | Minor | File | Minor |
|---|---|---|---|
| `Core.lua` | 13 -> 14 | `OptionsWidgets.lua` | 35 -> 38 |
| `DebugLogDiagnostics.lua` | 4 -> 5 | `PerfPanel.lua` | 10 -> 11 |
| `DebugLogWindow.lua` | 1 -> 2 | `SimPanel.lua` | 7 -> 8 |
| `Media.lua` | 8 -> 11 | `Skin.lua` | 5 -> 10 |
| `Options.lua` | 33 -> 34 | `SkinAce.lua` | 3 -> 5 |
| `OptionsAppearance.lua` | 2 -> 5 | `SkinDefs.lua` | 13 -> 18 |
| `OptionsCompose.lua` | 12 -> 14 | `SkinEUI.lua` | 1 -> 2 |
| `OptionsDrawer.lua` | 2 -> 3 | `SkinPaint.lua` | 10 -> 13 |
| `OptionsIdList.lua` | 6 -> 7 | `SkinPaintControls.lua` | 8 -> 11 |
| `OptionsIds.lua` | 4 -> 5 | `SkinPaintExtras.lua` | 3 -> 7 |
| `OptionsKeybinds.lua` | 5 -> 6 | `Toast.lua` | new, 1 |
| `OptionsMedia.lua` | new, 1 | `Widgets.lua` | 16 -> 17 |
| `OptionsNav.lua` | 3 -> 4 | `WidgetsAutocomplete.lua` | 4 -> 5 |
| `OptionsRegistry.lua` | 3 -> 4 | `WidgetsCopyWindow.lua` | 1 -> 2 |
| `OptionsScroll.lua` | 8 -> 9 | `WidgetsDragHandle.lua` | 6 -> 8 |
| `OptionsSkinPicker.lua` | new, 4 | `WidgetsLineChart.lua` | 4 -> 5 |
| `OptionsSwitch.lua` | new, 1 | `WidgetsReorder.lua` | 2 -> 3 |
| `OptionsTabs.lua` | 10 -> 11 | | |

There is no earlier bundle, so no base needs correcting. v1.78.0 is the base because it is the first
tag this addon carried.
