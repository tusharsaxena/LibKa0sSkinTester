# Analysis — 20261101-143611

- **Addon:** LibKa0sSkinTester 0.1.0 (labelled `full-skinning`; not a release run)
- **Verdict:** amber
- **Commit:** 75113a3 (feat/2026-11-01-full-skinning), clean
- **Previous run:** 20261101-025306

## Headline

Lint and tests pass on LibKa0s v1.85.0. Perf failed because `skinRepaint` is over its two pins in `tests/perf.lua`, at 1153.0 API calls against 1092 and 221104.3 bytes against 207020. The rise is the re-vendor and the new and repainted samples. The next FS-ST-FIX commit trims the opts tables and re-pins with its derivation.

## Suites

| Suite | Status | Result | Artifact | Moved since 20261101-025306 |
|---|---|---|---|---|
| lint | pass | 0 warnings / 0 errors in 80 files | [`lint.txt`](lint.txt) | unchanged |
| tests | pass | 631 passed, 1 skipped, 0 failed, 632 total | [`tests.txt`](tests.txt) · [`test-cases.md`](test-cases.md) | 617 → 632 cases |
| perf | fail | 4 scenarios, 2 assertions failed | [`perf.txt`](perf.txt) · [`perf.json`](perf.json) | see headline |
| complexity | pass | see below | [`complexity.txt`](complexity.txt) | max CCN 14 unchanged, warnings unchanged at 0 |

**Complexity is reported in full.** Values are from `manifest.json`'s `suites.complexity`.

| Metric | Value |
|---|---|
| Total NLOC | 11795 |
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

**perf.** Measured on an export of the re-vendor commit `0cbd665`: 1127.0 API calls and 216725.0 bytes. Cause A5's repainted samples add the other 26 calls.
