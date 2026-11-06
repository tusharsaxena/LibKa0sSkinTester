# Summary

- **Tag:** v1.89.0 -> v1.90.0 (a local tag, `4485b8f`, not pushed). The base comes from the provenance
  line, and the payload at `da85eef` agrees with it. Kit 51 -> 51 (unchanged). Moved minors: Core
  15 -> 16, Skin 16 -> 17, SkinPaint 18 -> 19, SkinPaintExtras 17 -> 18, Widgets 23 -> 24,
  WidgetsAutocomplete 7 -> 8, OptionsAppearance 6 -> 7. The table is in `01_DELTA.md`.
- **Span and base:** no span bundle (nothing unrecorded since 2026-10-31), no base correction (Step 0
  is `ok`), no refresh file.
- **For free (class A):** every Widgets edge in the showroom is one physical pixel at any UI scale
  (SF1-L1), the EditBox edge of feedback item 3 included.
- **Contract blockers (3g):** none. Every moved document says the host owes nothing, apart from the
  Options document's `keepScope` for a host whose Scope is a documented deviation, which is this
  addon's adoption below, not a blocker.
- **Icons:** the `LibKa0s icons:` line is kept (12 names, all Open Iconic). The prune kept 13 files and
  removed 5827, the catalog the full copy brought back, so the tracked icon set is unchanged. No
  provenance split. README credits unchanged. No dead stub mirrors.
- **Adopted:** `keepScope = true`, as `SF1-ST` (its own commit, after this one).
- **Declined:** nothing, no issue filed. **Unreached:** nothing.
- **Gate at the copy:** `ka0s-bounded luacheck .` reports 0 warnings and 0 errors in 83 files.
  `ka0s-bounded lua tests/run.lua` reports 893 passed, 0 failed, 1 skipped, 894 total. The suite's
  layout-cap gate covers the 1500-line cap and passes.
