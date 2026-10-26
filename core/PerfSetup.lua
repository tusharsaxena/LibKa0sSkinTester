local addonName, NS = ...
-- core/PerfSetup.lua — the LibKa0s-Perf-1.0 seam (performance). The probe, the step panel, the
-- capture ring and the report are the library's; this file says which paths get buckets and where
-- output goes.
--
-- LOAD-BEARING: after core/LifecycleSetup.lua (the harness takes its `perf` hold on NS.Lifecycle,
-- handed over at :New) and before the # Modules block, whose files take `local Perf = NS.Perf` at
-- file scope.
--
-- THE TWO HOT PATHS a skin tester has: building the showroom's samples (once per window) and
-- repainting them on a skin change, which repaints every sample the window shows. Both are
-- bracketed in modules/Showroom.lua with the gated `Perf.on and debugprofilestop()` form
-- (performance-§2), so with capture off each costs one field read and one boolean test.

local lib = LibStub and LibStub("LibKa0s-Perf-1.0", true)

if not lib then
    -- Degrade, never error. Every member the addon calls: the bracket gate and sink, `suspended`,
    -- and OnCommand, because `/st perf` is registered unconditionally.
    NS.Perf = {
        on        = false,
        suspended = false,
        Note      = function() end,
        OnCommand = function()
            return { NS.LIBKA0S_MISSING .. ", so performance measurement is unavailable." }
        end,
    }
    return
end

NS.Perf = lib:New({
    name      = addonName,
    -- The FOLDER name the panel's close control builds its texture path from (performance-§4).
    addonName = addonName,
    title     = NS.BRAND_NAME,
    slash     = "/st",
    version   = NS.Version and NS.Version() or nil,
    sv        = addonName .. "PerfDB",

    -- Report order (performance-§3); both are brackets in modules/Showroom.lua.
    buckets = {
        { key = "build" },     -- the showroom's first build, every section
        { key = "repaint" },   -- one skin change's repaint of the showroom
    },

    -- The harness takes the `perf` hold on the one latch (Perf minor 8); NS.Perf.suspended is a
    -- view of it, never a second boolean.
    lifecycle = NS.Lifecycle,

    -- Not gated on NS.State.debug: a perf run is an explicit act, and a console that stayed empty
    -- while a capture ran would read as a broken harness.
    log = function(line)
        if NS.DebugLog and NS.DebugLog.Add then
            NS.DebugLog:Add("Perf", line)
        else
            NS.Print(line)
        end
    end,
    print   = function(line) NS.Print(line) end,
    showLog = function()
        if NS.DebugLog and NS.DebugLog.Show and not NS.DebugLog:IsShown() then NS.DebugLog:Show() end
    end,
    -- No `decorate`: the library draws the panel's close control from addonName (anti-pattern #65).
})
