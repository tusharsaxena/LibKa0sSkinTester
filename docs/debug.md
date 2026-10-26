# Debug surfaces

## The console

The LibKa0s debug console (LibKa0s-DebugLog-1.0), wired in `core/DebugLogSetup.lua`.

| | |
|---|---|
| Open or close | `/st debug`, or Master controls -> Debug console |
| Logging on or off | `/st debug on`, `/st debug off`, or the console's title-bar toggle |
| The flag | `NS.State.debug`, session-only: off at every login, never in SavedVariables |
| `[Init]` line | Name, version, schema, profile, `enabled` and the skin, written when logging is turned on |

Tags this addon writes: `Showroom` (built, shown, hidden, position reset, skin changed), `Selector`
(each card pick, with whether it changed the skin), `Set` (every
write through the seam, and profile resets and copies), `Profile` (a switch), `Migrate`. The library
writes `Cmd`, `Cfg`, `Launcher` and `Lifecycle` lines itself; the addon repeats none of them.

## The diagnostics report

### Running it

`/st diagnostics`, `/st debug diagnostics`, or the console's orange **Diagnostics** link. No other
form. It runs while the addon is disabled and in combat.

### What it does to the console

It turns debug logging on for the session first when it is off, then appends the report; it never
clears the console. Copy the whole output with the console's **Copy** button.

### What it prints

The library's identity header and markers, then this addon's sections (`modules/Diagnostics.lua`):

- `identity`: schema stored and current, the profile, `enabled`, whether stood down, the holds.
- `settings`: every row that differs from its default, plus `enabled`, `skin.source`, `skin.skin`.
- `skin`: the skin engine's minor, the stored and applied choice, owner and reload state, the skins.
- `showroom`: whether the window is built and shown, the sections registered, and how many distinct
  primitives have been painted through the wrapper.
- `rejected`: event names the client refused (none: the addon registers no event).

### Caps

The library's line cap and per-list caps apply; a capped report ends with its `truncated` line.

### What it does not do

It takes no hold, builds no window, changes no skin and registers nothing.
