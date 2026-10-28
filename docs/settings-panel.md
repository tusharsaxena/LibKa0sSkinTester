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
    nine skins, "Font and texture" (two dropdowns, each starting with "Skin's own (<key>)", then
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
and the next one asks again. The window: "Choose a skin", a dropdown of every skin (three swatches
and the name in that skin's own face), the eye (the showroom), the gear (the panel, then General's
Skin tab) and the close control. Closing it by any route sets `skin.pickerSeen` through the schema
runtime; a pick and the eye leave it up. A new or reset profile starts false, so it shows again.
The addon takes it down itself on the stand-down (`/st disable`, `NS.StandDownSkinPicker`) and on a
profile event that lands on a disabled profile or one that has seen it; that hide is not a close by
the player, so it writes nothing and the profile stays unseen.

## The launcher

Left-click opens this panel; right-click opens the options menu, whose entries are Enabled and Show
window (the skin showroom). The Show window binding is set under Options -> Keybindings ->
Ka0s Skin Tester, or on General -> Keybindings here.
