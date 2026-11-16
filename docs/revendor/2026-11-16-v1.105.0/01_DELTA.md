Delta: LibKa0s v1.94.0 -> v1.105.0

# 01 Delta

Written 2026-11-16 by item RV-ST of the Ka0sAddonsCommonTasks run
`docs/2026-11-16-LIBKA0S_ISSUES_75_PLUS/`, branch `feat/2026-11-16-libka0s-75-plus`. Copy and bundle half of
`/dev-copilot:wow-revendor-libka0s` (dev-copilot 2.10.0) only; the adoption interview is phase [3] of that run.

## 3a. Base

- `grep -n '[Bb]undles' CLAUDE.md` → `CLAUDE.md:41: Bundles [LibKa0s](...) v1.94.0 (MIT).`
- `git log -1 --format=%H -- libs/LibKa0s tests/_kit` → `5d96db0` (W1-ST-03), whose CLAUDE.md names v1.94.0. No
  provenance roll since. `diff -rq` of the v1.94.0 archive against the payload shows only the undeclared icons
  (`Only in <tag>/LibKa0s/media/icons`); `tests/_kit` matches. The base is **v1.94.0**.
- New tag: **v1.105.0** (`79b1d9c4`), a local tag that is not on origin yet (`git ls-remote --tags origin v1.105.0`
  prints nothing; expected in this run). Taken with `git -C ../LibKa0s archive v1.105.0 LibKa0s testkit tools`.
- `git -C ../LibKa0s log --oneline v1.94.0..v1.105.0 | wc -l` → 114 commits;
  `git -C ../LibKa0s diff --stat v1.94.0 v1.105.0 | tail -1` → 653 files changed.
