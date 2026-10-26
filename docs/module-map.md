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
| `core/SkinSetup.lua` | The skin owner: `NS.Skin`, the choice seams, `NS.SKIN_OPTIONS` (LibKa0s-Skin-1.0) | Before the entry file and `settings/Schema.lua` |
| `core/LibKa0sSkinTester.lua` | AceAddon registration, initialize and enable, the profile events, the stand-down callbacks, `[Init]` | After the setup files above |
| `core/Database.lua` | The migration runner | Conventional |
| `core/LauncherSetup.lua` | The minimap button and broker row (LibKa0s-Launcher-1.0) | Conventional; registered from OnEnable |
| `defaults/Profile.lua` | `NS.C`, every default value | Before `settings/Schema.lua` |
| `modules/Selector.lua` | The swatch selector: one card per Ka0s skin, `Pick` (apply, then save) and `Refresh` | Before `modules/Showroom.lua`, which builds it into the window |
| `modules/Showroom.lua` | The showroom window, its toggle, the key-binding button and `NS.BINDINGS`; the paint wrapper (`Paint`, which records every primitive in `used`), the section registry (`AddSection`, laid out in a scroll body) and `Caption` | Before `settings/Panel.lua` (group order) |
| `modules/Diagnostics.lua` | The sections of `/st diagnostics` | Conventional; read at run time |
| `settings/SchemaSetup.lua` | `Settings.SchemaLib`: LibKa0s-Schema-1.0 or the host stub | Directly before `settings/Schema.lua` |
| `settings/Schema.lua` | The rows, the runtime `NS.SchemaRuntime`, defaults, reset | Before OptionsSetup, Panel and Slash |
| `settings/OptionsSetup.lua` | The LibKa0s-Options-1.0 instance, `Settings.Helpers` | Before `settings/Panel.lua` |
| `settings/Panel.lua` | The landing spec, the General page and its tabs, `Settings.Register` | After OptionsSetup |
| `settings/Slash.lua` | `COMMANDS`, the host verbs, the LibKa0s-Slash-1.0 dispatcher | Conventional within `# Settings` |
| `settings/Profiles.lua` | The Profiles page (AceDBOptions) | Last, so it is the last subcategory |

## Events

None registered: see `## Event Subscriptions` in [`ARCHITECTURE.md`](./ARCHITECTURE.md#event-subscriptions).
