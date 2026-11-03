# Smoke tests — Ka0s Skin Tester

The in-client checks the headless suite cannot make. Run them from a clean `/reload` with debug
logging off unless a check says to turn it on, and record each result on its `Result:` line (pass or
fail, the date, and a note when it fails). IDs are stable: a new check takes the next free number in
its theme, and a retired number is never reused.

## Index

| ID range | Theme | What it covers |
|---|---|---|
| INSTALL-1..3 | Install | Load, reload, first run |
| SLASH-1..6 | Slash commands | `/st`, `/skintester`, help, the disabled refusal, a foreign `/st`, `/st skin`, `/st widths` |
| PANEL-1..18 | Settings panel | Landing page, General's tabs, Skin, Keybindings, Sample controls, the Scope, Font and texture, the settings chrome's face and tooltips, the Font outline, the media pickers, a dropdown list closing on an outside press |
| PROFILE-1..3 | Profiles | The Profiles page and the `profile` verb |
| STATE-1..2 | Enable and disable | The stand-down and its refusal |
| COMBAT-1..2 | Combat | The showroom and the panel in combat |
| DIAG-1..5 | Diagnostics | The debug console, its copy window and the report, the library windows' headers |
| DEGRADED-1 | Degraded install | The library-absent load |
| SHOW-1..50 | Showroom | The window, the swatch selector, the sections, position and scale, the textures, Ka0s Default's face and bar, the addon surfaces, the library widgets, the tooltip colors and art tints, the HUD faces, the faces and widths, FontFlags and HudFontSize, the icon samples, a stored pick of the deleted Friz, Ka0s Default's header, the icon outline colors, the window edge beside the HUD's, round 5's darker header, the header on its band, every window like Loot History's |
| PICKER-1..26 | First-run skin picker | When and where it shows, its title, preview, Apply, close, the gear, Apply to all, one window across addons, taking it down, combat, a preview meeting another write, the reload popup, the list closing on an outside press, the title on its band |
| LOC-1 | Non-English client | Locale-dependent behavior |

## Before you start

Symlink the repo into `World of Warcraft\_retail_\Interface\AddOns\LibKa0sSkinTester` and fully
restart the client: new font and texture files are only seen at client start.

## Install

- **INSTALL-1. Loads.** Log in. → No Lua error; Ka0s Skin Tester is listed in Settings -> AddOns and
  the minimap button shows the fanned-swatch logo. Result: pass (owner-marked 2026-10-30)
- **INSTALL-2. Reloads.** `/reload`. → No Lua error; the same skin as before the reload. Result: pass (owner-marked 2026-10-30)
- **INSTALL-3. First run.** On a character that never ran it, `/st show`. → The showroom opens
  centered, in Ka0s Default. Result: pass (owner-marked 2026-10-30)

## Slash commands

- **SLASH-1. Help.** `/st help`. → The command list, `show` and `perf` included; the header names
  `/skintester` as the alias. Result: pass (owner-marked 2026-10-30)
- **SLASH-2. Alias.** `/skintester show`. → Opens the showroom. Result: pass (owner-marked 2026-10-30)
- **SLASH-3. Disabled refusal.** `/st disable`, then `/st show`. → One tagged line naming
  `/st enable`; nothing opens. `/st enable` afterwards. Result: pass (owner-marked 2026-10-30)
- **SLASH-4. A foreign /st.** With another addon that registers `/st` enabled (any one will do), log
  in. → One tagged line saying this addon answers only to `/skintester`; `/st` reaches the other
  addon, and `/skintester show` opens the showroom. With no such addon, no line at all. Result: pass (owner-marked 2026-10-30)
- **SLASH-5. `/st skin` (ST-01; LibKa0s v1.82.0, D-16).** On a profile that has closed the skin
  picker, `/st help`. → A `skin` row right after `config`, "Choose a skin: open the skin picker".
  `/st skin`. → The skin picker a new profile shows opens ("Choose a skin", "Ka0s Skin Tester" above
  the list); a pick previews, Apply saves, the close control puts the skin back. Enter combat and
  `/st skin` twice. → No picker; a gray "cannot open the skin picker during combat" line each time.
  Out of combat, `/st disable`, then `/st skin`. → One tagged line naming `/st enable`; no picker.
  `/st enable` afterwards. Fail: "unknown command", a picker in combat or while disabled, or one gray
  line for two presses. Result: Owner reported pass, 2026-10-31
