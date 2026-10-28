# Smoke tests — Ka0s Skin Tester

The in-client checks the headless suite cannot make. Run them from a clean `/reload` with debug
logging off unless a check says to turn it on, and record each result on its `Result:` line (pass or
fail, the date, and a note when it fails). IDs are stable: a new check takes the next free number in
its theme, and a retired number is never reused.

## Index

| ID range | Theme | What it covers |
|---|---|---|
| INSTALL-1..3 | Install | Load, reload, first run |
| SLASH-1..4 | Slash commands | `/st`, `/skintester`, help, the disabled refusal, a foreign `/st` |
| PANEL-1..10 | Settings panel | Landing page, General's tabs, Skin, Keybindings, Sample controls, the Scope, Font and texture |
| PROFILE-1..2 | Profiles | The Profiles page and the `profile` verb |
| STATE-1..2 | Enable and disable | The stand-down and its refusal |
| COMBAT-1..2 | Combat | The showroom and the panel in combat |
| DIAG-1..2 | Diagnostics | The debug console and the report |
| DEGRADED-1 | Degraded install | The library-absent load |
| SHOW-1..13 | Showroom | The window, the swatch selector, the sections, position and scale, the textures, Ka0s Default's face and bar |
| PICKER-1..16 | First-run skin picker | When and where it shows, its title, preview, Apply, close, the gear, Apply to all, one window across addons, taking it down, combat, a preview meeting another write, the reload popup |
| LOC-1 | Non-English client | Locale-dependent behavior |

## Before you start

Symlink the repo into `World of Warcraft\_retail_\Interface\AddOns\LibKa0sSkinTester` and fully
restart the client: new font and texture files are only seen at client start.

## Install

- **INSTALL-1. Loads.** Log in. → No Lua error; Ka0s Skin Tester is listed in Settings -> AddOns and
  the minimap button shows the fanned-swatch logo. Result:
- **INSTALL-2. Reloads.** `/reload`. → No Lua error; the same skin as before the reload. Result:
- **INSTALL-3. First run.** On a character that never ran it, `/st show`. → The showroom opens
  centered, in Ka0s Default. Result:

## Slash commands

- **SLASH-1. Help.** `/st help`. → The command list, `show` and `perf` included; the header names
  `/skintester` as the alias. Result:
- **SLASH-2. Alias.** `/skintester show`. → Opens the showroom. Result:
- **SLASH-3. Disabled refusal.** `/st disable`, then `/st show`. → One tagged line naming
  `/st enable`; nothing opens. `/st enable` afterwards. Result:
- **SLASH-4. A foreign /st.** With another addon that registers `/st` enabled (any one will do), log
  in. → One tagged line saying this addon answers only to `/skintester`; `/st` reaches the other
  addon, and `/skintester show` opens the showroom. With no such addon, no line at all. Result:

## Settings panel

- **PANEL-1. Landing page.** Open Settings -> AddOns -> Ka0s Skin Tester. → The logo, the notes line
  and the slash command list. Result:
- **PANEL-2. General's tabs.** Open General. → Tabs in this order: Master controls, Skin,
  Keybindings. Master controls shows Enable Skin Tester, Master scale, Master opacity, Debug console, Minimap
  button, Reset position, Reset all settings. Result:
- **PANEL-3. Skin.** On the Skin tab, pick each skin in turn with the showroom open. → The skins
  sit under a "Look" heading (not a second "Skin"); the showroom repaints at once each time; the pick
  survives a `/reload`. Result:
- **PANEL-4. Keybindings.** Bind a key on General -> Keybindings, then press it. → The showroom
  toggles; the same key shows under Options -> Keybindings -> Ka0s Skin Tester. Result:
