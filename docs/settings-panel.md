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
  - **Appearance**, the library's own tab: the skin source, the nine skins, "Copy to every Ka0s
    addon..." and the note. A pick repaints the showroom at once.
  - **Keybindings**, the library's own tab, last: the Show window binding (`NS.BINDINGS`).
- **Profiles**: AceDBOptions' profile controls.

## The write seam

Every control writes through `NS.SchemaRuntime.Set`, the same seam `/st set` uses: the same `[Set]`
debug line, the same row `onChange`, the same panel refresh. The Appearance tab calls
`Skin:SetChoice` first and then writes both halves through `NS.WriteSkinChoice`.

## The launcher

Left-click opens this panel; right-click opens the options menu, whose entries are Enabled and Show
window (the skin showroom). The Show window binding is set under Options -> Keybindings ->
Ka0s Skin Tester, or on General -> Keybindings here.
