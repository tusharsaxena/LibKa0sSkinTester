# 05 Summary

- Tag moved v1.106.0 -> v1.107.0 (local tag `5e963659`), base taken from the CLAUDE.md provenance line. Kit
  revision 57 -> 57. Two files moved a minor: WidgetsDragHandle 14 -> 15, WidgetsDragHandleTip 1 -> 2.
- Span bundle: `docs/revendor/2026-11-19-v1.106.0-v1.106.0/` (one tag, v1.106.0). Base correction: none.
- Delivered for free (class A): the strip's marks read `?`, settings, close in the window header's tints at the
  tighter pitch, with the gear on by default, and the strip's tooltip opens above it. Reaches the showroom's
  DragHandle specimen, which now shows `?` and the gear.
- Contract blockers: none. Nothing beyond the copy needed fixing.
- LibKa0s icons: line kept as written (`settings` already declared). Prune removed the undeclared icons and 362
  sound files; README credits unchanged (Open Iconic still ships). No provenance split, no dead stub mirror.
- Standard reference refreshed to v2.115.0 in the same commit: the `docs/midnight-quirks.md` vendored block
  replaced wholesale (v2.103.1 -> v2.115.0). The TOC `X-Standard`, the README badge and the CLAUDE.md
  compliance section were already current; no `§N.M` notation and no out-of-range `filename-§N` citation.
- Adopted: nothing. Declined: nothing. The specimen's default strip is kept (03_DECISIONS.md, AF-WVR-ST).
- Gate: `ka0s-bounded lua tests/run.lua` 914 passed, 0 failed, 1 skipped (retail) and the same with
  `KA0S_KIT_CLIENT=forever`; the skip is the diagnostics opt-out case, skipped before too.
  `ka0s-bounded luacheck .` 0 warnings / 0 errors in 83 files.
