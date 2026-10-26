# Performance

## The harness is wired

`core/PerfSetup.lua` builds `NS.Perf` from LibKa0s-Perf-1.0. The `perf` verb is registered by the
addon (`settings/Slash.lua`), the capture ring is `LibKa0sSkinTesterPerfDB`, and the harness takes its
`perf` hold on the addon's one latch, so a suspended addon is exactly a stood-down one.

## Buckets

| Key | Within | What it times | Where |
|---|---|---|---|
| `build` | — | The showroom's first build: the window and every section | `modules/Showroom.lua` `build()` |
| `repaint` | — | One skin change as the showroom sees it, from the library's `OnLooksChanged` | `modules/Showroom.lua` |

The library's own repaint (`Skin:Repaint`) runs before `OnLooksChanged` fires and is the library's
to measure.

## The bracket idiom

```lua
local t0 = Perf.on and debugprofilestop()
-- ... work ...
if t0 then Perf.Note("build", debugprofilestop() - t0) end
```

With capture off each bracket costs one upvalue read, one field read and one boolean test
(performance-§2).

## Offline scenarios (`lua tests/perf.lua`)

Outside the green gate (performance-§9), asserting only deterministic quantities: API calls on the
addon's own frames and bytes allocated per iteration. Run through the automated-test runner; its
output lands in that run's bundle.

| Scenario | What it drives | Ceiling |
|---|---|---|
| `showroomToggle` | `NS.Showroom.Toggle` on the built window | The mock's own Show/Hide record plus 24 bytes: the addon allocates nothing |
| `skinRepaint` | `NS.ApplySkinChoice` alternating two skins with the window open, the `repaint` path | Its measured figure plus 24 bytes |
| `applyScale`, `applyAlpha` | `NS.Showroom.ApplyWindowSettings` after a slider write | 24 bytes and at most 2 API calls (`SetScale`, `SetAlpha`) |

The one-off build is not measured: it runs once per session, before the first scenario.

## In-game captures

The standing store is [`perf-analysis/`](./perf-analysis/README.md). None has been taken yet.
