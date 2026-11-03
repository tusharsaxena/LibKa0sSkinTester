# Analysis — 20261102-023745

- **Addon:** LibKa0sSkinTester 0.1.0 (not a release run)
- **Verdict:** green
- **Commit:** 3e5a661 (feat/2026-11-01-full-skinning), clean
- **Previous run:** 20261102-004124 (an amber run at 21540ee; an interim run at 4a615be, which failed perf on the same change, was discarded and re-recorded after the re-pin below)

## Headline

SF-ST-2 drops the Blizzard dropdown and resize-grip workarounds (LibKa0s #71, #72) and samples the area chart (#70). Lint, tests and perf pass. The change moved the `skinRepaint` pins, which were re-pinned in the same commit.

## Suites

| Suite | Status | Result | Artifact | Moved since 20261102-004124 |
|---|---|---|---|---|
| lint | pass | 0 warnings / 0 errors in 81 files | [`lint.txt`](lint.txt) | unchanged |
| tests | pass | 860 passed, 0 failed, 1 skipped, 861 total | [`tests.txt`](tests.txt) · [`test-cases.md`](test-cases.md) | 860 → 861 cases (the chart fill case) |
| perf (recorded, non-gating) | pass | 4 scenarios; `skinRepaint` 1360.0 calls, 221860.8 bytes | [`perf.txt`](perf.txt) · [`perf.json`](perf.json) | 1160.0 → 1360.0 calls, 221285.9 → 221860.8 bytes; pins now 1360 and 221880 |
| complexity (recorded, non-gating) | pass | 0 warnings, max CCN 14 | [`complexity.txt`](complexity.txt) | NLOC 12038 → 12034 |

**Complexity in full** (`manifest.json`, `suites.complexity`): NLOC 12034, functions 1683, avg NLOC 6.6, avg CCN 2.0, max CCN 14, avg tokens 55.2, warnings 0 (fun rate 0.00 / nloc rate 0.00), 1 file in the 1000–1500 band, 0 over the cap, blindFiles 0, crashedFiles 0.

**tests.** The one skip is the kit's diagnostics-contract arm for an addon that keeps logging default; pre-existing.

## What moved

- **perf:** `skinRepaint` +200 calls and +575 bytes per iteration. The interim run at 4a615be failed both old pins on exactly these figures. The cause is that the Blizzard dropdown is now painted by the library's WowStyle1 path (arrow overlay, label hooks) in place of the sample's stock list and glyph. Not bisected beyond the one commit; the old pins were measured one commit earlier. `tests/perf.lua` and `docs/performance.md` carry the new pins and the reason.
- **complexity:** slightly smaller; the workaround code is gone.

## Complexity watch list

None new. `tests/test_libka0s.lua` stays on notice with its carried disposition in `RESULTS.md`.
