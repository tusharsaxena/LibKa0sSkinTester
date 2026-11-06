# Candidates

Sources: `git -C ../LibKa0s log --oneline v1.85.0..v1.89.0`, the tag's `CHANGELOG.md` blocks for v1.86.0
through v1.89.0, and the `Since` markers in `docs/api/Widgets/version-23.5.12.6.7.5-docs.md`,
`docs/api/Toast/version-4-docs.md`, `docs/api/DebugLog/version-22.7.1.4-docs.md`,
`docs/api/IconBrowser/version-1.1.1-docs.md` and `docs/api/testkit/version-51-docs.md`.

## A. Delivered on the re-vendor (not offered)

- **DebugLogDiagnostics minor 7** (CHANGELOG v1.86.0). The diagnostics report's `LibKa0s running:` line
  names IconBrowser. No member moves. The addon's diagnostics verb reports it with no host change.
- **Kit revision 51** (CHANGELOG v1.89.0, `docs/api/testkit/version-51-docs.md`). The mock
  CallbackHandler's unregister guard fixes a hash-order flake on an `Unregister*` made during a
  dispatch. No case name moves.
- **Widgets 23 for flat menus** (`version-23.5.12.6.7.5-docs.md:19-40`, "Every single-level menu, a
  dropdown's and a host's, is unchanged"). The showroom's two `W.Dropdown` samples draw what minor 22
  drew.

## B. Host change required

- **Widgets 23 `submenu`, `radio`, `selected` and `opts.check` on `W.ContextMenu` rows**
  (`version-23.5.12.6.7.5-docs.md:23-31`). This addon calls no `W.ContextMenu` (3e), so in the plan's
  terms there is no use site and the candidate is **not applicable**.
  - **Possible new candidate, outside the plan's table:** a Showroom sample of a skinned
    `W.ContextMenu` cascade. It would show the submenu arrow in the dropdown arrow's gray, the tick
    column in `icon.hot` (the declared `confirm`) and the stacked pooled levels. Building it would mean
    a new cell in `modules/ShowroomWidgets.lua` and a smoke row. It is **additive**: it replaces nothing
    the addon owns. The plan's "no use site" rule describes a consumer, and this addon exists to show
    every skinned surface, which may make the cascade worth showing here. It is not implemented and not
    filed. It is recorded as undecided for the run's lead.
- **Toast 4 stack** (`docs/api/Toast/version-4-docs.md`). This addon has no Toast lookup and no Toast
  stub, so the candidate is not applicable.

## C. Whole-module adoption

- **`LibKa0s-IconBrowser-1.0`** (CHANGELOG v1.86.0, `docs/api/IconBrowser/version-1.1.1-docs.md`). This
  addon has no icon chooser. **Settled** by the owner's ruling for every addon without one (run plan,
  Decisions). There is no issue.
