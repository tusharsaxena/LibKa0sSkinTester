# Schema

`LibKa0sSkinTesterDB` (AceDB, per-profile by default) and `LibKa0sSkinTesterPerfDB` (the perf
capture ring, outside AceDB, written only by the harness).

## Profile

| Path | Type | Default | Row | Notes |
|---|---|---|---|---|
| `enabled` | bool | `true` | Master controls (composed) | The `disabled` hold on the latch |
| `scale` | number | `1` | Master controls (composed) | The showroom's scale, 0.5 to 2 |
| `alpha` | number | `1` | Master controls (composed) | The showroom's opacity |
| `skin.source` | string | `ka0s` | Appearance | `ka0s` or `eui` |
| `skin.skin` | string | `ka0s` | Appearance | Any registered Ka0s skin key; an unregistered one applies Ka0s Default |
| `skin.ignorePanel` | bool | `true` | Appearance (Scope) | Leave this addon's settings pages the client's (`Skin:SetIgnore`) |
| `skin.ignoreFonts` | bool | `false` | Appearance (Scope) | Leave every font the client's; the skin still colors text |
| `sample.checked` | bool | `true` | Sample controls | Shown, read by nothing |
| `sample.size` | number | `5` | Sample controls | 1 to 10, step 1; read by nothing |
| `sample.mode` | string | `medium` | Sample controls | `small`, `medium`, `large`; read by nothing |
| `sample.color` | color | `{ r = 0.2, g = 0.6, b = 1, a = 1 }` | Sample controls | Read by nothing |
| `sample.useClassColor` | bool | `false` | Sample controls | The swatch's class-color companion (options-ui-§17), `classColorSource = "player"` |

Defaults live in `defaults/Profile.lua` (`NS.C`); each row reads its default from there.

## Session-only

| Path | Owner | Notes |
|---|---|---|
| `state.debugConsole` | the debug console | The console's open state; never in SavedVariables |
| `NS.State.debug` | `core/State.lua` | The logging flag, off at every login |

## Global

| Key | Written by | Notes |
|---|---|---|
| `global.schemaVersion` | `core/Database.lua` | Default `0`; the runner advances it |
| `global.minimap` | LibDBIcon | Its own `hide`; the Minimap button row reads and writes it, and no reset reaches it |
| `global.windows.LibKa0sSkinTesterShowroom` | `NS.Windows.Save` (drag stop), `NS.Windows.Forget` (Reset position) | The window's anchor; no row addresses it |

## Migrations

`NS.SCHEMA_VERSION = 1`. Step 1 is the stamp itself. A new step goes in `NS.MIGRATIONS` and is
idempotent against a fresh default profile.
