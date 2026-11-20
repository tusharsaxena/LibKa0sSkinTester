Delta: LibKa0s v1.107.0 -> v1.108.0

# 01 Delta

Written 2026-11-20 by item SD-RV-ST of the Ka0sAddonsCommonTasks run `docs/2026-11-20-LIBKA0S_94_97_99_100/`,
branch `feat/2026-11-20-libka0s-94-97-99-100`. The copy, provenance, declaration and prune half of
`/dev-copilot:wow-revendor-libka0s` (dev-copilot 2.10.1); its adoption interview and its issue filing are skipped,
because the run pre-decides this addon's items (SD-RV-ST, SD-SK-ST).

## 3a. Base

- `grep -n '[Bb]undles' CLAUDE.md` -> `CLAUDE.md:41: Bundles [LibKa0s](...) v1.107.0 (MIT).`
- `git log -1 --format=%H -- libs/LibKa0s tests/_kit` -> `06f8d8a` (the re-cut v1.107.0), whose CLAUDE.md names
  v1.107.0. `diff -rq --strip-trailing-cr` of the v1.107.0 archive against the payload shows only the pruned media
  (undeclared icons and `media/sounds/callout`); `diff -rq` of `testkit` against `tests/_kit` is empty. The base is
  **v1.107.0**.
- New tag: **v1.108.0** (`56c20b76`), a local tag not on origin yet (`git -C ../LibKa0s ls-remote --tags origin
  v1.108.0` prints nothing; expected in this run). Taken with
  `git -C ../LibKa0s archive v1.108.0 LibKa0s testkit tools`.
- `git -C ../LibKa0s log --oneline v1.107.0..v1.108.0` -> 15 commits (SD-LK-94, SD-LK-99, SD-LK-100, SD-LK-97
  Batches A to D, SD-LK-GUARD, SD-LK-REL); `git -C ../LibKa0s diff --stat v1.107.0 v1.108.0 -- LibKa0s testkit` ->
  23 files changed.
- Step 0 pre-flight for this addon: the newest single-tag bundle, `2026-11-19-v1.107.0`, states base v1.106.0, and
  the provenance before the commit that vendored v1.107.0 (`ef68f81`'s parent) was v1.106.0. ok, no correction.

## 3b. Actual version

Before the copy every file's minor matched v1.107.0 (the archive diff above is clean apart from the media subset).
Claim and bytes agree.

## 3c. Per-file minors that moved (XML order, from the tag's `LibKa0s.xml`)

| File | Old | New |
|---|---|---|
| Core.lua | 18 | 19 |
| Callout.lua | 4 | 5 |
| CalloutSettings.lua | 5 | 6 |
| WaypointArrow.lua | 2 | 3 |
| WaypointArrowSettings.lua | 2 | 3 |
| Charts.lua | 2 | 3 |
| ChartsRender.lua | 1 | 2 |
| SkinPaint.lua | 19 | 20 |
| SkinPaintHud.lua | 1 | 2 |
| SkinPaintControls.lua | 18 | 19 |
| Widgets.lua | 29 | 30 |
| WidgetsDropdown.lua | 2 | 3 |
| WidgetsDragHandle.lua | 15 | 16 |
| WidgetsDragHandleTip.lua | 2 | 3 |
| WidgetsLineChart.lua | 7 | 8 |
| WidgetsBar.lua | 1 | 2 |
| OptionsCompose.lua | 19 | 20 |

No file is new and none was removed. No consumer file was behind (no skew).

## 3d. Diffs

After the copy and before the prune: `diff -r --strip-trailing-cr` and `diff -r` of the extract against
`libs/LibKa0s` and `tests/_kit`: all four empty. After the prune the only differences are
`Only in <tag>/LibKa0s/media/icons` (the undeclared icons) and `media/sounds` (no `LibKa0s sounds:` line).

## 3e. Consumption

`grep -rhoE 'LibStub\("LibKa0s-[A-Za-z]+-1\.0", true\)' . --include='*.lua' --exclude-dir=libs --exclude-dir=tests`:
Core (2), DebugLog, Env, Launcher, Lifecycle, Media, Options (2), Perf, Schema, Skin (9), Slash, Tooltip,
Widgets (5). Of the moved majors this addon looks up Core, Skin, Widgets and Options. It never looks up Callout,
WaypointArrow or Charts.

## 3f. Kit revision

`grep -n 'Kit.VERSION'`: 57 -> **58**. Both payloads move together (pairing rule).

## 3g. Contract delta

`grep -rn '__Attach[A-Za-z]*' . --include='*.lua' --exclude-dir=libs --exclude-dir=_kit` -> no site. The tag's
CHANGELOG "What a consumer owes at its re-vendor", against this addon:

- Composers (`O.FontGroup`, `O.BorderGroup`, `O.BarGroup`, `O.ColorPair`): none called. The only hits are the
  library-absent stubs in `settings/OptionsSetup.lua:111-114`, which answer `{}`.
- `W.Bar`, Charts, `W.ContextMenu`, `S.ApplyBarFill`: no `W.Bar` and no Charts. The Overlays ApplyBarFill sample
  (`modules/ShowroomOverlays.lua:222-232`) sets its own texture first, so v1.108.0 keeps it. The Library widgets
  menu cascade (`modules/ShowroomWidgets.lua:250-255`) is owned, so its submenu arrows now take the menu palette's
  tint (class A).
- Callout, WaypointArrow, `skinBands`, `OwnerWarnings`: not used.
- Test kit revision 58: the suite went red on the copy in two places, both fixed in this commit:
  - `test_skin_switch`, the window's shell and "values: GetFont": "a string whose face follows the skin while its
    color is never set". The Values GetFont line set a face and no color. Fixed in `modules/ShowroomValues.lua`
    (`fontGetter`): the line takes `text.body` and the window flags `FontFlags(FROM_SKIN, "window")` on every
    redraw. That is the audit's SD-SK-ST.3, landed here because the gate needs it.
  - `test_skin_values`, `modules/ShowroomTextures.lua:42` `return 1, 1, 1, 1` (the scanner now reads `return`
    triples). The `rgba` fallback answers only a token that is no color table, which none of the tokens it reads
    is in any skin. Row added in `tests/run.lua` with `category = "unreachable default"`.

### Blockers

None beyond the two kit hits above, fixed in the copy's commit.

## 3h. Unrecorded vendored tags

Every vendored tag since the horizon has a bundle (v1.107.0 is `2026-11-19-v1.107.0`). No span bundle.

## 3i. Icon declaration

`CLAUDE.md:42`, directly under the provenance line, kept as written:
`LibKa0s icons: chevron-down, chevron-up, clear, close, confirm, copy, eye, info, move, reset, settings, volume-high.`
v1.108.0 adds no library-drawn icon. Prune: `lua <scratch>/tools/prune-icons.lua .` -> sounds: none, removed 362;
icons: 12 declared, 13 files kept (12 icons and the Open Iconic license). Hand lists have drifted before; the
owner's in-client smoke is the backstop for a name the host forgot to declare.

## 3j. Tests that assume the whole icon folder

`grep -rn "media/icons\|lib.ICONS\|\.ICONS)" tests --include='*.lua' | grep -v /_kit/` -> 7 lines, all in
`tests/test_mediasetup.lua`, each reading declared names or the catalog table. All pass after the prune.
No blocker.
