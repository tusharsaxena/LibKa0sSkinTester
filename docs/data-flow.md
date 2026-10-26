# Data flow

## A skin pick

- The player ticks a skin on General -> Appearance (or types `/st set skin.skin obsidian`).
- The tab calls `Skin:SetChoice("LibKa0sSkinTester", source, skin)`: the library resolves the skin,
  repaints every frame recorded for this owner, then fires `OnLooksChanged`.
- The tab writes both halves through `NS.WriteSkinChoice`, which goes through the write seam. Each
  row's `onChange` applies only its own half, so that write is a no-op (core/SkinSetup.lua).
- `modules/Showroom.lua`'s `OnLooksChanged` handler runs inside the `repaint` bracket.

## Opening the showroom

- `/st show`, the launcher's Show window entry and the key binding all call `NS.Showroom.Toggle`.
- While the addon is stood down, the toggle prints the refusal line and opens nothing.
- On the first open the window is built (the `build` bracket), painted through the facade, and its
  saved position restored.

## Login

- File load: the skin owner registers (Ka0s Default, since AceDB does not exist yet).
- OnInitialize: AceDB, migrations, the profile callbacks, the stored skin applied, the chat
  commands.
- OnEnable: the settings category, the launcher, then the latch from the stored `enabled`.
