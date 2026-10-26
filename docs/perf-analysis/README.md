# Perf analysis — the in-game capture store

**In-game captures only.** A player runs `/st perf` in a live client and copies the result out; no
script can produce one (`performance-§8`). Offline scenario runs are a different measurement: they
live in the bundle of the run that produced them under [`../automated-tests/`](../automated-tests/README.md)
(`automated-tests-§7`).

The store is standing and cumulative, so captures compare across versions. The protocol and how to
read the numbers are in [../performance.md](../performance.md).

## Bundle naming

```
docs/perf-analysis/<YYYYMMDD-HHMMSS>/
```

One directory per capture, stamped in local time from the record's own `timestamp`.

## The three artifacts

| File | What it is |
|---|---|
| `report.md` | What the client printed: the `/st perf report` summary plus the run's lifecycle lines |
| `dump.json` | The JSON record the summary was built from, one line, byte for byte as emitted |
| `ANALYSIS.md` | The write-up, following the standards repo's root `PERF_ANALYSIS.md` playbook |

Bundles are frozen once written and never pruned; this README is the one file here that is rewritten.

## Schema summary

The record shape is the library's, versioned there:
[LibKa0s docs/record-schema.md](https://github.com/tusharsaxena/LibKa0s/blob/master/docs/record-schema.md).
This addon's buckets, `build` and `repaint`, are listed in [../performance.md](../performance.md).

## Taking a capture

`/st perf` with no sub-verb prints status and opens the step panel, which offers only the next legal
step:

```
/st perf start [label]     out of combat — begins the run
/st perf measure a         arms Experiment A (addon active)
/st perf measure b         arms Experiment B (addon suspended)
/st perf finish            ends the run and appends it to the ring
/st perf report            prints the human-readable summary
/st perf dump              writes the run as one line of JSON into the debug console
```

Then use the debug console's **Copy** button; one paste carries the report, the dump and the
lifecycle lines that `/dev-copilot:wow-perf-analysis` needs. For this addon the useful arm is a
skin-switching session with the showroom open: pick several skins in turn during each experiment.

## Capture index

No capture has been taken yet: the addon has not been played. A fabricated first capture would be
worse than none.
