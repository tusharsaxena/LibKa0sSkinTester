# 05 Summary

- Tag moved v1.107.0 -> v1.108.0 (local tag `56c20b76`), base taken from the CLAUDE.md provenance line. Kit
  revision 57 -> 58. Seventeen files moved a minor (01_DELTA.md, 3c); none added or removed.
- Span bundle: none. Base correction: none.
- Delivered for free (class A): the footer's shown-marks layout, the secret-rect tooltip fallback, the owned menu's
  tinted submenu arrows (the Library widgets cascade), and the library defaults that follow the skin, none of which
  this addon overrides.
- Contract blockers: none. The kit's revision 58 checks found two things, both fixed in the copy's commit: the
  Values GetFont line drew the skin's face with no color (now `text.body` and the window flags; SD-SK-ST.3), and
  the scanner's new `return` triples read `rgba`'s fallback in `modules/ShowroomTextures.lua` (a row, category
  `unreachable default`).
- LibKa0s icons: line kept as written. Prune removed the undeclared icons and 362 sound files; README credits
  unchanged (Open Iconic still ships). No provenance split, no dead stub mirror.
- Standard reference refreshed to v2.116.0 in the same commit, from the local WowAddonStandards checkout on
  `feat/2026-11-20-libka0s-94-97-99-100`: the `docs/midnight-quirks.md` vendored block restamped v2.115.0 ->
  v2.116.0 (the catalog `standards/client-quirks.md` is byte-identical between them). The TOC `X-Standard`, the
  README badge and the CLAUDE.md compliance section were already current; no `§N.M` notation and no out-of-range
  `filename-§N` citation.
- Adopted: nothing. Declined: nothing. Not adopted and noted: `W.OwnerWarnings` (02_CANDIDATES.md).
- New smoke checks: SHOW-57 (the GetFont line) and SHOW-58 (the cascade's submenu arrows).
- Gate: `ka0s-bounded lua tests/run.lua` 916 passed, 0 failed, 1 skipped (retail) and the same with
  `KA0S_KIT_CLIENT=forever`; `ka0s-bounded luacheck .` 0 warnings / 0 errors in 83 files.
