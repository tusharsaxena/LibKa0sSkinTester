# Analysis — 20261031-211703

- **Addon:** LibKa0sSkinTester 0.1.0 (labelled `findings-remediation`; not a release run)
- **Verdict:** green
- **Commit:** a55ccfa (feat/2026-10-31-findings-remediation), clean
- **Previous run:** 20261031-202019

## Headline

All four suites pass, so the amber of the previous run is gone: `showroomToggle` is back to 64.0
bytes/iter and its assertion no longer fails. `skinRepaint`'s byte figure rose from 41794.7 to
206134.2, and that is a change of measurement, not a change in what the addon allocates (see *What
moved*). Nothing here needs acting on.

## Suites

| Suite | Status | Result | Artifact | Moved since 20261031-202019 |
|---|---|---|---|---|
| lint | pass | 0 warnings / 0 errors in 79 files | [`lint.txt`](lint.txt) | did not move |
| tests | pass | 606 passed, 1 skipped, 0 failed, 607 total | [`tests.txt`](tests.txt) · [`test-cases.md`](test-cases.md) | total 606 → 607, skips unchanged at 1 |
| perf | pass | 4 scenarios | [`perf.txt`](perf.txt) · [`perf.json`](perf.json) | fail → pass |
| complexity | pass | see below | [`complexity.txt`](complexity.txt) | max CCN 14 unchanged, warnings unchanged at 0 |

**Complexity is reported in full.** Values are from `manifest.json`'s `suites.complexity`.

| Metric | Value |
|---|---|
| Total NLOC | 11112 |
| Functions | 1565 |
| Avg NLOC / function | 6.5 |
| Avg CCN | 2.0 |
| Max CCN | 14 |
| Avg tokens / function | 54.3 |
| Warnings (CCN > 15) | 0 |
| Warning rate (`Fun Rt` / `nloc Rt`) | 0.00 / 0.00 |
| Files in the 1000–1500 band | 1 |
| Files over the 1500 cap | 0 |
| Blind files (parity mismatch) | 0 |
| Crashed files (lizard raised) | 0 |

**tests.** The one skip is the kit's diagnostics-contract arm for an addon that opts out of turning
logging on ([`tests.txt`](tests.txt), line 596). This addon keeps the default, so the arm does not
apply. It is counted in the total and not in `passed`. Pre-existing.

## What moved

- **lint:** 0/0 over 79 files did not move.
- **tests:** 606 → 607 cases (passed 605 → 606), with failures at 0 and skips at 1. The new case is
  in [`test-cases.md`](test-cases.md): `harness: an undefined frame method reads as one cached stub,
  not a fresh closure`.
- **perf:** the verdict moved from amber because the single failed assertion in the previous bundle
  no longer appears in [`perf.txt`](perf.txt).

| Scenario | api/iter (prev → now) | bytes/iter (prev → now) |
|---|---|---|
| `showroomToggle` | 1.0 → 1.0 | 160.0 → 64.0 |
| `skinRepaint` | 1083.0 → 1083.0 | 41794.7 → 206134.2 |
| `applyScale` | 2.0 → 2.0 | 0.0 → 0.0 |
| `applyAlpha` | 2.0 → 2.0 | 0.0 → 0.0 |

  `showroomToggle` moved because 323b0df caches the mock's frame stub. The bytes were the mock's,
  as the previous analysis found, so no in-game claim follows.

  **`skinRepaint`'s byte figures are not comparable across these two runs.** Its API count did not
  move. 323b0df stops the collector across the byte pass in `tests/perf.lua`, so this figure is the
  whole allocation per iteration, where the previous one was reduced by whatever the collector
  freed during the pass. The same commit replaced the ceiling derived from each run's own reading
  with a fixed pin in bytes and API calls, so this scenario can now fail. It passed. Read this
  figure as the new baseline, not as a regression. A repaint is one click, not a per-frame path.

  `ms/iter` figures are for orientation only and are not compared across runs
  ([`perf.txt`](perf.txt)).
- **complexity:** NLOC 11088 → 11112 and functions 1563 → 1565 are growth. Avg NLOC 6.5, avg CCN 2.0
  and max CCN 14 did not move. Avg tokens 54.2 → 54.3.

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
a band. Neither this run nor the previous one is a release run, so the three-release shelf life has
not begun.

## Actions

None. The previous analysis's action on `tests/wow_mock.lua` was done in 323b0df, and this run's
[`perf.txt`](perf.txt) shows it held.
