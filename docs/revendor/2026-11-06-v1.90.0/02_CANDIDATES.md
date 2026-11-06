# Candidates

Sources: `git -C ../LibKa0s log --oneline v1.89.0..v1.90.0`, the tag's `CHANGELOG.md` block for v1.90.0,
and the `Since` markers and *What changed* sections in `docs/api/Core/version-16-docs.md`,
`docs/api/Widgets/version-24.5.12.6.8.5-docs.md`, `docs/api/Skin/version-17.1.27.8.19.18.17.4.9-docs.md`
and `docs/api/Options/version-37.4.44.2.7.2.9.15.2.4.19.13.5.5.7.7.11.1.1.4-docs.md`.

## A. Delivered on the re-vendor (not offered)

- **One physical pixel (SF1-L1)**: Core 16, Widgets 24, WidgetsAutocomplete 8, SkinPaint 19 and
  SkinPaintExtras 18. The showroom's `W.Dropdown`, `W.SearchBox`, `W.ContextMenu` cascade and
  `W.Autocomplete` samples, and the `bevelIn` input edge under WoW Default, draw a 1 px edge at any UI
  scale (Widgets doc `:27`, "What a host owes: nothing"). This is the Skin Tester EditBox edge of
  feedback item 3.
- **OptionsAppearance 7's copy rule for every other host**: a copy still carries the Scope to an owner
  that did not opt out, so nothing moves until the opt-out below.

## B. Host change required

- **`RegisterOwner(owner, { keepScope = true })`** (Skin doc `:25`, Options doc `:26`: "a host whose
  Scope is a documented deviation registers with `keepScope = true`"). Touches `core/SkinSetup.lua`
  (the `RegisterOwner` call) and a test. Additive: one option on an existing call, replacing nothing.
  Recommendation: adopt, because this addon's `ignorePanel = false` is a documented deviation
  (`docs/ARCHITECTURE.md`, *Documented deviations*) that an Apply to all overwrote (feedback item 2).

## C. Whole-module adoption

None. No new major at v1.90.0.
