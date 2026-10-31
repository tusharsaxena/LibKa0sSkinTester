# Analysis — 20261031-202019

- **Addon:** LibKa0sSkinTester 0.1.0 (labelled `pre-merge`; not a release run)
- **Verdict:** amber
- **Commit:** 1fab9f1 (feat/2026-10-31-font-pickers-skin-faces), clean
- **Previous run:** 20261026-163042

## Headline

Lint and tests pass, so the commit gate is met. The verdict is amber because `perf` failed one
assertion: `showroomToggle` allocated 160.0 bytes/iter against its 88-byte ceiling. That failure does
not block a commit, but it does block a tag until it is resolved. The bytes are the test mock's, not
the addon's. Complexity is clean: max CCN 14, nothing warned on, nothing over the 1500 cap, no blind
or crashed files.

## Suites

| Suite | Status | Result | Artifact | Moved since 20261026-163042 |
|---|---|---|---|---|
| lint | pass | 0 warnings / 0 errors in 79 files | [`lint.txt`](lint.txt) | files 53 → 79, still 0/0 |
| tests | pass | 605 passed, 1 skipped, 0 failed, 606 total | [`tests.txt`](tests.txt) · [`test-cases.md`](test-cases.md) | total 456 → 606, skips unchanged at 1 |
| perf | fail | 4 scenarios, 1 assertion failed | [`perf.txt`](perf.txt) · [`perf.json`](perf.json) | pass → fail |
| complexity | pass | see below | [`complexity.txt`](complexity.txt) | max CCN 13 → 14, warnings unchanged at 0 |

**Complexity is reported in full.** Values are from `manifest.json`'s `suites.complexity`.

| Metric | Value |
|---|---|
| Total NLOC | 11088 |
| Functions | 1563 |
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

**tests.** The skip is the kit's diagnostics-contract arm for an addon that opts out of turning
logging on ([`tests.txt`](tests.txt), line 595). This addon keeps the default, so the arm does not
apply. It is counted in the total and not in `passed`. Pre-existing.

**perf.** A regression in the record, and it is a measurement artifact. [`perf.txt`](perf.txt) reads
`showroomToggle allocated 160.0 bytes/iter, over its 88-byte ceiling`. The previous bundle's figure
was 64.0.

- **Bisect.** The figure changed at 3afa3be (ST-03, the showroom's skinned scrollbar). Its parent
  6e2a0af measures the old figure. That commit made `R.Show` call `syncBar`
  (`modules/Showroom.lua`).
- **Cause.** `tests/wow_mock.lua`'s frame `__index` fallback returns a fresh closure on every read of
  a PascalCase method the stub does not define, so each method read in `syncBar` allocates in the
  mock. `syncBar` builds no string or table of its own on this path.
- **Proof.** In a scratch export of HEAD, with that fallback caching its closure and nothing else
  changed, `showroomToggle` went back to the previous bundle's figure and the assertion passed. That
  export is not part of this bundle, so it contributes no figure here. Nothing in the repo changed.
- **Why the ceiling missed it.** The ceiling is the bare frame's Show/Hide flip plus 24 bytes, and
  the flip never reaches `syncBar`.

No in-game claim follows from this: the suite measures the mock.

## What moved

- **lint:** 0/0 did not move. Scope grew from 53 to 79 files.
- **tests:** 456 → 606 cases (passed 455 → 605), with failures at 0 and skips at 1.
- **perf:**

| Scenario | api/iter (prev → now) | bytes/iter (prev → now) |
|---|---|---|
| `showroomToggle` | 1.0 → 1.0 | 64.0 → 160.0 |
| `skinRepaint` | 12.0 → 1083.0 | 8501.7 → 41794.7 |
| `applyScale` | 2.0 → 2.0 | 0.0 → 0.0 |
| `applyAlpha` | 2.0 → 2.0 | 0.0 → 0.0 |

  `skinRepaint` passes because its ceiling is pinned to each run's own measurement. Its rise is the
  growth the previous analysis expected: the scenario then painted the shell, title bar and close
  button, and now paints every showroom sample.
- **complexity:** NLOC 7288 → 11088 and functions 1082 → 1563 are growth. The density signals moved
  slightly: avg NLOC 6.2 → 6.5, avg CCN 1.9 → 2.0, avg tokens 48.2 → 54.2. Max CCN 13 → 14, at
  `reloadProfile` in `core/LibKa0sSkinTester.lua` and an anonymous case in `tests/test_settings.lua`.
  Both are under the CCN 15 release ceiling.

## Complexity watch list

### Functions

| Function | CCN | Location | Disposition |
|---|---|---|---|

None.

### Files

| Band | File | LOC | Disposition |
|---|---|---|---|
| 1000–1500 (on notice) | `tests/test_libka0s.lua` | 1038 | Accepted: the LibKa0s adoption characterization suite, carried from the scaffold. Split by library major if it nears the cap. |

The disposition is carried forward. Neither run in this record is a release run, so it has not begun
the three-release shelf life. The file grew by one line (1037 → 1038 from the previous analysis).

## Actions

1. `tests/wow_mock.lua`: cache the closure in the frame `__index` fallback, or pin the toggle's
   ceiling to a measurement that includes `syncBar`. `perf` gates the tag, so one of them is needed
   before this addon's next release. New here; no tracked id. `tests/wow_mock.lua` is authored, not
   vendored, so the change is local. This run changed no code.
