# 03 Decisions

Pre-decided by Ka0sAddonsCommonTasks `docs/2026-11-20-LIBKA0S_94_97_99_100/` (items SD-RV-ST and SD-SK-ST), not
interviewed. No GitHub issue was filed from this run.

- The two kit revision 58 hits are fixed in the re-vendor commit (01_DELTA.md, 3g), not deferred to SD-SK-ST, so the
  re-vendor commit is green.
- The GetFont line keeps its fixed 14 px (the text-size Leave class) and takes its color by `SetTextColor` on each
  redraw rather than through `R.Paint("Text")`, whose recorded repaint would put the skin's body size back.
