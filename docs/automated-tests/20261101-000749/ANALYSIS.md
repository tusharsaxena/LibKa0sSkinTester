# Analysis — 20261101-000749

- **Addon:** LibKa0sSkinTester 0.1.0 (labelled `v1.84.0-adoption`; not a release run)
- **Verdict:** green
- **Commit:** 7c77443 (feat/2026-10-31-findings-remediation), clean
- **Previous run:** 20261031-211703

## Headline

All four suites pass on the LibKa0s v1.84.0 re-vendor. The case inventory did not change. The one
real movement is `skinRepaint`, from 1083.0 to 1085.0 API calls per iteration, which 7c77443
attributes to the vendored `WidgetsDragHandle` and re-pinned. Nothing here needs acting on.

## Suites

| Suite | Status | Result | Artifact | Moved since 20261031-211703 |
|---|---|---|---|---|
| lint | pass | 0 warnings / 0 errors in 79 files | [`lint.txt`](lint.txt) | did not move |
| tests | pass | 606 passed, 1 skipped, 0 failed, 607 total | [`tests.txt`](tests.txt) · [`test-cases.md`](test-cases.md) | did not move |
| perf | pass | 4 scenarios | [`perf.txt`](perf.txt) · [`perf.json`](perf.json) | `skinRepaint` api/iter 1083.0 → 1085.0 |
| complexity | pass | see below | [`complexity.txt`](complexity.txt) | max CCN 14 unchanged, warnings unchanged at 0 |

**Complexity is reported in full.** Values are from `manifest.json`'s `suites.complexity`.

| Metric | Value |
|---|---|
| Total NLOC | 11122 |
| Functions | 1566 |
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
logging on ([`tests.txt`](tests.txt), line 596). This addon keeps the default, so the arm does not
apply. It is counted in the total and not in `passed`. Pre-existing.

## What moved

- **lint:** 0/0 over 79 files did not move.
- **tests:** 607 cases, 606 passed, 1 skipped, 0 failed, all unchanged. The new
  [`test-cases.md`](test-cases.md) is identical to the previous bundle's, so the re-vendor added no
  case to this suite and renamed none.
- **perf:** the suite stayed at pass.

| Scenario | api/iter (prev → now) | bytes/iter (prev → now) |
|---|---|---|
| `showroomToggle` | 1.0 → 1.0 | 64.0 → 64.0 |
| `skinRepaint` | 1083.0 → 1085.0 | 206134.2 → 206038.2 |
| `applyScale` | 2.0 → 2.0 | 0.0 → 0.0 |
| `applyAlpha` | 2.0 → 2.0 | 0.0 → 0.0 |

  `skinRepaint`'s two extra calls are the expected result of the re-vendor: 7c77443 records that
  `WidgetsDragHandle` minor 10 adds two calls per fit, and that the showroom's strip re-fits after
  every repaint. That commit re-pinned the scenario's fixed ceiling, so this pass is measured
  against the new pin, not the old one. A repaint is one click, not a per-frame path.

  `ms/iter` figures are for orientation only and are not compared across runs
  ([`perf.txt`](perf.txt)).
- **complexity:** NLOC 11112 → 11122 and functions 1565 → 1566 are growth. Avg NLOC 6.5, avg CCN 2.0
  and max CCN 14 did not move. Avg tokens 54.3 → 54.2.

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

None.