- Step 0 pre-flight for this addon: the newest single-tag bundle, `2026-11-07-v1.93.0`, states base v1.92.0, and
  the provenance before the commit that vendored v1.93.0 (`e5acf9f`'s parent) was v1.92.0. ok, no correction.

## 3b. Actual version

`grep -hoE 'local (MAJOR, )?[A-Z_]*MINOR *= *("[^"]+", *)?[0-9]+' libs/LibKa0s/*.lua` before the copy: every file
matched v1.94.0 (the archive diff above is clean apart from the icon subset). Claim and bytes agree.

## 3c. Per-file minors that moved (XML order, from the tag's `LibKa0s.xml`)

| File | Constant | Old | New |
|---|---|---|---|
| Core.lua | MAJOR, MINOR | 17 | 18 |
| Tooltip.lua | MAJOR, MINOR | (new) | 1 |
| Role.lua | MAJOR, MINOR | (new) | 1 |
| Callout.lua | MAJOR, MINOR | (new) | 4 |
| CalloutSettings.lua | SETTINGS_MINOR | (new) | 5 |
| WaypointArrow.lua | MAJOR, MINOR | (new) | 2 |
| WaypointArrowSettings.lua | SETTINGS_MINOR | (new) | 2 |
| Charts.lua | MAJOR, MINOR | 1 | 2 |
| Media.lua | MAJOR, MINOR | 12 | 13 |
| SkinDefs.lua | DEFS_MINOR | 27 | 28 |
| SkinDefsOthers.lua | OTHERS_MINOR | 8 | 10 |
| Widgets.lua | MAJOR, MINOR | 26 | 27 |
| WidgetsDropdown.lua | DROPDOWN_MINOR | 1 | 2 |
| WidgetsReorder.lua | REORDER_MINOR | 6 | 7 |
| WidgetsDragHandle.lua | DRAG_MINOR | 13 | 14 |
| WidgetsDragHandleTip.lua | DRAGTIP_MINOR | (new) | 1 |
| WidgetsCopyWindow.lua | COPY_MINOR | 5 | 6 |
| WidgetsHeader.lua | HEADER_MINOR | (new) | 1 |
| WidgetsBar.lua | BAR_MINOR | (new) | 1 |
| DebugLog.lua | MAJOR, MINOR | 22 | 23 |
| DebugLogDiagnostics.lua | DIAG_MINOR | 7 | 11 |
| DebugLogWindow.lua | WINDOW_MINOR | 4 | 5 |
| Launcher.lua | MAJOR, MINOR | 9 | 11 |
| OptionsWidgets.lua | WIDGETS_MINOR | 45 | 46 |
| OptionsNav.lua | NAV_MINOR | 6 | 7 |
| OptionsSkinPicker.lua | PICKER_MINOR | 11 | 12 |
| OptionsSkinPickerQueue.lua | QUEUE_MINOR | (new) | 1 |
| IconBrowserWindow.lua | WINDOW_MINOR | 1 | 2 |
| IconBrowser.lua | BROWSER_MINOR | 1 | 2 |
| PerfPanel.lua | PANEL_MINOR | 13 | 14 |
| Sim.lua | MAJOR, MINOR | 2 | 3 |
| SimPanel.lua | SIM_PANEL_MINOR | 10 | 11 |
| SimPanelRender.lua | RENDER_MINOR | 3 | 4 |

Ten files are new in this range: Tooltip, Role, Callout, CalloutSettings, WaypointArrow, WaypointArrowSettings,
WidgetsDragHandleTip, WidgetsHeader, WidgetsBar, OptionsSkinPickerQueue. No consumer file was behind (no skew).

## 3d. Diffs

Before the prune: `diff -r --strip-trailing-cr` and `diff -r` of the extract against `libs/LibKa0s` and
`tests/_kit`: all four empty. After the prune the only differences are `Only in <tag>/LibKa0s/media/icons` (214
undeclared icons) and `media/sounds` (362 files; no `LibKa0s sounds:` line, so none ship). No file removed upstream
survived here.

## 3e. Consumption

`grep -rnoE 'LibStub\("LibKa0s-[A-Za-z]+-1\.0", true\)' . --include='*.lua' | grep -v /libs/ | grep -v /tests/`:
Charts 1, Compat 8, Core 46, DebugLog 5, Env 1, IconBrowser 2, Item 2, Launcher 1, Lifecycle 2, Media 20,
Options 22, Perf 4, Pool 5, Schema 2, Sim 3, Skin 37, Slash 5, Widgets 16. Not looked up: Bus, Glow, Toast,
Callout, WaypointArrow, Role, Tooltip (all new or unconsumed majors).

## 3f. Kit revision

`grep -n 'Kit.VERSION'`: 53 → **57**. Both payloads move in the same commit (pairing rule).

## 3g. Contract delta

`grep -rn '__Attach[A-Za-z]*' . --include='*.lua' --exclude-dir=libs --exclude-dir=_kit` → no site. The tag's
CHANGELOG "What a consumer owes at its re-vendor" lines that reach this addon:

- A host whose tests load library files by name adds the new files in XML order. This addon's
  `tests/loader.lua` list is pinned to `LibKa0s.xml` by `tests/test_harness.lua`, so it gains the ten new files.
  Without `OptionsSkinPickerQueue.lua` the suite stops at `OptionsSkinPicker.lua:1314` (`queueKit()` nil).
- New instance members `Report` and `Serialize` on the DebugLog instance (DebugLogDiagnostics minor 11, LibKa0s#79),
  and `SideTabs` on the Options instance (OptionsNav minor 7): the parity cases in
  `tests/test_surface_parity.lua` go red until the stubs carry them.
- Each host's launcher `name` against its windows' `addonName` (the settings mark, LibKa0s#86): both are the folder
  name (`core/LauncherSetup.lua:51`, `core/DebugLogSetup.lua:113-114`, `core/PerfSetup.lua:32-34`). ok.

### Blockers

None that needs a decision. The three items above are fixed in the re-vendor commit.

## 3h. Unrecorded vendored tags

The AUDIT.md listing (horizon 2026-10-31) gives vendored v1.83.0 … v1.94.0 against recorded v1.78.0 … v1.93.0, so
**v1.94.0** is unrecorded. Span bundle written: `docs/revendor/2026-11-16-v1.94.0-v1.94.0/`.

## 3i. Icon declaration

`CLAUDE.md:42`, directly under the provenance line, kept as written:
`LibKa0s icons: chevron-down, chevron-up, clear, close, confirm, copy, eye, info, move, reset, settings, volume-high.`
`settings` joins the library-drawn set at this tag (the header marks, LibKa0s#86) and is already declared.
Prune: `lua <scratch>/tools/prune-icons.lua .` → icons: 12 declared, kept 13 files (12 icons and the Open Iconic
license), removed 214; sounds: none, removed 362. A second run removes 0. Hand lists have drifted before; the
owner's in-client smoke is the backstop for a name the host forgot to declare.

## 3j. Tests that assume the whole icon folder

`grep -rn "media/icons\|lib.ICONS\|\.ICONS)" tests --include='*.lua' | grep -v /_kit/` → `tests/test_mediasetup.lua`
lines 126, 139, 165-187, 259: each reads declared names or the catalog table, not the folder whole. All pass after
the prune. No blocker.
