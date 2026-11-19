Delta: LibKa0s v1.106.0 -> v1.107.0

# 01 Delta

Written 2026-11-19 by item AF-RV-ST of the Ka0sAddonsCommonTasks run `docs/2026-11-19-ADOPTION_FEEDBACK/`,
branch `feat/2026-11-19-adoption-feedback`. The copy, provenance, declaration and prune half of
`/dev-copilot:wow-revendor-libka0s` (dev-copilot 2.9.0); its adoption interview is skipped, because the run's
`plan-data/items.tsv` pre-decides this addon's items (AF-RV-ST, AF-WVR-ST).

## 3a. Base

- `grep -n '[Bb]undles' CLAUDE.md` -> `CLAUDE.md:41: Bundles [LibKa0s](...) v1.106.0 (MIT).`
- `git log -1 --format=%H -- libs/LibKa0s tests/_kit` -> `1dee78a` (Re-vendor LibKa0s v1.106.0), whose CLAUDE.md
  names v1.106.0. `diff -rq` of the v1.106.0 archive against the payload shows only the pruned media (icons and
  `media/sounds/callout`); `tests/_kit` matches. The base is **v1.106.0**.
- New tag: **v1.107.0** (`5e963659`), a local tag not on origin yet (`git -C ../LibKa0s ls-remote --tags origin
  v1.107.0` prints nothing; expected in this run). Taken with
  `git -C ../LibKa0s archive v1.107.0 LibKa0s testkit tools`.
- `git -C ../LibKa0s log --oneline v1.106.0..v1.107.0` -> 6 commits (AF-LK-01, AF-LK-02, AF-DR-LK, AF-LK-03 x3);
  `git -C ../LibKa0s diff --stat v1.106.0 v1.107.0 -- LibKa0s testkit` -> 2 files changed
  (`WidgetsDragHandle.lua`, `WidgetsDragHandleTip.lua`).
- Step 0 pre-flight for this addon: the newest single-tag bundle, `2026-11-16-v1.105.0`, states base v1.94.0, and
  the provenance before the commit that vendored v1.105.0 (`21c53b1`'s parent) was v1.94.0. ok, no correction.

## 3b. Actual version

Before the copy every file's minor matched v1.106.0 (the archive diff above is clean apart from the media subset).
Claim and bytes agree.

## 3c. Per-file minors that moved (XML order, from the tag's `LibKa0s.xml`)

| File | Constant | Old | New |
|---|---|---|---|
| WidgetsDragHandle.lua | DRAG_MINOR | 14 | 15 |
| WidgetsDragHandleTip.lua | DRAGTIP_MINOR | 1 | 2 |

No file is new and none was removed. No consumer file was behind (no skew).

## 3d. Diffs

After the copy and before the prune: `diff -r --strip-trailing-cr` and `diff -r` of the extract against
`libs/LibKa0s` and `tests/_kit`: all four empty. After the prune the only differences are
`Only in <tag>/LibKa0s/media/icons` (the undeclared icons) and `media/sounds` (no `LibKa0s sounds:` line).

## 3e. Consumption

Unchanged from the v1.105.0 bundle. The one moved major, `LibKa0s-Widgets-1.0`, is looked up here; its
`DragHandle` has one site, the Library widgets section's specimen (`modules/ShowroomWidgets.lua:66-83`).

## 3f. Kit revision

`grep -n 'Kit.VERSION'`: 57 -> **57**. Both payloads still move together (pairing rule); the kit bytes are equal.

## 3g. Contract delta

`grep -rn '__Attach[A-Za-z]*' . --include='*.lua' --exclude-dir=libs --exclude-dir=_kit` -> no site. The tag's
CHANGELOG "What a consumer owes at its re-vendor" and the Widgets document
`docs/api/Widgets/version-28.2.7.15.2.7.8.6.1.1-docs.md:29,38`, against this addon:

- A strip `tooltipPlace` hook: none here (`grep -rn tooltipPlace core modules settings` is empty).
- A strip with no `settings` field gains the settings mark: the showroom specimen passes none, so it now draws
  the gear (`?` and settings; no X, since it passes no `onClose`). Kept on purpose, see 03_DECISIONS.md.
- A suite pinning strip literals: none (`grep -rn "RESERVE\|HELP_HIT\|HELP_INSET" tests --include='*.lua'
  | grep -v _kit` is empty).
- `settings` on the `LibKa0s icons:` line: already declared.

### Blockers

None.

## 3h. Unrecorded vendored tags

The AUDIT.md listing (horizon 2026-10-31) gives vendored v1.83.0 ... v1.106.0 against recorded v1.78.0 ...
v1.105.0, so **v1.106.0** (vendored by `1dee78a`, no bundle) is unrecorded. Span bundle written:
`docs/revendor/2026-11-19-v1.106.0-v1.106.0/`.

## 3i. Icon declaration

`CLAUDE.md:42`, directly under the provenance line, kept as written:
`LibKa0s icons: chevron-down, chevron-up, clear, close, confirm, copy, eye, info, move, reset, settings, volume-high.`
It holds `settings`, which v1.107.0's strip gear draws. Prune: `lua <scratch>/tools/prune-icons.lua .` -> sounds:
none, removed 362; icons: 12 declared, 13 files kept (12 icons and the Open Iconic license). Hand lists have
drifted before; the owner's in-client smoke is the backstop for a name the host forgot to declare.

## 3j. Tests that assume the whole icon folder

`grep -rn "media/icons\|lib.ICONS\|\.ICONS)" tests --include='*.lua' | grep -v /_kit/` -> 7 lines, all in
`tests/test_mediasetup.lua`, each reading declared names or the catalog table. All pass after the prune.
No blocker.
