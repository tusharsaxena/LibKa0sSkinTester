local _, NS = ...
-- settings/Slash.lua — the ordered COMMANDS table, the host verbs and the LibKa0s-Slash-1.0
-- descriptor. The dispatcher, help renderer, formatters and value parser are the library's.
--
-- Conventional within # Settings: it reads NS.SchemaRuntime (settings/Schema.lua) at file scope,
-- which the group's earlier lines publish, and every verb resolves its handler at call time.

local Tester = NS.addon
local L      = NS.L

local function helpers() return Tester.Settings and Tester.Settings.Helpers end
local function trim(s) return (s or ""):gsub("^%s+", ""):gsub("%s+$", "") end

local ENABLED_PATH = "enabled"
local CLI_MISSING = NS.LIBKA0S_MISSING .. ", so the settings CLI is unavailable."

local Sl   -- forward-declared: the handlers below reach it at call time
local runShow, runConfig, runSkin, runDebug, runReset, runResetAll, runEnabled, runPerf

-- Positional triples {name, desc, fn}, in help order (slash-commands-§3). The reserved verbs mean
-- the same thing in every Ka0s addon (slash-commands-§2), `skin` among them (LibKa0s v1.82.0's
-- O.SkinVerb, ruling D-16); `show` is this addon's feature verb.
local COMMANDS = {
    {"help",        L["List available commands"],                  function() Sl:PrintHelp() end},
    {"show",        L["Show or hide the skin showroom"],           function() runShow() end},
    {"config",      L["Open the Ka0s Skin Tester settings"],       function() runConfig() end},
    {"skin",        L["Choose a skin: open the skin picker"],      function() runSkin() end},
    {"enable",      L["Enable the addon"],                         function() runEnabled(true) end},
    {"disable",     L["Disable the addon"],                        function() runEnabled(false) end},
    {"version",     L["Print the addon version"],                  function() Sl:CliVersion() end},
    {"list",        L["List every setting and its current value"], function() Sl:CliList() end},
    {"get",         L["Print a setting's current value — `/st get <path>`"],
        function(rest) Sl:CliGet(rest) end},
    {"set",         L["Set a setting — `/st set <path> <value>` (try /st list)"],
        function(rest) Sl:CliSet(rest) end},
    {"reset",       L["Reset one setting to its default — `/st reset <path>`"],
        function(rest) runReset(rest) end},
    {"resetall",    L["Reset this profile to defaults"],           function() runResetAll() end},
    {"profile",     L["List profiles, or switch to one: profile <name>"],
        function(rest) Sl:CliProfile(rest) end},
    {"debug",       L["Open/close the debug window — `/st debug on|off` toggles logging"],
        function(rest) runDebug(rest) end},
    {"diagnostics", L["Write the diagnostics report to the debug console"],
        function() NS.DebugLog:RunDiagnostics() end},
    {"perf",        L["Measure performance — try `/st perf` for the workflow"],
        function(rest) runPerf(rest) end},
}
Tester.COMMANDS = COMMANDS

local lib = LibStub and LibStub("LibKa0s-Slash-1.0", true)

