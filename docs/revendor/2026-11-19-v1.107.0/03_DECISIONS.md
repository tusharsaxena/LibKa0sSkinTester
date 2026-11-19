# 03 Decisions

Pre-decided by Ka0sAddonsCommonTasks `docs/2026-11-19-ADOPTION_FEEDBACK/` (items AF-RV-ST and AF-WVR-ST), not
interviewed. No GitHub issue was filed from this run.

- **The showroom's DragHandle specimen keeps the library default.** It passes neither `settings = false` nor
  `onClose`, so from v1.107.0 it shows `?` and the settings mark, the strip the library builds for a host that
  asks for nothing. It is a specimen of the widget, not a strip of this addon's: `settings = false` would show a
  shape no real strip has after the owner's 2026-11-19 ruling (the gear on every strip), and an X would need a
  close handler for a display that does not exist. Pinned by AF-WVR-ST in `tests/test_showroom_widgets.lua`.
