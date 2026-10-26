# Data flow

## A skin pick

- The player clicks a card in the showroom's swatch selector, ticks a skin on General -> Appearance,
  or types `/st set skin.skin obsidian`. A card click is `NS.Selector.Pick`: it applies the Ka0s
  skin first and saves it only when that was a change, the same order the tab uses.
- The tab calls `Skin:SetChoice("LibKa0sSkinTester", source, skin)`: the library resolves the skin,
  repaints every frame recorded for this owner, then fires `OnLooksChanged`.
- The tab writes both halves through `NS.WriteSkinChoice`, which goes through the write seam. Each
  row's `onChange` applies only its own half, so that write is a no-op (core/SkinSetup.lua).
- `modules/Showroom.lua`'s `OnLooksChanged` handler runs inside the `repaint` bracket and moves the
  selector's selection to the applied skin, so all three routes keep it right.
- A stored skin key no registered skin carries applies Ka0s Default (`NS.ApplySkinChoice`): the
  library keeps any non-empty string.
- A Scope tick (Ignore settings panel, Ignore fonts) runs the same way: the tab calls
  `Skin:SetIgnore`, which repaints this owner live, then writes the pair through
  `NS.WriteSkinChoice`'s third argument; `/st set skin.ignorePanel false` goes through the row's
  `onChange`, `NS.ApplySkinIgnore`, one half at a time.

## Opening the showroom

- `/st show`, the launcher's Show window entry and the key binding all call `NS.Showroom.Toggle`.
- While the addon is stood down, the toggle prints the refusal line and opens nothing.
- On the first open the window is built (the `build` bracket), painted through the facade, and its
  saved position restored.

## Login

- File load: the skin owner registers (Ka0s Default, since AceDB does not exist yet).
- OnInitialize: AceDB, migrations, the profile callbacks, the stored skin and its Scope applied
  (`NS.ApplySkinChoice` with no argument), the chat commands.
- OnEnable: the settings category, the launcher, the `/st` collision check, then the latch from
  the stored `enabled`.
