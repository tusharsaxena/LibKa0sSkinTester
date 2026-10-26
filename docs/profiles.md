# Profiles

AceDB profiles are user-visible: Settings -> AddOns -> Ka0s Skin Tester -> Profiles draws
AceDBOptions' controls (`settings/Profiles.lua`), and `/st profile [name]` lists or switches them.

## What a profile holds

Everything in [`schema.md`](./schema.md)'s Profile table: `enabled`, the showroom's scale and
opacity, and the skin (`skin.source`, `skin.skin`). So a profile can carry a skin: switching profiles
switches the skin the showroom shows.

## What survives a switch, a copy or a reset

The global keys: the minimap button's state (LibDBIcon's own `hide`), the showroom's window
position, and the schema stamp.

## What happens on a profile event

`core/LibKa0sSkinTester.lua`'s `reloadProfile`, for switch, copy and reset alike: migrations run,
open panels refresh, the latch is re-set from the incoming `enabled`, the incoming skin is applied,
and the showroom's scale and opacity are re-applied. One debug line per event, written by the
profile-event handler.
