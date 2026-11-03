# Analysis — 20261102-004124

- **Addon:** LibKa0sSkinTester 0.1.0 (not a release run)
- **Verdict:** amber
- **Commit:** 21540ee (feat/2026-11-01-full-skinning), clean
- **Previous run:** 20261101-201525

## Headline

Lint and tests pass. Perf is amber: `skinRepaint` went over both of its pinned ceilings in `tests/perf.lua`. The cause is SF-ST-1, the Source dropdown added to the showroom's selector row: it is one more library widget painted on every skin switch. The ceilings were not touched; raising them is a call for the owner.

## Suites

| Suite | Status | Result | Artifact | Moved since 20261101-201525 |
|---|---|---|---|---|
| lint | pass | 0 warnings / 0 errors in 81 files | [`lint.txt`](lint.txt) | unchanged |
| tests | pass | 859 passed, 0 failed, 1 skipped, 860 total | [`tests.txt`](tests.txt) · [`test-cases.md`](test-cases.md) | 859 → 860 cases (the dropdown case) |
| perf (recorded, non-gating) | fail | 4 scenarios; `skinRepaint` 1160.0 calls, 221284.8 bytes | [`perf.txt`](perf.txt) · [`perf.json`](perf.json) | 1151.0 → 1160.0 calls (pin 1153), 220229.9 → 221284.8 bytes (ceiling 220590) |
| complexity (recorded, non-gating) | pass | 0 warnings, max CCN 14 | [`complexity.txt`](complexity.txt) | NLOC 12002 → 12038, functions 1678 → 1683 |

**Complexity in full** (`manifest.json`, `suites.complexity`): NLOC 12038, functions 1683, avg NLOC 6.6, avg CCN 2.0, max CCN 14, avg tokens 55.3, warnings 0 (fun rate 0.00 / nloc rate 0.00), 1 file in the 1000–1500 band, 0 over the cap, blindFiles 0, crashedFiles 0.

**tests.** The one skip is the kit's diagnostics-contract arm for an addon that keeps logging default; pre-existing.

## What moved

- **perf:** `skinRepaint` +9 calls and +1.05 KB per iteration, over the pins (1153 calls, 220590 bytes). Both assertions failed in `perf.txt`. The other three scenarios are at their floors. Cause is the added dropdown, not a regression elsewhere; this was not bisected.
- **complexity:** growth is the new dropdown code and test; averages hold.

## Complexity watch list

None new. `tests/test_libka0s.lua` (1057 LOC) stays on notice with its carried disposition in `RESULTS.md`.
