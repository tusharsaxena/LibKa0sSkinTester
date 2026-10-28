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
    player opens, not a positionable display.
  - **Skin** (the library's own tab, keyed `Appearance` and labeled "Skin"): the skin source, the
    nine skins under the "Look" heading (the tab's own name is not repeated), "Font and texture" (two dropdowns, each starting with "Skin's own (<key>)", then
    every LibSharedMedia font or statusbar key), the Scope ("Ignore settings panel", "Ignore
    fonts"), "Copy to every Ka0s addon..." and the note. A pick repaints the showroom at once; so do
    the font, the texture and Ignore fonts. Ignore fonts wins over a font override.
  - **Keybindings**, the library's own tab, last: the Show window binding (`NS.BINDINGS`).
- **Sample controls**: one row of each widget type the renderer draws (a checkbox, a slider, a
  dropdown, a color swatch and its Use class color companion) under one group heading, untabbed. It
  shows the skin on a settings page once Ignore settings panel is off (a new profile has it on, so
  the page starts in the client's look); the rows are read by nothing. No Skin tab and no copy
  action: the skin is picked on General.
- **Profiles**: AceDBOptions' profile controls, last.

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

## The first-run skin picker

The library's `O.SkinPicker` (OptionsSkinPicker minor 1), shown by `NS.MaybeShowSkinPicker`
(settings/Panel.lua) while the profile's `skin.pickerSeen` is false: once from `OnEnable`, after the
stored skin is applied, and after every profile switch, copy or reset. Never while the addon is
disabled and never in combat; the addon registers no game event, so a trigger in combat is skipped
and the next one asks again.

The window sits with its center 75% of the way up the screen, so the showroom the eye opens does not
cover it. It holds the title "Choose a skin for Ka0s Skin Tester", a dropdown of every skin (three
swatches and the name in that skin's own face), the eye (the showroom), the gear, "Apply", "Apply
to all Ka0s addons" (only while another Ka0s addon is loaded) and the close control.

- A pick previews: the showroom and the addon repaint in it, and nothing is written.
- **Apply** saves the pick through `NS.WriteSkinChoice`, then closes.
- **The gear** saves the pick as Apply does, then opens the settings panel on the General page
  (`O.OpenOptionsPanel("general")`) and selects its Skin tab.
- **The close control and Escape** put the skin the window opened with back, write nothing, and
  close.
- **Apply to all Ka0s addons** saves here, gives every other Ka0s addon the same source and skin
  (their scope and font and texture overrides are left alone), and closes this window and every
  picker still waiting.

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

Left-click opens this panel; right-click opens the options menu, whose entries are Enabled and Show
window (the skin showroom). The Show window binding is set under Options -> Keybindings ->
Ka0s Skin Tester, or on General -> Keybindings here.
