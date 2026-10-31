# Refresh 1 of v1.84.0

Item `M3-RV` of the 2026-10-31 findings remediation. The tag `v1.84.0` moved before it was pushed:
`git -C ../LibKa0s ls-remote --tags origin v1.84.0` prints nothing, so this is a refresh and not a new
re-vendor. No new bundle folder, and line 1 of `01_DELTA.md` stands.

- Old commit: `e917ccd` (the one `01_DELTA.md` names).
- New commit: `7a8bc0f133ed118d2c79c7c5288b97964e24fae5`, from `git -C ../LibKa0s rev-parse v1.84.0^{commit}`.
- Why it moved: the owner's ruling of 2026-11-01, `Ka0sMedia_*` is the only media picker (LibKa0s#73).

## Per-file minor delta

Step 3c's loop run against each commit. Only these moved.

| File | Old | New |
|---|---|---|
| `Options.lua` | 35 | 36 |
| `OptionsWidgets.lua` | 40 | 41 |
| `OptionsCompose.lua` | 15 | 16 |
| `OptionsScroll.lua` | 9 | 10 |
| `OptionsMedia.lua` | 1 | 2 |
| `SkinAce.lua` | 5 | 6 |

`tests/_kit/` did not move: revision 47 before and after, `diff -r` clean.

## What arrived

Class A, on the copy: a row naming `LSM30_*` draws the `Ka0sMedia_*` picker whether or not that type is
registered; `O.FontGroup`, `O.BorderGroup` and `O.BarGroup` write `Ka0sMedia_*`; `lib.__PatchLSM30Border`
is a no-op. This addon composes none of those rows and never called the patch, so no blocker: the
3g read, `grep -rn '__PatchLSM30Border\|__lsmBorderPatched' core settings modules defaults tests/*.lua`,
prints nothing.

Nothing to adopt here. `M3-MEDIA` removes the showroom's two `LSM30_*` cells, which asked for a type
outside the library's route. This repo never vendored AceGUI-3.0-SharedMediaWidgets.

## Gate

Copy and prune as Step 4: `diff -r --strip-trailing-cr` empty before the prune, and after it only
undeclared icons differ. Prune: 5 icons declared, kept 6 files, removed 5834. `CLAUDE.md` is unchanged,
since its lines already name v1.84.0.

- `ka0s-bounded luacheck .`: 0 warnings / 0 errors in 80 files.
- `ka0s-bounded lua tests/run.lua`: 616 passed, 0 failed, 1 skipped, 617 total.
