local addonName, NS = ...
-- core/LifecycleSetup.lua — the stand-down latch (slash-commands-§7): one LibKa0s-Lifecycle-1.0
-- instance and the one refusal helper.
--
-- TWO HOLDS ON ONE LATCH. `disabled` follows the stored `enabled` path; `perf` is taken by the
-- performance harness while a capture runs (core/PerfSetup.lua hands it this instance). The addon
-- is down while either is held, and the teardown both reach is NS.StandDown in
-- core/LibKa0sSkinTester.lua: one mechanism, so the two cannot drift about what "inert" means.
--
-- LOAD-BEARING: before core/PerfSetup.lua, which passes NS.Lifecycle to LibKa0s-Perf-1.0 at file
-- load. The callbacks resolve NS.StandDown / NS.StandUp at CALL time, and the first call is from
-- OnEnable, after every file has loaded.

local lib = LibStub and LibStub("LibKa0s-Lifecycle-1.0", true)

--- True while any hold is held.
function NS.IsStoodDown()
    return NS.Lifecycle ~= nil and NS.Lifecycle:IsDown() == true
end

--- The one refusal helper: the line a stood-down feature prints, or nil while standing up. The
--- `disabled` hold answers the dispatcher's own disabled line; the `perf` hold alone answers the
--- capture line, never the disabled one (slash-commands-§7, Which refusal, by hold).
function NS.StandDownRefusal()
    local latch = NS.Lifecycle
    if latch == nil or latch:IsDown() ~= true then return nil end
    if latch:IsHeld(NS.HOLD_DISABLED) then return NS.SlashCommands:DisabledLine() end
    return NS.L["Not available during a performance capture."]
end

if not lib then
    -- Degrade, never error: a set of held keys and the same edge rule, so `/st disable` still stands
    -- the addon down on an install missing the library. Every member the addon and the harness stub
    -- call is answered.
    local held, down = {}, false
    local function reevaluate()
        local anyHeld = next(held) ~= nil
        if anyHeld == down then return false end
        down = anyHeld
        if down then NS.StandDown() else NS.StandUp() end
        return true
    end
    NS.Lifecycle = {
        name    = addonName,
        Hold    = function(_, key) held[key] = true; return reevaluate() end,
        Release = function(_, key) held[key] = nil;  return reevaluate() end,
        Set     = function(self, key, on) if on then return self:Hold(key) end return self:Release(key) end,
        IsHeld  = function(_, key) return held[key] == true end,
        IsDown  = function() return down end,
        Holds   = function()
            local out = {}
            for k in pairs(held) do out[#out + 1] = k end
            table.sort(out)
            return out
        end,
        Reevaluate = function() return reevaluate() end,
        PrintHolds = function() return false end,
    }
    NS.HOLD_DISABLED = "disabled"
    NS.HOLD_PERF     = "perf"
    return
end

NS.HOLD_DISABLED = lib.HOLD_DISABLED
NS.HOLD_PERF     = lib.HOLD_PERF

-- The edges are logged by the LIBRARY through `debug` (Lifecycle minor 3): one `[Lifecycle]` line
-- per stand-down and stand-up, naming the holds. The callbacks write no edge line of their own
-- (debug-logging-§8).
NS.Lifecycle = lib:New({
    name      = addonName,
    standDown = function() NS.StandDown() end,
    standUp   = function() NS.StandUp() end,
    print     = function(line) NS.Print(line) end,
    debug     = function(tag, message) NS.Debug(tag, message) end,
})
