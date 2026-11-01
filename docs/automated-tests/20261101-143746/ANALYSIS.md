# Analysis — 20261101-143746

- **Addon:** LibKa0sSkinTester 0.1.0 (labelled `full-skinning`; not a release run)
- **Verdict:** green
- **Commit:** 77b89c9 (feat/2026-11-01-full-skinning), clean
- **Previous run:** 20261101-143611

## Headline

All four suites pass on LibKa0s v1.85.0, with `skinRepaint` re-pinned and its derivation in `tests/perf.lua`. It is not a release run, and no version moved.

## Suites

| Suite | Status | Result | Artifact | Moved since 20261101-143611 |
|---|---|---|---|---|
| lint | pass | 0 warnings / 0 errors in 80 files | [`lint.txt`](lint.txt) | unchanged |
| tests | pass | 631 passed, 1 skipped, 0 failed, 632 total | [`tests.txt`](tests.txt) · [`test-cases.md`](test-cases.md) | unchanged |
| perf | pass | 4 scenarios, `skinRepaint` 1153.0 calls, 220560.3 bytes | [`perf.txt`](perf.txt) · [`perf.json`](perf.json) | fail → pass on the re-pin |
| complexity | pass | see below | [`complexity.txt`](complexity.txt) | max CCN 14 unchanged, warnings unchanged at 0 |

**Complexity is reported in full.** Values are from `manifest.json`'s `suites.complexity`.

| Metric | Value |
|---|---|
| Total NLOC | 11797 |
| Functions | 1650 |
| Avg NLOC / function | 6.6 |
| Avg CCN | 2.0 |
| Max CCN | 14 |
| Avg tokens / function | 55.1 |
| Warnings (CCN > 15) | 0 |
| Warning rate (`Fun Rt` / `nloc Rt`) | 0.00 / 0.00 |
| Files in the 1000–1500 band | 1 |
| Files over the 1500 cap | 0 |
| Blind files (parity mismatch) | 0 |
| Crashed files (lizard raised) | 0 |

**tests.** The one skip is the kit's diagnostics-contract arm for an addon that opts out of turning logging on. This addon keeps the default, so the arm does not apply. Pre-existing.
