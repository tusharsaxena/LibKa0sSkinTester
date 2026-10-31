# Candidates: LibKa0s v1.83.0 to v1.84.0

From the `CHANGELOG.md` block `## v1.84.0` and the current API documents. Blast radius is additive for
every candidate below, because this addon replaces none of its own code with them.

## A. Reached the addon on the re-vendor alone

- The eight peels, pure moves with no public member, default or pixel moved.
- `WidgetsDragHandle.lua` minors 9 and 10: `ApplyLevel` allocates nothing, the measure sits at the
  strip's scale, and a fitted strip fits again on show. The showroom's handle takes all three.
- `DebugLogDiagnostics.lua` minor 6: the report's identity header names Charts, between Toast and
  Media. Player-visible in `/st diagnostics`, so it gets DIAG-3.
- WoW Default's Friz is measured and guarded. No size moved.

## B. Host change required

| Candidate | Evidence | Would touch | Recommendation |
|---|---|---|---|
| `O.RenderRows` `opts.beforeGroup`, `opts.afterSubgroup` | Options document, "the flow seams" | `settings/Panel.lua` | Decline: the two rendered pages have no block needing a seam |
| The `note` row | Options document; `Schema` version 3 | `settings/Schema.lua` | Decline: the pages carry no dim line |
| `O.PositionBlock(spec)` | Options document, OptionsCompose minor 15 | `settings/Schema.lua` | Decline: Reset position comes from the composed Master controls, and the addon stores no X and Y rows |
| `O.PageBanner{ acts }` | Options document, OptionsTabs minor 13 | `settings/Panel.lua` | Decline: this addon's pages draw no picker banner |

The Sample controls page could later show the `note` row, to judge its dim face in each skin. That is
a showroom coverage question for the owner, not an adoption the release needs.

## C. Whole-module adoption

| Candidate | Evidence | Would touch | Recommendation |
|---|---|---|---|
| `LibKa0s-Charts-1.0` | `docs/api/Charts/version-1.1-docs.md` | a new `modules/` showroom section | Decline for this run: LootHistory and DpsRace are the named adopters (M2 step 4) |

`LibKa0s-Sim-1.0` stays unconsumed, as at v1.83.0. No recorded decline was found to carry forward.
