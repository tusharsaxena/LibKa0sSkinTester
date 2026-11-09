# Schema

`LibKa0sSkinTesterDB` (AceDB, per-profile by default) and `LibKa0sSkinTesterPerfDB` (the perf
capture ring, outside AceDB, written only by the harness).

## Profile

| Path | Type | Default | Row | Notes |
|---|---|---|---|---|
| `enabled` | bool | `true` | Master controls (composed) | The `disabled` hold on the latch |
| `scale` | number | `1` | Master controls (composed) | The showroom's scale, 0.5 to 2 |
| `alpha` | number | `1` | Master controls (composed) | The showroom's opacity |
| `skin.source` | string | `ka0s` | Skin | `ka0s` or `eui` |
| `skin.skin` | string | `NS.DEFAULT_SKIN`: `forever` on WoW Forever, `ka0s` on Retail (LibKa0s v1.94.0, skinning-§2) | Skin | Any registered Ka0s skin key; an unregistered one applies the client's default |
| `skin.font` | string | `""` | Skin (Font and texture) | A LibSharedMedia font key over the skin's own (`Skin:SetOverride`); `""` is the skin's own. No `values`: the keys are whatever media packs registered |
| `skin.texture` | string | `""` | Skin (Font and texture) | A LibSharedMedia statusbar key for every bar of data; `""` is the skin's own |
| `skin.outline` | string | `hud` | Skin (Font and texture) | The Font outline (`Skin:SetOutline`, LibKa0s v1.82.0; the default since v1.83.0): `hud` text only, `all` text, or `off`; Ignore fonts wins |
| `skin.ignorePanel` | bool | `true` | Skin (Scope) | Leave this addon's settings pages and the showroom's "(Scope: panel)" samples the client's (`Skin:SetIgnore`); on by default, as skinning-§3 has it (QFE-ST2, retiring R4-ST1's off). A stored value is kept |
| `skin.ignoreFonts` | bool | `false` | Skin (Scope) | Leave every font the client's; the skin still colors text, and a font override has no effect |
| `skin.pickerSeen` | bool | `false` | none (skip-render) | The first-run skin picker was closed on this profile (Apply, the gear, the close control, Escape, or another addon's Apply to all); set by its `onClose` |

Defaults live in `defaults/Profile.lua` (`NS.C`); each row reads its default from there. Every
`skin.*` row is `skipRender`: the library's Skin tab (keyed `Appearance`) draws them, and they stay
schema rows so the defaults resolve, every reset reaches them and `/st get|set` addresses them. The
tab writes them only through `NS.WriteSkinChoice`.

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

`NS.SCHEMA_VERSION = 2`. Step 1 is the stamp itself. Step 2 (R3-FRIZ) moves a stored pick of
`Ka0s Friz Quadrata TT`, which LibKa0s v1.85.0 deleted, to `Ka0s Ubuntu` in every stored profile, at
any depth; Blizzard's own `Friz Quadrata TT` stays. A new step goes in `NS.MIGRATIONS` and is
idempotent against a fresh default profile.

The Sample controls page's fourteen `sample.*` rows were retired with the page (QFE-ST1, 2026-11-10).
No step removes them: a profile that stored one keeps it, read by nothing and harmless, and step 2
still walks it.
