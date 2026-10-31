Delta: LibKa0s v1.83.0 -> v1.84.0

Run non-interactively by item `XX-RV` of the 2026-10-31 findings remediation (M2), on branch
`feat/2026-10-31-findings-remediation`, following the installed `/dev-copilot:wow-revendor-libka0s`
at 2.6.1. The tag `v1.84.0` (`e917ccd`) is local to `../LibKa0s`; `git ls-remote --tags origin v1.84.0`
prints nothing.

## Step 0, pre-flight

Run for this repo only; the other roster repos have their own agents. The store holds one span
bundle and no single-tag bundle, so there is no base to check: `no store` in the pre-flight's terms.
This bundle is the store's first single-tag bundle.

## 3a, 3b. Claimed and actual version

`grep -n '[Bb]undles' CLAUDE.md` gives `CLAUDE.md:40`, v1.83.0. The last commit touching either payload
(`git log -1 --format=%H -- libs/LibKa0s tests/_kit` gives `1fab9f1`) leaves the same line. The two
agree, so the base is v1.83.0.

`diff -rq --strip-trailing-cr <extract of v1.83.0> libs/LibKa0s` lists only pruned icons, and the same
over `tests/_kit` lists nothing: no fork.

`git -C ../LibKa0s log --oneline v1.83.0..v1.84.0` holds 26 commits, and
`git -C ../LibKa0s diff --stat v1.83.0 v1.84.0` reads 145 files changed.

## 3c. Per-file minors

From the loop over the tag's `LibKa0s/LibKa0s.xml`. Files not listed did not move. `new` is a file
new in this range. No file is behind: no cross-major skew.

| File | v1.83.0 | v1.84.0 |
|---|---|---|
| `Schema.lua` | 2 | 3 |
| `Charts.lua` | new | 1 |
| `ChartsRender.lua` | new | 1 |
| `Skin.lua` | 10 | 11 |
| `SkinOwnerTokens.lua` | new | 1 |
| `SkinDefs.lua` | 18 | 19 |
| `SkinDefsOthers.lua` | new | 1 |
| `WidgetsDragHandle.lua` | 8 | 10 |
| `DebugLogDiagnostics.lua` | 5 | 6 |
| `Slash.lua` | 20 | 21 |
| `Options.lua` | 34 | 35 |
| `OptionsWidgets.lua` | 38 | 40 |
| `OptionsFlow.lua` | new | 2 |
| `OptionsIds.lua` | 5 | 6 |
| `OptionsIdSuggest.lua` | new | 1 |
| `OptionsTabs.lua` | 11 | 13 |
| `OptionsTabbed.lua` | new | 2 |
| `OptionsCompose.lua` | 14 | 15 |
| `OptionsSkinPicker.lua` | 4 | 5 |
| `OptionsSkinPickerRows.lua` | new | 1 |
| `SimPanel.lua` | 8 | 9 |
| `SimPanelRender.lua` | new | 1 |

## 3d. Both diffs, before the copy

`diff -r --strip-trailing-cr <extract>/testkit tests/_kit` shows the kit's new `mock_ace.lua`, and the
library's the moved files. Nothing is `Only in` the addon outside the icons, so no file removed
upstream survives here.

## 3e. Consumption map

`grep -rnoE 'LibStub\("LibKa0s-[A-Za-z]+-1\.0", true\)' . --include='*.lua' | grep -v '/libs/' | grep -v '/tests/'`:
Lifecycle, Env, DebugLog, Core, Skin, Media, Launcher, Perf, Widgets, Options, Schema, Slash. Charts
is new and has no lookup here. Sim has none either.

## 3f. Kit revision

`grep -n 'Kit.VERSION =' <extract>/testkit/framework.lua tests/_kit/framework.lua`: 46 to 47. Both
payloads move in one commit, as the pairing rule (kit revision 11 and later) requires.

## 3g. Contract delta

Majors both moved and consumed: Skin, Widgets, DebugLog, Slash, Options, Schema.
`grep -rn '__Attach[A-Za-z]*' . --include='*.lua' --exclude-dir=libs --exclude-dir=Libs --exclude-dir=_kit`
prints nothing, so this addon hands the library no attached member.

Documents read: `docs/api/Options/version-35.4.40.2.6.1.7.13.2.3.15.9.4.3.6.5.5.1.1.1-docs.md`,
`docs/api/Widgets/version-17.3.10.5.5.2-docs.md`, `docs/api/Schema/version-3-docs.md`,
`docs/api/Slash/version-21.2-docs.md`, `docs/api/DebugLog/version-22.6.1.2-docs.md`, each against the
v1.83.0 document it supersedes.

**Blockers: none.** The moved surfaces state what a host owes, and the only debt falls on this
addon's stub and test pins, listed below. No existing sentence tightened a surface this addon uses.

Pins that move in the re-vendor commit:

- `settings/OptionsSetup.lua`: the stub gains `H.PositionBlock` (Options document, "A new public
  member, `O.PositionBlock`, is owed by every consumer's degradation stub at the re-vendor").
- `tests/loader.lua`: the typed file list gains the nine new files in XML order.
- `tests/test_diagnostics.lua`: `skin engine=10` moves to 11, the Skin minor.

No test here pins `DebugLogDiagnostics 5`, and none counts `ApplyWidth` calls.

## 3h. Tags vendored and unrecorded

The listing prints nothing: the span bundle `docs/revendor/2026-10-31-v1.78.0-v1.83.0/` recorded
everything to v1.83.0. No new span bundle.

## 3i. The icon declaration

`grep -n 'LibKa0s icons:' CLAUDE.md` gives `CLAUDE.md:41`, `close, copy, clear, eye, settings`, the
next non-blank line under the provenance line. Kept as it stands; the provenance line ends at its own
line. Evidence for each name is the table in `tests/test_mediasetup.lua:19-30`.

Hand lists have drifted before (KickCD `tests/test_mediasetup.lua:28`, WhatGroup
`tests/test_mediasetup.lua:19`), and a pruned icon still resolves to a path and draws blank, so the
owner's in-client smoke is the backstop.

## 3j. Tests that assume the whole icon folder

`grep -rn "media/icons\|lib.ICONS\|\.ICONS)" tests --include='*.lua' | grep -v '/_kit/'` gives
`tests/test_mediasetup.lua:124,137,163,172,185,257`. The first and last read the catalog names and
the rest read the folder with the declared names only, as they did at v1.83.0. Not a blocker.

## Dead stub mirrors

`grep -rn '__releaseChrome' . --include='*.lua' --exclude-dir=libs --exclude-dir=_kit` prints nothing.
