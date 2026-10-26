local addonName, NS = ...
-- core/CoreSetup.lua — NS.Util.print and the window chrome from LibKa0s-Core-1.0; every tagged chat
-- line leaves through here.
--
-- LOAD-BEARING: after core/Namespace.lua (NS.PREFIX, NS.LIBKA0S_MISSING) and before every file
-- that prints. It publishes onto NS.Util.print rather than NS.Print, because AceAddon:NewAddon(NS,
-- ..., "AceConsole-3.0") stamps AceConsole's :Print over the namespace; core/LibKa0sSkinTester.lua
-- reclaims NS.Print by pointing it at this same function object (architecture-§2).

NS.Util = NS.Util or {}

-- The host owns the rejected-event list; the library keeps no state (events-frames-taint-§1). The
-- [Init] summary and the diagnostics report surface it.
NS.RejectedEvents = NS.RejectedEvents or {}

local lib = LibStub and LibStub("LibKa0s-Core-1.0", true)

if not lib then
    -- Degrade, never error. Every chat line goes through NS.Util.print, so it must work, and the
    -- "not installed" sentence is said once, on the first line printed.
    local function probeConcat(v) return table.concat({ v }) end
    function NS.IsConcatSafe(v) return (pcall(probeConcat, v)) end
    function NS.SafeToString(v)
        if v == nil then return "nil" end
        if type(v) == "boolean" then return tostring(v) end
        if NS.IsConcatSafe(v) then return tostring(v) end
        return "<secret>"
    end

    local announced = false
    function NS.Util.print(...)
        if not announced then
            announced = true
            print(NS.PREFIX, NS.LIBKA0S_MISSING .. "; running on reduced built-in fallbacks.")
        end
        local parts = {}
        for i = 1, select("#", ...) do parts[i] = NS.SafeToString((select(i, ...))) end
        print(NS.PREFIX, table.concat(parts, " "))
    end
    -- The parity half of the printer surface: published on both branches so a caller added later
    -- works on a degraded install too.
    function NS.Util.format(fmt, ...)
        local parts = {}
        for i = 1, select("#", ...) do parts[i] = NS.SafeToString((select(i, ...))) end
        if #parts == 0 then return NS.Util.print(fmt) end
        NS.Util.print(NS.SafeToString(fmt):format(unpack(parts)))
    end

    -- The chrome degrades to NOTHING rather than to a hand-copied backdrop: Core.SKIN's values are
    -- the contract (standalone-windows), and a host copy of them is the copy that goes stale.
    NS.SKIN            = {}
    NS.ApplySkin       = function() end
    NS.MakeCloseButton = function() return nil end

    -- The pcalled registration as a one-rung body (the Core API document's Degradation section):
    -- the pcall and the once-only rejected-list append.
    function NS.SafeRegisterEvent(target, event, handler, rejected)
        local ok = pcall(target.RegisterEvent, target, event, handler)
        if not ok and type(rejected) == "table" then
            for i = 1, #rejected do
                if rejected[i] == event then return false end
            end
            rejected[#rejected + 1] = event
        end
        return ok
    end
    return
end

NS.IsConcatSafe = lib.IsConcatSafe
NS.SafeToString = lib.SafeToString

-- The one pcalled event registration (events-frames-taint-§1). Only this member of the three is
-- published: the tester registers no unit events and walks no event list, and
-- tests/test_surface_parity.lua compares the live and degraded namespaces.
NS.SafeRegisterEvent = lib.SafeRegisterEvent

-- The window chrome seam (standalone-windows): the library's table, not a copy.
NS.SKIN      = lib.SKIN
NS.ApplySkin = lib.ApplySkin

-- WRAPPED, TO SAY WHO IS ASKING (a MUST, standalone-windows). Core draws the catalog's `close` mark
-- only when it is told the addon FOLDER to build the texture path from, and a vendored copy cannot
-- know which folder it landed in. Every close control the addon builds comes through here:
--   grep -rn 'MakeCloseButton(' --include='*.lua' . | grep -v '/libs/'
-- returns this definition and calls to NS.MakeCloseButton, and nothing else.
NS.MakeCloseButton = function(parent, onClick)
    return lib.MakeCloseButton(parent, onClick, addonName)
end

-- The prefix goes in as a FUNCTION, re-read on every call. `sink` is the Lua global `print`, which
-- the headless harness captures (Core's default is DEFAULT_CHAT_FRAME:AddMessage).
local printer = lib:New({
    prefix = function() return NS.PREFIX end,
    sink   = function(line) print(line) end,
})

NS.Util.print  = printer.Print
NS.Util.format = printer.Format
