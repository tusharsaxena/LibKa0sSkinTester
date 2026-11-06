# Summary

- **Tag:** v1.90.0 -> v1.91.0 (a local tag, `55bfbb4`, not pushed). The base comes from the provenance
  line, and the payload agrees with it. Kit 51 -> 51 (unchanged). Moved minors: Core 16 -> 17,
  SkinPaintExtras 18 -> 19, Widgets 25 -> 26, WidgetsLineChart 6 -> 7. New files at minor 1:
  CorePixel, SkinPaintHud, SkinAceConfirm, WidgetsDropdown. The table is in `01_DELTA.md`.
- **Span and base:** no span bundle (nothing unrecorded since 2026-10-31), no base correction (this
  addon's Step 0 row is `ok`; the collection-wide Step 0 was skipped because the installed skill's
  roster regex matches nothing), no refresh file.
- **For free (class A):** the showroom's line chart draws its axis, grid, markers, crosshair and series
  in physical pixels at any UI scale (FU-L1). The four peels are internal.
- **Contract blockers (3g):** none. Every moved document says the host owes nothing.
- **Other blockers, fixed in the re-vendor commit:** `tests/loader.lua` lists the four new files in
  `LibKa0s.xml` order. No minor pins and no stub mirrors needed moving.
- **Icons:** the `LibKa0s icons:` line is kept (12 names, all Open Iconic). The prune kept 13 files and
  removed 5827, the catalog the full copy brought back, so the tracked icon set is unchanged. No
  provenance split. README credits unchanged. No dead stub mirrors.
- **Adopted:** nothing. **Declined:** nothing, no issue filed. **Unreached:** nothing.
- **Gate at the copy:** `ka0s-bounded luacheck .` reports 0 warnings and 0 errors in 83 files.
  `ka0s-bounded lua tests/run.lua` reports 894 passed, 0 failed, 1 skipped, 895 total. The suite's
  layout-cap gate covers the 1500-line cap and passes.
