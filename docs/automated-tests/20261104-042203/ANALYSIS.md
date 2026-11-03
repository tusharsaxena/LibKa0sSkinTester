# Analysis — 20261104-042203

- **Addon:** LibKa0sSkinTester 0.1.0 (not a release run)
- **Verdict:** amber
- **Commit:** 2b336b3 (feat/2026-11-01-full-skinning), clean
- **Previous run:** 20261102-023745 (green, at 3e5a661, 27 commits behind this one)

## Headline

Lint and tests pass, so the run and the commit gates hold. Perf fails: `skinRepaint` is over both of
its pinned ceilings, the API-call pin (1360) and the byte ceiling (221880). Perf never fails a run or
blocks a commit, but it does gate the tag, so the pins are owed a re-measure and a re-pin with a stated
reason before any release (Actions 1). Complexity is unchanged in shape: 0 warnings, max CCN 14.

## Suites

| Suite | Status | Result | Artifact | Moved since 20261102-023745 |
|---|---|---|---|---|
| lint | pass | 0 warnings / 0 errors in 83 files | [`lint.txt`](lint.txt) | 81 → 83 files |
| tests | pass | 886 passed, 1 skipped, 0 failed, 887 total | [`tests.txt`](tests.txt) · [`test-cases.md`](test-cases.md) | 861 → 887 cases; the same one skip |
| perf (gates neither run nor commit; gates the tag) | fail | 4 scenarios; `skinRepaint` 1415.0 calls, 249621.7 bytes per iteration | [`perf.txt`](perf.txt) · [`perf.json`](perf.json) | pass → fail; `skinRepaint` 1360.0 → 1415.0 calls, 221860.8 → 249621.7 bytes |
| complexity (gates neither run nor commit; gates the tag) | pass | see below | [`complexity.txt`](complexity.txt) | NLOC 12034 → 12430, functions 1683 → 1741 |

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

**perf — fail, a pre-existing drift, not a round 6 regression.** [`perf.txt`](perf.txt) reports two
failed assertions: `skinRepaint made 1415.0 API calls, over its pinned 1360` and `skinRepaint
allocated 249621.7 bytes/iter, over its 221880-byte ceiling`. The other three scenarios
(`showroomToggle`, `applyScale`, `applyAlpha`) are within their ceilings. The pins in
`tests/perf.lua` were last set at SF-ST-2 (3e5a661), the previous run's commit, and the 27 commits
since include several LibKa0s v1.85.0 re-cut re-vendors and showroom sample changes. That file's own
comment names a re-vendor or a new sample as the moment to re-measure and re-pin, and none of them did.
Measured on `git archive` exports outside this bundle, the repaint first moved at R3-RV (115020c) and
then at R4-ST1 (49bfafe), R4-ST3 (958358c), R4-ST4 (c623473), R5-RV (8189bff) and R5-WIN (94aae3f).
The round 6 commits (266cdfe, 2dcf085, ddad584, 2b336b3) left it unchanged. A skin change is one
click, not a per-frame path, so the figure is a ceiling that went unrecorded rather than a hot-path
cost. Whether to accept the new figure is the owner's call, because a rise is the finding.

**tests — 1 skip, unchanged.** [`tests.txt`](tests.txt) line 657: the diagnostics-contract opt-out
case skips because this addon keeps the default (`Kit.diagnostics.enablesLogging` is not false); the
case above it holds the default. It is counted in neither passed nor failed.

## What moved

- **lint:** still 0/0, over 83 files instead of 81.
- **tests:** 861 → 887 cases (+26), all passing, with the same single skip.
- **perf:** pass → fail. `skinRepaint` rose 1360.0 → 1415.0 API calls and 221860.8 → 249621.7 bytes
  per iteration. `showroomToggle` stayed at 1.0 call and 64.0 bytes. `applyScale` and `applyAlpha`
  stayed at 2.0 calls and 0.0 bytes. The ms/iter figures are for orientation within a run only.
- **complexity:** the addon grew (NLOC 12034 → 12430, functions 1683 → 1741). The averages held
  (avg NLOC 6.6, avg CCN 2.0), avg tokens went 55.2 → 55.3 and max CCN stayed at 14. So the code grew
  without getting denser. The band table did not change: one file on notice, none over the cap.

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

1. `tests/perf.lua`, the `REPAINT_MAX_BYTES, REPAINT_MAX_API` pin: re-measure `skinRepaint` and
   re-pin it, with the rise and its commits written into the ceiling comment as that file requires.
   Alternatively, find and remove the extra repaint work. This is new here. No deviation ID or review
   finding tracks it, and it gates the next tag.
