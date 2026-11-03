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

- `/st show` or `/skintester show` opens the showroom; so do the minimap button's menu and a key
  binding. Bare `/st` opens the settings.
- The skin is chosen from the swatch cards across the top of the showroom (Ka0s skins only), on
  General -> Skin, the library's own tab, or in the skin picker a fresh profile opens and `/st skin`
  brings back; the showroom repaints at once on a pick. Font and Texture, on the tab and in the
  picker, lay a font and a bar texture over the skin's own, and Font outline says where the skin
  outlines text.
- Twelve sections show every primitive in `lib.VOCAB`, every dropdown kind the collection draws (the library's own, AceGUI's, the media pickers and a Blizzard template), every getter's value, the semantic colors,
  quality tiers, tooltip colors and art tints, every skin's body, title and HUD faces with its
  measured width against Ka0s Default, the library's own custom
  widgets as an owned window draws them (a drag handle and its tooltip, an autocomplete, a line
  chart, a resize grip, a drawer head and nav entry with their hover art, a copy window, the debug
  console and the skin picker), and the surfaces an adopting addon gets beyond the vocabulary (its own owner tokens,
  the `opts.tokens` slot remap, an AceGUI TreeGroup, a window
  built on a Blizzard template and skinned in every skin), each sample captioned with the primitive and state it shows; a Sample controls settings page shows the skin on the
  settings renderer's widgets while the Skin tab's Ignore settings panel is off (a new profile
  has it off in this addon, a documented deviation from skinning-§3, R4-ST1).
- Everything is painted through the addon's own skin facade, so what the showroom shows is what an
  adopting addon gets.

## Non-goals

- Side-by-side comparison of two skins: one skin at a time, as the owner asked.
- Editing or creating skins, or a token inspector.
- Painting anything a skin does not: the showroom paints only through the library.
- Localization beyond English.
