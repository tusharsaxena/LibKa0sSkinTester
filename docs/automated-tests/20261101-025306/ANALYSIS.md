# Analysis — 20261101-025306

- **Addon:** LibKa0sSkinTester 0.1.0 (labelled `final-pre-merge`; not a release run)
- **Verdict:** amber
- **Commit:** 7d93f9a (feat/2026-10-31-findings-remediation), clean
- **Previous run:** 20261101-000749

## Headline

Lint and tests pass, so the run and the commit are not gated. Perf failed: `skinRepaint` is over both
of its pins in `tests/perf.lua`, at 1092.0 API calls against 1085 and 206990.2 bytes against a
206068-byte ceiling. That is a stale pin after sample additions on this branch, not a runaway path,
but perf gates the tag, so it wants a re-pin or a ruling before any release run.

## Suites

| Suite | Status | Result | Artifact | Moved since 20261101-000749 |
|---|---|---|---|---|
| lint | pass | 0 warnings / 0 errors in 80 files | [`lint.txt`](lint.txt) | files 79 → 80 |
| tests | pass | 616 passed, 1 skipped, 0 failed, 617 total | [`tests.txt`](tests.txt) · [`test-cases.md`](test-cases.md) | 607 → 617 cases |
| perf | fail | 4 scenarios, 2 assertions failed | [`perf.txt`](perf.txt) · [`perf.json`](perf.json) | pass → fail on `skinRepaint` |
| complexity | pass | see below | [`complexity.txt`](complexity.txt) | max CCN 14 unchanged, warnings unchanged at 0 |

**Complexity is reported in full.** Values are from `manifest.json`'s `suites.complexity`.

| Metric | Value |
|---|---|
| Total NLOC | 11412 |
| Functions | 1608 |
| Avg NLOC / function | 6.5 |
| Avg CCN | 2.0 |
| Max CCN | 14 |
| Avg tokens / function | 54.2 |
| Warnings (CCN > 15) | 0 |
| Warning rate (`Fun Rt` / `nloc Rt`) | 0.00 / 0.00 |
| Files in the 1000–1500 band | 1 |
| Files over the 1500 cap | 0 |
| Blind files (parity mismatch) | 0 |
| Crashed files (lizard raised) | 0 |

**tests.** The one skip is the kit's diagnostics-contract arm for an addon that opts out of turning
logging on ([`tests.txt`](tests.txt), line 606). This addon keeps the default, so the arm does not
apply. It is counted in the total and not in `passed`. Pre-existing.

**perf.** [`perf.txt`](perf.txt) lists two failed assertions, both on `skinRepaint`: 1092.0 API calls
over the pinned 1085, and 206990.2 bytes per iteration over the 206068-byte ceiling. This is a
regression against the pin, and it is new on this branch since the previous run. Running
`tests/perf.lua` on an export of each commit after that run placed it: the last passing commit is
bb72a00, the breach first appears at 98d90f5 (ST-D1, which adds the dropdown samples the repaint
walks), and 7d93f9a (M3-MEDIA) reduced it without clearing it. The other two commits did not move
either figure. So the cost follows samples added to the showroom, the same cause the pin's history
in `tests/perf.lua` records for its earlier rises. A repaint is one click, not a per-frame path. Perf
gates neither this run nor the commit. It does gate the tag.

## What moved

- **lint:** 0/0 did not move. Files 79 → 80 is the new `tests/test_showroom_dropdowns.lua`.
- **tests:** 607 → 617 cases, 606 → 616 passed, skip and failed unchanged at 1 and 0. Per
  [`test-cases.md`](test-cases.md), the 10 new cases are 8 in `test_showroom_dropdowns.lua` and 2 in
  `test_showroom_widgets.lua`.
- **perf:** pass → fail.

| Scenario | api/iter (prev → now) | bytes/iter (prev → now) |
|---|---|---|
| `showroomToggle` | 1.0 → 1.0 | 64.0 → 64.0 |
| `skinRepaint` | 1085.0 → 1092.0 | 206038.2 → 206990.2 |
| `applyScale` | 2.0 → 2.0 | 0.0 → 0.0 |
| `applyAlpha` | 2.0 → 2.0 | 0.0 → 0.0 |

  `ms/iter` figures are for orientation only and are not compared across runs
  ([`perf.txt`](perf.txt)).
- **complexity:** NLOC 11122 → 11412 and functions 1566 → 1608 are growth. Avg NLOC 6.5, avg CCN 2.0,
  avg tokens 54.2 and max CCN 14 did not move, so the addon grew without getting denser.

## Complexity watch list

### Functions

| Function | CCN | Location | Disposition |
|---|---|---|---|

None.

### Files

| Band | File | LOC | Disposition |
|---|---|---|---|
| 1000–1500 (on notice) | `tests/test_libka0s.lua` | 1038 | Accepted: the LibKa0s adoption characterization suite, carried from the scaffold. Split by library major if it nears the cap. |

The disposition is carried forward and its entry is unchanged at 1038 lines. Nothing newly crossed
a band and no disposition is owed. This is not a release run, so the three-release shelf life has
not begun.

## Actions

1. `tests/perf.lua`: confirm the added `skinRepaint` cost is the intended showroom samples, then
   re-pin `REPAINT_MAX_BYTES` and `REPAINT_MAX_API` with a history note, and re-run so the suite is
   back at pass before any release run. New here; no deviation ID or review finding owns it.
