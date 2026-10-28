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
| PICKER-1..12 | First-run skin picker | When and where it shows, its title, preview, Apply, close, the gear, Apply to all, one window across addons, taking it down |
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
  sections scrolling under the mouse wheel. Result:
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
  each. → Chrome, Controls, Lists, Text, Panels, Overlays, Values and Textures are all legible in every skin.
  Record an illegible sample as a skin defect (skin, section, caption), not as a showroom failure.
  Result:
- **SHOW-9. Live samples.** Hover "Hover me", click the dropdown, click the second and third tabs. →
  A skinned tooltip, the skinned popup menu, and the tab selection moving. Result:
- **SHOW-10. Values.** Look at the Values section in Ka0s Default, then Azeroth. → The swatches and the
  `sem.*` lines change color with the skin, and the body-font line changes face where the skin sets
  one. Result:
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
  picker does not open. `/st enable`, then switch the tester's profile away and back. → Its picker
  opens: waiting and being taken down did not mark the profile seen. Load order decides which
  picker comes first: if the tester's is up first, close it, then create a fresh tester profile
  while Loot History's is up, and continue from there. Result:

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
