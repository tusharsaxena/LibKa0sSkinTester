# Analysis — 20261101-201525

- **Addon:** LibKa0sSkinTester 0.1.0 (not a release run)
- **Verdict:** green
- **Commit:** d143651 (feat/2026-11-01-full-skinning), clean
- **Previous run:** 20261101-143746

## Headline

All four suites pass on the re-cut LibKa0s v1.85.0, kit revision 50, with the typed-value gate and the skin-switch test adopted. The rise from 632 to 859 cases is the new surface declaration, not new behavior. Nothing to act on; no version moved.

## Suites

| Suite | Status | Result | Artifact | Moved since 20261101-143746 |
|---|---|---|---|---|
| lint | pass | 0 warnings / 0 errors in 81 files | [`lint.txt`](lint.txt) | 80 → 81 files: `tests/skin_surfaces.lua` |
| tests | pass | 858 passed, 1 skipped, 0 failed, 859 total | [`tests.txt`](tests.txt) · [`test-cases.md`](test-cases.md) | 632 → 859 cases |
| perf | pass | 4 scenarios, `skinRepaint` 1151.0 calls, 220229.9 bytes | [`perf.txt`](perf.txt) · [`perf.json`](perf.json) | 1153.0 → 1151.0 calls, 220560.3 → 220229.9 bytes |
| complexity | pass | see below | [`complexity.txt`](complexity.txt) | max CCN 14 unchanged, warnings unchanged at 0 |

**Complexity is reported in full.** Values are from `manifest.json`'s `suites.complexity`.

| Metric | Value |
|---|---|
| Total NLOC | 12002 |
| Functions | 1678 |
| Avg NLOC / function | 6.6 |
| Avg CCN | 2.0 |
| Max CCN | 14 |
| Avg tokens / function | 55.2 |
| Warnings (CCN > 15) | 0 |
| Warning rate (`Fun Rt` / `nloc Rt`) | 0.00 / 0.00 |
| Files in the 1000–1500 band | 1 |
| Files over the 1500 cap | 0 |
| Blind files (parity mismatch) | 0 |
| Crashed files (lizard raised) | 0 |

**tests.** The one skip is the kit's diagnostics-contract arm for an addon that opts out of turning logging on. This addon keeps the default, so the arm does not apply. Pre-existing.

## What moved

- **lint:** one more file in scope, still 0/0.
- **tests:** 227 more cases. Nearly all are `test_skin_switch`, which runs each declared surface once with the Scope cleared and once ignored. The rest are the typed-value gate's and the new showroom cases.
- **perf:** `skinRepaint` fell slightly with the re-cut library and stays under its ceiling in `tests/perf.lua`. The other three scenarios are at their floors.
- **complexity:** NLOC 11797 → 12002 and functions 1650 → 1678, growth from the vendored kit's new tests and the samples; the averages hold (avg CCN 2.0, avg NLOC 6.6, avg tokens 55.1 → 55.2).

## Complexity watch list

### Functions `lizard` warned on

| Function | CCN | Location | Disposition |
|---|---|---|---|

None.

### Files by `layout-§1` band

| Band | File | LOC | Disposition |
|---|---|---|---|
| 1000–1500 (on notice) | `tests/test_libka0s.lua` | 1057 | Accepted: the LibKa0s adoption characterization suite, carried from the scaffold. Split by library major if it nears the cap. |

## Actions

None.