if not lib then
    -- Degrade, never error: `/st` is registered unconditionally, so something must answer it. The
    -- host verbs keep working; the schema CLI verbs NAME the missing library. Nothing of the
    -- library's rendering is copied; the one library string carried is DISABLED_LINE_FORMAT,
    -- pinned against the live major by tests/test_surface_parity.lua.
    local function unavailable() NS.Print(CLI_MISSING) end
    local function profileAbsent()
        NS.Print(L["%s is unavailable: the LibKa0s library did not load."]:format("/st profile"))
    end
    local DISABLED_LINE_FORMAT = "%s is disabled \226\128\148 enable it with |cFFFFFF00%s|r"
    Sl = {
        OnSlash = function(_, msg)
            local raw = trim(msg)
            if raw == "" then return runConfig() end
            local name, rest = raw:match("^(%S+)%s*(.*)$")
            name = (name or ""):lower()
            for _, entry in ipairs(COMMANDS) do
                if entry[1] == name then return entry[3](rest or "") end
            end
            NS.Print("unknown command '" .. name .. "'")
            Sl:PrintHelp()
        end,
        PrintHelp = function()
            NS.Print("v" .. NS.Version() .. " slash commands")
            for _, entry in ipairs(COMMANDS) do NS.Print("  /st " .. entry[1] .. " — " .. entry[2]) end
        end,
        HelpRows = function()
            local out = {}
            for i, entry in ipairs(COMMANDS) do out[i] = "  /st " .. entry[1] .. " — " .. entry[2] end
            return out
        end,
        LandingRows = function()
            local out = {}
            for i, entry in ipairs(COMMANDS) do out[i] = "/st " .. entry[1] .. " — " .. entry[2] end
            return out
        end,
        HelpHeader      = function() return "v" .. NS.Version() .. " slash commands" end,
        DisabledLine    = function() return DISABLED_LINE_FORMAT:format(NS.BRAND_NAME, "/st enable") end,
        __disabledLineFormat = DISABLED_LINE_FORMAT,
        CliList         = unavailable,
        CliGet          = unavailable,
        CliSet          = unavailable,
        CliReset        = unavailable,
        CliResetAll     = unavailable,
        CliVersion      = function() NS.Print("v" .. NS.Version()) end,
        BuildListLines  = function() return { CLI_MISSING } end,
        SetRowAnnotator = function() end,
        Text            = function(_, key) return key end,
        CliProfile      = profileAbsent,
        ProfileSwitch   = function() profileAbsent(); return false end,
    }
    NS.SlashCommands = Sl
