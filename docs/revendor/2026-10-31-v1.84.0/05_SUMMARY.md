# Summary: LibKa0s v1.83.0 to v1.84.0

- **Tag:** v1.83.0 to v1.84.0, base taken from `CLAUDE.md:40`. Minors are in `01_DELTA.md`; kit revision 46 to 47.
- **Span bundle or base correction:** none.
- **Free on the copy:** the peels, the drag handle's fit, the Charts entry in the diagnostics header.
- **Contract blockers:** none. `H.PositionBlock` joined the Options stub, the nine new files joined `tests/loader.lua`, and `skin engine` moved to 11 in `tests/test_diagnostics.lua`.
- **Icons:** `close, copy, clear, eye, settings.` kept. The prune kept 6 files and removed 5834: the whole copy's undeclared Open Iconic, Phosphor and Game-icons files, which the addon never shipped.
- **Provenance split, credits, dead mirrors:** none needed. README unchanged.
- **Refresh file:** none.
- **Adopted:** nothing. **Declined:** five candidates, in `03_DECISIONS.md`, with no issue filed, per the brief.
- **LibKa0s#67:** none. **LibKa0s#68:** fits by computation.
- **Gate after the copy:** `lua tests/run.lua` 606 passed, 0 failed, 1 skipped, 607 total; `luacheck` 0 warnings / 0 errors in 79 files.
- **Owner's smoke:** DIAG-3 added, `Result:` empty.
