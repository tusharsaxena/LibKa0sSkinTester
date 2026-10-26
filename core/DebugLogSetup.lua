local addonName, NS = ...
-- core/DebugLogSetup.lua — NS.DebugLog from a LibKa0s-DebugLog-1.0 descriptor; publishes the bare
-- NS.Debug sink and the console's change gates.
--
-- LOAD-BEARING: after core/Constants.lua (FONT_MONO), core/State.lua (the flag) and
-- core/CoreSetup.lua (the printer), and before any NS.Debug call. The window, both formatters, the
-- 3000-line buffer, the copy window and the diagnostics machinery are the library's; this file says
-- where the flag lives and what the [Init] line says.

local lib = LibStub and LibStub("LibKa0s-DebugLog-1.0", true)

if not lib then
    -- Degrade, never error. Every member the addon calls; SetEnabled still flips OUR flag and still
    -- acknowledges, because a player who types `/st debug on` must not be told nothing happened. The
    -- window is lost, said once. RunDiagnostics prints the library-absent line and writes nothing.
    local missing = NS.LIBKA0S_MISSING .. ", so the debug console window is unavailable."
    -- One announcement per ENTRY POINT: turning logging on, and asking for the window. A single
    -- shared token would be spent by whichever came first and leave the other silent.
    local function announcer()
        local said = false
        return function()
            if said then return end
            said = true
            if NS.Print then NS.Print(missing) end
        end
    end
    local sayOnEnable, sayOnWindow = announcer(), announcer()
    local noop = function() end
    NS.DebugLog = {
        buffer          = {},
        Add             = noop,
        Debug           = noop,
        DebugOnce       = noop,
        DebugChanged    = noop,
        DebugForget     = noop,
        DebugAtEnable   = noop,
        Clear           = noop,
        Show            = sayOnWindow,
        Hide            = noop,
        Toggle          = sayOnWindow,
        IsShown         = function() return false end,
        IsEnabled       = function() return (NS.State and NS.State.debug) and true or false end,
        RefreshHeader   = noop,
        ShowCopy        = sayOnWindow,
        UpdateScrollBar = noop,
        UpdateStatus    = noop,
        BufferSize      = function() return 0 end,
        LastLine        = function() return nil end,
        FindLine        = function() return nil end,
        CopyText        = function() return "" end,
        MakeCloseButton = function() return nil end,
        Text            = function(_, key) return key end,
        SetEnabled      = function(_, on)
            on = not not on
            if NS.State then NS.State.debug = on end
            if NS.Print then NS.Print("debug logging " .. (on and "ON" or "OFF")) end
            if on then sayOnEnable() end
        end,
        ConsoleCheckbox = function()
            return {
                label   = "Debug console",
                tooltip = missing,
                get     = function() return false end,
                set     = sayOnWindow,
            }
        end,
        RunDiagnostics  = function()
            if NS.Print and NS.L then
                NS.Print(NS.L["%s is unavailable: the LibKa0s library did not load."]:format("/st diagnostics"))
            end
            return 0
        end,
        BuildDiagnostics = function() return { lines = {}, dropped = 0, capped = false, capsHit = false } end,
        -- The host's own routing of the debug words (the live DebugVerb's contract): `diagnostics`
        -- first, then `on` / `off`; any other word answers false and the caller toggles the window.
        DebugVerb       = function(self, rest)
            local word = (((rest or ""):match("^%s*(%S*)")) or ""):lower()
            if word == "diagnostics" then
                self:RunDiagnostics()
                return true
            end
            if word == "on" or word == "off" then
                self:SetEnabled(word == "on")
                return true
            end
            return false
        end,
    }
    NS.Debug         = NS.DebugLog.Debug
    NS.DebugOnce     = NS.DebugLog.DebugOnce
    NS.DebugChanged  = NS.DebugLog.DebugChanged
    NS.DebugAtEnable = NS.DebugLog.DebugAtEnable
    return
end

NS.DebugLog = lib:New({
    name      = addonName,       -- seeds the frame globals and the UISpecialFrames entries
    addonName = addonName,       -- the FOLDER the console's close / copy / clear marks are drawn from
    title     = NS.BRAND_NAME,
    font      = NS.Constants.FONT_MONO,
    slash     = "/st",

    -- The flag stays the ADDON's (debug-logging-§5): the library never stores a copy.
    isEnabled  = function() return (NS.State and NS.State.debug) and true or false end,
    setEnabled = function(on) if NS.State then NS.State.debug = on end end,

    -- Thin CALL-TIME forwarders: NS.Print is reclaimed from AceConsole's embed in a later file.
    print        = function(line) NS.Print(line) end,
    safeToString = function(v) return NS.SafeToString(v) end,

    initSummary = function()
        local addon = NS.addon
        if addon and addon.InitSummary then return addon:InitSummary() end
    end,

    -- So a console opened by `/st debug` moves the checkbox on an already-open settings panel.
    onVisibilityChanged = function()
        local H = NS.addon and NS.addon.Settings and NS.addon.Settings.Helpers
        if H and H.RefreshAll then H.RefreshAll() end
    end,

    -- The diagnostics dump (debug-logging-§14). `diagnostics` is read at RUN time, because
    -- modules/Diagnostics.lua loads after this file. A run turns debug logging on for the session.
    brandName   = NS.BRAND_NAME,
    diagnostics = function() return NS.Diagnostics and NS.Diagnostics.Sections() or {} end,
    L = {
        DIAG_WRITTEN = NS.L["Diagnostic report written to the debug console: %d lines. Use Copy to share it."],
    },
})

-- The gated sink and the console's gates, bound bare (debug-logging-§1, §8, §9).
NS.Debug         = NS.DebugLog.Debug
NS.DebugOnce     = NS.DebugLog.DebugOnce
NS.DebugChanged  = NS.DebugLog.DebugChanged
NS.DebugAtEnable = NS.DebugLog.DebugAtEnable
