local _, NS = ...
-- locales/enUS.lua — NS.L, the canonical English strings; the key IS the English source string.

-- The metatable fallback answers the key itself, so a string with no entry still reads correctly
-- (localization-§2). Every label, tooltip and chat line the addon authors has an entry below.
local L = setmetatable({}, {
    __index = function(_, k) return k end,
})
NS.L = L

-- The settings panel
L["Slash Commands"] = "Slash Commands"
L["Profiles"]       = "Profiles"
L["Reset this profile to the addon's defaults? Everything you have configured or added in it is discarded \226\128\148 your other profiles are not affected."] =
    "Reset this profile to the addon's defaults? Everything you have configured or added in it is discarded \226\128\148 your other profiles are not affected."
L["all settings reset to defaults"] = "all settings reset to defaults"

-- The slash help
L["List available commands"]                 = "List available commands"
L["Show or hide the skin showroom"]          = "Show or hide the skin showroom"
L["Open the Ka0s Skin Tester settings"]      = "Open the Ka0s Skin Tester settings"
L["Enable the addon"]                        = "Enable the addon"
L["Disable the addon"]                       = "Disable the addon"
L["Print the addon version"]                 = "Print the addon version"
L["List every setting and its current value"] = "List every setting and its current value"
L["Print a setting's current value — `/st get <path>`"] =
    "Print a setting's current value — `/st get <path>`"
L["Set a setting — `/st set <path> <value>` (try /st list)"] =
    "Set a setting — `/st set <path> <value>` (try /st list)"
L["Reset one setting to its default — `/st reset <path>`"] =
    "Reset one setting to its default — `/st reset <path>`"
L["Reset this profile to defaults"]          = "Reset this profile to defaults"
L["List profiles, or switch to one: profile <name>"] =
    "List profiles, or switch to one: profile <name>"
L["Open/close the debug window — `/st debug on|off` toggles logging"] =
    "Open/close the debug window — `/st debug on|off` toggles logging"
L["Write the diagnostics report to the debug console"] =
    "Write the diagnostics report to the debug console"
L["Measure performance — try `/st perf` for the workflow"] =
    "Measure performance — try `/st perf` for the workflow"

-- The debug console
L["Diagnostic report written to the debug console: %d lines. Use Copy to share it."] =
    "Diagnostic report written to the debug console: %d lines. Use Copy to share it."

-- The showroom window and its key binding
L["Skin showroom"]                      = "Skin showroom"
L["Wearing %s"]                          = "Wearing %s"
L["Window chrome"]                      = "Window chrome"
L["Controls"]                           = "Controls"
L["Lists"]                              = "Lists"
L["Text"]                               = "Text"
L["Panels"]                             = "Panels"
L["Overlays"]                           = "Overlays"
L["Values"]                             = "Values"
L["Textures"]                           = "Textures"

-- The first-run skin picker's eye
L["Preview: open the skin showroom"]    = "Preview: open the skin showroom"
L["Another addon already uses /st, so this one answers only to /skintester."] =
    "Another addon already uses /st, so this one answers only to /skintester."
L["Toggle the skin showroom"]           = "Toggle the skin showroom"
L["Shows or hides the skin showroom."]  = "Shows or hides the skin showroom."

-- Refusals
L["%s is unavailable: the LibKa0s library did not load."] =
    "%s is unavailable: the LibKa0s library did not load."
L["Not available during a performance capture."] = "Not available during a performance capture."
