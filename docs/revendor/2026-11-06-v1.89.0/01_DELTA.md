Delta: LibKa0s v1.85.0 -> v1.89.0

Part of Ka0sAddonsCommonTasks `docs/2026-11-06-REVENDOR_LIBKA0S_V1_89/` (item `V89-ST`). The tag is
pushed (`0bd4839`). Payload from `git -C ../LibKa0s archive v1.89.0 LibKa0s testkit tools`, extracted
to a scratch directory outside the tree.

## Step 0 (pre-flight)

The run's lead ran it for the roster (`inputs/step0-preflight.txt` in the run bundle). This addon's row:
`LibKa0sSkinTester  2026-11-01-v1.85.0  base v1.84.0  vendored-before v1.84.0@0cbd665  ok`. No base
correction is owed.

## Base (3a, 3b)

- `grep -n '[Bb]undles' CLAUDE.md` gives `40:Bundles [LibKa0s](https://github.com/tusharsaxena/LibKa0s) v1.85.0 (MIT).`
- `git log -1 --format=%H -- libs/LibKa0s tests/_kit` is `ddad584` (R6-RV2, the v1.85.0 re-cut), and its
  `CLAUDE.md` names v1.85.0. No `CLAUDE.md` commit since rolls the line. Claim and payload agree.
- The minors grep over `libs/LibKa0s/*.lua` reads the v1.85.0 values (Widgets 22, Toast 3,
  DebugLogDiagnostics 6). The line and the bytes agree.
- `git -C ../LibKa0s log --oneline v1.85.0..v1.89.0` lists 27 commits;
  `git -C ../LibKa0s diff --stat v1.85.0 v1.89.0` reports 83 files changed.

## Per-file minors (3c), moved files only

`for f in the tag's LibKa0s.xml files: grep the [A-Z_]*MINOR constant, old against tag`. Every other file
is at its v1.85.0 minor.

| File | old | new |
|---|---|---|
| Toast.lua | 3 | 4 |
| Widgets.lua | 22 | 23 |
| DebugLogDiagnostics.lua | 6 | 7 |
| IconBrowserSources.lua | (new) | 1 (`LibKa0s-IconBrowser-1.0`) |
| IconBrowserWindow.lua | (new) | 1 |
| IconBrowser.lua | (new) | 1 |

No cross-major skew: no file in the addon is ahead of, or missing from, the tag apart from the three new
IconBrowser files.

## Diffs (3d), before the copy

`diff -rq [--strip-trailing-cr] <scratch>/LibKa0s libs/LibKa0s`, ignoring `media/icons`:
`DebugLogDiagnostics.lua`, `LibKa0s.xml`, `Toast.lua` and `Widgets.lua` differ, and the three
`IconBrowser*.lua` files are only in the tag. Content and bytes give the same list, so there is no
line-ending drift. Under `media/icons` there are only `Only in <scratch>` lines (the undeclared icons):
no `differ` and no `Only in libs/LibKa0s` line.

`diff -rq [--strip-trailing-cr] <scratch>/testkit tests/_kit`: `README.md`, `framework.lua` and
`mock_ace.lua` differ. Content and bytes agree.

## Consumption (3e)

`grep -rnoE 'LibStub\("LibKa0s-[A-Za-z]+-1\.0", true\)' . --include='*.lua'`, outside `libs/` and `tests/`:
Core, DebugLog, Env, Launcher, Lifecycle, Media, Options, Perf, Schema, Skin, Slash and Widgets
(`modules/Selector.lua`, `modules/ShowroomControls.lua`, `modules/ShowroomOverlays.lua`,
`modules/ShowroomWidgets.lua`). Of the moved majors, the addon consumes Widgets and DebugLog. Toast and
IconBrowser have no lookup.

## Kit (3f)

`grep -n 'Kit.VERSION'`: tag 51, addon 50. The pairing rule (kit 11 or newer with LibKa0s 1.9.0 or newer)
holds by construction, since both payloads are copied whole in one commit.

## Contract delta (3g)

- Widgets: `diff` of `docs/api/Widgets/version-22.5.12.6.7.5-docs.md` (v1.85.0) against
  `version-23.5.12.6.7.5-docs.md` (v1.89.0). Every change is additive and `W.ContextMenu`-only (rows
  gain `submenu`, `radio` and `selected`, and `opts.check`). The new document's lines 19-40 say "Every
  single-level menu, a dropdown's and a host's, is unchanged". Its `What a consumer owes` reads "nothing
  for a flat menu; a re-vendor". At line 1236 a dropdown's menu still has no sub-menus. This addon calls
  `W.Dropdown`, `W.Autocomplete`, `W.CopyWindow`, `W.DragHandle`, `W.LineChart`, `W.SearchBox` and
  `W.TestStrip`. It calls no `W.ContextMenu`.
- DebugLog: `version-22.6.1.4-docs.md` against `version-22.7.1.4-docs.md`. The only change is that the
  report's `LibKa0s running:` line names IconBrowser (CHANGELOG v1.86.0, "DebugLogDiagnostics minor 7").
  No member moves.
- `grep -rn '__Attach[A-Za-z]*'` outside `libs/` and `_kit/` finds nothing, so the addon supplies no
  host member the library calls back.

No contract change reaches this addon.

## Blockers

- **The runner's explicit library list.** `tests/loader.lua` lists the payload's Lua files in XML order.
  `tests/test_harness.lua` compares that list against `LibKa0s.xml` and fails with "same number of
  library files (expected 67, got 64)". A probe copy of the tree outside the repo showed this. The tag's
  XML loads `IconBrowserSources.lua`, `IconBrowserWindow.lua` and `IconBrowser.lua` between
  `OptionsMedia.lua` and `Perf.lua` (`LibKa0s.xml:58-60`). Fixed in the re-vendor commit by adding the
  three files at that position.
- No Toast instance stub exists (`grep -rn 'Toast' core modules settings` finds none). The v1.88.0
  `SetStack`, `Visible` and `FrameFor` stub members are therefore not owed.

## Span (3h)

The audit walk plus the provenance-roll walk since the store's horizon (2026-10-31) gives vendored tags
v1.83.0, v1.84.0 and v1.85.0. The recorded tags are v1.78.0 through v1.85.0. Nothing is unrecorded, so
no span bundle is written.

## Icon declaration (3i)

`grep -n 'LibKa0s icons:' CLAUDE.md` gives line 41, the next non-blank line under the provenance line:
`chevron-down, chevron-up, clear, close, confirm, copy, eye, info, move, reset, settings, volume-high`.
The line is **kept**. The library-drawn set at the tag (`docs/releasing.md`, "Library-drawn icons are
the host's to declare") adds only `search` and `close`, both for an icon browser, and this addon builds
none. Widgets 23's new `radio` and `selected` tick is `confirm`, which is already declared, and the
submenu arrow is client art (`Interface\ChatFrame\ChatFrameExpandArrow`), not a catalog name. There is
no provenance split. Hand lists have drifted before (KickCD `tests/test_mediasetup.lua:28`, WhatGroup
`tests/test_mediasetup.lua:19`), so the owner's in-client smoke stays the backstop for a forgotten name.

## Whole-folder icon tests (3j)

`grep -rn "media/icons\|lib.ICONS\|\.ICONS)" tests --include='*.lua'` hits `tests/test_mediasetup.lua:126,
139, 165-174, 187, 259`. These lines were already narrowed to the declaration at v1.85.0 and pass against
the pruned probe. Nothing is owed.

## Dead stub mirrors

`grep -rn '__releaseChrome'` outside `libs/` and `_kit/` finds nothing.
