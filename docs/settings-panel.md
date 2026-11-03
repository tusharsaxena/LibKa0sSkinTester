# Settings panel

Settings -> AddOns -> Ka0s Skin Tester, built by `LibKa0s-Options-1.0`. The category registers at
login; each page's body builds on its first show.

## The tree

- **Ka0s Skin Tester** (landing): the logo, the TOC notes and the slash command list, all drawn by
  the library's `BuildLandingPage`.
- **General**, one tab strip:
  - **Master controls**, composed by the library: Enable Skin Tester; Master scale and Master
    opacity (the showroom's); Debug console and Minimap button; Reset position and Reset all
    settings. No Lock frame, Test mode or General visibility, because the showroom is a window the
    player opens, not a positionable display. No Sim mode box either: the library draws it only
    for a host that passes `isSimMode` and `toggleSim` (OptionsCompose minor 19), and this addon
    has no simulation (PANEL-19).
  - **Skin** (the library's own tab, keyed `Appearance` and labeled "Skin"): the skin source;
    "Look", with the library's note and the nine skins (the tab's own name is not repeated); "Font
    and texture" (two preview pickers, each row in its face or beside its bar, each list led by
    "Skin's default (<key>)" and then every LibSharedMedia font or statusbar key; "Reset font" and
    "Reset texture" under them, disabled while that half is the skin's own; then the Font outline
    dropdown, All text, HUD text only or Off); the Scope ("Ignore settings panel", "Ignore fonts");
    "Other Ka0s addons" ("Copy to every Ka0s addon..."). A pick repaints the showroom at once; so
    do the font, the texture, the outline and Ignore fonts. Ignore fonts wins over a font override
    and disables the Font outline.
  - **Keybindings**, the library's own tab, last: the Show window binding (`NS.BINDINGS`).
- **Sample controls**: one row of each widget type the renderer draws, bar the dim `note` row (a checkbox, a slider, a
  dropdown, a color swatch and its Use class color companion) and one `Ka0sMedia_*` picker of each
  media kind (font, bar texture, border, background, sound; LibKa0s v1.83.0, options-ui-§23), under
  one group heading, untabbed. The swatch and the font, bar and border pickers carry the skin
  companion a real row carries, on by default; a background and a sound have no skin token. The descriptor's `getLSM` feeds the pickers' lists. It
  shows the skin on a settings page while Ignore settings panel is off (a new profile has it off
  in this addon, a documented deviation from skinning-§3, R4-ST1, so the page starts skinned); the rows are read by nothing. No Skin tab and no copy
  action: the skin is picked on General.
- **Profiles**: AceDBOptions' profile controls, last. `NS.SkinPaintAceTree` follows each `Open`, so
  the page follows the Scope and the delete confirmation wears the skin (LibKa0s v1.85.0).

A row with no `page` is the General page's; the sample rows carry `page = "sample"`, and the host's
`rowsForPage` (settings/OptionsSetup.lua) hands each page only its own rows.

## The write seam

Every control writes through `NS.SchemaRuntime.Set`, the same seam `/st set` uses: the same `[Set]`
debug line, the same row `onChange`, the same panel refresh. The Skin tab calls
`Skin:SetChoice` first and then writes both halves through `NS.WriteSkinChoice`. A Scope tick calls
`Skin:SetIgnore` first and then hands the pair to `NS.WriteSkinChoice` as its third argument
(`{ panel, fonts }`), which writes `skin.ignorePanel` and `skin.ignoreFonts`; their rows'
`onChange` (`NS.ApplySkinIgnore`, one half each) is then a no-op, and a bare
`/st set skin.ignoreFonts true` applies live. A Font or Texture pick calls `Skin:SetOverride` first
and then hands both halves to `NS.WriteSkinChoice` as its fourth argument (`{ font, texture }`, a
key or false), which writes `skin.font` and `skin.texture` ("" for false); their rows' `onChange`
(`NS.ApplySkinMedia`, one half each) is then a no-op, and `/st set skin.texture <key>` applies live.
The Font outline dropdown (LibKa0s v1.82.0) calls `Skin:SetOutline` first and then passes the mode
as that fourth argument's `outline`, which writes `skin.outline`; its row's `onChange`
(`NS.ApplySkinOutline`) is then a no-op, and `/st set skin.outline off` applies live.

## The first-run skin picker

The library's `O.SkinPicker` (OptionsSkinPicker minor 11), shown by `NS.MaybeShowSkinPicker`
(settings/Panel.lua) while the profile's `skin.pickerSeen` is false: once from `OnEnable`, after the
stored skin is applied, and after every profile switch, copy or reset. The addon never asks for it
while disabled or in combat; it registers no game event, so a trigger in combat is skipped and the
next one asks again. A picker waiting behind another addon's shows when that one closes, but never
mid-combat: the close control and Escape still work in combat, and a close there leaves the queue
waiting until combat ends (the library parks it on its end-of-combat frame, PK-03), when this one
shows (PICKER-16). The waiting entry is not checked against `enabled` or `skin.pickerSeen` again,
which is safe because the stand-down and every profile event take it out of the queue first.

