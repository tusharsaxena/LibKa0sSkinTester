# Decisions: LibKa0s v1.83.0 to v1.84.0

The run's brief pre-decides these (Ka0sAddonsCommonTasks
`docs/2026-10-31-FINDINGS_REMEDIATION/M2_LIBRARY_RELEASE.md`, step 7, and the item's task text): no
adoption is named for this addon, nobody is interviewed, candidates beyond the brief are recorded here
as declined, and no GitHub issue is filed.

| Candidate | Decision | Why |
|---|---|---|
| Flow seams | declined | Nothing on the two rendered pages needs one |
| `note` row | declined | No dim line on either page |
| `O.PositionBlock` | declined; stub owed and added | No stored position rows |
| `O.PageBanner{ acts }` | declined | No picker banner |
| `LibKa0s-Charts-1.0` | declined | Named adopters are LootHistory and DpsRace |

## LibKa0s#67

Checked `settings/Schema.lua`, `settings/Panel.lua` and `settings/Profiles.lua`:
`grep -rnE 'shownWhen|disabledIf' settings modules core` prints nothing, and no group here is picked
by a selector. The Skin tab is the library's own. On Sample controls `sample.mode` is a sample that
selects nothing, and every sample row is always shown on purpose. Finding: none. No commit.

## LibKa0s#68

`modules/ShowroomWidgets.lua:60-73` is in the library's host table as no risk: `ApplyWidth(220)` puts
the floor above the natural width in all nine skins (at most 174 px, library computation of
LK-M2-68). Fits by computation; no host change and no commit. The in-client sweep is the owner's.
