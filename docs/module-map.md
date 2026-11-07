# Module map

Every non-vendored file and what it is for: the addon's files in TOC order, then `Bindings.xml`, and
the headless suite under [Tests](#tests). `libs/` (Ace3, LibSharedMedia,
LibDataBroker, LibDBIcon, LibKa0s) and `tests/_kit/` are vendored and never edited here.

| File | Responsibility | Load-order constraint |
|---|---|---|
| `locales/enUS.lua` | `NS.L`, the English strings, with the key-is-the-string fallback | First of the addon's files |
| `core/Namespace.lua` | `NS.PREFIX`, `NS.BRAND_NAME`, `NS.LIBKA0S_MISSING` | Before every file that prints or names the brand |
| `core/CoreSetup.lua` | The printer, `SafeToString`, `SafeRegisterEvent`, the window chrome, `NS.MakeCloseButton` (LibKa0s-Core-1.0) | Before everything that prints |
| `core/MediaSetup.lua` | `NS.Icon`, `NS.MediaFont`, the one `RegisterLSM` (LibKa0s-Media-1.0) | Before `core/Constants.lua` |
| `core/Constants.lua` | `FONT_MONO` and the layers table, `NS.Constants.LAYERS` | Conventional |
| `core/State.lua` | `NS.State.debug`, session-only | Before `core/DebugLogSetup.lua` |
| `core/EnvSetup.lua` | `NS.Meta`, `NS.Version` (LibKa0s-Env-1.0) | Conventional |
| `core/Util.lua` | `NS.Windows`: the showroom's saved position | Conventional |
| `core/LifecycleSetup.lua` | The stand-down latch and `NS.StandDownRefusal` (LibKa0s-Lifecycle-1.0) | Before `core/PerfSetup.lua` |
| `core/PerfSetup.lua` | `NS.Perf` (LibKa0s-Perf-1.0): the `build` and `repaint` buckets | Before `modules/`, which take it as an upvalue |
| `core/DebugLogSetup.lua` | `NS.DebugLog`, `NS.Debug` and the gates (LibKa0s-DebugLog-1.0) | After Constants, State and CoreSetup |
| `core/SkinSetup.lua` | The skin owner: `NS.Skin`, the choice seams, the Scope's `NS.ApplySkinIgnore`, the overrides' `NS.ApplySkinMedia`, the Font outline's `NS.ApplySkinOutline` and `NS.SKIN_OUTLINE_OPTIONS`, `NS.SKIN_OPTIONS`, the owner tokens `NS.SKIN_OWNER_TOKENS` handed to `RegisterOwner` (LibKa0s-Skin-1.0) | Before the entry file and `settings/Schema.lua` |
| `core/LibKa0sSkinTester.lua` | AceAddon registration, initialize and enable, the profile events, the stand-down callbacks, `[Init]` | After the setup files above |
| `core/Database.lua` | The migration runner | Conventional |
| `core/LauncherSetup.lua` | The minimap button and broker row (LibKa0s-Launcher-1.0) | Conventional; registered from OnEnable |
| `defaults/Profile.lua` | `NS.C`, every default value | Before `settings/Schema.lua` |
| `modules/Selector.lua` | The swatch selector: one card per Ka0s skin, `Pick` (apply, then save) and `Refresh` | Before `modules/Showroom.lua`, which builds it into the window |
| `modules/Showroom.lua` | The showroom window (its Shell painted with `noTopBar`, the TitleBar drawing the band), its toggle, the key-binding button and `NS.BINDINGS`; the paint wrapper (`Paint`, which records every primitive in `used`, and calls an owner-bound library member such as `PaintAce` the facade does not carry), the section registry (`AddSection`, laid out in a scroll body with a skinned scrollbar that shows only on overflow) and `Caption` | Before `settings/Panel.lua` (group order) |
| `modules/ShowroomChrome.lua` | Section: the tab strip (Tab, SetTabSelection); the window itself is the rest of the chrome | After `modules/Showroom.lua` (it calls `AddSection`); the twelve section files load in display order |
| `modules/ShowroomControls.lua` | Section: buttons in every state, paging arrows, an icon button, the library's search box, check buttons, a slider, and a row of every dropdown kind the collection draws: the library's `W.Dropdown`, AceGUI's Dropdown and the `Ka0sMedia_Font` and `Ka0sMedia_Statusbar` pickers through `PaintAce` (repainted on each skin change, so they follow the Scope's settings-panel half, each showing a real key), and a `WowStyle1DropdownTemplate` button through `Dropdown` with its template art in `opts.stock` and a glyph of its own | As above |
| `modules/ShowroomLists.lua` | Section: sort header, a list row in each state, a scroll bar | As above |
| `modules/ShowroomText.lua` | Section: the nine text roles, Font and White | As above |
| `modules/ShowroomPanels.lua` | Section: Panel, Inset, Card, Divider, Drawer, Strip, Cover, NavItem | As above |
| `modules/ShowroomOverlays.lua` | Section: a hover tooltip (a frame of this addon's), a standing menu, a confirm-popup miniature, the library's test strip, the two fades beside stock twins, IconBorder, ApplyBarFill, Mark and MarkText | As above |
| `modules/ShowroomOwner.lua` | Section: Addon surfaces, LibKa0s v1.80.0's rollout surfaces: a line in the owner token `st.note`, a danger button and a caution callout through `opts.tokens`, an AceGUI TreeGroup through `PaintAce` (repainted on each skin change, so it follows the Scope's settings-panel half; its height is the host's, with a placeholder page in its content pane), and a `SettingsFrameTemplate` miniature painted like any window, Ka0s Default included (LibKa0s v1.81.0 retired `opts.stockDefault`) | As above |
| `modules/ShowroomWidgets.lua` | Section: Library widgets, the custom LibKa0s widgets v1.81.0 newly skins, each owned by this addon and on a window: a drag handle (its tooltip in `gtip.title`, `gtip.value`, `gtip.footer`), an autocomplete, a line chart, a resize grip through `MakeResizable`'s `opts.owner` (`icon.grip`), its box put back on its cell after a drag and to its size on close, a drawer head and a nav entry with `opts.hover` (`list.hoverArt`) and `opts.chevron`, `S.HoverArt` on a sample of its own (LibKa0s v1.85.0), launchers for a copy window, the debug console and the skin picker (`NS.ShowSkinPicker`), and a button opening an owned `W.ContextMenu` cascade (Widgets 23, LibKa0s v1.89.0: a plain and a disabled row, a `submenu` of `radio` rows, a `selected`/`keepOpen` multi group, a second-depth submenu), closed by `W.CloseMenu` when the showroom hides or the skin changes | As above |
| `modules/ShowroomValues.lua` | Section: the nine getters' answers (FontFlags and HudFontSize, LibKa0s v1.82.0, and BarBorder, v1.85.0, among them), then four token categories under their headings: every `sem.*` color, every `q.*` quality tier, every `gtip.*` tooltip color and the art tints `list.hoverArt` and `icon.grip`, redrawn on each skin change (`NS.Values`) | As above |
| `modules/ShowroomTextures.lua` | Section: three status bars, a bar chart and a stacked bar, every fill through BarTexture and labeled with `bar.texture` (`NS.Textures`) | As above |
| `modules/ShowroomFonts.lua` | Section: Faces and widths (LibKa0s v1.82.0, D-02, D-06, D-08): this addon's Font outline and what it gives window and HUD text, then one line per skin in its own body and title faces and sizes under that outline, with its measured width ratio against Ka0s Default per role; `NS.Fonts.Measure` and `/st widths` (`NS.Fonts.PrintWidths`) | As above |
| `modules/ShowroomHud.lua` | Section: HUD faces, one line per skin in its own `hud.font`, size and outline (LibKa0s v1.81.0, R-4), one in the face `BarStyle` hands a HUD, which Ignore fonts gives back to the host's, and the v1.85.0 HUD primitives: HudFont, HudTextColor, HudLabelColor, HudShadow, BarFillColor, BarGloss (`NS.Hud`) | Last of the sections |
| `modules/Diagnostics.lua` | The sections of `/st diagnostics` | Conventional; read at run time |
| `settings/SchemaSetup.lua` | `Settings.SchemaLib`: LibKa0s-Schema-1.0 or the host stub | Directly before `settings/Schema.lua` |
| `settings/Schema.lua` | The rows, the runtime `NS.SchemaRuntime`, defaults, reset | Before OptionsSetup, Panel and Slash |
| `settings/OptionsSetup.lua` | The LibKa0s-Options-1.0 instance, `Settings.Helpers`, and `rowsForPage`, which hands each page only its own rows | Before `settings/Panel.lua` |
| `settings/Panel.lua` | The landing spec, the General page and its tabs, the Sample controls page, the first-run skin picker (`NS.MaybeShowSkinPicker`, `NS.StandDownSkinPicker`) and its spec's `preview` (window mode: the showroom through `NS.Showroom.Show`, `Hide` and `IsShown`), the reserved `/st skin` verb's act (`NS.RunSkinVerb`) and the showroom's on-demand showing (`NS.ShowSkinPicker`), `Settings.Register` | After OptionsSetup |
| `settings/Slash.lua` | `COMMANDS`, the host verbs, the LibKa0s-Slash-1.0 dispatcher, `NS.CheckSlashCollision` | Conventional within `# Settings` |
| `settings/Profiles.lua` | The Profiles page (AceDBOptions) | Last, so it is the last subcategory |
| `Bindings.xml` | The Show window key: one `CLICK` binding on `LibKa0sSkinTesterToggleShowroom` (created in `modules/Showroom.lua`), in the addon's own category, with no default key | Not in the TOC; the client reads it from the addon root |

## Tests

Every authored file under `tests/`. `tests/_kit/` is the vendored LibKa0s test kit and is never edited
here; [testing.md](testing.md) says how to run the suite, and [test-cases.md](test-cases.md) is the
generated case inventory.

| File | Responsibility |
|---|---|
| `tests/run.lua` | The headless runner on the shared kit: the suite list (this addon's suites and the kit's), the load list from the TOC, `--list` for `docs/test-cases.md` |
| `tests/loader.lua` | The instance factory: one isolated addon instance per call in a fresh mock environment, answering `(NS, env, mock)` |
| `tests/wow_mock.lua` | This addon's extender over the kit's `mock_base`: the client surface the showroom, the settings panel and the launcher reach for |
| `tests/mock_menu.lua` | A headless stand-in for the client's context-menu API |
| `tests/skin_surfaces.lua` | The skin-switch test's facts (`Kit.skinSwitch`): every surface this addon paints, off one opened showroom |
| `tests/perf.lua` | The offline performance runner (performance-§9) |
| `tests/test_harness.lua` | The harness's own wiring: the TOC-derived load list, the LibKa0s file list, the kit revision |
| `tests/test_vendor_sync.lua` | The vendored-payload gate; the implementation is the kit's `vendor_sync.lua` |
| `tests/test_surface_parity.lua` | Every degradation stub carries the whole live surface |
| `tests/test_libka0s.lua` | The LibKa0s seams this addon owns: the vendored library registers, each descriptor is well-formed, a degraded install answers |
| `tests/test_library_lines.lua` | The lines LibKa0s writes into this addon's debug log |
| `tests/test_lintconfig.lua` | The no-blanket-suppression gate over `.luacheckrc` (lint) |
| `tests/test_doc_structure.lua` | The README and architecture-hub shapes documentation-§1 and documentation-§3 fix |
| `tests/test_docmap.lua` | The `## Documentation map` says what `docs/` actually holds (documentation-§3) |
| `tests/test_register.lua` | The deviation register's citations are checked |
| `tests/test_lifecycle.lua` | The addon shell: `OnInitialize` / `OnEnable` wiring and the file-load post-hooks |
| `tests/test_disabled.lua` | The stand-down conformance suite (slash-commands-§7) |
| `tests/test_database.lua` | `schemaVersion` seeding and migration idempotency |
| `tests/test_envsetup.lua` | `core/EnvSetup.lua`, the LibKa0s-Env-1.0 seam |
| `tests/test_mediasetup.lua` | `core/MediaSetup.lua`, the LibKa0s-Media-1.0 seam |
| `tests/test_util.lua` | The secret-safe stringifier and chat-printer seam and the standalone-window geometry helpers |
| `tests/test_debuglog.lua` | The debug console: formatters, the font constant, the `/st debug` window-versus-flag semantics |
| `tests/test_diagnostics.lua` | This addon's sections of `/st diagnostics` (debug-logging-§14) |
| `tests/test_launcher.lua` | The launcher: one LibDataBroker object, registered twice, wearing this addon's logo, and its clicks |
| `tests/test_launcher_skin_entry.lua` | The launcher menu's *Open skin selector* entry |
| `tests/test_keybinds.lua` | The Show window key binding's section under Keybindings and the General page's Keybindings tab |
| `tests/test_settings.lua` | Schema defaults, validation, Get / Set and reset |
| `tests/test_settings_sample.lua` | The Sample controls settings page: one row of each widget type the settings renderer draws |
| `tests/test_panel.lua` | The canvas settings panel (`settings/Panel.lua`): registration, the lazy build, schema-to-widget rendering |
| `tests/test_profiles.lua` | The Profiles page and the shared reaction to AceDB's three profile events |
| `tests/test_slash.lua` | The slash surface: the `COMMANDS` table, the host verbs and the LibKa0s-Slash-1.0 descriptor's wiring |
| `tests/test_skin_verb.lua` | The reserved `skin` verb |
| `tests/test_skin_picker.lua` | The first-run skin picker's triggers (`NS.MaybeShowSkinPicker`) |
| `tests/test_skin_picker_preview.lua` | The skin picker's window-mode preview |
| `tests/test_skin_media.lua` | The font and texture overrides (`skin.font`, `skin.texture`), written only through the skin write seam |
| `tests/test_skin_outline.lua` | The font outline (`skin.outline`) |
| `tests/test_selector.lua` | The swatch selector: one card per Ka0s skin, and a click that moves the showroom's skin |
| `tests/test_skin_default.lua` | The default skin per client: a fresh profile stores and wears WoW Forever on Forever and Ka0s Default on Retail, and a reset lands on it |
| `tests/test_showroom.lua` | The showroom window and its paint wrapper |
| `tests/test_showroom_coverage.lua` | The showroom's claim: every name in the skin's vocabulary is on show |
| `tests/test_showroom_dropdowns.lua` | The Controls section's dropdown row: every dropdown kind the collection draws |
| `tests/test_showroom_fonts.lua` | The Faces and widths section and the `/st widths` probe |
| `tests/test_showroom_hud.lua` | The HUD faces section |
| `tests/test_showroom_owner.lua` | The Addon surfaces section |
| `tests/test_showroom_textures.lua` | The Textures section: status bars, a bar chart and a stacked bar in the skin's bar texture |
| `tests/test_showroom_values.lua` | The Values section: the getters' answers, the semantic colors and the item quality tiers |
| `tests/test_showroom_widgets.lua` | The Library widgets section |

## Events

None registered: see `## Event Subscriptions` in [`ARCHITECTURE.md`](./ARCHITECTURE.md#event-subscriptions).
