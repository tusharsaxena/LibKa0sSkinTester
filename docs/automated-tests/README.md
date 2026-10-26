# Automated test records

Every run of the four out-of-game suites, recorded. The normative rules are the standard's
[`automated-tests`](https://github.com/tusharsaxena/WowAddonStandards/blob/master/standards/standards/automated-tests.md)
section; this file is the local how-to.

## Running

```sh
~/.claude/dev-copilot/bin/ka0s-bounded tests/_kit/run-automated-tests.sh             # all four, writes a bundle
~/.claude/dev-copilot/bin/ka0s-bounded tests/_kit/run-automated-tests.sh --suite complexity --no-bundle
~/.claude/dev-copilot/bin/ka0s-bounded tests/_kit/run-automated-tests.sh --suite lint --suite tests --no-bundle
```

The runner is **vendored** from LibKa0s's `testkit/` and is byte-identical in every Ka0s addon. Never
edit `tests/_kit/`: a kit fix goes upstream and is re-vendored.

## What gates, and what only records

**Two checkpoints, the commit and the tag**, and a suite's answer differs between them
(`automated-tests-§3`), so each row names both.

| Suite | Command | Gates the run and the commit? | Gates the tag? |
|---|---|---|---|
| `lint` | `luacheck .` | **yes** | **yes**: must be `pass` |
| `tests` | `lua tests/run.lua` | **yes** | **yes**: must be `pass` |
| `perf` | `lua tests/perf.lua` | no, recorded only | **yes**: must be `pass`; a `skip` is not evaluated |
| `complexity` | the runner's `--suite complexity` (lizard over the kit's sighted shadow, with function-count parity; raw `lizard` is blind in Lua) | no, recorded only | **yes**: `pass`, zero functions above CCN 15 and `blindFiles` 0 |

`perf` and `complexity` are measured, recorded and diffed, and never fail a run or block a commit: a
threshold that fails a run teaches everyone to reach for `--no-verify`. The tag is gated on all four
suites at `pass` plus zero functions above CCN 15, evaluated by `/dev-copilot:bump-version` from the
release run's `manifest.json`. This addon is never published, so no release run is expected, but the
gate is kept so the record means the same thing as every other addon's.

**A missing tool is a skip, not a failure**, recorded with its reason.

## What is here

- **`RESULTS.md`**: one row per run across all four suites, plus the complexity watch list. One
  file, overwritten in place; its git history is the trend line.
- **`<YYYYMMDD-HHMMSS>/`**: one frozen bundle per run: `manifest.json`, one file per suite, and
  `ANALYSIS.md`. Bundles are never edited once written and never pruned.

In-game captures are a different store: [`../perf-analysis/`](../perf-analysis/README.md).
