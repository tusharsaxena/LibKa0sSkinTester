Delta: LibKa0s v1.89.0 -> v1.90.0

Part of Ka0sAddonsCommonTasks `docs/2026-11-06-REVENDOR_LIBKA0S_V1_89/` (item `SF1-RV-ST`, from
`SF1_SMOKE_FEEDBACK.md`). The tag is **local** (`4485b8f`), not pushed:
`git -C ../LibKa0s ls-remote --tags origin v1.90.0` prints nothing, which is expected here. This is a new
tag for this addon (its line names v1.89.0), so it is a re-vendor, not a refresh. Payload from
`git -C ../LibKa0s archive v1.90.0 LibKa0s testkit tools`, extracted to a scratch directory outside the
tree.

## Step 0 (pre-flight)

This addon's row: `LibKa0sSkinTester  2026-11-06-v1.89.0  base v1.85.0  vendored-before v1.85.0@da85eef  ok`
(`tag_at da85eef^` is v1.85.0, `tag_at da85eef` is v1.89.0). No base correction is owed.

## Base (3a, 3b)

- `grep -n '[Bb]undles' CLAUDE.md` gives `40:Bundles [LibKa0s](https://github.com/tusharsaxena/LibKa0s) v1.89.0 (MIT).`
- `git log -1 --format=%H -- libs/LibKa0s tests/_kit` is `da85eef` (V89-ST), and its `CLAUDE.md` names
  v1.89.0. Claim and payload agree.
- The minors grep over `libs/LibKa0s/*.lua` reads the v1.89.0 values (Core 15, Skin 16, Widgets 23).
  The line and the bytes agree.
- `git -C ../LibKa0s log --oneline v1.89.0..v1.90.0` lists 7 commits (SF1-L1 `7d42f4e`, SF1-L2
  `b9f7651`, SF1-L3 `4ac9f3c` and `4485b8f`, and the harvest merge and sync-docs before them);
  `git -C ../LibKa0s diff --stat v1.89.0 v1.90.0` reports 37 files changed.

## Per-file minors (3c), moved files only

The 3c loop over the tag's `LibKa0s.xml`. Every other file is at its v1.89.0 minor.

| File | old | new |
|---|---|---|
| Core.lua | 15 | 16 |
| Skin.lua | 16 | 17 |
| SkinPaint.lua | 18 | 19 |
| SkinPaintExtras.lua | 17 | 18 |
| Widgets.lua | 23 | 24 |
| WidgetsAutocomplete.lua | 7 | 8 |
| OptionsAppearance.lua | 6 | 7 |

No new file, no cross-major skew.

## Diffs (3d), before the copy

`diff -rq [--strip-trailing-cr] <scratch>/LibKa0s libs/LibKa0s`, ignoring the `Only in <scratch>` lines
under `media/icons` (the undeclared icons): exactly the seven files above differ. Content and bytes
give the same list, so there is no line-ending drift, and there is no `Only in libs/LibKa0s` line.

`diff -rq [--strip-trailing-cr] <scratch>/testkit tests/_kit`: empty. The kit is unchanged.

## Consumption (3e)

As at v1.89.0: Core, DebugLog, Env, Launcher, Lifecycle, Media, Options, Perf, Schema, Skin, Slash and
Widgets. Of the moved majors the addon consumes Core, Skin, Widgets and Options, all four.

## Kit (3f)

`grep -n 'Kit.VERSION'`: tag 51, addon 51. The pairing rule holds by construction (both payloads copied
whole in one commit).

## Contract delta (3g)

- Core 16 (`docs/api/Core/version-16-docs.md`): pixel edges, all internal (`__PixelSize`,
  `__WatchPixels`, `__OnPixelScale`, `__PixelBackdrop`). No member manifest moves.
- Widgets 24.5.12.6.8.5 (`version-24.5.12.6.8.5-docs.md:27`): "What a host owes: nothing." The
  dropdown, search box, menu and autocomplete edges become one physical pixel.
- Skin 17.1.27.8.19.18.17.4.9 (`version-17.1.27.8.19.18.17.4.9-docs.md:21,31`): additive, "a host's Skin
  facade owes nothing". `RegisterOwner` gains `opts.keepScope` (line 25).
- Options 37.4.44.2.7.2.9.15.2.4.19.13.5.5.7.7.11.1.1.4 (its `:26`): "a host whose Scope is a documented
  deviation registers with `keepScope = true`; every other host owes nothing." This addon's
  `ignorePanel = false` is that case. It is not a broken contract (a copy behaves as it did at v1.89.0),
  so it is not a blocker; it is the run's own item `SF1-ST`, its own commit.
- `grep -rn '__Attach[A-Za-z]*'` outside `libs/` and `_kit/` finds nothing.

No contract change breaks this addon on the copy.

## Blockers

None. A probe of the whole re-vendor (copy, provenance roll, prune) in a scratch copy of the tree ran
`lua tests/run.lua` at 893 passed, 0 failed, 1 skipped. `tests/test_diagnostics.lua:59` reads the Skin
minor live rather than pinning it, and the kit's `mock_paint.lua:188` already has
`SetSnapToPixelGrid`.

## Span (3h)

Vendored since the horizon (2026-10-31): v1.83.0, v1.84.0, v1.85.0, v1.89.0. All are recorded. No span
bundle.

## Icon declaration (3i)

`grep -n 'LibKa0s icons:' CLAUDE.md` gives line 41, directly under the provenance line. **Kept**
unchanged (decided by the run: no new library-drawn name at v1.90.0, whose changes add no icon). No
provenance split. Hand lists have drifted before (KickCD `tests/test_mediasetup.lua:28`, WhatGroup
`tests/test_mediasetup.lua:19`), so the owner's in-client smoke stays the backstop.

## Whole-folder icon tests (3j)

`grep -rn "media/icons\|lib.ICONS\|\.ICONS)" tests --include='*.lua'` hits
`tests/test_mediasetup.lua:126,139,165,166,174,187,259`, already narrowed to the declaration. Nothing owed.

## Dead stub mirrors

`grep -rn '__releaseChrome'` outside `libs/` and `_kit/` finds nothing.
