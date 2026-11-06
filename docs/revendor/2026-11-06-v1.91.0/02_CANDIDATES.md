# Candidates

Sources: `git -C ../LibKa0s log --oneline v1.90.0..v1.91.0`, the tag's `CHANGELOG.md` block for v1.91.0,
and the *What changed* sections in `docs/api/Core/version-17.1-docs.md`,
`docs/api/Widgets/version-26.1.6.13.7.8.5-docs.md` and
`docs/api/Skin/version-17.1.27.8.19.19.1.1.17.4.9-docs.md`.

## A. Delivered on the re-vendor (not offered)

- **The line chart's lines in physical pixels (FU-L1)**: WidgetsLineChart 7. The showroom's
  `W.LineChart` sample (`modules/ShowroomWidgets.lua:117`) draws its axis, grid rules, markers,
  crosshair and series at one physical pixel (series 1.5 px) at any UI scale, re-sized on a scale
  change (Widgets doc `:33`, "What a host owes: nothing").
- **The four peels (FU-L2)**: `CorePixel.lua`, `WidgetsDropdown.lua`, `SkinPaintHud.lua` and
  `SkinAceConfirm.lua`. Pure moves; no member, option or behaviour changes. They arrive with the copy
  and the `LibKa0s.xml` that loads them. The test loader's file list is a blocker, fixed in the
  re-vendor commit (`01_DELTA.md`, *Blockers*), not a candidate.

## B. Host change required

None. v1.91.0 adds no member, option or row field.

## C. Whole-module adoption

None. No new major at v1.91.0.
