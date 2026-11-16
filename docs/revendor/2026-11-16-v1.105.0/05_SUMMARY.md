# 05 Summary

- Tag moved v1.94.0 -> v1.105.0 (local tag `79b1d9c4`), base taken from the CLAUDE.md provenance line. Kit
  revision 53 -> 57. 33 files moved a minor, ten of them new: see 01_DELTA.md.
- Span bundle: `docs/revendor/2026-11-16-v1.94.0-v1.94.0/` (one tag, v1.94.0). Base correction: none.
- Delivered for free (class A): see 02_CANDIDATES.md.
- Contract blockers: none needing a decision. Fixed in the re-vendor commit:
  - `tests/loader.lua`: the explicit library list gains the ten new payload files in XML order (Tooltip, Role,
    Callout, CalloutSettings, WaypointArrow, WaypointArrowSettings, WidgetsDragHandleTip, WidgetsHeader, WidgetsBar,
    OptionsSkinPickerQueue).
  - `core/DebugLogSetup.lua`: the library-absent stub gains `Report` (streams to chat, answers the line count) and
    `Serialize` (one line).
  - `settings/OptionsSetup.lua`: the Options stub gains an inert `SideTabs`.
- LibKa0s icons: line kept as written. Prune removed 214 Open Iconic icons and 362 sound files; the Open Iconic
  credit in the README stays (that set still ships). No provenance split, no dead stub mirror.
- Adopted: nothing. Declined: nothing. Owed in phase [3]: #89, #86, #79, #88, #92, #87 (02_CANDIDATES.md).
- Gate: `ka0s-bounded lua tests/run.lua` 890 passed, 0 failed, 1 skipped (retail) and the same with
  `KA0S_KIT_CLIENT=forever`; the skip is the diagnostics opt-out case, skipped before too.
  `ka0s-bounded luacheck .` 0 warnings / 0 errors in 83 files. Largest authored file 1099 lines
  (`docs/test-cases.md`, regenerated, unchanged).