- **PANEL-5. Sample controls.** On General -> Skin untick Ignore settings panel (a new
  profile has it ticked, and the page is then the client's), pick Obsidian, then open Settings ->
  AddOns -> Ka0s Skin Tester -> Sample controls. → One group heading over a checkbox, a slider, a dropdown, a color swatch and Use
  class color, all in Obsidian; no Skin tab and no copy button. Pick Glass on General and come
  back. → The page follows. Result:
- **PANEL-6. The Scope.** On a fresh profile open General -> Skin with the showroom open. →
  Ignore settings panel is ticked and Ignore fonts is not; the settings pages are in the client's
  look while the showroom wears the skin. Untick Ignore settings panel. → The settings pages take the
  skin at once, no reload. Pick Azeroth and tick Ignore fonts. → The showroom's Vollkorn text and titles go
  back to the game's fonts at once and keep the skin's colors. `/reload`. → Both ticks are as you left them. Result:
- **PANEL-7. Font and texture rows.** Open General -> Skin. → A "Font and texture" section between
  the skins and the Scope, with a Font and a Texture dropdown. Each list starts with "Skin's own
  (<key>)" naming the current skin's own font or texture, then every font or statusbar texture
  LibSharedMedia knows, sorted. Pick another skin. → Both "Skin's own" entries name the new skin's
  keys. Result:
- **PANEL-8. The override applies live.** With the showroom open, pick a font in Font, then a
  texture in Texture (any media pack's). → The showroom's text takes the font at once, its monospace
  text keeps its own face, and every bar in the Textures section takes the texture at once, its
  labels naming the key. Pick "Skin's own" in both. → Both go back. `/reload` after a pick. → The
  pick is still applied. Result:
- **PANEL-9. Ignore fonts wins.** With a font chosen in Font, tick Ignore fonts. → Every string goes
  back to the game's font; the Font dropdown keeps your pick. Untick it. → Your font is back. Result:
- **PANEL-10. The copy carries them.** With Ka0s Loot History installed, choose a font and a texture
  here, press "Copy to every Ka0s addon..." and confirm. → Loot History's Skin tab shows the same
  skin, font, texture and Scope, and its window wears them. Result:

## Profiles

- **PROFILE-1. Switch carries the skin.** Create a profile, give it another skin, switch back and
  forth on the Profiles page. → The showroom follows each profile's skin. Result:
- **PROFILE-2. The verb.** `/st profile`, then `/st profile <name>`. → Lists, then switches.
  Result:

## Enable and disable

- **STATE-1. Disable closes the showroom.** With the showroom open, untick Enable. → It closes; the
  launcher's menu grays Show window. Result:
- **STATE-2. Key binding refuses.** While disabled, press the bound key. → The disabled line; nothing
  opens. Result:

## Combat

- **COMBAT-1. Showroom in combat.** Enter combat, open the showroom and switch skins on the Skin tab
  (the panel is locked in combat; use `/st set skin.skin obsidian`). → It opens and repaints; no
  `ADDON_ACTION_BLOCKED`. Result:
- **COMBAT-2. Panel refuses.** In combat, `/st config`. → The gray refusal notice; no panel. Result:

## Diagnostics

- **DIAG-1. Console.** `/st debug`, `/st debug on`, open and close the showroom. → `[Showroom]` lines
  for built, shown and hidden. Result:
- **DIAG-2. Report.** `/st diagnostics`. → The report in the console, with the `skin` section naming
  the stored and applied skin. Result:

## Degraded install

- **DEGRADED-1. Library absent.** Rename `libs/LibKa0s` and `/reload`. → No Lua error; one line says
  the library is missing; `/st show` opens nothing useful but raises nothing. Restore the folder.
  Result:

## Showroom

- **SHOW-1. Window.** `/st show`. → A window titled "Ka0s Skin Tester — Skin showroom", closed by its
  close button and by Escape, with a footer reading "Wearing Ka0s Default" (the skin you wear) and the
  sections scrolling under the mouse wheel and by the scrollbar at the right edge (ST-03). Result:
- **SHOW-2. Position.** Drag it by the title bar, `/reload`, reopen. → Same place. Master controls ->
  Reset position centers it. Result:
- **SHOW-3. Scale and opacity.** Move Master scale and Master opacity. → The window follows. Result:
- **SHOW-4. Two addons, one copy.** With Ka0s Loot History also installed and on the same skin, open
  both. → Both wear the skin the same way. Result:
- **SHOW-5. Swatch selector.** `/st show`. → Nine cards across the top, Ka0s Default first, each with
  its name and four color swatches; the card of the skin you are wearing has its name in the skin's
  accent. No EllesmereUI card. Result:
- **SHOW-6. Pick a skin.** Click Obsidian, then `/reload` and reopen. → The window repaints in Obsidian
  at the click, Obsidian's card reads selected, and after the reload it is still Obsidian. Fail: a
  card that repaints nothing, or a reload that comes back in Default. Result:
- **SHOW-7. A pick made elsewhere.** With the showroom open, pick Glass on General -> Skin. →
  The window repaints and the Glass card becomes the selected one. Result:
- **SHOW-8. Every section, every skin.** Click through all nine cards and scroll the whole window on
  each. → Chrome, Controls, Lists, Text, Panels, Overlays, Addon surfaces, Values and Textures are all legible in every skin.
  Record an illegible sample as a skin defect (skin, section, caption), not as a showroom failure.
  Result:
- **SHOW-9. Live samples.** Hover "Hover me", click the dropdown, click the second and third tabs. →
  A skinned tooltip, the skinned popup menu, and the tab selection moving. Result:
- **SHOW-10. Values.** Look at the Values section in Ka0s Default, then Azeroth. → The swatches and the
  `sem.*` lines change color with the skin, and the body-font line changes face where the skin sets
  one. Result:
- **SHOW-16. Quality tiers (ST-01).** Scroll to the Values section in Ka0s Default. → Below the
  getters, two headings in the heading color, "Semantic colors (sem.*)" over the `sem.*` lines and
  "Quality tiers (q.*)" over six lines in order: `q.poor` gray, `q.common` white, `q.uncommon` green,
  `q.rare` blue, `q.epic` purple, `q.legendary` orange, each label and swatch in that tier's color,
  the client's item colors. Click Obsidian, then Ember. → The tiers keep the client's colors (no
  shipped skin moves them), and every label is still drawn. Fail: a missing tier, tiers out of order,
  a label whose color differs from its swatch, or a heading in body text. Result:
- **SHOW-11. Card names on one line (R5-05).** `/st show`, then click High Contrast. → Every card's
  name stays on one line above its swatches; a long name such as "High Contrast" is drawn a little
  smaller rather than wrapped or cut. Click Ka0s Default. → The names are back at full size. Fail: a
  name on two lines, a name cut off with "...", or text over the swatches. Result:
- **SHOW-12. Textures.** Scroll to the Textures section in Ka0s Default, then Obsidian. → Three
  status bars (the accent at 72%, a green at 45%, a red at 88%), a five-row bar chart and a
  five-segment stacked bar in the skin's chart colors, every fill drawn in the skin's bar texture
  over a dark track, and each sample labeled "Texture: <key>". On the switch the colors, the
  texture and the labels change at once. Fail: a flat fill where the skin names a texture, or a label
  naming a key the bars do not show. Result:
- **SHOW-13. Ka0s Default's face and bar.** Fully restart the client (new font and texture files),
  then `/st show` in Ka0s Default. → Every title is in Oxanium Bold and the body text in Oxanium
  SemiBold, a squared techno face, not Friz Quadrata; the Textures section's labels read "Texture:
  Ka0s Default" and every fill shows that bar, dim at the top with a highlight low on the bar and a
  short lip, not the flat Blizzard bar. Click Obsidian, then WoW Default. → Their own faces and bars;
  WoW Default is still Friz Quadrata with the Blizzard bar. Fail: a square where a glyph should be,
  or a flat or missing fill. Result:
- **SHOW-14. Every skin's own bar (ST-02; LibKa0s SO-04).** Fully restart the client (new texture
  files), clear any Texture override on General → Skin, then `/st show` and scroll to Textures. Click
  each card in turn → every label reads "Texture: <key>" for that skin and every fill shows it: Ka0s
  Default: Ka0s Default; Obsidian: Ka0s Matte; Azeroth: Ka0s Parchment; Glass: Ka0s Glass Bar; High
  Contrast: Ka0s Solid; Ember: Ka0s Forge; WoW Midnight: Ka0s Satin; WoW Forever: Ka0s Classic; WoW
  Default: Blizzard. The seven new textures are visibly distinct (Parchment mottled, Solid flat, Glass
  Bar glossy, Classic like the client's bar). Fail: a label and a fill that disagree, a fill left on
  the previous skin's texture, a white or missing fill, or a visible seam where a texture tiles.
  Result:
- **SHOW-15. The showroom's scrollbar (ST-03).** `/st show` in Ka0s Default. → A thin scrollbar,
  a corridor and one knob, runs down the right edge beside the sections, never over them. Roll the
  wheel over the sections, then over the bar → both scroll, and the knob follows. Drag the knob to
  the bottom → the Textures section is in view; click the corridor above the knob → the sections
  move back up. Click Obsidian, then High Contrast → the corridor and knob take each skin's colors.
  The sections always overflow the fixed window, so the bar is always there; the headless suite
  covers the bar hiding when they fit. Fail: no bar, a knob that does not move with the wheel, a
  drag that leaves the sections still, a bar over the section content, or a bar in another skin's
  colors. Result:

- **SHOW-17. Addon surfaces (ST-01; LibKa0s v1.80.0).** Scroll to the Addon surfaces section in Ka0s
  Default. → "A note in this addon's own gray" in a mid gray (0.53, darker than the captions); a
  "Delete run" button on a dark red fill with a red edge and a white label; a "Waiting for the pull"
  callout on a faint orange wash with an orange edge and an orange title; a question-mark icon with a
  2px black border; a TreeGroup with General (expanded to Skin), Strings and About, in the client's
  stock look; and a small window titled "Settings-style window" with the client's settings-window
  frame and a stock close button, exactly as Blizzard draws them. Click High Contrast. → The
  note turns a light gray (0.85, the token's own High Contrast value), the button keeps its red edge
  on the skin's button fill with a red label, the callout takes the skin's card fill with an orange
  edge and title, the icon border follows the skin, and the small window is now skinned (its frame
  art faded, the skin's window colors and title). Click Obsidian → the icon border is 1px. Click Ka0s
  Default → the small window is the client's frame again. Clicking its close button does nothing.
  Fail: a sample in another skin's colors, a small window skinned under Ka0s Default or left stock
  under another skin, or an error. Result:
- **SHOW-18. The TreeGroup follows the Scope (ST-01).** With the showroom open on Addon surfaces,
  open General -> Skin and clear Scope -> Ignore settings panel. → The TreeGroup sample repaints at
  once: both panes in the skin's navigation fill and edge, the row labels in the skin's navigation
  text and body font, the selected row (General) tinted. Click a row → the selection moves and stays
  tinted. Click Glass → it follows. Set Ignore settings panel again → the TreeGroup is stock again.
  Fail: a TreeGroup that needs a reload to change, a row that loses its paint after a click, or a
  stock TreeGroup while the panel is skinned. Result:

## First-run skin picker

- **PICKER-1. A fresh profile.** Create a new profile on the Profiles page (or log in on a character
  that never ran the tester), with no other Ka0s addon loaded. → A small window titled "Choose a skin
  for Ka0s Skin Tester" opens in the skin worn, its center about three quarters of the way up the
  screen: a dropdown showing that skin, with the eye and the gear beside it, an Apply button and a
  close control. No "Apply to all Ka0s addons" button. Fail: a window centered on the screen, or a
  title that does not name the tester. Result:
- **PICKER-2. Its list, and a pick previews.** Click the dropdown. → The list opens inside the
  window, which grows to hold it: every skin, each row three color swatches and the skin's name in
  that skin's own font and size. Pick Ember. → The window and the showroom repaint in Ember, the
  list closes, the dropdown reads Ember and the window stays up. Open General -> Skin. → It still
  shows the skin you had: a pick is only a preview. `/reload`. → The skin you had, and the picker
  opens again. Result:
- **PICKER-3. The eye.** Pick Ember, then click the eye. → The showroom opens in Ember, below the
  picker, which it does not cover; the picker stays up with Ember still pending. Result:
- **PICKER-4. The gear lands on General -> Skin.** Pick Glass, then click the gear. → The settings
  panel opens on General (not the Ka0s Skin Tester landing page) with the Skin tab selected, Glass
  ticked there and worn. The picker closes; `/reload` keeps Glass and does not open it again. In
  combat, the gear does nothing and the picker stays. Result:
- **PICKER-5. Close puts the old skin back.** On a fresh profile, pick Ember, then close the picker
  with its close control. → The tester goes back to the skin it wore when the window opened, and
  General -> Skin still shows that skin. On another fresh profile, do the same with Escape. → The
  same. `/reload` on either. → It does not open again on that profile. Result:
- **PICKER-6. After a reset, and a disabled profile.** Reset the profile (Reset all settings, or
  the Profiles page). → The picker opens again. A reset restores `enabled` to on, so it opens even
  if the addon was disabled before. Now close the picker on profile A, create profile B (the picker
  opens), run `/st disable` instead of closing it, switch to A, then back to B.
  → It does not open on B while B is disabled; `/st enable` on B and switch to A and back. → It opens
  on B, because B never closed it. Result:
- **PICKER-7. Taken down, not closed.** On a fresh profile with the picker up, run `/st disable`.
  → The picker goes away with the showroom. `/st enable`, then switch to a profile that has closed it, and back.
  → It opens again: the addon taking it down did not mark the profile seen. With it up on a profile
  that has not closed it, switch to one that has. → It goes away, and switching back opens it
  again. Result:
- **PICKER-8. Apply saves.** On a fresh profile, pick Obsidian, then press Apply. → The picker
  closes and the tester keeps Obsidian; General -> Skin shows it. `/reload`. → Still Obsidian, and
  the picker does not open. Result:
- **PICKER-9. Apply to all Ka0s addons.** With Ka0s Loot History installed (on this library
  branch) and both on profiles that have seen their pickers, create a fresh profile here only. → The
  picker shows "Apply to all Ka0s addons" beside Apply. Pick Azeroth and press it. → The picker
  closes, both addons wear Azeroth, and Loot History's Skin tab shows Azeroth with its Scope and its
  font and texture as they were. If either needs a reload, one popup names it. Result:
- **PICKER-10. One window at a time.** With Ka0s Loot History installed, give both addons fresh
  profiles and `/reload`. → One skin picker shows, never two, its title naming one addon. Close it
  (or press Apply). → The other addon's picker opens, its title naming that addon. Close it. → No
  third window. `/reload`. → Neither opens again. Result:
- **PICKER-11. Apply to all ends the queue.** As PICKER-10, but on the first picker pick Glass and
  press "Apply to all Ka0s addons". → No second picker opens, and both addons wear Glass.
  `/reload`. → Neither picker opens again. Result:
- **PICKER-12. Taken down while waiting.** As PICKER-10, with Loot History's picker up first and the
  tester's waiting behind it, run `/st disable`, then close Loot History's picker. → The tester's
  picker does not open. `/st enable`. → The picker still does not open: enabling is not a trigger.
  Switch the tester to a profile that has closed its picker (for example the one PICKER-8 applied
  on), then back to this one. → Its picker opens: waiting and being taken down did not mark the
  profile seen. Load order decides which picker comes first: if the tester's is up first, close it,
  then create a fresh tester profile while Loot History's is up, and continue from there. Result:
- **PICKER-13. Apply and close in combat.** On a fresh profile, pick Ember, then enter combat (a
  training dummy). Press Apply. → Nothing happens: the window stays up with Ember pending. With
  Ka0s Loot History installed, "Apply to all Ka0s addons" does the same. Press the close control.
  → The window closes and the tester goes back to the skin it wore when the window opened; General
  -> Skin still shows that skin. Repeat on another fresh profile with Escape instead. → The same.
  Result:
- **PICKER-14. A pending preview meets another write.** On a fresh profile, pick Ember (keep it
  pending). Then, in turn on fresh profiles: (a) `/st show` and click the Obsidian card; (b) on
  General -> Skin pick Obsidian; (c) run `/st set skin.skin obsidian`. Close the picker each time.
  → The tester wears Obsidian, the skin stored. Then pick Ember on a fresh profile and switch to a
  profile that has closed its picker and stores another skin (Glass, say). → The picker goes and
  the tester wears Glass. Switch instead to a fresh profile. → A new showing: the dropdown names
  that profile's skin, not Ember, and the close control or Apply leaves that skin on and stored.
  Fail: the tester wearing a skin other than the one General -> Skin shows, or (a), (b) or (c)
  putting back the skin the window opened with (the close undoes only the unsaved preview, so a
  skin stored while the window was up stays). Result:
- **PICKER-15. Apply's reload popup.** Only where a pick needs a reload (EllesmereUI installed and
  the tester on the EllesmereUI source, painted by it this session). Pick a skin that needs a
  reload, then another, then press Apply. → One reload popup naming the tester, once, not one per
  pick. A pick alone raises none. Result:
- **PICKER-16. A queued picker in combat.** As PICKER-10, with the tester's picker waiting behind
  Loot History's. Enter combat and close Loot History's picker with its close control. → Loot
  History's picker closes, and the tester's does not open while combat lasts. Leave combat. → The
  tester's picker opens, its title naming the tester. Repeat, and run `/st disable` while in
  combat after the close. → Nothing opens when combat ends. Fail: any picker opening mid-combat.
  Result:

## Non-English client

- **LOC-1. A deDE or frFR client.** The addon reads no localized global, parses no tooltip line and
  keys nothing off a display string: every label is its own English text, and the skins' fonts are
  shipped faces. On a German or French client, open the showroom and the settings panel. → English
  labels everywhere, the skins' fonts drawn (no fallback squares), and no `%s` or `%d` left in any
  line. Fail: a label in German or French (this addon ships no translation, so one would mean a
  client string leaked in), a square where a glyph should be, or a stray `%s` or `%d`. The headless suite stands in for the strings (`test_prose`, the locale suite); on English,
  INSTALL-1 and PANEL-3 cover the rest, so this can be signed off without a language pack. Result:

## Pending sign-off

| ID | Origin | Why it is owed |
|---|---|---|
| INSTALL-1..3, SLASH-1..3, PANEL-1..4, PROFILE-1..2, STATE-1..2, COMBAT-1..2, DIAG-1..2, DEGRADED-1, SHOW-1..4, LOC-1 | v0.1.0 scaffold | No client pass recorded yet |
| SHOW-5..7 | ST-03, the swatch selector | No client pass recorded yet |
| SHOW-8..10 | ST-05 + ST-06, the sections | No client pass recorded yet |
| SLASH-4, PANEL-5 | ST-07, the collision and the sample page | No client pass recorded yet |
| PANEL-6 | SF-40, SF-43, SF-46: the Scope and its defaults | No client pass recorded yet |
| SHOW-11 | R5-05, the card names | No client pass recorded yet |
| PANEL-7..10, SHOW-12, PICKER-6..7 | ST-01, the font and texture overrides and the skin picker (LibKa0s#63, #64) | No client pass recorded yet |
| PANEL-3, SHOW-13, PICKER-1..5, PICKER-8..12 | ST-01 after PK-02 and SO-06: the "Look" heading, Ka0s Default's Oxanium and bar, the picker's position, title, preview, Apply, Apply to all and one window across addons | Rewritten for PK-02; no client pass recorded yet |
| PICKER-13..16 | ST-01, the review of PK-02: Apply and close in combat, a pending preview meeting another write or a profile event, Apply's reload popup, a queued picker in combat | Rewritten for PK-03 (PICKER-14 (a) to (c), PICKER-16); no client pass recorded yet |
| SHOW-14 | ST-02, LibKa0s v1.79.0's bar textures (SO-04) | No client pass recorded yet |
| SHOW-1 (amended), SHOW-15 | ST-03, the showroom's scrollbar | No client pass recorded yet |
| SHOW-8 (amended), SHOW-16..18 | ST-01 of the skinning rollout (LibKa0s v1.80.0): the Quality tiers category and the Addon surfaces section | No client pass recorded yet |
