Delta: LibKa0s v1.94.0 -> v1.94.0 (span: v1.94.0)

# 01 Delta (consolidated span)

Written 2026-11-16 by item RV-ST of the Ka0sAddonsCommonTasks run `docs/2026-11-16-LIBKA0S_ISSUES_75_PLUS/`,
beside this run's own bundle `docs/revendor/2026-11-16-v1.105.0/`.

The AUDIT.md re-vendor listing, run before the copy:

```sh
horizon=$(ls -1 docs/revendor | sort | head -1 | cut -c1-10)   # 2026-10-31
# vendored: the provenance tag at every payload commit and every provenance roll since the horizon
# recorded: the tags named by docs/revendor/*/ folders and span lines
grep -vxF -f recorded.txt vendored.txt
```

- vendored: v1.83.0 v1.84.0 v1.85.0 v1.89.0 v1.90.0 v1.91.0 v1.92.0 v1.93.0 v1.94.0
- recorded: v1.78.0 v1.79.0 v1.80.0 v1.81.0 v1.82.0 v1.83.0 v1.84.0 v1.85.0 v1.89.0 v1.90.0 v1.91.0 v1.92.0 v1.93.0
- unrecorded: **v1.94.0**, vendored by `f2e408a` (W1-ST-02) and re-copied after the tag's re-cut by `5d96db0`
  (W1-ST-03), with no bundle.
