# Ka0s Skin Tester

![WoW](https://img.shields.io/badge/WoW-Midnight_12.1.5-purple)
![License](https://img.shields.io/badge/License-MIT-orange)
![Standard](https://img.shields.io/badge/Ka0s-WoW_Addon_Standard-yellow)
![Tests](https://img.shields.io/badge/Tests-538%2F538_passing-green)

Ka0s Skin Tester is a fitting room for the Ka0s skins. Pick a skin and one window shows you what that skin does to buttons, tabs, lists, scrollbars, tooltips and everything else it can paint, so you don't have to open five other addons to see how a scrollbar came out.

It's a tool for people working on the skins, which is why it isn't on CurseForge. Otherwise it installs and updates like any other Ka0s addon.

## Screenshots

None yet.

## Usage

Type `/st` to open the settings, and `/st show` to open the showroom. `/skintester` works the same way. If another addon already answers to `/st`, the tester tells you once when you log in and leaves `/st` to that addon.

Across the top of the showroom is a row of nine cards, one per Ka0s skin, each with four color swatches. Click one and the window repaints in it. The General page's Skin tab picks the same thing, and either way the choice is saved with your profile, so a second profile can wear a different skin.

The first time a profile runs, a small "Choose a skin for Ka0s Skin Tester" window opens high on the screen, above where the showroom opens. Pick a skin from its list (each one shows three of its colors and its name in its own font) and the tester wears it at once, as a preview. Press the eye to see it in the showroom, Apply to keep it, or the gear to keep it and go to the Skin tab. The close button and Escape put back the skin you had. With another Ka0s addon loaded, "Apply to all Ka0s addons" gives every one of them the same skin. Whichever way you close the window, you won't see it again on that profile. A new profile, or one you reset, shows it again.

When several Ka0s addons start on new profiles at once, their skin windows come one at a time, and "Apply to all Ka0s addons" answers all of them.

Below the cards, the showroom scrolls through the window chrome, controls, lists, text, panels and overlays, then the skin's raw colors, then the bar textures at the bottom: three status bars, a bar chart and a stacked bar, each labeled with the texture it is drawn with. Every sample has a small label under it naming the part it shows.

The settings have a Sample controls page too: a checkbox, a slider, a dropdown and a color swatch, so you can see a skin on a settings page. None of them does anything. A new profile keeps the tester's own settings pages in the game's look, so untick Ignore settings panel on the Skin tab before you judge a skin there. Ignore fonts, next to it, gives every piece of text in the tester back the game's font and leaves the skin's colors on it.

The Skin tab's Font and Texture menus put a font, or a bar texture, of your choice over the skin's own. They list what LibSharedMedia knows about, so a media pack adds to them. Texture changes every bar of data, which is what the showroom's Textures section shows. Ignore fonts still wins over a chosen font.

The minimap button opens the settings on a left-click and a small menu on a right-click, where Show window opens the showroom. You can also bind a key to it from the game's Keybindings menu (the Ka0s Skin Tester header) or from the General page's Keybindings tab.

Everything else is in Settings, AddOns, Ka0s Skin Tester, and `/st help` lists the slash commands.

## How it works

- The addon wears a Ka0s skin the same way every other Ka0s addon with skins does.
- The showroom draws everything through the same painting code those addons use, so a skin looks the same here as it does there. If a part looks wrong in the showroom, the skin is at fault, not the showroom.
- A test checks that every part a skin can paint has a sample in the window. When the skins learn to paint something new, that test fails until the tester has a sample for it.

## FAQ

**Can I compare two skins side by side?** No. You see one skin at a time; switching is instant.

**Does it change my other addons?** Only if you press "Copy to every Ka0s addon" on the Skin tab, which copies the skin, the font, the texture and the Ignore boxes. Picking a skin here changes this addon alone.

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

The debug console uses [JetBrains Mono](https://www.jetbrains.com/lp/mono/), licensed under the SIL
Open Font License 1.1. It ships inside the bundled LibKa0s payload, with its license text beside it.

**Open Iconic** icons (the debug console's copy, clear and close marks, and the skin picker's eye
and gear), by Waybury, MIT license
(<https://github.com/iconic/open-iconic>), with the license beside them in the bundled payload.
