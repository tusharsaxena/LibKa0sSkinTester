# Analysis — 20261026-163042

- **Addon:** Ka0s Skin Tester 0.1.0 (first run; not a release run)
- **Verdict:** green
- **Commit:** 50bf43b (master), clean
- **Previous run:** none. This is the first row in the record.

## Headline

The scaffold's first run, and every suite passed. Lint is 0/0 over 53 files. 455 of 456 headless cases
passed, with none failed and one kit case skipped. The four offline perf scenarios tripped no ceiling.
Complexity ran sighted, with a max CCN of 13 and nothing warned on. Nothing here needs action. The one
row worth watching is `tests/test_libka0s.lua` in the 1000–1500 band, a test suite that arrived at
that size with the scaffold.

## Suites

| Suite | Status | Result | Artifact | Moved since previous |
|---|---|---|---|---|
| lint | pass | 0 warnings / 0 errors in 53 files | [`lint.txt`](lint.txt) | first run |
| tests | pass | 455 passed, 1 skipped, 0 failed, 456 total | [`tests.txt`](tests.txt) · [`test-cases.md`](test-cases.md) | first run |
| perf | pass | 4 scenarios | [`perf.txt`](perf.txt) · [`perf.json`](perf.json) | first run |
| complexity | pass | 7288 NLOC, 1082 functions, avg CCN 1.9, max 13, 0 warnings | [`complexity.txt`](complexity.txt) | first run |

**tests.** The skip is the kit's diagnostics-contract arm for an addon that opts out of turning
logging on ([`tests.txt`](tests.txt), line 445). This addon keeps the default, so its report turns
logging on, and the case before it holds that. The skip counts toward the total, not toward `passed`.

**perf.** All four scenarios are the showroom's own paths. Ceilings are described in
`docs/performance.md`.

| Scenario | api/iter | bytes/iter | Reading |
|---|---|---|---|
| `showroomToggle` | 1.0 | 64.0 | All 64 bytes are the mock's own Show/Hide record. The same flip on the bare frame measures the same figure, and the ceiling charges the addon only what is over it. |
| `skinRepaint` | 12.0 | 8501.7 | One skin change repaints the shell, title bar and close button through the library's paint. Pinned at its measured figure. The number grows once ST-04 adds the sample sections, and that growth is expected. |
| `applyScale` / `applyAlpha` | 2.0 | 0.0 | One `SetScale` and one `SetAlpha` per write, with nothing allocated. |

**complexity.** The top of the list is test code and the vendored-from-WhatGroup schema seam:
an anonymous case in `tests/test_libka0s.lua` (CCN 13), `trackedMarkdown` in
`tests/test_doc_structure.lua` (13), `S.SetMany` in `settings/SchemaSetup.lua` (13) and
`assignedIn` in `tests/test_register.lua` (13). Each is under the CCN 15 release ceiling. None of
them is showroom code. The showroom's code is still small.

## Watch list

`tests/test_libka0s.lua` is 1037 lines, in the `layout-§1` notice band. It is the LibKa0s adoption
characterization suite, carried from the addon this one was scaffolded from and cut down to the
tester's rows. Its disposition in `RESULTS.md` is **Accepted**. Split it by library major if it nears
the 1500 cap.

## Release gate

Not evaluated. This is not a release run, and `manifest.json` stamps no `release`.