else
    -- `toggle` on a bool row flips it; everything else is the library's type-aware parse.
    local function parseValue(row, text)
        if row and row.type == "bool" then
            local first = (text or ""):match("^(%S+)")
            if first and first:lower() == "toggle" then
                local H = helpers()
                return not (H and H.Get(row.path))
            end
        end
        local v, err = lib.ParseValue(row, text)
        if v == nil and err == lib.STRINGS.ERR_BOOL then return nil, Sl:Text("ERR_BOOL") end
        return v, err
    end

    -- `profile` answers while disabled too: a player must be able to switch to a profile that
    -- enables the addon.
    local liveVerbs = {}
    for i, verb in ipairs(lib.LIVE_VERBS) do liveVerbs[i] = verb end
    liveVerbs[#liveVerbs + 1] = "profile"

    Sl = lib:New({
        slash        = "/st",
        slashAliases = { "/skintester" },
        commands     = COMMANDS,
        -- The DISABLED hold only (slash-commands-§7, Which refusal, by hold): under the perf hold
        -- alone the dispatcher lets the feature verb through, and the verb's own refusal answers
        -- with the capture line rather than the disabled one.
        isEnabled    = function()
            return not (NS.Lifecycle and NS.Lifecycle:IsHeld(NS.HOLD_DISABLED))
        end,
        brandName    = NS.BRAND_NAME,
        liveVerbs    = liveVerbs,
        profiles     = function() return Tester.db end,
        print        = function(line) NS.Print(line) end,
        -- The dispatcher's own refusals land in the console as `[Cmd]` lines (Slash minor 18).
        debug        = function(tag, message) NS.Debug(tag, message) end,
        version      = NS.Version,
        get          = NS.SchemaRuntime.Get,
        set          = NS.SchemaRuntime.Set,
        findRow      = NS.SchemaRuntime.FindRow,
        allRows      = function() return Tester.Settings.Schema end,
        applyDefault = NS.SchemaRuntime.ApplyDefault,
        groupKey     = function(row) return row.section or "?" end,
        parse        = parseValue,
        L = { ERR_BOOL = "expected true/false/on/off/1/0/toggle" },
    })
    NS.SlashCommands = Sl
end

local function libraryAbsent(verb)
    NS.Print(L["%s is unavailable: the LibKa0s library did not load."]:format(verb))
end

--- `/st show`: the showroom's one toggle, refused while stood down (the dispatcher's gate refuses
--- the verb first; the toggle's own refusal serves the launcher and the key binding).
function runShow() NS.Showroom.Toggle() end

--- `/st skin`: the skin picker a new profile shows, on demand (settings/Panel.lua's NS.RunSkinVerb,
--- which prints the library-absent line itself). The dispatcher refuses it while disabled.
function runSkin() NS.RunSkinVerb() end

function Tester:OpenSettings()
    if self.Settings and self.Settings.Register then self.Settings.Register() end
    local H = helpers()
    if not (H and H.OpenOptionsPanel) then return NS.Print("Settings panel is not available.") end
    H.OpenOptionsPanel()
end

function runConfig() Tester:OpenSettings() end

--- `/st enable` / `/st disable`: aliases writing the Enable row's stored path through the single
--- write seam (slash-commands-§2), with the stored value echoed as the CLI prints it.
function runEnabled(on)
    local H = helpers()
    if not (H and H.Set) then return NS.Print(CLI_MISSING) end
    local row = H.FindSchema(ENABLED_PATH)
    if not row then return libraryAbsent(on and "/st enable" or "/st disable") end
    local ok, err = H.Set(ENABLED_PATH, on)
    if ok == false then return NS.Print(tostring(err)) end
    local value = H.Get(ENABLED_PATH)
    if lib then return NS.Print(lib.FormatKV(row.path, lib.FormatValue(row, value))) end
    NS.Print(ENABLED_PATH .. " = " .. tostring(value))
end

--- `/st reset` takes a PATH (slash-commands-§2); a bare one explains itself.
function runReset(rest)
    if trim(rest) == "" then
        NS.Print("|cffFFFF00/st reset|r takes a setting path: |cffFFFF00/st reset <path>|r (try |cffFFFF00/st list|r).")
        NS.Print("  To reset everything: |cffFFFF00/st resetall|r, or the |cffFFFF00Defaults|r button on the settings page.")
        return
    end
    Sl:CliReset(rest)
end

function runResetAll()
    local H = helpers()
    if not (H and H.RestoreAllDefaults) then return NS.Print(CLI_MISSING) end
    if StaticPopup_Show and Tester.Settings.EnsureResetPopup then
        Tester.Settings.EnsureResetPopup()
        StaticPopup_Show("LIBKA0SSKINTESTER_RESET_ALL")
    else
        H.RestoreAllDefaults()
        NS.Print(L["all settings reset to defaults"])
    end
end

--- `/st debug` toggles the WINDOW; `on`/`off` go through the one SetEnabled seam, and
--- `diagnostics` is tested FIRST (debug-logging-§5, §14). Any other word toggles the window.
function runDebug(rest)
    local DL = NS.DebugLog
    if not DL then return NS.Print("Debug console not ready yet") end
    if not DL:DebugVerb(rest) then DL:Toggle() end
end

--- The guided perf run is the library's; it returns lines and this prints them (performance-§4).
function runPerf(rest)
    for _, line in ipairs(NS.Perf.OnCommand(rest or "")) do NS.Print(line) end
end

-- The launcher's menu reaches the same handlers its verbs do (launcher-§2).
function Tester:SlashEnabled(on) runEnabled(on and true or false) end

function Tester:OnSlashCommand(input) Sl:OnSlash(input) end

-- ── the /st collision ────────────────────────────────────────────────────────────────────────
-- AceConsole registers `/st` as SLASH_ACECONSOLE_ST1. Any other SLASH_<NAME><n> global spelling
-- `/st`, with a live SlashCmdList[<NAME>], is another addon's: this addon lets go of `/st` so the
-- other keeps it, and says so in one line. Run once, from OnEnable (PLAYER_LOGIN).
local OWN_ST = "ACECONSOLE_ST"

function NS.CheckSlashCollision()
    local list = _G.SlashCmdList
    if type(list) ~= "table" then return false end
    for key, value in pairs(_G) do
        if type(key) == "string" and type(value) == "string" and value:lower() == "/st" then
            local name = key:match("^SLASH_(.-)%d+$")
            if name and name ~= OWN_ST and list[name] ~= nil then
                Tester:UnregisterChatCommand("st")
                NS.Print(L["Another addon already uses /st, so this one answers only to /skintester."])
                return true
            end
        end
    end
    return false
end
