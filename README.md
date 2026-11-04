# Skin Tester

![WoW](https://img.shields.io/badge/WoW-Midnight_12.1.5-purple)
![License](https://img.shields.io/badge/License-MIT-orange)
![Standard](https://img.shields.io/badge/Ka0s-WoW_Addon_Standard-yellow)
![Tests](https://img.shields.io/badge/Tests-886%2F886_passing-green)

Skin Tester is a fitting room for the Ka0s skins. Pick a skin and one window shows you what that skin does to buttons, tabs, lists, scrollbars, tooltips and everything else it can paint, so you don't have to open five other addons to see how a scrollbar came out.

It's a tool for people working on the skins, which is why it isn't on CurseForge. Otherwise it installs and updates like any other Ka0s addon.

## Screenshots

None yet.

## Usage

Type `/st show` to open the showroom, and `/st` on its own to open the settings; `/skintester` works the same way. The minimap button does both: a left-click opens the settings, and a right-click opens a small menu where Show window opens the showroom and Open skin selector brings back the skin picker. You can also bind a key to the showroom from the game's Keybindings menu (the Ka0s Skin Tester header) or from the General page's Keybindings tab. If another addon already answers to `/st`, the tester tells you once when you log in and leaves `/st` to that addon.

Across the top of the showroom is a row of nine cards, one per Ka0s skin, each with four color swatches. Click one and the window repaints in it. The General page's Skin tab picks the same thing, and either way the choice is saved with your profile, so a second profile can wear a different skin. Below the cards the window scrolls through everything a skin can paint: window chrome, controls, lists, text, panels and overlays, the extras an addon can ask a skin for, the library's own widgets, the skin's colors, the bar textures, and every skin's body, title and HUD fonts with how wide its text measures against Ka0s Default (`/st widths` prints the same numbers in chat). Every sample has a small label under it naming the part it shows. The full list is in [docs/scope.md](docs/scope.md).

The first time a profile runs, a small "Choose a skin" window opens high on the screen, and `/st skin` opens the same skin picker whenever you want it. Picking a skin in its list previews it on the tester, and so do the Font, Texture, Font outline and Ignore boxes under the list. Here the preview is the showroom itself: the picker opens it if it was closed, the eye closes it or opens it again, and whichever way you close the picker the showroom goes back to how it was. Press Apply to keep your choice, or the gear to keep it and go to the Skin tab; the close button and Escape put back what you had. With another Ka0s addon loaded, "Apply to all Ka0s addons" gives every one of them the same skin, font, texture, font outline and Ignore boxes. When several Ka0s addons start on new profiles at once, their pickers come one at a time, and that button answers all of them. Once closed, the picker stays away on that profile until you make a new one or reset it. [docs/settings-panel.md](docs/settings-panel.md) has the details.

The Skin tab's Font and Texture menus put a font or a bar texture of your choice over the skin's own, from every font and bar texture your addons have registered, so a media pack adds to them. A Reset button under each goes back to the skin's own, and choosing another skin puts both back too. Font outline says where the skin outlines text: on HUD text only (the default), on all of it, or nowhere. Ignore fonts gives every piece of text in the tester back the game's font, leaves the skin's colors on it, and wins over both a chosen font and the outline. Unlike the other Ka0s addons, the tester starts with Ignore settings panel unticked, so its own settings pages and the showroom's settings-panel samples wear the skin from the first run; tick it to see them in the game's look. The Sample controls page is there to show that off: a checkbox, a slider, a dropdown, a color swatch and one picker each for fonts, bar textures, borders, backgrounds and sounds, none of which does anything.

Everything else is in Settings, AddOns, Ka0s Skin Tester, and `/st help` lists the slash commands.

## How it works

- The addon wears a Ka0s skin the same way every other Ka0s addon with skins does.
- The showroom draws everything through the same painting code those addons use, so a skin looks the same here as it does there. If a part looks wrong in the showroom, the skin is at fault, not the showroom.
- A test checks that every part a skin can paint has a sample in the window. When the skins learn to paint something new, that test fails until the tester has a sample for it.

## FAQ

**Can I compare two skins side by side?** No. You see one skin at a time; switching is instant.

**Does it change my other addons?** Only if you press "Copy to every Ka0s addon" on the Skin tab or "Apply to all Ka0s addons" in the skin picker. Both copy the skin, the font, the texture, the font outline and the Ignore boxes. Picking a skin here changes this addon alone.

**Why is EllesmereUI on the Skin tab?** With EllesmereUI installed, an addon can let it do the painting. Coming back from EllesmereUI needs a `/reload`, because EllesmereUI's painting cannot be undone in place.

## Troubleshooting

| Symptom | Fix |
|---|---|
| `/st` opens something else | Another addon has `/st`, and the tester said so at login. Use `/skintester`. |
| The showroom does not open | The addon may be disabled: `/st enable`. |
| A skin looks wrong | That is what the tool is for. Note the skin and the label under the sample, and report it. |
| Something else looks wrong and I want to report it | Follow [Reporting a bug](#reporting-a-bug) below. |

## Reporting a bug

- Type `/st debug on` and reproduce the bug.
- Type `/st diagnostics`.
- If the debug window isn't open, open it with `/st debug`. Press **Copy**, copy the entire output, and include it with your bug report.

The report is added after the debug trace in the same window, so one copy carries both.

## Issues and feature requests

Bugs, feature requests and outstanding work are all tracked at [https://github.com/tusharsaxena/LibKa0sSkinTester/issues](https://github.com/tusharsaxena/LibKa0sSkinTester/issues). Please file new reports there. The issue tracker is the one place the project's backlog is kept.

## Version History

| Version | Date | Highlights |
|---|---|---|
| 0.1.0 | 2026-10-26 | - The first version: the showroom window, the skin picker on the Appearance tab, the minimap button and the key binding. |

## Credits

**Open Iconic** icons (the debug console's copy, clear and close marks, the skin picker's eye and
gear, and the small marks LibKa0s draws beside skinned controls), by Waybury, MIT license
(<https://github.com/iconic/open-iconic>), with the license beside them in the bundled payload.
