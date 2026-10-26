# Slash dispatch

`/st`, with `/skintester` as the alias, dispatched by LibKa0s-Slash-1.0 from the ordered `COMMANDS`
table in `settings/Slash.lua`. Bare `/st` opens the settings panel.

| Verb | Does | While disabled |
|---|---|---|
| `help` | Lists the commands | answers |
| `show` | Shows or hides the skin showroom | refused with the disabled line |
| `config` | Opens the settings panel | answers |
| `enable` / `disable` | Writes `enabled` through the write seam | answers |
| `version` | Prints the version | answers |
| `list` | Every setting and its value | answers |
| `get <path>` | One setting's value | answers |
| `set <path> <value>` | Writes one setting through the write seam; `toggle` flips a bool | answers |
| `reset <path>` | One setting back to its default | answers |
| `resetall` | The profile back to defaults, after a confirmation | answers |
| `profile [name]` | Lists profiles, or switches to one | answers |
| `debug [on\|off\|diagnostics]` | Toggles the console window; `on`/`off` toggle logging | answers |
| `diagnostics` | Writes the diagnostics report to the console | answers |
| `perf` | The guided performance run | answers |

The reserved verbs mean the same in every Ka0s addon (slash-commands-§2); `show` is this addon's one
feature verb. The dispatcher's own refusals land in the debug console as `[Cmd]` lines.
