Delta: LibKa0s v1.106.0 -> v1.106.0 (span: v1.106.0)

# 01 Delta (consolidated span)

Written 2026-11-19 by item AF-RV-ST of the Ka0sAddonsCommonTasks run `docs/2026-11-19-ADOPTION_FEEDBACK/`,
beside this run's own bundle `docs/revendor/2026-11-19-v1.107.0/`.

The AUDIT.md re-vendor listing, run before the copy:

```sh
horizon=$(ls -1 docs/revendor | sort | head -1 | cut -c1-10)   # 2026-10-31
# vendored: the provenance tag at every payload commit and every provenance roll since the horizon
# recorded: the tags named by docs/revendor/*/ folders and span lines
grep -vxF -f recorded.txt vendored.txt
```

- vendored: v1.83.0 v1.84.0 v1.85.0 v1.89.0 v1.90.0 v1.91.0 v1.92.0 v1.93.0 v1.94.0 v1.105.0 v1.106.0
- recorded: v1.78.0 v1.79.0 v1.80.0 v1.81.0 v1.82.0 v1.83.0 v1.84.0 v1.85.0 v1.89.0 v1.90.0 v1.91.0 v1.92.0
  v1.93.0 v1.94.0 v1.105.0
- unrecorded: **v1.106.0**, vendored by `1dee78a` (Widgets minor 28, the HUD dock guard), with no bundle.