- **SLASH-6. `/st widths` (ST-01; LibKa0s v1.82.0, D-08).** Fully restart the client, clear any Font
  override on General -> Skin, then `/st widths`. → A header, "Widths of a fixed corpus against Ka0s
  Default (1.000x is parity):", and nine lines, one per skin, each "<skin>: body <face> <size>
  <ratio>x, title ..., hud ...". Ka0s Default reads 1.000x on all three. Note every other ratio here
  (D-08's in-client check: the owner judges how near 1.000x is near enough); a ratio far from 1, say
  below 0.95 or above 1.05, is a finding for LibKa0s's sizes, not for this addon. Fail: "unmeasured"
  for a shipped face, or a line missing. Result: Owner reported pass, 2026-10-31

## Settings panel

- **PANEL-1. Landing page.** Open Settings -> AddOns -> Ka0s Skin Tester. → The logo, the notes line
  and the slash command list. Result: pass (owner-marked 2026-10-30)
- **PANEL-2. General's tabs.** Open General. → Tabs in this order: Master controls, Skin,
  Keybindings. Master controls shows Enable Skin Tester, Master scale, Master opacity, Debug console, Minimap
  button, Reset position, Reset all settings. Result: pass (owner-marked 2026-10-30)
- **PANEL-3. Skin.** On the Skin tab, pick each skin in turn with the showroom open. → The skins
  sit under a "Look" heading (not a second "Skin"); the showroom repaints at once each time; the pick
  survives a `/reload`. Result: pass (owner-marked 2026-10-30)
- **PANEL-4. Keybindings.** Bind a key on General -> Keybindings, then press it. → The showroom
  toggles; the same key shows under Options -> Keybindings -> Ka0s Skin Tester. Result: pass (owner-marked 2026-10-30)
- **PANEL-5. Sample controls.** On General -> Skin check Ignore settings panel is unticked (a new
  profile has it unticked in this addon, R4-ST1, so the page wears the skin), pick Obsidian, then open Settings ->
  AddOns -> Ka0s Skin Tester -> Sample controls. → One group heading over a checkbox, a slider, a dropdown, a color swatch and Use
  class color, Use the skin's color, then the five media pickers (PANEL-13) with three skin companions, all in Obsidian; no Skin tab and no copy button. Pick Glass on General and come
  back. → The page follows. (Amended by FS-ST-FIX, 2026-11-01: the four companions; the pass of
  2026-10-31 was against the old rows.) Result: Failed (owner, 2026-11-02): re-opened as R3-L1
- **PANEL-6. The Scope.** On a fresh profile open General -> Skin with the showroom open. →
  Neither Ignore settings panel nor Ignore fonts is ticked (this addon defaults the panel half off,
  a documented deviation, R4-ST1); the settings pages and the showroom wear the skin. Tick Ignore
  settings panel. → The settings pages go to the client's look at once, no reload; untick it → they
  take the skin again. Pick Azeroth and tick Ignore fonts. → The showroom's Open Sans text and titles go
  back to the game's fonts at once and keep the skin's colors. `/reload`. → Both ticks are as you left them. (Amended by R4-ST1, 2026-11-03: the new default; the pass of 2026-11-02 was against the old one.) Result:
- **PANEL-7. Font and texture rows.** Open General -> Skin. → A "Font and texture" section between
  the skins and the Scope, with a Font and a Texture dropdown. Each list starts with "Skin's default
  (<key>)" naming the current skin's own font or texture, then every font or statusbar texture
  LibSharedMedia knows, sorted, each shown in its face or with its bar, the leading row too. Pick another skin. → Both "Skin's default" entries name the new skin's
  keys. Result: Owner reported pass, 2026-10-31
- **PANEL-8. The override applies live.** With the showroom open, pick a font in Font, then a
  texture in Texture (any media pack's). → The showroom's text takes the font at once, its monospace
  text keeps its own face, and every bar in the Textures section takes the texture at once, its
  labels naming the key. Pick "Skin's default (<key>)" in both. → Both go back. `/reload` after a pick. → The
  pick is still applied. Result: pass (owner-marked 2026-10-30)
- **PANEL-9. Ignore fonts wins.** With a font chosen in Font, tick Ignore fonts. → Every string goes
  back to the game's font; the Font dropdown keeps your pick. Untick it. → Your font is back. Result: pass (owner-marked 2026-10-30)
- **PANEL-10. The copy carries them.** With Ka0s Loot History installed, choose a font and a texture
  here, press "Copy to every Ka0s addon..." and confirm. → Loot History's Skin tab shows the same
  skin, font, texture and Scope, and its window wears them. Result: pass (owner-marked 2026-10-30)
- **PANEL-11. The settings rows' tooltips (ST-01; LibKa0s v1.81.0, LK-06d).** On General -> Skin,
  with Ignore settings panel unticked (the tester's default since R4-ST1), pick Glass. Hover a row's label on any of the tester's pages → its
  tooltip title is white, Glass's `gtip.value`. Tick Ignore settings panel and hover it again → the
  client's own tooltip title color. The tester's pages draw no nav rail and no drawer, so LK-06c's
  hover art and chevron are checked on the showroom's Library widgets samples (SHOW-22), which wear
  the skin whatever Ignore settings panel says. Fail: a title in another skin's color while the panel
  is skinned, or a skinned title while Ignore settings panel is ticked. Result: pass (owner-marked 2026-10-30)
- **PANEL-12. The Font outline (ST-01; LibKa0s v1.82.0, D-06).** Open General -> Skin. → A "Font
  outline" dropdown in the Font and texture section, on HUD text only (the default since v1.83.0). Open the showroom beside it on
  Faces and widths. → The mode line reads "Font outline: HUD text only. Window
  text draws "", HUD text "OUTLINE"", and window strings in the showroom (titles, labels, the
  face lines) have no dark outline; the HUD faces keep theirs. Pick All text. → Every window string
  takes the outline, live. Pick Off. → The HUD faces lose
  theirs too. `/reload`. → Off is still chosen and still applied. Tick Ignore fonts → the dropdown is
  grayed and the mode line ends "(Ignore fonts wins)". Pick HUD text only and untick Ignore fonts
  afterwards. Fail: an outline under Off, a mode that does not survive the reload, or a change that
  needs a reload. Result: Owner reported pass, 2026-10-31
- **PANEL-13. The media pickers (ST-F01; LibKa0s v1.83.0, LK-F03, D-08, D-09).** Fully restart the
  client (new font files), check Ignore settings panel is unticked on General -> Skin (the tester's default since R4-ST1), pick Obsidian and open
  Sample controls. Untick Use the skin's font, texture and border (PANEL-15). → Five pickers under the
  color swatch: A font picker on Ka0s Prototype, drawn in Prototype; A bar texture picker on Ka0s
  Default, beside its bar; A border picker and A background picker on Blizzard Tooltip, each beside
  its swatch; A sound picker on None. Open each. → The
  pull-out wears Obsidian, and every row shows what it offers: fonts each in their own face (the
  thirteen new Ka0s faces among them), bars, borders and backgrounds each with their art. Sounds
  need a media pack: with one loaded, a row's play button plays it, and without one the list holds
  None alone. Pick an entry in each. → The closed row shows it, it survives a `/reload`, and nothing
  else changes. Tick Ignore fonts. → The font rows keep their own faces. Fail: a list of plain
  names, a blank row, a stock (unskinned) pull-out with the panel skinned, or a list reading only
  the no-media entry. (Amended by FS-ST-FIX, 2026-11-01: the companions, and the bar default moved
  from Blizzard to Ka0s Default; the pass of 2026-10-31 was against the old rows.) Result: Passed (owner, 2026-11-02)
- **PANEL-14. A font row and a border row are the pickers (M3-MEDIA; LibKa0s v1.84.0, the owner's
  ruling of 2026-11-01).** With Ignore settings panel unticked on General -> Skin (the tester's default since R4-ST1), pick Obsidian and open
  Sample controls. → A font picker reads a font name in that face, and A border picker reads a border
  name beside its swatch, both lined up with the rows around them, with no extra tile to the
  left. Open each. → Both pull-outs wear Obsidian, with a preview on every row. Pick Glass on General
  and open them again. → Both follow. Fail: a stock pull-out on either row, a blank closed row, or a
  border row sitting further right than the rows around it. Result: Failed (owner, 2026-11-02): re-opened as R3-L1
- **PANEL-15. The sample rows follow the skin (FS-ST-FIX, cause A5).** With Ignore settings panel
  unticked (the tester's default since R4-ST1), pick Obsidian and open Sample controls on a new profile. → Use the skin's color, font, texture and
  border are ticked, and A font picker, A bar texture picker and A border picker are grayed, showing
  Obsidian's HUD font, bar texture and border style. A color swatch stays live. Pick Glass on General
  and come back. → The grayed font and bar rows show Glass's. Untick Use the skin's texture. → A bar
  texture picker comes alive on Ka0s Default. A background picker and A sound picker carry no
  companion, because no skin token names one. Fail: a grayed row showing a value that is not the
  skin's, or a live row with its companion ticked. Result: Passed (owner, 2026-11-02)
- **PANEL-16. The tester skins its own panel by default (R4-ST1, owner ruling of 2026-11-03).** With
  no profile reset, `/reload` and open General -> Skin. → Ignore settings panel is unticked. Open the
  showroom on Controls under Ka0s Default, then Obsidian and Glass. → AceGUI Dropdown, Ka0sMedia_Font
  and Ka0sMedia_Statusbar (images 2 and 3 of round 4) and the Addon surfaces TreeGroup wear the skin.
  Tick Ignore settings panel → those four and the settings pages go to the client's look, live; untick
  it → they take the skin again. Open another Ka0s addon's Skin tab on a new profile → its Ignore
  settings panel is still ticked. Fail: any of the four stock with the box unticked, or another addon
  defaulting the box off. Result:
- **PANEL-17. A dropdown list on a Ka0s surface closes on a press outside it (R4-L1; LibKa0s R4-L1,
  OptionsCombat minor 4; round 4, image 1).** Settings -> AddOns -> Ka0s Skin Tester -> Sample controls.
  Open the AceGUI dropdown's list, then left-click an empty part of the page. → The list closes and
  the click does nothing else. Do the same with A font picker (Ka0sMedia_Font) and A bar texture picker
  (Ka0sMedia_Statusbar). → Each closes. Open one list and click another dropdown on the page. → The
  first closes and the second opens. Open a list and click inside it, scroll it, drag its scrollbar,
  then click the dropdown that owns it. → It stays open until the owning dropdown toggles it shut or a
  row is picked, and a pick applies and closes as before. On Profiles, open Existing Profiles and click
  outside it. → It closes. In the showroom (`/st show`, Controls), open each of the five dropdowns and
  click the showroom's body outside it. → Each closes. Repeat one of them in combat. → The same, with
  no `ADDON_ACTION_BLOCKED`. Escape is not part of this change: on a settings page it still closes the
  panel. Fail: a list that stays open after an outside press, an outside press that also lands as a
  pick, a press inside the list that closes it without a pick, or a Lua error. Result:
- **PANEL-18. Another author's AceGUI dropdown keeps its stock behavior (R4-L1; LibKa0s R4-L1).**
  With a non-Ka0s addon installed whose settings use AceGUI dropdowns (any Ace3 addon's AceConfig
  page), open one of its dropdown lists and click outside it. → It behaves as it did before this
  round (AceGUI's own behavior: the list stays open until it is toggled, a row is picked, or the page
  hides). Then open a Ka0s dropdown (PANEL-17) and click outside it. → The Ka0s one closes. Fail: the
  other author's list now closing on an outside press, or a Lua error naming LibKa0s. Result:

## Profiles

- **PROFILE-1. Switch carries the skin.** Create a profile, give it another skin, switch back and
  forth on the Profiles page. → The showroom follows each profile's skin. Result: pass (owner-marked 2026-10-30)
- **PROFILE-2. The verb.** `/st profile`, then `/st profile <name>`. → Lists, then switches.
  Result: pass (owner-marked 2026-10-30)
- **PROFILE-3. The delete confirmation (FS-ST-FIX, cause A4; LibKa0s v1.85.0).** With two profiles,
  with Ignore settings panel unticked (the tester's default since R4-ST1), pick Obsidian, open Profiles and press Delete a Profile on the spare
  one. → The confirmation wears Obsidian; nothing else on the page moved. Cancel it, tick Ignore
  settings panel and press Delete again. → The stock box. Open another, non-Ka0s addon's Ace dialog
  that raises the same box. → Stock under every setting. Fail: a Ka0s box stock with the panel skinned,
  a skinned box with the panel ignored, or another addon's box skinned. Result: Passed (owner, 2026-11-02)

## Enable and disable

- **STATE-1. Disable closes the showroom.** With the showroom open, untick Enable. → It closes; the
  launcher's menu grays Show window. Result: pass (owner-marked 2026-10-30)
- **STATE-2. Key binding refuses.** While disabled, press the bound key. → The disabled line; nothing
  opens. Result: pass (owner-marked 2026-10-30)

## Combat

- **COMBAT-1. Showroom in combat.** Enter combat, open the showroom and switch skins on the Skin tab
  (the panel is locked in combat; use `/st set skin.skin obsidian`). → It opens and repaints; no
  `ADDON_ACTION_BLOCKED`. Result: pass (owner-marked 2026-10-30)
- **COMBAT-2. Panel refuses.** In combat, `/st config`. → The gray refusal notice; no panel. Result: pass (owner-marked 2026-10-30)

## Diagnostics

- **DIAG-1. Console.** `/st debug`, `/st debug on`, open and close the showroom. → `[Showroom]` lines
  for built, shown and hidden. Result: pass (owner-marked 2026-10-30)
- **DIAG-2. Report.** `/st diagnostics`. → The report in the console, with the `skin` section naming
  the stored and applied skin. Result: pass (owner-marked 2026-10-30)
- **DIAG-3. Charts in the report.** `/st diagnostics`. → The identity header lists Charts between
  Toast and Media, in the same `File minor` form as its neighbors. Result:
- **DIAG-4. No line under the console's title (R4-SEP; LibKa0s R4-SEP; round 4, image 28).** `/st debug`
  in Ka0s Default, then Obsidian and Glass, and press Copy. → The console's title bar runs straight
  into the log, as the showroom's title bar runs into its body (image 27), and the copy window has no
  line under its title either; the rule over the console's footer stays. Fail: a 1 px line under
  either window's title bar in any skin. Result:
- **DIAG-5. The console, copy window and perf panel headers sit on their band (R5-RV; LibKa0s R5-L2, R5-L3).** `/st debug`, press Copy, and run `/st perf` until its step panel shows, in Ka0s Default, then WoW Midnight. → Each window shows exactly one title band, its title and close mark vertically centered on it; under WoW Midnight they sit 1 px lower than in round 4, still centered. Fail: two bands or none, or a title or close mark off the band's middle. Result:

## Degraded install

- **DEGRADED-1. Library absent.** Rename `libs/LibKa0s` and `/reload`. → No Lua error; one line says
  the library is missing; `/st show` opens nothing useful but raises nothing. Restore the folder.
  Result: pass (owner-marked 2026-10-30)

## Showroom

- **SHOW-1. Window.** `/st show`. → A window titled "Ka0s Skin Tester — Skin showroom", closed by its
  close button and by Escape, with a footer reading "Wearing Ka0s Default" (the skin you wear) and the
  sections scrolling under the mouse wheel and by the scrollbar at the right edge (ST-03). Result: pass (owner-marked 2026-10-30)
- **SHOW-2. Position.** Drag it by the title bar, `/reload`, reopen. → Same place. Master controls ->
  Reset position centers it. Result: pass (owner-marked 2026-10-30)
- **SHOW-3. Scale and opacity.** Move Master scale and Master opacity. → The window follows. Result: pass (owner-marked 2026-10-30)
- **SHOW-4. Two addons, one copy.** With Ka0s Loot History also installed and on the same skin, open
  both. → Both wear the skin the same way. Result: pass (owner-marked 2026-10-30)
- **SHOW-5. Swatch selector.** `/st show`. → Nine cards across the top, Ka0s Default first, each with
  its name and four color swatches; the card of the skin you are wearing has its name in the skin's
  accent. No EllesmereUI card; a Source dropdown sits at the right of the cards. Result: Passed (owner, 2026-11-02)
- **SHOW-37. Source dropdown (SF-ST-1).** With EllesmereUI installed, `/st show`, open the Source dropdown at the right of the cards and pick EllesmereUI. → The showroom wears EllesmereUI's look and no card reads selected; picking Ka0s skins asks for a `/reload` if EllesmereUI painted. Without EllesmereUI the pick falls back to the Ka0s skin. Result: Passed (owner, 2026-11-02)
- **SHOW-38. The library does the work (SF-ST-2; LibKa0s #70, #71, #72).** `/st show`, Library widgets, in Obsidian. → The line chart's first series has a soft area under its line; the Blizzard dropdown shows no gold button, a flat box and one chevron at its right, and its label stays the skin's color while you hover and press it; drag the "Drag the corner" grip → the box keeps its top left and scrolls with its cell. Fail: a flat chart line, a gold button or a doubled arrow, a white label on hover, or a box that comes off its cell. Result: Passed (owner, 2026-11-02)
- **SHOW-39. The icon samples zoom and wear a 1 px outline (R3-L3; LibKa0s R3-L3).** With the re-vendored LibKa0s, `/st show` in Ka0s Default, then Azeroth, WoW Default and Obsidian. → The Overlays IconBorder sample and Controls' SquareIcon (crop) + IconBorder (the Addon surfaces duplicate is gone, R4-ST3) each show the question-mark icon zoomed in, its own art edge gone, inside a 1 px outline in the skin's icon outline color (icon.outline since R4-L3, SHOW-46), the same thickness in every skin. Fail: the icon's own gray frame showing inside the outline, a 2 px edge in Ka0s Default, Azeroth or WoW Midnight, or a tooltip-style edge in WoW Default. Result: not run
- **SHOW-40. A stored pick of the deleted Friz lands on Ka0s Ubuntu (R3-FRIZ).** Before you update, set General's A font picker to Ka0s Friz Quadrata TT and log out. Install the re-vendored build and fully restart the client (a new font file), then `/st show` and open the settings panel. → A font picker reads Ka0s Ubuntu, drawn in Ubuntu, and `/dump LibKa0sSkinTesterDB.global.schemaVersion` prints 2. A profile that picked Blizzard's own Friz Quadrata TT keeps it. Fail: the picker empty, on the game's default face, or still naming Ka0s Friz Quadrata TT. Result: not run
- **SHOW-41. The zoom keeps a tighter crop, and the outline stays 1 px after a scale change (R3-FIX; LibKa0s R3-FIX).** `/st show`, Controls, in Obsidian: look at SquareIcon (crop) + IconBorder, then switch skins twice. → Its icon stays cropped as tightly as SquareIcon left it (no more of the art's edge showing after a switch), inside a 1 px outline. Then change Options → Graphics → UI Scale and come back. → Every IconBorder outline and FadeNineSlice edge in the showroom is still exactly 1 px. Fail: the art's own edge creeping back in after a switch, or a 2 px or blurred edge after the scale change. Result: not run
- **SHOW-42. The TreeGroup sample keeps its height and shows a page (R4-ST2; round 4, images 4-7).** `/st show`, Addon surfaces, the "TreeGroup via PaintAce (Scope: panel)" cell, in each of the nine skins with Ignore settings panel unticked (the sample skinned, the default here), then again with it ticked (the client's look). → Both boxes are the full 120 tall, side by side; General, Skin, Strings and About sit inside the left box; the right box reads "The General page". Fail: either box collapsed to a thin strip, a row hanging below the boxes, or an empty right pane. Result:
- **SHOW-43. One IconBorder sample in Overlays, none beside the caution box (R4-ST3; round 4, image 22).** `/st show` in Ka0s Default, then Obsidian. → Overlays shows its "IconBorder, fromSkin" sample beside ApplyBarFill, and Controls shows SquareIcon (crop) + IconBorder; in Addon surfaces the "Waiting for the pull" box is followed by the next row (the TreeGroup), with no icon cell beside it. Fail: an icon border cell beside the Waiting for the pull box, or either remaining sample missing. Result:
- **SHOW-44. The showroom's title band is painted once (R4-ST4).** `/st show` in Glass, then Ka0s Default and Obsidian, and compare the title band with Drop Watcher's or Loot History's window in the same skin. → The band is the same strength in all of them; Glass's reads as a faint white wash (title.bg at 0.10), not a noticeably brighter strip. Fail: the showroom's band clearly brighter or more opaque than another Ka0s window's in the same skin. Result:
- **SHOW-45. Ka0s Default's header is the dark gold band (R4-L2; LibKa0s R4-L2; owner's mockup option E).** With the re-vendored LibKa0s, `/st show` in Ka0s Default. → The showroom's title band is a dark gold gradient, lighter at the top than at the bottom, with no line under it, and the Ka0s Default card's second swatch is the same dark gold, not black. (Option E's shade is retired by R5-L1; SHOW-48 checks round 5's darker one.) Fail: a black or near-black band, a flat band where the other Ka0s windows show the gradient, or a black second swatch. Result:
- **SHOW-46. The icon samples' outline takes the new icon.outline colors (R4-L3; LibKa0s R4-L3).** `/st show`, Overlays' "IconBorder, fromSkin" and Controls' SquareIcon (crop) + IconBorder, in each skin. → The 1 px outline reads gray #4D4D57 in Ka0s Default, a soft white (0.35) in Glass, #5A5048 in WoW Forever, #8A3C1C in Ember and #7A6532 in WoW Midnight; Obsidian, Azeroth, High Contrast and WoW Default look as they did. Fail: a black outline in Ka0s Default, any outline thicker than 1 px, or the icon's own art edge showing inside it. Result:
- **SHOW-47. The icon samples keep the window outline after the HUD edge option (R4-RV3; LibKa0s R4-L4).** With the re-vendored LibKa0s, `/st show` in Ka0s Default, then Glass and Ember, and look at Overlays' "IconBorder, fromSkin" and Controls' SquareIcon (crop) + IconBorder. → Both still wear the 1 px window outline of SHOW-46: gray #4D4D57 in Ka0s Default, not black; the HUD edge (`opts.hud`) is for HUD icons in other addons and this addon draws none. Fail: a black outline in Ka0s Default, or either sample's outline changing color from SHOW-46. Result:
- **SHOW-48. Ka0s Default's header is darker than round 4 (R5-RV; LibKa0s R5-L1; the owner's option C).** With the re-vendored LibKa0s, `/st show` in Ka0s Default, and open Loot History's or Drop Watcher's window beside it. → The showroom's title band is a dark gold gradient visibly darker than round 4's, the same shade as the other Ka0s windows' bands, and the Ka0s Default card's second swatch is that darker gold, not black. The other skins' bands look as they did. Fail: a band no darker than round 4, a black band, a showroom band of another shade than the other Ka0s windows', or another skin's band changing. Result:
- **SHOW-49. The showroom's header sits on its band (R5-RV; LibKa0s R5-L3; feedback item 5).** `/st show` in Ka0s Default, then WoW Midnight (its 2 px edge), Glass and WoW Default, and, with EllesmereUI installed, its source. → In each, the title bar fills the band flush inside the window's edge with no strip of body color above or beside it, and the title and the close mark are vertically centered on the band (within 1 px, the title's capitals against the close mark's middle); the title follows the skin's title alignment. Fail: a title or close mark visibly above or below the band's middle in any skin, or a gap between the edge and the band. Result:
- **SHOW-50. Every showroom window matches Loot History's (R5-WIN; LibKa0s R5-L2, R5-L3; feedback items 2 and 5).** `/st show` in Ka0s Default, then WoW Midnight and Glass, beside Loot History's window. → The showroom's body starts 6 px inside its title bar and footer, as Loot History's content does. On Addon surfaces, the "Shell on SettingsFrameTemplate" sample's title and close mark are vertically centered on its title band, not near its top edge. On Overlays, the "Confirm popup" sample shows one title band flush inside its edge, with "Reset every setting?" centered on it and its two buttons below. Fail: a strip of body color between any edge and its band, a title or close mark off its band's middle, two bands on one window, or the popup's question off its band. Result:
- **SHOW-6. Pick a skin.** Click Obsidian, then `/reload` and reopen. → The window repaints in Obsidian
  at the click, Obsidian's card reads selected, and after the reload it is still Obsidian. Fail: a
  card that repaints nothing, or a reload that comes back in Default. Result: pass (owner-marked 2026-10-30)
- **SHOW-7. A pick made elsewhere.** With the showroom open, pick Glass on General -> Skin. →
  The window repaints and the Glass card becomes the selected one. Result: pass (owner-marked 2026-10-30)
- **SHOW-8. Every section, every skin.** Click through all nine cards and scroll the whole window on
  each. → Chrome, Controls, Lists, Text, Panels, Overlays, Addon surfaces, Library widgets, Values, Textures and HUD faces are all legible in every skin.
  Record an illegible sample as a skin defect (skin, section, caption), not as a showroom failure.
  Result: pass (owner-marked 2026-10-30)
- **SHOW-9. Live samples.** Hover "Hover me", click the dropdown, click the second and third tabs. →
  A tooltip in the skin's tooltip background and border, its title and line in the skin's tooltip
  colors, the skinned popup menu, and the tab selection moving. (Amended by FS-ST-FIX, 2026-11-01: the
  sample is now a frame of this addon's, so the pass of 2026-10-30, on the GameTooltip sample, no
  longer stands.) Result: Passed (owner, 2026-11-02)
- **SHOW-10. Values.** Look at the Values section in Ka0s Default, then Azeroth. → The swatches and the
  `sem.*` lines change color with the skin, and the body-font line changes face where the skin sets
  one. Result: pass (owner-marked 2026-10-30)
- **SHOW-16. Quality tiers (ST-01).** Scroll to the Values section in Ka0s Default. → Below the
  getters, two headings in the heading color, "Semantic colors (sem.*)" over the `sem.*` lines and
  "Quality tiers (q.*)" over six lines in order: `q.poor` gray, `q.common` white, `q.uncommon` green,
  `q.rare` blue, `q.epic` purple, `q.legendary` orange, each label and swatch in that tier's color,
  the client's item colors. Click Obsidian, then Ember. → The tiers keep the client's colors (no
  shipped skin moves them), and every label is still drawn. Fail: a missing tier, tiers out of order,
  a label whose color differs from its swatch, or a heading in body text. Result: pass (owner-marked 2026-10-30)
- **SHOW-11. Card names on one line (R5-05).** `/st show`, then click High Contrast. → Every card's
  name stays on one line above its swatches; a long name such as "High Contrast" is drawn a little
  smaller rather than wrapped or cut. Click Ka0s Default. → The names are back at full size. Fail: a
  name on two lines, a name cut off with "...", or text over the swatches. Result: pass (owner-marked 2026-10-30)
- **SHOW-12. Textures.** Scroll to the Textures section in Ka0s Default, then Obsidian. → Three
  status bars (the accent at 72%, a green at 45%, a red at 88%), a five-row bar chart and a
  five-segment stacked bar in the skin's chart colors, every fill drawn in the skin's bar texture
  over a dark track, and each sample labeled "Texture: <key>". On the switch the colors, the
  texture and the labels change at once. Fail: a flat fill where the skin names a texture, or a label
  naming a key the bars do not show. Result: pass (owner-marked 2026-10-30)
- **SHOW-13. Ka0s Default's face and bar.** Fully restart the client (new font and texture files),
  then `/st show` in Ka0s Default. → Every title and the body text are in Prototype (LibKa0s v1.82.0,
  D-02; Oxanium before), titles larger than the body, not Ka0s Ubuntu; the Textures section's labels read "Texture:
  Ka0s Default" and every fill shows that bar, dim at the top with a highlight low on the bar and a
  short lip, not the flat Blizzard bar. Click Obsidian, then WoW Default. → Their own faces and bars;
  WoW Default is the shipped Ka0s Ubuntu (LibKa0s R3-L6; Ka0s Friz Quadrata TT before), visibly unlike Prototype, with the Blizzard bar. Fail: a square where a glyph should be,
  or a flat or missing fill. Result: not run (re-opened by R3-FRIZ)
- **SHOW-14. Every skin's own bar (ST-02; LibKa0s SO-04).** Fully restart the client (new texture
  files), clear any Texture override on General → Skin, then `/st show` and scroll to Textures. Click
  each card in turn → every label reads "Texture: <key>" for that skin and every fill shows it: Ka0s
  Default: Ka0s Default; Obsidian: Ka0s Matte; Azeroth: Ka0s Parchment; Glass: Ka0s Glass Bar; High
  Contrast: Ka0s Solid; Ember: Ka0s Forge; WoW Midnight: Ka0s Satin; WoW Forever: Ka0s Classic; WoW
  Default: Blizzard. The seven new textures are visibly distinct (Parchment mottled, Solid flat, Glass
  Bar glossy, Classic like the client's bar). Fail: a label and a fill that disagree, a fill left on
  the previous skin's texture, a white or missing fill, or a visible seam where a texture tiles.
  Result: pass (owner-marked 2026-10-30)
- **SHOW-15. The showroom's scrollbar (ST-03).** `/st show` in Ka0s Default. → A thin scrollbar,
  a corridor and one knob, runs down the right edge beside the sections, never over them. Roll the
  wheel over the sections, then over the bar → both scroll, and the knob follows. Drag the knob to
  the bottom → the Textures section is in view; click the corridor above the knob → the sections
  move back up. Click Obsidian, then High Contrast → the corridor and knob take each skin's colors.
  The sections always overflow the fixed window, so the bar is always there; the headless suite
  covers the bar hiding when they fit. Fail: no bar, a knob that does not move with the wheel, a
  drag that leaves the sections still, a bar over the section content, or a bar in another skin's
  colors. Result: pass (owner-marked 2026-10-30)

- **SHOW-17. Addon surfaces (ST-01; LibKa0s v1.80.0).** Scroll to the Addon surfaces section in Ka0s
  Default. → "A note in this addon's own gray" in a mid gray (0.53, darker than the captions); a
  "Delete run" button on a dark red fill with a red edge and a white label; a "Waiting for the pull"
  callout on a faint orange wash with an orange edge and an orange title; a question-mark icon with a
  2px black border; a TreeGroup with General (expanded to Skin), Strings and About, in the client's
  stock look; and a small window titled "Settings-style window" in Ka0s Default's window colors and
  title, the client's settings-window frame art faded (LibKa0s v1.81.0, ruling R-2: Ka0s Default
  looks like Ka0s Default everywhere). Click High Contrast. → The
  note turns a light gray (0.85, the token's own High Contrast value), the button keeps its red edge
  on the skin's button fill with a red label, the callout takes the skin's card fill with an orange
  edge and title, the icon border follows the skin, and the small window takes High Contrast's window
  colors and title. Click Obsidian → the icon border is 1px. Click Ka0s Default → the small window
  is in Ka0s Default's colors again, never the client's frame. Clicking its close button does
  nothing. Fail: a sample in another skin's colors, the client's settings-window frame showing under
  any skin, or an error. (Since 2026-11-03 the section has no icon border, R4-ST3, and its
  TreeGroup starts skinned, R4-ST1; the pass of 2026-10-30 stands for the rest.) Result: pass (owner-marked 2026-10-30)
- **SHOW-18. The TreeGroup follows the Scope (ST-01).** With the showroom open on Addon surfaces,
  open General -> Skin, set Scope -> Ignore settings panel, then clear it (a new profile has it
  clear in this addon, R4-ST1). → The TreeGroup sample repaints at once: both panes in the skin's navigation fill and edge, the row labels in the skin's navigation
  text and body font, the selected row (General) tinted. Click a row → the selection moves and stays
  tinted. Click Glass → it follows. Set Ignore settings panel again → the TreeGroup is stock again.
  Fail: a TreeGroup that needs a reload to change, a row that loses its paint after a click, or a
  stock TreeGroup while the panel is skinned. Result: pass (owner-marked 2026-10-30)
- **SHOW-19. Every skin's HUD face (ST-01; LibKa0s v1.81.0, LK-04, ruling R-4).** Fully restart the
  client, clear any Font override on General -> Skin, then `/st show` and scroll to HUD faces, the
  last section. → Nine lines, two to a row, each "<skin>  12,345  0:42  98%  (<face>)" in that skin's
  own face, at its own HUD size (LibKa0s v1.82.0, D-09) with a dark outline, whatever skin is worn:
  Ka0s Default Prototype, Obsidian Expressway (v1.82.0; Oxanium SemiBold and Inter SemiBold before), Azeroth Open Sans Semibold, Glass Avant Garde, High Contrast Doris PP, Ember
  Emblem, WoW Default Ka0s Ubuntu (LibKa0s R3-L6; Ka0s Friz Quadrata TT before), WoW Midnight Segoe UI Semibold, WoW
  Forever Fira Sans SemiBold. Judge each face as a HUD face: digits legible under the outline, no
  closed-up counters. The tenth line, under them, is the worn skin's face: click Ember → it reads
  Emblem. Fail: a square where a glyph should be, a line in another skin's face, two skins
  sharing a face, or a face you reject for a HUD (record which skin and
  why: the owner's call, R-4). Result: not run (re-opened by R3-FRIZ)
- **SHOW-20. Ignore fonts reaches the HUD (ST-01; LibKa0s v1.81.0, LK-01, ruling R-1).** On HUD
  faces in Obsidian, tick Ignore fonts on General -> Skin. → The last line drops to the game's own
  face and reads "(Ignore fonts: the host's own face)" at once; the nine skin lines keep their faces
  (they show the skins). Untick it. → The last line is Expressway again. Fail: the last line
  keeping Expressway under Ignore fonts, or a skin line losing its face. Result: Owner reported pass, 2026-10-31
- **SHOW-21. Library widgets (ST-01; LibKa0s v1.81.0, LK-06a, LK-08).** Scroll to Library widgets in
  Ka0s Default. → A drag strip "Hover me: a drag handle" with its label in Prototype (v1.82.0), a box with an
  input, a line chart with two series and its axis labels, a resizable panel, a drawer head with a
  chevron and a nav entry. Hover the strip → the tooltip's title "Drag handle" in gold, the body in
  white, a blank line, then the footer in 0.6 gray. Type "o" in the box → a list of the skins whose
  name holds an "o", in the body face (Prototype). Click Azeroth and hover again → the title, body and
  footer take Azeroth's tooltip colors, the strip's label, the suggestion rows and the chart's axis
  labels take Open Sans. Also open the Controls section's dropdown → its rows are in the skin's body
  face, and the Overlays test strip's line is in the accent color and the body face. Tick Ignore
  fonts → the strip label, suggestion rows, chart labels, dropdown rows and test strip line go back to
  the game's fonts, live, and their colors stay. Fail: a tooltip in Ka0s Default's gold, white and
  gray under Azeroth, or any of those strings left in Friz Quadrata under a skin. Result: Owner reported pass, 2026-10-31
- **SHOW-22. Hover art and the resize grip (ST-01; LibKa0s v1.81.0, LK-06b, LK-06c).** On Library
  widgets in Ka0s Default, hover the drawer head and the nav entry → the client's own highlight
  wash; the chevron is gold; the grip in the panel's bottom-right corner is the client's own art.
  Click Glass → the hover washes take Glass's accent, the chevron its arrow color and the grip its
  icon tint, each desaturated first. Click WoW Default → the client's art again. Drag the grip → the
  panel resizes. Fail: a tinted wash or grip under Ka0s Default or WoW Default, or the client's own
  colors under Glass. Result: pass (owner-marked 2026-10-30)
- **SHOW-23. Tool windows (ST-01; LibKa0s v1.81.0, LK-06b).** On Library widgets press "Open a copy
  window" → a copy window in the skin, its resize grip bottom right in the skin's icon tint (the
  client's own art under Ka0s Default and WoW Default). Press "Open the console" → the debug console
  opens; its title-bar labels (the logging toggle, Diagnostics, Copy and Clear where drawn as words)
  are in the skin's body face, Prototype under Ka0s Default (v1.82.0), and its grip follows the skin as the copy
  window's. Run `/st perf` and follow it until its step panel shows → the panel's step and command columns are
  in the body face too. Tick
  Ignore fonts → those labels go back to the game's fonts, live; tick Ignore settings panel and
  untick it again → the windows keep their skin either way (they are windows). Fail: a label in Friz
  Quadrata while fonts are not ignored, or a window going stock with Ignore settings panel. Result: Owner reported pass, 2026-10-31
- **SHOW-24. The skin picker's layout (ST-01; LibKa0s v1.81.0, LK-11, ruling R-11).** On Library
  widgets press "Show the picker" (on any profile) → the skin picker titled "Choose a skin", with
  "Ka0s Skin Tester" on its own line in the heading color above the dropdown, whole and never cut off.
  Its rows still preview each skin in its own face, Ignore fonts or not. Close it → the skin worn is
  unchanged. In combat the button opens nothing and prints the gray "cannot open the skin picker
  during combat" line, every press (v1.82.0: the button runs `/st skin`'s act). Fail: the addon's
  name in the title, a cut-off owner line, or a picker mid-combat. Result: Owner reported pass, 2026-10-31
- **SHOW-25. Tooltip colors and art tints (ST-01; LibKa0s v1.81.0).** Scroll to Values in Ka0s
  Default. → Below Quality tiers, a "Tooltip colors (gtip.*)" heading over one labeled swatch per
  `gtip.*` token, `gtip.footer` a 0.6 gray, and an "Art tints (false: the client's art)" heading over
  `list.hoverArt` and `icon.grip`, each reading ": false, the client's art" in muted text with no
  swatch. Click Obsidian → `gtip.footer` takes `gtip.muted`'s color and both art tints show a swatch
  in their own color. Fail: a missing token, or a swatch under Ka0s Default's art tints. Result: pass (owner-marked 2026-10-30)

- **SHOW-26. Faces and widths (ST-01; LibKa0s v1.82.0, D-02, D-06, D-08).** Fully restart the
  client (new font files), clear any Font override, then `/st show` and scroll to Faces and widths,
  just above HUD faces. → The Font outline line, then nine face lines, each a body sample in the
  skin's body face and size and a title sample in its title face and size, naming both, with a muted
  "body <ratio>x  title <ratio>x  hud <ratio>x" line under them. Ka0s Default reads Prototype for
  both and 1.000x; Obsidian Expressway for both; WoW Forever Fira Sans Medium for the body and Fira
  Sans SemiBold for the title. Judge width parity by the ratio lines, not by where the samples end
  (each sample is followed by its own face name and size, so the line ends differ by design): every
  ratio should read close to 1.000x. Fail: a square where a glyph should be, a line in another skin's face, Inter
  or Oxanium anywhere, or a ratio reading "unmeasured". Result: Owner reported pass, 2026-10-31
- **SHOW-27. FontFlags and HudFontSize (ST-01; LibKa0s v1.82.0, D-07, D-09).** Scroll to Values in
  Ka0s Default. → After ChartStyle, "HUD OUTLINE   window ""   picked THICKOUTLINE THICKOUTLINE"
  (captioned FontFlags, under the default HUD text only) and "12 draws at 12   24 draws at 24" (captioned HudFontSize). Pick All
  text on the Skin tab's Font outline → the window value reads OUTLINE; Off → both read `""`, the picked
  flag still THICKOUTLINE. Click Obsidian → HudFontSize shows Obsidian's own sizes for a stored 12 and
  24. Fail: a From skin value that does not follow the Font outline, or a picked flag that changes.
  Result: Owner reported pass, 2026-10-31
- **SHOW-28. Every dropdown kind (ST-D1).** `/st show` in Obsidian and scroll to the dropdown rows of
  Controls. → Five dropdowns, each captioned: Dropdown (click: MenuFrame), WowStyle1DropdownTemplate,
  AceGUI Dropdown, Ka0sMedia_Font and Ka0sMedia_Statusbar, the last two reading a real key (Ka0s
  Prototype, Ka0s Default), and no LSM30 cell anywhere. The first two wear
  Obsidian's input fill and edge, with a small down arrow in its arrow color and no gold button; hover
  and open the WowStyle1 one → it stays that way, and its list is the client's own, as its caption
  says. AceGUI Dropdown and the two pickers wear the skin too, because a new profile has Scope ->
  Ignore settings panel clear in this addon (R4-ST1). Open General -> Skin, tick Scope -> Ignore
  settings panel → those three go to the client's stock look; clear it. → Those three repaint at once
  like the first two (LibKa0s R3-L1): the
  skin's input fill and edge, the text left-aligned, one chevron in the skin's arrow color and no gold
  button, with no client art behind them; open each → the list wears the skin, the font picker's rows in their own
  faces, the bar picker's rows with their swatches. Click Glass → all five follow. Set Ignore settings
  panel again → those three are stock again and the first two stay skinned. Tick Ignore fonts → the
  first two go to the game's fonts. Scroll the section → every dropdown moves with it and clips at the window's
  edge. Fail: a dropdown that stays put, a gold button or client text holder showing under the skin
  on any of the five while it wears the skin (record the state: idle, hover or open), one that needs a reload to
  change, or an empty cell. Result:
- **SHOW-29. The resize sample stays in its cell (ST-D2).** On Library widgets drag the "Drag the
  corner" box's grip to make it larger. → It resizes and its top left stays put. Roll the wheel → it
  scrolls with its caption. Drag it again, then move the window by its title bar → it stays with the
  section. Close the showroom and reopen it → the box is back at its first size, in its cell. Close
  with Escape in the middle of a drag, then reopen → the same, and the grip still works. Fail: a box
  that stays put while the section scrolls, or a size that survives a close. Result: Passed (owner, 2026-11-02)
- **SHOW-30. The HUD primitives (FS-ST-RV; LibKa0s v1.85.0).** Scroll to HUD faces, below the worn
  line, in Ka0s Default. → White sample numbers, a gold HUD label, "HudShadow: none in this skin" and a
  blue bar with no shine. Pick Azeroth, then Obsidian, then High Contrast with no reload. → The
  numbers, the label and the bar change color with each skin, and the shadow line reads 1, -1, then
  2, -2 on High Contrast, with a visible shadow on the text. Pick Glass. → The bar shines over its
  fill's top half. Tick Ignore fonts. → The shadow line reads nil. Fail: a color that stays between
  skins, a shine under any skin but Glass, or a needed reload. Result: Passed (owner, 2026-11-02)
- **SHOW-31. Marks (FS-ST-RV; LibKa0s v1.85.0).** Scroll to Overlays. → An info mark, a green tick and
  a line holding the info mark, the first and the line's mark in the skin's icon tint. Pick Azeroth. →
  All follow with no reload. Fail: a blank mark, a client icon, or a line left on the old tint.
  Result: Passed (owner, 2026-11-02)
- **SHOW-32. The samples tell the truth (FS-ST-FIX, cause A5).** In Obsidian: the Overlays ApplyBarFill
  bar wears Ka0s Matte in the accent color; the Faded label is body text beside the stock twin; the
  IconBorder sample and Controls' SquareIcon carry the skin's icon edge. In Values, every getter
  readout, the BarStyle line, the FontFlags and HudFontSize lines and, in Faces and widths, the Font
  outline line are body text, and the BarStyle bar has its fill color. In HUD faces the worn line is
  body text. On Panels, NavItem (selected) shows a filled selection. On Controls, the slider shows one
  track. The window's title bar is 30 high, its band ending where the bar does. Pick Azeroth. →
  All of them follow. Fail: gold or white stock text on a readout, a white or unfilled bar, a doubled
  slider track, or a band running past the title bar. Result: Failed (owner, 2026-11-02): re-opened as R3-L3
- **SHOW-33. The strip's look (LibKa0s v1.85.0, releasing Step 5).** On Overlays, in Azeroth: the test
  strip's icon takes the skin's icon tint. Hover the drag handle on Library widgets. → Its title is in
  the skin's tooltip title color. Fail: a strip icon or a tooltip title on the old color. Result: Passed (owner, 2026-11-02)

- **SHOW-34. BarBorder (LibKa0s v1.85.0).** Scroll to Values in Ka0s Default. → The BarBorder line reads
  "Draws Solid, shown false, 2 thick": a skin's None hands the stored three back. Pick Azeroth. → "Draws
  Solid, shown true, 1 thick". Pick WoW Default. → "Draws Blizzard Tooltip, shown true, 2 thick". Pick
  Obsidian. → The stored three again. Fail: a line that stays between skins, or a needed reload.
  Result: Passed (owner, 2026-11-02)
- **SHOW-35. HoverArt (LibKa0s v1.85.0).** On Library widgets in Ka0s Default, hover the HoverArt sample.
  → The client's own highlight wash, as on the drawer head. Pick Glass and hover it. → The wash takes
  `list.hoverArt`, desaturated first. Fail: a tinted wash under Ka0s Default, or the client's own color
  under Glass. Result: Passed (owner, 2026-11-02)
- **SHOW-36. Every skin's own bar, glow and cover (LibKa0s v1.85.0, the owner's rulings of 2026-11-01).**
  Click through every card with the Textures, Values and Panels sections in view. → Each non-default
  skin's bar track, GlowColor swatch and Cover dim are its own, from its palette; Ka0s Default's are what
  they were. Fail: two skins sharing all three, or Ka0s Default's moving. Result: Passed (owner, 2026-11-02)
- **SHOW-37. The Source dropdown on its own row (SF-FIX, not run).**
  Open the showroom: the Source dropdown sits under the skin cards, inside the window's right edge, and still switches between Ka0s and EllesmereUI skins. Result: Passed (owner, 2026-11-02)

## First-run skin picker

- **PICKER-1. A fresh profile.** Create a new profile on the Profiles page (or log in on a character
  that never ran the tester), with no other Ka0s addon loaded. → A small window titled "Choose a skin"
  opens in the skin worn, its center about three quarters of the way up the screen: "Ka0s Skin
  Tester" on a line of its own in the heading color, whole, above a dropdown showing that skin, with
  the eye and the gear beside it, an Apply button and a close control. No "Apply to all Ka0s addons"
  button. Fail: a window centered on the screen, a title that still names the addon, or an owner
  line that is missing, cut off or does not name the tester. Result: pass (owner-marked 2026-10-30)
- **PICKER-2. Its list, and a pick previews.** Click the dropdown. → The list opens over the
  window's rows, which stay where they are (LK-A3): every skin, each row three color swatches and the skin's name in
  that skin's own font and size. Pick Ember. → The window and the showroom repaint in Ember, the
  list closes, the dropdown reads Ember and the window stays up. Open General -> Skin. → It still
  shows the skin you had: a pick is only a preview. `/reload`. → The skin you had, and the picker
  opens again. Result: pass (owner-marked 2026-10-30)
- **PICKER-3. The eye.** Pick Ember, then click the eye. → The showroom opens in Ember, below the
  picker, which it does not cover; the picker stays up with Ember still pending. Result: pass (owner-marked 2026-10-30)
- **PICKER-4. The gear lands on General -> Skin.** Pick Glass, then click the gear. → The settings
  panel opens on General (not the Ka0s Skin Tester landing page) with the Skin tab selected, Glass
  ticked there and worn. The picker closes; `/reload` keeps Glass and does not open it again. In
  combat, the gear does nothing and the picker stays. Result: pass (owner-marked 2026-10-30)
- **PICKER-5. Close puts the old skin back.** On a fresh profile, pick Ember, then close the picker
  with its close control. → The tester goes back to the skin it wore when the window opened, and
  General -> Skin still shows that skin. On another fresh profile, do the same with Escape. → The
  same. `/reload` on either. → It does not open again on that profile. Result: pass (owner-marked 2026-10-30)
- **PICKER-6. After a reset, and a disabled profile.** Reset the profile (Reset all settings, or
  the Profiles page). → The picker opens again. A reset restores `enabled` to on, so it opens even
  if the addon was disabled before. Now close the picker on profile A, create profile B (the picker
  opens), run `/st disable` instead of closing it, switch to A, then back to B.
  → It does not open on B while B is disabled; `/st enable` on B and switch to A and back. → It opens
  on B, because B never closed it. Result: pass (owner-marked 2026-10-30)
- **PICKER-7. Taken down, not closed.** On a fresh profile with the picker up, run `/st disable`.
  → The picker goes away with the showroom. `/st enable`, then switch to a profile that has closed it, and back.
  → It opens again: the addon taking it down did not mark the profile seen. With it up on a profile
  that has not closed it, switch to one that has. → It goes away, and switching back opens it
  again. Result: pass (owner-marked 2026-10-30)
- **PICKER-8. Apply saves.** On a fresh profile, pick Obsidian, then press Apply. → The picker
  closes and the tester keeps Obsidian; General -> Skin shows it. `/reload`. → Still Obsidian, and
  the picker does not open. Result: pass (owner-marked 2026-10-30)
- **PICKER-9. Apply to all Ka0s addons.** With Ka0s Loot History installed (on this library
  branch) and both on profiles that have seen their pickers, create a fresh profile here only. → The
  picker shows "Apply to all Ka0s addons" beside Apply. Pick Azeroth and press it. → The picker
  closes, both addons wear Azeroth, and Loot History's Skin tab shows Azeroth with its Scope and its
  font and texture as they were. If either needs a reload, one popup names it. Result: pass (owner-marked 2026-10-30)
- **PICKER-10. One window at a time.** With Ka0s Loot History installed, give both addons fresh
  profiles and `/reload`. → One skin picker shows, never two, its owner line naming one addon. Close
  it (or press Apply). → The other addon's picker opens, its owner line naming that addon. Close it. → No
  third window. `/reload`. → Neither opens again. Result: pass (owner-marked 2026-10-30)
- **PICKER-11. Apply to all ends the queue.** As PICKER-10, but on the first picker pick Glass and
  press "Apply to all Ka0s addons". → No second picker opens, and both addons wear Glass.
  `/reload`. → Neither picker opens again. Result: pass (owner-marked 2026-10-30)
- **PICKER-12. Taken down while waiting.** As PICKER-10, with Loot History's picker up first and the
  tester's waiting behind it, run `/st disable`, then close Loot History's picker. → The tester's
  picker does not open. `/st enable`. → The picker still does not open: enabling is not a trigger.
  Switch the tester to a profile that has closed its picker (for example the one PICKER-8 applied
  on), then back to this one. → Its picker opens: waiting and being taken down did not mark the
  profile seen. Load order decides which picker comes first: if the tester's is up first, close it,
  then create a fresh tester profile while Loot History's is up, and continue from there. Result: pass (owner-marked 2026-10-30)
- **PICKER-13. Apply and close in combat.** On a fresh profile, pick Ember, then enter combat (a
  training dummy). Press Apply. → Nothing happens: the window stays up with Ember pending. With
  Ka0s Loot History installed, "Apply to all Ka0s addons" does the same. Press the close control.
  → The window closes and the tester goes back to the skin it wore when the window opened; General
  -> Skin still shows that skin. Repeat on another fresh profile with Escape instead. → The same.
  Result: pass (owner-marked 2026-10-30)
- **PICKER-14. A pending preview meets another write.** On a fresh profile, pick Ember (keep it
  pending). Then, in turn on fresh profiles: (a) `/st show` and click the Obsidian card; (b) on
  General -> Skin pick Obsidian; (c) run `/st set skin.skin obsidian`. Close the picker each time.
  → The tester wears Obsidian, the skin stored. Then pick Ember on a fresh profile and switch to a
  profile that has closed its picker and stores another skin (Glass, say). → The picker goes and
  the tester wears Glass. Switch instead to a fresh profile. → A new showing: the dropdown names
  that profile's skin, not Ember, and the close control or Apply leaves that skin on and stored.
  Fail: the tester wearing a skin other than the one General -> Skin shows, or (a), (b) or (c)
  putting back the skin the window opened with (the close undoes only the unsaved preview, so a
  skin stored while the window was up stays). Result: pass (owner-marked 2026-10-30)
- **PICKER-15. Apply's reload popup.** Only where a pick needs a reload (EllesmereUI installed and
  the tester on the EllesmereUI source, painted by it this session). Pick a skin that needs a
  reload, then another, then press Apply. → One reload popup naming the tester, once, not one per
  pick. A pick alone raises none. Result: pass (owner-marked 2026-10-30)
- **PICKER-16. A queued picker in combat.** As PICKER-10, with the tester's picker waiting behind
  Loot History's. Enter combat and close Loot History's picker with its close control. → Loot
  History's picker closes, and the tester's does not open while combat lasts. Leave combat. → The
  tester's picker opens, its owner line naming the tester. Repeat, and run `/st disable` while in
  combat after the close. → Nothing opens when combat ends. Fail: any picker opening mid-combat.
  Result: pass (owner-marked 2026-10-30)
- **PICKER-17. The Skin tab's rows (LibKa0s v1.83.0, LK-A3).** `/st skin`. → Under the skin dropdown:
  Font and Texture, each with a small refresh-arrow button at its right; Font outline; Scope, with
  Ignore settings panel and Ignore fonts side by side; then Apply to all and Apply. Nothing cut off
  or wrapped, in every skin; the window is about 10% wider than it was and taller. Check the arrow
  draws at all: it is the client's own art, in a size the harness cannot judge. Fail: a blank
  reset button, a wrapped check box label, or rows without the skin. Result: Owner reported pass, 2026-10-31
- **PICKER-18. Rows and pull-outs over the window.** Open the skin list. → It lays over the rows and
  the buttons, on top, and may hang below the window. Open Font. → Every row in its own face,
  "Skin's default (X)" first; the list opens over the window and is not hidden behind any of it.
  Open Texture. → Each row beside its bar. Fail: a list behind a row, or a blank face on the second
  open. Result: Owner reported pass, 2026-10-31
- **PICKER-19. Preview, Apply, close.** Pick a font, a texture, All text and Ignore fonts. → The
  showroom follows each one, and Font outline grays with Ignore fonts on. Close with the X. →
  Everything is back. Do it again and press Apply; `/reload`. → All four kept. Fail: a change that
  saves without Apply, or one that survives the X. Result: Owner reported pass, 2026-10-31
- **PICKER-20. Another skin clears the font and texture.** With a font override in force, pick
  another skin. → Font and Texture read "Skin's default (X)", naming the new skin's face. Pick the
  first skin back. → The override returns. A reset button is gray while its row is on the skin's
  default, and live otherwise. Result: Owner reported pass, 2026-10-31
- **PICKER-21. Apply to all carries them,** with a second Ka0s addon loaded. Pick a skin, font,
  texture, outline and scope, then Apply to all. → The second addon wears all of them, and its Skin
  tab shows them after a `/reload`. Result: Owner reported pass, 2026-10-31
- **PICKER-22. Ignore settings panel on.** Tick it in the picker (it starts unticked in this addon, R4-ST1). → The picker's own rows keep the
  skin, as the window does; the settings pages go to the game's look. Result: Owner reported pass, 2026-10-31
- **PICKER-23. Combat.** Start combat with the picker up, then change a row. → Refused, the row reads
  what is worn, one gray line. A picker raised in combat draws its rows disabled. Result: Owner reported pass, 2026-10-31
- **PICKER-24. The skin list closes on a press outside it (R5-RV; LibKa0s R5-L4; feedback item 6, images 46 and 47).** `/st skin`, open the skin list, then press the picker window's body. → The list closes. Open it again and press the game world. → It closes. Open it before each press, then press the picker's title, its eye, then its gear. → Each press closes the list and the eye and gear still do what they do. On General -> Skin, open the settings page's skin list, then press the Font dropdown. → The list closes and the Font list opens. With the picker and the settings page both up, open the picker's list, then press the settings page's skin list button. → The picker's list closes (that press is outside it) and the settings page's list opens and stays open until it is itself pressed outside; the two lists never open or close each other by any other route. (Both cannot be open at once in game: opening one is a press outside the other.) Escape still closes the window. Fail: a list that stays open after an outside press, a press that closes the list but drops the button's own click, or a Lua error. Result:
- **PICKER-25. The picker's title sits on its band (R5-RV; LibKa0s R5-L3).** `/st skin` in Ka0s Default, then WoW Midnight. → "Choose a skin" and the close mark are vertically centered on the window's title band. Fail: the title TOP-aligned above the band's middle, or the close mark off it. Result:
- **PICKER-26. The picker's file runs at minor 11 (R6-RV; LibKa0s R6-L1).** `/st diagnostics`. → The identity header's Options line lists `OptionsSkinPicker 11`, not 10, with every other Ka0s addon loaded too (Outfitter's own copy stays at 10, and the client runs 11). Fail: `OptionsSkinPicker 10`, or a Lua error on load. Result:

## Non-English client

- **LOC-1. A deDE or frFR client.** The addon reads no localized global, parses no tooltip line and
  keys nothing off a display string: every label is its own English text, and the skins' fonts are
  shipped faces. On a German or French client, open the showroom and the settings panel. → English
  labels everywhere, the skins' fonts drawn (no fallback squares), and no `%s` or `%d` left in any
  line. Fail: a label in German or French (this addon ships no translation, so one would mean a
  client string leaked in), a square where a glyph should be, or a stray `%s` or `%d`. The headless suite stands in for the strings (`test_prose`, the locale suite); on English,
  INSTALL-1 and PANEL-3 cover the rest, so this can be signed off without a language pack. Result: pass (owner-marked 2026-10-30)

## Pending sign-off

On 2026-10-30 the owner reported that every check of the v0.1.0 scaffold, the showroom and settings
work (ST-03, ST-05 to ST-07, SF-40, SF-43, SF-46, R5-05), the skin overrides and picker (2026-10-28),
the skinning rollout (2026-10-29) and the skin library follow-ups (2026-10-30) passed: INSTALL-1..3,
SLASH-1..4, PANEL-1..11, PROFILE-1..2, STATE-1..2, COMBAT-1..2, DIAG-1..2, DEGRADED-1, SHOW-1..25,
PICKER-1..16 and LOC-1, each recorded on its `Result:` line as pass (owner-marked 2026-10-30). Nothing
was owed then.

LibKa0s v1.82.0 (ST-01 of the skin fonts and feedback run, 2026-10-30) adds SLASH-5, SLASH-6,
PANEL-12, SHOW-26 and SHOW-27, and re-opens SHOW-13, SHOW-19, SHOW-20, SHOW-21, SHOW-23 and SHOW-24,
whose expected faces (Prototype and Expressway for Oxanium and Inter) or combat behavior changed;
their `Result:` lines are empty until the owner runs them.

LibKa0s v1.83.0 (ST-F01 of the font pickers and skin faces run, 2026-10-31) adds PANEL-13 and
re-opens PANEL-5, PANEL-6 and PANEL-7, whose expected rows, faces or wording changed; SHOW-13,
SHOW-19, SHOW-21, PANEL-12, SHOW-26 and SHOW-27 stay open and now state v1.83.0's faces and the HUD
text only default.

The owner reported the 2026-10-30 and 2026-10-31 runs' lists passed on 2026-10-31
("everythings works as expected"), recorded here line by line by the findings remediation
(FX-ST-DOCS). That remediation changed nothing a player sees: its perf fix is in the test mock and
`tests/perf.lua`, and the export it removed was read only by tests. So it adds no check.

LibKa0s v1.84.0 (XX-RV of the findings remediation, M2, 2026-10-31) adds DIAG-3. Its other changes
to this addon draw what they drew: the peels are pure moves, and the showroom's drag handle already
sat on a floor wider than its title.

ST-D1 and ST-D2 (2026-11-01) add SHOW-28 and SHOW-29; their `Result:` lines are empty until the owner
runs them.

M3-MEDIA (2026-11-01) removes the two LSM30 cells from SHOW-28 and adds PANEL-14, whose `Result:` line
is empty until the owner runs it.

The full skinning run (FS-ST-RV, FS-ST-FIX, 2026-11-01, LibKa0s v1.85.0) adds PANEL-15, PROFILE-3 and
SHOW-30 to SHOW-33, and re-opens PANEL-5, PANEL-13 and SHOW-9, whose expected rows or sample changed.

The FS-ST-GATE commit (2026-11-01, LibKa0s v1.85.0 re-cut) adds SHOW-34 to SHOW-36. Its slider sample
starts in the slider tokens, which S.Slider paints over, so no expected result moved, and no owner
pass mark goes: the bar tracks SHOW-12 names stay dark on both its skins.

R3-L3 of the owner's third smoke round (2026-11-02) adds SHOW-39, whose `Result:` line reads not run
until the owner runs it. SHOW-32's IconBorder samples keep their pass: they still carry the skin's
icon edge.

R3-FRIZ of the same round (LibKa0s R3-L6, R3-L7: Ka0s Friz Quadrata TT deleted, WoW Default on Ka0s
Ubuntu) adds SHOW-40 and re-opens SHOW-13 and SHOW-19, whose WoW Default face changed.

Owed: PANEL-5, PANEL-6, PANEL-13, PANEL-14, PANEL-15, PROFILE-3, SHOW-9, SHOW-13, SHOW-19, SHOW-28, SHOW-29, SHOW-30, SHOW-31,
SHOW-32, SHOW-33, SHOW-34, SHOW-35, SHOW-36, SHOW-37, SHOW-38, SHOW-39, SHOW-40, SHOW-41, PANEL-16, SHOW-42, SHOW-43, SHOW-44,
DIAG-4, SHOW-45, SHOW-46, SHOW-47, PANEL-17, PANEL-18, SHOW-48, SHOW-49, DIAG-5, PICKER-24, PICKER-25, SHOW-50, PICKER-26.

On 2026-11-02 the owner reported that every check on the smoke lists of the full skinning run and its smoke feedback batch (Ka0sAddonsCommonTasks `docs/2026-11-01-FULL_SKINNING/` and `docs/2026-11-01-SMOKE_FEEDBACK/`) passed, apart from DpsRace's clock font, the skinned look of the AceGUI Dropdown and the Ka0sMedia_Font and Ka0sMedia_Statusbar pickers, FadeNineSlice and IconBorder (`docs/2026-11-02-SMOKE_ROUND3/`, R3-SMOKE). Passed, recorded on each `Result:` line as `Passed (owner, 2026-11-02)`: PANEL-6, PANEL-13, PANEL-15, PROFILE-3, SHOW-5, SHOW-9, SHOW-29, SHOW-30, SHOW-31, SHOW-33, SHOW-34, SHOW-35, SHOW-36, SHOW-37 and SHOW-38. Failed, re-opened as R3-L3 (IconBorder's 1 px outline and zoom) and recorded as `Failed (owner, 2026-11-02): re-opened as R3-L3`: SHOW-32. Failed, re-opened as R3-L1 (the skinned AceGUI and media-picker dropdowns) and recorded as `Failed (owner, 2026-11-02): re-opened as R3-L1`: PANEL-5 and PANEL-14. Still owed: SHOW-28, whose expected result the third smoke round itself changed after the owner's run.

R4-ST1 of the owner's fourth smoke round (2026-11-03) defaults Ignore settings panel off in this addon
only (a documented deviation, docs/ARCHITECTURE.md). It adds PANEL-16 and re-opens PANEL-6, whose
expected starting state changed. The other steps that told the owner to untick the box now say it
starts unticked; what they check is unchanged, so their results stand.

R4-ST2 of the same round (2026-11-03) adds SHOW-42: the TreeGroup sample keeps its 120 height
(SetAutoAdjustHeight(false), as PrettyChat's) and its content pane shows a placeholder page.

R4-ST3 of the same round (2026-11-03) removes the Addon surfaces IconBorder sample, a duplicate of
Overlays' one (image 22), and adds SHOW-43. SHOW-39 drops it from its list; SHOW-17 keeps its pass
with a note.

R4-ST4 of the same round (2026-11-03) paints the showroom's Shell with `noTopBar`, as every other
Ka0s window whose title bar paints its own band does, and adds SHOW-44.

R4-RV2 of the same round (2026-11-03) re-vendors LibKa0s v1.85.0 at its fourteenth re-cut (bea4ac8),
which brings the library's R4-L2 (Ka0s Default's dark gold header), R4-L3 (the new icon.outline
token that IconBorder and SquareIcon outlines read) and R4-SEP (no line under any window title the
library draws). It adds DIAG-4, SHOW-45 and SHOW-46, and SHOW-39 now names the outline color. This
addon draws no header line of its own, so R4-SEP needs no host change here.

R4-RV3 of the same round (2026-11-03) re-vendors LibKa0s v1.85.0 at its fifteenth re-cut (2a78817),
which brings R4-L4: S.IconBorder's `opts.hud = true` draws a HUD icon's edge in `icon.border` and
never `icon.outline`. Both of this addon's IconBorder samples sit in the showroom window, so they keep
the outline and pass no `hud`; R4-HUD needs no host change here. It adds SHOW-47.

R4-L1 of the same round (LibKa0s OptionsCombat minor 4, 2026-11-03; LibKa0s has no smoke file, so its
in-client steps live here) adds PANEL-17, a dropdown list on a Ka0s settings page, the Profiles page
or a Ka0s window closing on a press outside it, and PANEL-18, another author's AceGUI dropdown keeping
its stock behavior.

R5-RV of the owner's fifth smoke round (Ka0sAddonsCommonTasks `docs/2026-11-03-SMOKE_ROUND5/`, 2026-11-03)
re-vendors LibKa0s v1.85.0 at its sixteenth re-cut (17d18aa), which brings R5-L1 (Ka0s Default's
darker header, option C), R5-L2 (Shell's band over a backdrop window's fill), R5-L3 (`S.Band` and
`S.Header`: every header child on the band's middle), R5-L4 (the skin list's outside-press close) and
R5-L5 (the icon rule). The showroom's own header moves onto the band in the same commit, because the
showroom shows every `lib.VOCAB` name. It adds SHOW-48, SHOW-49, DIAG-5, PICKER-24 and PICKER-25, and
SHOW-45 drops option E's hexes. LibKa0s has no smoke file, so the library's checks live here.

R5-WIN of the same round (2026-11-03) brings every window this addon builds to Loot History's look:
the showroom's body gutter moves from 8 to 6 px, the SettingsFrameTemplate sample's title and close
move from the template's anchors onto `S.Band` through `S.Header`, and the confirm popup, which
R5-L2 now gives a title band, carries its question on the band's middle. It adds SHOW-50.

R6-RV of the owner's sixth smoke round (Ka0sAddonsCommonTasks `docs/2026-11-03-SMOKE_ROUND6/`, 2026-11-04)
re-vendors LibKa0s v1.85.0 at its seventeenth re-cut (79d043d), which moves `OptionsSkinPicker.lua` alone,
to minor 11, for R6-L1 (the skin picker's preview contract, `spec.preview`). It adds PICKER-26.
