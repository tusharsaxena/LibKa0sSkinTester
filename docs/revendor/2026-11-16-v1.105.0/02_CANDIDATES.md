# 02 Candidates

Not interviewed in this run. The run's plan (`Ka0sAddonsCommonTasks/docs/2026-11-16-LIBKA0S_ISSUES_75_PLUS/`,
`03_ADOPTION_PLAN.md`) defers every adoption to its phase [3]. Listed here as **owed in phase [3]**, with the
LibKa0s issue that tracks each:

| Issue | Surface | This addon's site | Class |
|---|---|---|---|
| #89 | `W.Footer` (24 px) | The Showroom's hand-built 22 px footer (`modules/Showroom.lua`) | B, replaces host code |
| #86 | `W.HeaderButtons` | The Showroom's title bar and close (`modules/Showroom.lua`) | B, replaces host code |
| #79 | `D:Report` / `D:Serialize` | The `widths` verb (`settings/Slash.lua:27`) | B, replaces host code |
| #88 | Docked test/sim strip | One strip per showcase cell (`modules/ShowroomOverlays.lua`); a specimen, likely kept as a showcase | B, ruling at adoption |
| #92 | `LibKa0s-Tooltip-1.0` placers | No own `:SetOwner(` site found (`grep -rn ":SetOwner(" core modules settings`); confirm at adoption | B, likely none |
| #87 | `Sim.Sample(client)` | Any own sample names in its sim/test data; confirm at adoption | B |

Not applicable: #80 `W.Bar` and #81 launcher `extraEntries` (Skill Master only), #85 Callout (DpsRace, DropWatcher,
QuickComms, Skill Master only).

Delivered on the copy alone (class A): the library's own tooltips through the placers (skin picker toolbar tips
below, dropdown entries beside the menu, icon browser and sim panel tips), the settings mark on the debug console,
copy window, perf panel and sim panel, the skin picker's gear in its header, the moved `icon.hot` and Ka0s Default
list tokens (SkinDefs 28, SkinDefsOthers 10), and the console footer.
