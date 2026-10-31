# Refresh 2 of v1.84.0

Item `M4-RV` of the 2026-10-31 findings remediation. The tag `v1.84.0` moved again before it was pushed:
`git -C ../LibKa0s ls-remote --tags origin v1.84.0` prints nothing, so this is a refresh and not a new
re-vendor. No new bundle folder, and line 1 of `01_DELTA.md` stands.

- Old commit: `7a8bc0f133ed118d2c79c7c5288b97964e24fae5` (the one `06_REFRESH_1.md` names).
- New commit: `b5229b876e803768322fb4d8c66be69f01c8e4a1`, from `git -C ../LibKa0s rev-parse v1.84.0^{commit}`.
- Why it moved: the owner's ruling of 2026-11-01 against keeping the stub. `LK-M4` deletes
  `lib.__PatchLSM30Border` outright.

## Per-file minor delta

Step 3c's loop run against each commit. Only these moved.

| File | Old | New |
|---|---|---|
| `Options.lua` | 36 | 37 |
| `OptionsDrawer.lua` | 3 | 4 |
| `OptionsMedia.lua` | 2 | 3 |

`tests/_kit/` did not move: `diff -rq` against the tag's `testkit` is clean.

## What arrived

Class A, on the copy: the member is gone. No blocker. `grep -rn '__PatchLSM30Border'` over the repo
outside `.git` and `docs/` finds no authored call, stub or test in this addon, before or after the copy;
the only hit left is the history comment at `libs/LibKa0s/Options.lua:46`. So nothing was removed from
authored code here, and no guard or stub was added. Nothing to adopt.

## Gate

Copy and prune as Step 4: `diff -r --strip-trailing-cr` empty before the prune, and after it only
undeclared icons differ. Prune: 5 icons declared, kept 6 files, removed 5834. `CLAUDE.md` is unchanged,
because the tag name did not move.

- `ka0s-bounded luacheck .`: 0 warnings / 0 errors in 80 files.
- `ka0s-bounded lua tests/run.lua`: 616 passed, 0 failed, 1 skipped, 617 total.
