# Scope

## What it is for

Judging the Ka0s skins the way you pick a sofa fabric: choose a swatch, see it on the real thing. The
showroom shows the elements `LibKa0s-Skin-1.0` can paint in the skin the addon is wearing, so a skin
can be judged, and a skin defect spotted, in one window instead of by walking another addon's screens.

## Who uses it

The collection's owner and anyone working on the skins: checking a new skin, a token change, or a
fix to a primitive. It is a roster addon, so it receives every collection-wide upgrade, and it is
never published on CurseForge.

## What it does

- `/st` or `/skintester` opens the showroom; so do the minimap button's menu and a key binding.
- The skin is chosen from the swatch cards across the top of the showroom (Ka0s skins only), on
  General -> Skin, the library's own tab, or in the first-run skin picker a fresh profile opens; the
  showroom repaints at once on a pick. The Skin tab's Font and Texture lay a font and a bar texture
  over the skin's own.
- Eight sections show every primitive in `lib.VOCAB` and every getter's value, each sample captioned
  with the primitive and state it shows; a Sample controls settings page shows the skin on the
  settings renderer's widgets, once the Skin tab's Ignore settings panel is off (a new profile
  has it on).
- Everything is painted through the addon's own skin facade, so what the showroom shows is what an
  adopting addon gets.

## Non-goals

- Side-by-side comparison of two skins: one skin at a time, as the owner asked.
- Editing or creating skins, or a token inspector.
- Painting anything a skin does not: the showroom paints only through the library.
- Localization beyond English.
