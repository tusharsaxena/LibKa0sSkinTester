# Module map

Every non-vendored file, in TOC order, and what it is for. `libs/` (Ace3, LibSharedMedia,
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
| `core/SkinSetup.lua` | The skin owner: `NS.Skin`, the choice seams, the Scope's `NS.ApplySkinIgnore`, the overrides' `NS.ApplySkinMedia`, `NS.SKIN_OPTIONS`, the owner tokens `NS.SKIN_OWNER_TOKENS` handed to `RegisterOwner` (LibKa0s-Skin-1.0) | Before the entry file and `settings/Schema.lua` |
| `core/LibKa0sSkinTester.lua` | AceAddon registration, initialize and enable, the profile events, the stand-down callbacks, `[Init]` | After the setup files above |
| `core/Database.lua` | The migration runner | Conventional |
| `core/LauncherSetup.lua` | The minimap button and broker row (LibKa0s-Launcher-1.0) | Conventional; registered from OnEnable |
| `defaults/Profile.lua` | `NS.C`, every default value | Before `settings/Schema.lua` |
| `modules/Selector.lua` | The swatch selector: one card per Ka0s skin, `Pick` (apply, then save) and `Refresh` | Before `modules/Showroom.lua`, which builds it into the window |
| `modules/Showroom.lua` | The showroom window, its toggle, the key-binding button and `NS.BINDINGS`; the paint wrapper (`Paint`, which records every primitive in `used`, and calls an owner-bound library member such as `PaintAce` the facade does not carry), the section registry (`AddSection`, laid out in a scroll body with a skinned scrollbar that shows only on overflow) and `Caption` | Before `settings/Panel.lua` (group order) |
| `modules/ShowroomChrome.lua` | Section: the tab strip (Tab, SetTabSelection); the window itself is the rest of the chrome | After `modules/Showroom.lua` (it calls `AddSection`); the nine section files load in display order |
| `modules/ShowroomControls.lua` | Section: buttons in every state, paging arrows, an icon button, the library's search box and dropdown, check buttons, a slider | As above |
| `modules/ShowroomLists.lua` | Section: sort header, a list row in each state, a scroll bar | As above |
| `modules/ShowroomText.lua` | Section: the nine text roles, Font and White | As above |
| `modules/ShowroomPanels.lua` | Section: Panel, Inset, Card, Divider, Drawer, Strip, Cover, NavItem | As above |
| `modules/ShowroomOverlays.lua` | Section: a hover tooltip, a standing menu, a confirm-popup miniature, the library's test strip, the two fades beside stock twins, IconBorder, ApplyBarFill | As above |
| `modules/ShowroomOwner.lua` | Section: Addon surfaces, LibKa0s v1.80.0's rollout surfaces: a line in the owner token `st.note`, a danger button and a caution callout through `opts.tokens`, an AceGUI TreeGroup through `PaintAce` (repainted on each skin change, so it follows the Scope's settings-panel half), an icon border through `IconBorder`'s `fromSkin`, and a `SettingsFrameTemplate` miniature painted like any window, Ka0s Default included (LibKa0s v1.81.0 retired `opts.stockDefault`) | As above |
| `modules/ShowroomValues.lua` | Section: the six getters' answers, then two token categories under their headings: every `sem.*` color and every `q.*` quality tier, redrawn on each skin change (`NS.Values`) | As above |
| `modules/ShowroomTextures.lua` | Section: three status bars, a bar chart and a stacked bar, every fill through BarTexture and labeled with `bar.texture` (`NS.Textures`) | Last of the sections |
| `modules/Diagnostics.lua` | The sections of `/st diagnostics` | Conventional; read at run time |
| `settings/SchemaSetup.lua` | `Settings.SchemaLib`: LibKa0s-Schema-1.0 or the host stub | Directly before `settings/Schema.lua` |
| `settings/Schema.lua` | The rows, the runtime `NS.SchemaRuntime`, defaults, reset | Before OptionsSetup, Panel and Slash |
| `settings/OptionsSetup.lua` | The LibKa0s-Options-1.0 instance, `Settings.Helpers`, and `rowsForPage`, which hands each page only its own rows | Before `settings/Panel.lua` |
| `settings/Panel.lua` | The landing spec, the General page and its tabs, the Sample controls page, the first-run skin picker (`NS.MaybeShowSkinPicker`, `NS.StandDownSkinPicker`, `NS.SKIN_PICKER_SPEC`), `Settings.Register` | After OptionsSetup |
| `settings/Slash.lua` | `COMMANDS`, the host verbs, the LibKa0s-Slash-1.0 dispatcher, `NS.CheckSlashCollision` | Conventional within `# Settings` |
| `settings/Profiles.lua` | The Profiles page (AceDBOptions) | Last, so it is the last subcategory |

## Events

None registered: see `## Event Subscriptions` in [`ARCHITECTURE.md`](./ARCHITECTURE.md#event-subscriptions).
