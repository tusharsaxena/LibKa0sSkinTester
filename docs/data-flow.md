# Data flow

## A skin pick

- The player clicks a card in the showroom's swatch selector, ticks a skin on General -> Skin, applies one in the skin picker,
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
- A Font or Texture pick on the Skin tab calls `Skin:SetOverride`, which lays the key over the
  owner's tokens (`font.body`, `font.title`, `hud.font`; `bar.texture`), repaints every recorded
  frame and fires `OnLooksChanged` (the showroom's Values and Textures sections redraw, and Addon surfaces repaints its TreeGroup), then writes
  both halves through `NS.WriteSkinChoice`'s fourth argument; `/st set skin.texture <key>` goes
  through the row's `onChange`, `NS.ApplySkinMedia`. Another addon's copy reaches the same seam
  through `Skin:WriteChoice`.
- The Font outline dropdown calls `Skin:SetOutline` (a repaint and `OnLooksChanged`; the Values
  section's FontFlags line redraws), then writes `media.outline` through `NS.WriteSkinChoice`;
  `/st set skin.outline <mode>` goes through the row's `onChange`, `NS.ApplySkinOutline`. Load and
  every profile event apply the stored mode with the pair, the Scope and the overrides.
- The skin picker splits the two steps: a pick in its list calls `Skin:SetChoice` only (a preview,
  repainted live, nothing written); Apply or the gear then hands the pending pair to
  `NS.WriteSkinChoice`, and the close control or Escape calls `Skin:SetChoice` back to the pair the
  profile stores at the close (the spec's `get`, `NS.SkinChoice`), so only the unsaved preview is
  undone. Every close then runs the spec's `onClose`, which sets `skin.pickerSeen`.
  "Apply to all Ka0s addons" (this addon's or another's) reaches every other owner through
  `Skin:WriteChoice`, as the tab's copy does.

## Opening the showroom

- `/st show`, the launcher's Show window entry and the key binding all call `NS.Showroom.Toggle`.
- While the addon is stood down, the toggle prints the refusal line and opens nothing.
- On the first open the window is built (the `build` bracket), painted through the facade, and its
  saved position restored.

## Login

- File load: the skin owner registers (Ka0s Default, since AceDB does not exist yet).
- OnInitialize: AceDB, migrations, the profile callbacks, the stored skin, its Scope and its font
  and texture overrides applied (`NS.ApplySkinChoice` with no argument), the chat commands.
- OnEnable: the settings category, the launcher, the `/st` collision check, the latch from the
  stored `enabled`, then the first-run skin picker when `skin.pickerSeen` is false, the addon is
  enabled and the player is out of combat (`NS.MaybeShowSkinPicker`). A profile switch, copy or reset
  takes down a picker that is up or queued first (`NS.StandDownSkinPicker`, nothing written), applies
  the incoming skin, then asks again.