`/st skin` and the showroom's "Show the picker" button show the same window on demand, whatever
`skin.pickerSeen` says (`NS.RunSkinVerb`, the library's `O.SkinVerb`). In combat `/st skin` shows
nothing and prints a gray line on every call; while the addon is disabled the dispatcher refuses it.

The window sits with its center 75% of the way up the screen, clear of the middle, at DIALOG
strata and raised after it opens the showroom and after the eye runs, so the showroom does not cover it. It holds the title "Choose a skin", the addon's label on a line of its own, a
dropdown of every skin (three swatches and the name in that skin's own face), the eye (the
showroom, below), the gear, the Skin tab's rows ("Font and texture": Font and Texture, each a full-width
picker with a reset icon, then Font outline; "Scope": Ignore settings panel and Ignore fonts),
"Apply", "Apply to all Ka0s addons" (only while another Ka0s addon is loaded) and the close control.

- A pick previews: the showroom and the addon repaint in it, and nothing is written. A pick of a
  look other than the one the window opened with previews with the font and texture overrides
  cleared; a pick back to it restores them.
- The rows preview the same way, through `Skin:SetOverride`, `Skin:SetOutline` and `Skin:SetIgnore`,
  and write nothing.
- **Apply** saves the pick, then whatever the rows moved, through `NS.WriteSkinChoice`, then closes.
- **The gear** saves the pick as Apply does, then opens the settings panel on the General page
  (`O.OpenOptionsPanel("general")`) and selects its Skin tab.
- **The close control and Escape** undo only the unsaved preview: they put back the skin the
  profile stores as it reads at the close (`NS.SkinChoice`), so a skin General -> Skin, `/st set`
  or the showroom stored while the window was up stays (PICKER-14), and they put back what the rows
  previewed. They write nothing, and close.
- **Apply to all Ka0s addons** saves here, gives every other Ka0s addon the same source, skin,
  scope, font, texture and font outline, and closes this window and every picker still waiting.

**The eye and the showroom (`spec.preview`, LibKa0s OptionsSkinPicker minor 11, R6-PV).** This
addon has no test mode and no lock, so its preview mode is `"window"`: the showroom itself. When the
picker shows with the showroom closed, the showroom opens with it. The eye closes and opens the
showroom, lit while it is open and dimmed while it is closed, its tooltip "Preview: the skin showroom
is open. Click to close it." or "... is closed. Click to open it.". Every close (Apply, Apply to all,
the gear, the close control, Escape and the addon's own take-down) puts the showroom back as it was
when the picker opened: closed again if the picker or the eye opened it, open again if it was open
and the eye closed it. A picker opened from the showroom's own "Show the picker" button finds it open
and leaves it so. The picker and the eye call `NS.Showroom.Show`, `NS.Showroom.Hide` and
`NS.Showroom.IsShown`, the calls `/st show`, the launcher's Show window entry and the key binding make,
so the stand-down refusal still applies. The showroom's shown state is not stored, so a `/reload` while
the picker is up leaves nothing behind.

A write on the Skin tab while the window is up first drops a preview left unapplied here, so the
profile never stores what the picker only previewed.

Each of those closes sets `skin.pickerSeen` through the schema runtime; the eye leaves the window
up. A new or reset profile starts false, so it shows again.

One window serves every Ka0s addon in the client. Behind another addon's picker this one waits in
the library's queue (`NS.MaybeShowSkinPicker` answers false, "queued") and shows when that one
closes. Another addon's "Apply to all" dismisses it unshown, through its `onClose`, so the profile
is marked seen and has the skin.

The addon takes it down itself on the stand-down (`/st disable`, `NS.StandDownSkinPicker`) and at
the start of every profile switch, copy or reset, before the incoming skin is applied. That hide is
not a close by the player: a window that is up puts a pending preview back and closes with nothing
recorded, a picker still waiting leaves the queue, and the profile stays unseen. The profile event
then asks again, so an enabled profile that has not seen the picker gets a fresh showing whose
dropdown names that profile's skin. A pick pending on the old profile is never carried over: it is
not written into the new profile and does not overwrite the skin the new profile wears.

## The launcher

Left-click opens this panel; right-click opens the options menu, whose entries are the toggles
Enabled and Show window (the skin showroom), then the actions Open settings and Open skin selector
(the skin picker, through `NS.RunSkinVerb`; the library adds it because the descriptor passes
`openSkinPicker` and the addon is a registered skin owner, LibKa0s-Launcher minor 6, SF-F2). Show
window and Open skin selector gray while the addon is disabled. The Show window binding is set under Options -> Keybindings ->
Ka0s Skin Tester, or on General -> Keybindings here.
