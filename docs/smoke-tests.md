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
| PANEL-1..13 | Settings panel | Landing page, General's tabs, Skin, Keybindings, Sample controls, the Scope, Font and texture, the settings chrome's face and tooltips, the Font outline, the media pickers |
| PROFILE-1..2 | Profiles | The Profiles page and the `profile` verb |
| STATE-1..2 | Enable and disable | The stand-down and its refusal |
| COMBAT-1..2 | Combat | The showroom and the panel in combat |
| DIAG-1..2 | Diagnostics | The debug console and the report |
| DEGRADED-1 | Degraded install | The library-absent load |
| SHOW-1..27 | Showroom | The window, the swatch selector, the sections, position and scale, the textures, Ka0s Default's face and bar, the addon surfaces, the library widgets, the tooltip colors and art tints, the HUD faces, the faces and widths, FontFlags and HudFontSize |
| PICKER-1..16 | First-run skin picker | When and where it shows, its title, preview, Apply, close, the gear, Apply to all, one window across addons, taking it down, combat, a preview meeting another write, the reload popup |
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
  line for two presses. Result:
- **SLASH-6. `/st widths` (ST-01; LibKa0s v1.82.0, D-08).** Fully restart the client, clear any Font
  override on General -> Skin, then `/st widths`. → A header, "Widths of a fixed corpus against Ka0s
  Default (1.000x is parity):", and nine lines, one per skin, each "<skin>: body <face> <size>
  <ratio>x, title ..., hud ...". Ka0s Default reads 1.000x on all three. Note every other ratio here
  (D-08's in-client check: the owner judges how near 1.000x is near enough); a ratio far from 1, say
  below 0.95 or above 1.05, is a finding for LibKa0s's sizes, not for this addon. Fail: "unmeasured"
  for a shipped face, or a line missing. Result:

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
- **PANEL-5. Sample controls.** On General -> Skin untick Ignore settings panel (a new
  profile has it ticked, and the page is then the client's), pick Obsidian, then open Settings ->
  AddOns -> Ka0s Skin Tester -> Sample controls. → One group heading over a checkbox, a slider, a dropdown, a color swatch and Use
  class color, then the five media pickers (PANEL-13), all in Obsidian; no Skin tab and no copy button. Pick Glass on General and come
  back. → The page follows. Result:
- **PANEL-6. The Scope.** On a fresh profile open General -> Skin with the showroom open. →
  Ignore settings panel is ticked and Ignore fonts is not; the settings pages are in the client's
  look while the showroom wears the skin. Untick Ignore settings panel. → The settings pages take the
  skin at once, no reload. Pick Azeroth and tick Ignore fonts. → The showroom's Open Sans text and titles go
  back to the game's fonts at once and keep the skin's colors. `/reload`. → Both ticks are as you left them. Result:
- **PANEL-7. Font and texture rows.** Open General -> Skin. → A "Font and texture" section between
  the skins and the Scope, with a Font and a Texture dropdown. Each list starts with "Skin's default
  (<key>)" naming the current skin's own font or texture, then every font or statusbar texture
  LibSharedMedia knows, sorted, each shown in its face or with its bar, the leading row too. Pick another skin. → Both "Skin's default" entries name the new skin's
  keys. Result:
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
- **PANEL-11. The settings rows' tooltips (ST-01; LibKa0s v1.81.0, LK-06d).** On General -> Skin
  untick Ignore settings panel and pick Glass. Hover a row's label on any of the tester's pages → its
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
  needs a reload. Result:
- **PANEL-13. The media pickers (ST-F01; LibKa0s v1.83.0, LK-F03, D-08, D-09).** Fully restart the
  client (new font files), untick Ignore settings panel on General -> Skin, pick Obsidian and open
  Sample controls. → Five pickers under the color swatch: A font picker on Ka0s Prototype, drawn in
  Prototype; A bar texture picker on Blizzard, beside its bar; A border picker and A background
  picker on Blizzard Tooltip, each beside its swatch; A sound picker on None. Open each. → The
  pull-out wears Obsidian, and every row shows what it offers: fonts each in their own face (the
  thirteen new Ka0s faces among them), bars, borders and backgrounds each with their art. Sounds
  need a media pack: with one loaded, a row's play button plays it, and without one the list holds
  None alone. Pick an entry in each. → The closed row shows it, it survives a `/reload`, and nothing
  else changes. Tick Ignore fonts. → The font rows keep their own faces. Fail: a list of plain
  names, a blank row, a stock (unskinned) pull-out with the panel skinned, or a list reading only
  the no-media entry. Result:

## Profiles

- **PROFILE-1. Switch carries the skin.** Create a profile, give it another skin, switch back and
  forth on the Profiles page. → The showroom follows each profile's skin. Result: pass (owner-marked 2026-10-30)
- **PROFILE-2. The verb.** `/st profile`, then `/st profile <name>`. → Lists, then switches.
  Result: pass (owner-marked 2026-10-30)

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
  accent. No EllesmereUI card. Result: pass (owner-marked 2026-10-30)
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
  A skinned tooltip, the skinned popup menu, and the tab selection moving. Result: pass (owner-marked 2026-10-30)
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
  D-02; Oxanium before), titles larger than the body, not Ka0s Friz Quadrata TT; the Textures section's labels read "Texture:
  Ka0s Default" and every fill shows that bar, dim at the top with a highlight low on the bar and a
  short lip, not the flat Blizzard bar. Click Obsidian, then WoW Default. → Their own faces and bars;
  WoW Default is the shipped Ka0s Friz Quadrata TT (v1.83.0, D-01), visibly unlike Prototype, with the Blizzard bar. Fail: a square where a glyph should be,
  or a flat or missing fill. Result:
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
  any skin, or an error. Result: pass (owner-marked 2026-10-30)
- **SHOW-18. The TreeGroup follows the Scope (ST-01).** With the showroom open on Addon surfaces,
  open General -> Skin and clear Scope -> Ignore settings panel. → The TreeGroup sample repaints at
  once: both panes in the skin's navigation fill and edge, the row labels in the skin's navigation
  text and body font, the selected row (General) tinted. Click a row → the selection moves and stays
  tinted. Click Glass → it follows. Set Ignore settings panel again → the TreeGroup is stock again.
  Fail: a TreeGroup that needs a reload to change, a row that loses its paint after a click, or a
  stock TreeGroup while the panel is skinned. Result: pass (owner-marked 2026-10-30)
- **SHOW-19. Every skin's HUD face (ST-01; LibKa0s v1.81.0, LK-04, ruling R-4).** Fully restart the
  client, clear any Font override on General -> Skin, then `/st show` and scroll to HUD faces, the
  last section. → Nine lines, two to a row, each "<skin>  12,345  0:42  98%  (<face>)" in that skin's
  own face, at its own HUD size (LibKa0s v1.82.0, D-09) with a dark outline, whatever skin is worn:
  Ka0s Default Prototype, Obsidian Expressway (v1.82.0; Oxanium SemiBold and Inter SemiBold before), Azeroth Open Sans Semibold, Glass Avant Garde, High Contrast Doris PP, Ember
  Emblem, WoW Default Ka0s Friz Quadrata TT (v1.83.0), WoW Midnight Segoe UI Semibold, WoW
  Forever Fira Sans SemiBold. Judge each face as a HUD face: digits legible under the outline, no
  closed-up counters. The tenth line, under them, is the worn skin's face: click Ember → it reads
  Emblem. Fail: a square where a glyph should be, a line in another skin's face, two skins
  sharing a face, or a face you reject for a HUD (record which skin and
  why: the owner's call, R-4). Result:
- **SHOW-20. Ignore fonts reaches the HUD (ST-01; LibKa0s v1.81.0, LK-01, ruling R-1).** On HUD
  faces in Obsidian, tick Ignore fonts on General -> Skin. → The last line drops to the game's own
  face and reads "(Ignore fonts: the host's own face)" at once; the nine skin lines keep their faces
  (they show the skins). Untick it. → The last line is Expressway again. Fail: the last line
  keeping Expressway under Ignore fonts, or a skin line losing its face. Result:
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
  gray under Azeroth, or any of those strings left in Friz Quadrata under a skin. Result:
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
  Ignore fonts → those labels go back to the game's fonts, live; untick Ignore settings panel and
  tick it again → the windows keep their skin either way (they are windows). Fail: a label in Friz
  Quadrata while fonts are not ignored, or a window going stock with Ignore settings panel. Result:
- **SHOW-24. The skin picker's layout (ST-01; LibKa0s v1.81.0, LK-11, ruling R-11).** On Library
  widgets press "Show the picker" (on any profile) → the skin picker titled "Choose a skin", with
  "Ka0s Skin Tester" on its own line in the heading color above the dropdown, whole and never cut off.
  Its rows still preview each skin in its own face, Ignore fonts or not. Close it → the skin worn is
  unchanged. In combat the button opens nothing and prints the gray "cannot open the skin picker
  during combat" line, every press (v1.82.0: the button runs `/st skin`'s act). Fail: the addon's
  name in the title, a cut-off owner line, or a picker mid-combat. Result:
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
  or Oxanium anywhere, or a ratio reading "unmeasured". Result:
- **SHOW-27. FontFlags and HudFontSize (ST-01; LibKa0s v1.82.0, D-07, D-09).** Scroll to Values in
  Ka0s Default. → After ChartStyle, "HUD OUTLINE   window ""   picked THICKOUTLINE THICKOUTLINE"
  (captioned FontFlags, under the default HUD text only) and "12 draws at 12   24 draws at 24" (captioned HudFontSize). Pick All
  text on the Skin tab's Font outline → the window value reads OUTLINE; Off → both read `""`, the picked
  flag still THICKOUTLINE. Click Obsidian → HudFontSize shows Obsidian's own sizes for a stored 12 and
  24. Fail: a From skin value that does not follow the Font outline, or a picked flag that changes.
  Result:

## First-run skin picker

- **PICKER-1. A fresh profile.** Create a new profile on the Profiles page (or log in on a character
  that never ran the tester), with no other Ka0s addon loaded. → A small window titled "Choose a skin"
  opens in the skin worn, its center about three quarters of the way up the screen: "Ka0s Skin
  Tester" on a line of its own in the heading color, whole, above a dropdown showing that skin, with
  the eye and the gear beside it, an Apply button and a close control. No "Apply to all Ka0s addons"
  button. Fail: a window centered on the screen, a title that still names the addon, or an owner
  line that is missing, cut off or does not name the tester. Result: pass (owner-marked 2026-10-30)
- **PICKER-2. Its list, and a pick previews.** Click the dropdown. → The list opens inside the
  window, which grows to hold it: every skin, each row three color swatches and the skin's name in
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
