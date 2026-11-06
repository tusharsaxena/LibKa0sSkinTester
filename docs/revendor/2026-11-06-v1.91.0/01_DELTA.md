Delta: LibKa0s v1.90.0 -> v1.91.0

Part of Ka0sAddonsCommonTasks `docs/2026-11-06-FOLLOWUPS_V1_91/` (item `FU-RV-ST`). The tag is
**local** (`55bfbb4`), not pushed: `git -C ../LibKa0s ls-remote --tags origin v1.91.0` prints nothing,
which is expected here. This is a new tag for this addon (its line names v1.90.0), so it is a re-vendor,
not a refresh. Payload from `git -C ../LibKa0s archive v1.91.0 LibKa0s testkit tools`, extracted to a
scratch directory outside the tree.

## Step 0 (pre-flight)

Skipped as a collection-wide table. The installed skill's roster regex expects markdown links, but
`ADDONS.md` writes `` `../../<Folder>/` ``, so it matches nothing; this run fixes that upstream in
dev-copilot. This addon's own row was computed by hand, with `tag_at` rewritten to named variables:
`LibKa0sSkinTester  2026-11-06-v1.90.0  base v1.89.0  vendored-before v1.89.0@1c9d91e  ok`. No base
correction is owed.

## Base (3a, 3b)

- `grep -n '[Bb]undles' CLAUDE.md` gives `40:Bundles [LibKa0s](https://github.com/tusharsaxena/LibKa0s) v1.90.0 (MIT).`
- `git log -1 --format=%H -- libs/LibKa0s tests/_kit` names a commit whose `CLAUDE.md` says v1.90.0.
  Claim and payload agree: the payload diffed against `git -C ../LibKa0s archive v1.90.0` differs only
  by the undeclared icons the prune removed (`Only in <scratch>/LibKa0s/media/icons`), and the kit
  is identical.
- The minors grep over `libs/LibKa0s/*.lua` reads the v1.90.0 values (Core 16, Widgets 25,
  SkinPaintExtras 18, WidgetsLineChart 6). The line and the bytes agree.
- `git -C ../LibKa0s log --oneline v1.90.0..v1.91.0` lists 7 commits after the v1.90.0 merge: FU-L1
  `55d3b0f`, FU-L2 `d72dc4a`, `c1ed261`, `acc9640` and `3f7be30`, and FU-L3 `1938837` and `55bfbb4`.
  `git -C ../LibKa0s diff --stat v1.90.0 v1.91.0` reports 62 files changed.

## Per-file minors (3c), moved and new files only

The 3c loop over the tag's `LibKa0s.xml`. Every other file is at its v1.90.0 minor.

| File | old | new |
|---|---|---|
| Core.lua | 16 | 17 |
| CorePixel.lua | (new) | 1 |
| SkinPaintExtras.lua | 18 | 19 |
| SkinPaintHud.lua | (new) | 1 |
| SkinAceConfirm.lua | (new) | 1 |
| Widgets.lua | 25 | 26 |
| WidgetsDropdown.lua | (new) | 1 |
| WidgetsLineChart.lua | 6 | 7 |

Four new files, the FU-L2 peels. No cross-major skew.

## Diffs (3d), before the copy

`diff -rq [--strip-trailing-cr] <scratch>/LibKa0s libs/LibKa0s`, ignoring the `Only in <scratch>` lines
under `media/icons` (the undeclared icons): `Core.lua`, `LibKa0s.xml`, `SkinPaintExtras.lua`,
`Widgets.lua` and `WidgetsLineChart.lua` differ, and the four new files are `Only in <scratch>`. Content
and bytes give the same list, so there is no line-ending drift, and there is no `Only in libs/LibKa0s`
line.

`diff -rq [--strip-trailing-cr] <scratch>/testkit tests/_kit`: empty. The kit is unchanged.

## Consumption (3e)

`grep -rnoE 'LibStub\("LibKa0s-[A-Za-z]+-1\.0", true\)'` outside `libs/` and `tests/`: Charts, Compat,
Core, DebugLog, Env, IconBrowser, Item, Launcher, Lifecycle, Media, Options, Perf, Pool, Schema, Sim,
Skin, Slash and Widgets. Of the moved majors the addon consumes Core, Skin and Widgets, all three.

## Kit (3f)

`grep -n 'Kit.VERSION'`: tag 51, addon 51. The pairing rule holds by construction (both payloads copied
whole in one commit).

## Contract delta (3g)

- Core 17.1 (`docs/api/Core/version-17.1-docs.md`): the pixel-edge section moves to `CorePixel.lua`.
  All its members are internal (`__`), and none of them is mirrored outside `libs/` (grep for
  `__PixelSize`, `__WatchPixels`, `__OnPixelScale`, `__PixelBackdrop` finds only the payload).
- Widgets 26.1.6.13.7.8.5 (`version-26.1.6.13.7.8.5-docs.md:33`): "What a host owes: nothing.
  LootHistory and LibKa0sSkinTester pass no `thickness`". The showroom's chart
  (`modules/ShowroomWidgets.lua:117-128`) passes none. The dropdown peel moves no member.
- Skin 17.1.27.8.19.19.1.1.17.4.9: a pure move of the confirmation box and the HUD looks. The tag's
  `CHANGELOG.md` v1.91.0 block says "No host owes a facade or stub member".
- `grep -rn '__Attach[A-Za-z]*'` outside `libs/` and `_kit/` finds nothing.

No contract change breaks this addon on the copy.

## Blockers

- **`tests/loader.lua`'s library list** spells out every file of `LibKa0s.xml` in XML order. It gains
  `CorePixel.lua` after `Core.lua`, `SkinPaintHud.lua` and `SkinAceConfirm.lua` after
  `SkinPaintExtras.lua`, and `WidgetsDropdown.lua` after `Widgets.lua`, in this commit. Without them
  the suite would load a Widgets with no dropdown and a Core with no pixel members. After the edit,
  the list compared against the tag's `LibKa0s.xml` is identical.
- **Minor pins:** none. No test pins an exact minor of a moved file (`tests/test_diagnostics.lua:59`
  reads the Skin minor live).
- **Stub mirrors of moved members:** none outside `libs/` and `_kit/`.

## Span (3h)

Vendored since the horizon (2026-10-31): v1.83.0, v1.84.0, v1.85.0, v1.89.0, v1.90.0. All are recorded.
No span bundle. (The installed skill's `tag_at` arrived with `"Ka0s"` where `"$1"` was meant; it was run
with named variables.)

## Icon declaration (3i)

`grep -n 'LibKa0s icons:' CLAUDE.md` gives line 41, directly under the provenance line. **Kept**
unchanged (decided by the run: v1.91.0 adds no library-drawn icon). No provenance split. Hand lists
have drifted before (KickCD `tests/test_mediasetup.lua:28`, WhatGroup `tests/test_mediasetup.lua:19`),
so the owner's in-client smoke stays the backstop.

## Whole-folder icon tests (3j)

`grep -rn "media/icons\|lib.ICONS\|\.ICONS)" tests --include='*.lua'` hits
`tests/test_mediasetup.lua:126,139,165,166,174,187,259`, already narrowed to the declaration. Nothing owed.

## Dead stub mirrors

`grep -rn '__releaseChrome'` outside `libs/` and `_kit/` finds nothing.
