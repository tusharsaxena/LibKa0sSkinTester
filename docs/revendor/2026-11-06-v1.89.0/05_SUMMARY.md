# Summary

- **Tag:** v1.85.0 -> v1.89.0. The base comes from the provenance line, and the payload at `ddad584`
  agrees with it. Kit 50 -> 51. Moved minors: Toast 3 -> 4, Widgets 22 -> 23, DebugLogDiagnostics
  6 -> 7. New major `LibKa0s-IconBrowser-1.0`: IconBrowserSources, IconBrowserWindow and IconBrowser,
  each at 1. The full table is in `01_DELTA.md`.
- **Span and base:** no span bundle (nothing unrecorded since 2026-10-31), and no base correction
  (Step 0 is `ok`). No refresh file.
- **For free (class A):** the diagnostics report names IconBrowser, kit 51's CallbackHandler unregister
  guard, and flat dropdown menus unchanged under Widgets 23.
- **Contract blockers (3g):** none. The Widgets 23 and DebugLog 22.7.1.4 documents change nothing this
  addon calls, and the addon has no `__Attach*` site.
- **Other blocker:** `tests/loader.lua`'s explicit library list gains `IconBrowserSources.lua`,
  `IconBrowserWindow.lua` and `IconBrowser.lua` after `OptionsMedia.lua`, in XML order. The harness case
  "the explicit LibKa0s list matches LibKa0s.xml" required it. Fixed in the re-vendor commit.
- **Icons:** the `LibKa0s icons:` line is kept as it was (12 names, all Open Iconic). The prune kept 13
  files (12 icons and the license) and removed 5827. Those 5827 are the catalog the full copy brought
  back, so the tree's tracked icon set is unchanged. No provenance split.
- **README credits:** unchanged, because no shipped set changed. There were no dead stub mirrors to
  remove.
- **Adopted:** nothing, since the plan names no adoption for this addon. **Declined:** nothing, and no
  issue was filed.
- **Undecided:** a Showroom sample of a skinned `W.ContextMenu` cascade (`02_CANDIDATES.md`). The
  plan's table does not cover it, so it was reported to the run's lead.
- **Gate at the copy:** `ka0s-bounded luacheck .` reports 0 warnings and 0 errors in 83 files.
  `ka0s-bounded lua tests/run.lua` reports 887 passed, 0 failed, 1 skipped, 888 total. The suite's
  layout-cap gate covers the 1500-line cap and passes.
