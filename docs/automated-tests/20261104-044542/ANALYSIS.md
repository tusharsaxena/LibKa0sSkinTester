# Analysis — 20261104-044542

- **Addon:** LibKa0sSkinTester 0.1.0 (not a release run)
- **Verdict:** green
- **Commit:** 9c3debb (feat/2026-11-01-full-skinning), clean
- **Previous run:** 20261104-042203 (amber, at 2b336b3, 2 commits behind this one)

## Headline

All four suites pass. The one change since the previous run is the R6-AT re-pin in `tests/perf.lua`
(9c3debb): `skinRepaint` measured the same as before, and its ceilings now sit at that figure. Lint,
tests and complexity did not move. Nothing is left to act on.

## Suites

| Suite | Status | Result | Artifact | Moved since 20261104-042203 |
|---|---|---|---|---|
| lint | pass | 0 warnings / 0 errors in 83 files | [`lint.txt`](lint.txt) | unchanged |
| tests | pass | 886 passed, 1 skipped, 0 failed, 887 total | [`tests.txt`](tests.txt) · [`test-cases.md`](test-cases.md) | unchanged; the same one skip |
| perf (gates neither run nor commit; gates the tag) | pass | 4 scenarios; `skinRepaint` 1415.0 calls, 249621.7 bytes per iteration | [`perf.txt`](perf.txt) · [`perf.json`](perf.json) | fail → pass; the figures did not move, the pins did |
| complexity (gates neither run nor commit; gates the tag) | pass | see below | [`complexity.txt`](complexity.txt) | unchanged |

| Metric | Value |
|---|---|
| Total NLOC | 12430 |
| Functions | 1741 |
| Avg NLOC / function | 6.6 |
| Avg CCN | 2.0 |
| Max CCN | 14 |
| Avg tokens / function | 55.3 |
| Warnings (CCN > 15) | 0 |
| Warning rate (`Fun Rt` / `nloc Rt`) | 0.00 / 0.00 |
| Files in the 1000–1500 band | 1 |
| Files over the 1500 cap | 0 |
| Blind files (parity mismatch) | 0 |
| Crashed files (lizard raised) | 0 |

Every value is from [`manifest.json`](manifest.json)'s `suites.complexity` and the footer of
[`complexity.txt`](complexity.txt). The run is sighted (0 blind files) and measured (0 crashed files).

**perf: pass, after a re-pin and no code change.** [`perf.txt`](perf.txt) reports `skinRepaint` at
1415.0 API calls and 249621.7 bytes per iteration, the same figures the previous run failed on. What
changed is the pin in `tests/perf.lua`: R6-AT (9c3debb) set `REPAINT_MAX_API` to 1415 and
`REPAINT_MAX_BYTES` to 249640, up from SF-ST-2's 1360 and 221880. The ceiling comment now records the
date, the figures, and the six commits the rise came from. Those are R3-RV 115020c, R4-ST1 49bfafe,
R4-ST3 958358c, R4-ST4 c623473, R5-RV 8189bff and R5-WIN 94aae3f, each measured on exports of the
commit and its parent. Every one of those steps was deliberate skin work, and round 6 left the figure
flat, so the lead accepted it rather than cutting work. The other three scenarios are within their
ceilings and did not move.

**tests: 1 skip, unchanged.** [`tests.txt`](tests.txt) line 657: the diagnostics-contract opt-out
case skips because this addon keeps the default (`Kit.diagnostics.enablesLogging` is not false). The
case above it covers the default. The skip is counted as neither passed nor failed.

## What moved

- **lint:** still 0/0 over 83 files.
- **tests:** 887 cases, 886 passed, unchanged, with the same single skip. The re-pin touched no test
  file.
- **perf:** fail → pass. `skinRepaint` stayed at 1415.0 calls and 249621.7 bytes, and its ceilings
  rose to 1415 and 249640. `showroomToggle` stayed at 1.0 call and 64.0 bytes. `applyScale` and
  `applyAlpha` stayed at 2.0 calls and 0.0 bytes. The ms/iter figures are for orientation within a
  run only.
- **complexity:** unchanged. NLOC 12430, 1741 functions, avg NLOC 6.6, avg CCN 2.0, max CCN 14 and
  avg tokens 55.3. The band table did not change.

## Complexity watch list

**Functions `lizard` warned on**

| Function | CCN | Location | Disposition |
|---|---|---|---|

None.

**Files by `layout-§1` band**

| Band | File | LOC | Disposition |
|---|---|---|---|
| 1000–1500 (on notice) | `tests/test_libka0s.lua` | 1060 | Accepted: the LibKa0s adoption characterization suite, carried from the scaffold. Split by library major if it nears the cap. |

No entry is new and no disposition is blank.

## Actions

None. The previous run's Action 1, the `skinRepaint` re-pin, is done in 9c3debb.
