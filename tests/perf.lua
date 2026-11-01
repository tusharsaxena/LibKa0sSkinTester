#!/usr/bin/env lua
-- tests/perf.lua — the offline performance runner (performance-§9).
--
--   lua tests/perf.lua [--out <path>] [--label <text>]
--
-- DELIBERATELY OUTSIDE THE GREEN GATE: `lua tests/run.lua` never runs it, and no commit depends on
-- it. It asserts only deterministic quantities (API calls on the addon's own frames and bytes
-- allocated per iteration, each isolated by a full collect either side) and prints timings for
-- orientation only: compare scenarios within a run, never across machines.
--
-- The scenarios are the showroom's paths: opening and closing it, a skin change repainting it (the
-- `repaint` bucket's path, through the library's Skin:SetChoice), and the scale and opacity
-- reapply a slider drag drives. The one-off build is not measured; it happens once per session.

local Kit  = dofile("tests/_kit/framework.lua")
local mockf = dofile("tests/wow_mock.lua")

local opts = { out = nil, label = "offline" }
do
    local i = 1
    while arg and arg[i] do
        local a = arg[i]
        if a == "--out" then opts.out = arg[i + 1]; i = i + 2
        elseif a == "--label" then opts.label = arg[i + 1] or opts.label; i = i + 2
        else
            io.stderr:write("unknown argument: " .. tostring(a) .. "\n")
            io.stderr:write("usage: lua tests/perf.lua [--out <path>] [--label <text>]\n")
            os.exit(2)
        end
    end
end

-- ── environment ─────────────────────────────────────────────────────────────────────────────
--
-- The same instance factory every suite uses (tests/loader.lua), driven through the full in-game
-- lifecycle, so what is measured is the addon the client runs rather than a hand-assembled subset.

local loadAddon = dofile("tests/loader.lua")(".", mockf)
local NS, _, mock = loadAddon({})
NS.addon:OnInitialize()
NS.addon:OnEnable()

NS.Showroom.Show()            -- builds the window once, so no scenario measures the one-off build
NS.Showroom.Hide()

-- ── the API counting layer ──────────────────────────────────────────────────────────────────
--
-- Counted on the addon's OWN frames and their regions: the calls this addon makes into the client
-- per pass. Installed here rather than in tests/wow_mock.lua so the gated suite keeps measuring the
-- addon, not a counting shim.

local apiCalls = 0
local COUNTED = {
    "SetText", "SetFormattedText", "Show", "Hide", "SetPoint", "ClearAllPoints",
    "SetScale", "SetAlpha", "SetWidth", "SetHeight", "SetSize", "SetTexture",
    "SetVertexColor", "SetTextColor", "SetBackdrop", "SetBackdropColor", "SetBackdropBorderColor",
    "SetFont", "SetFontObject", "SetColorTexture",
}

-- Every wrap is recorded so it can be taken OFF again. The wrapper takes varargs, and a vararg call
-- allocates under Lua 5.1, so a byte figure measured with the shim installed is partly the shim's.
-- Each scenario is therefore measured TWICE: once with the wrappers on, for the API count, and once
-- with them off, for the bytes.
local wraps = {}

local function count(obj)
    if type(obj) ~= "table" or rawget(obj, "__perfCounted") then return end
    rawset(obj, "__perfCounted", true)
    for _, m in ipairs(COUNTED) do
        local orig = rawget(obj, m) or obj[m]
        if type(orig) == "function" then
            local wrapped = function(self, ...)
                apiCalls = apiCalls + 1
                return orig(self, ...)
            end
            rawset(obj, m, wrapped)
            wraps[#wraps + 1] = { obj = obj, method = m, orig = orig, wrapped = wrapped }
        end
    end
end

local function countingEnabled(on)
    for _, w in ipairs(wraps) do rawset(w.obj, w.method, on and w.wrapped or w.orig) end
end

-- Every frame the addon built, and every FontString and texture hanging off one. Walked from the
-- mock's registry rather than from a hand-kept list, so a sample added to the showroom is counted
-- without this file being edited.
local function countEverything()
    for _, f in ipairs(mock.frames) do
        count(f)
        for _, fs in ipairs(f.__fontStrings or {}) do count(fs) end
        for _, tx in ipairs(f.__textures or {}) do count(tx) end
        for _, kid in ipairs(f.__children or {}) do count(kid) end
    end
end
countEverything()

-- ── measurement ─────────────────────────────────────────────────────────────────────────────

local results, failures = {}, {}

local function assert_(cond, msg)
    if not cond then failures[#failures + 1] = msg end
    return cond
end

-- Two passes over the same closure, and the second one is the honest byte figure. Every scenario
-- here alternates between two states, so running it twice changes no conclusion. The collector is
-- stopped across the byte pass: a heavy scenario otherwise triggers collections mid-pass, and what
-- it reports is wherever the sawtooth stopped (skinRepaint read 9 KB to 47 KB across commits).
local function measure(name, iterations, fn)
    countingEnabled(true)
    collectgarbage("collect")
    collectgarbage("collect")
    apiCalls = 0
    for i = 1, iterations do fn(i) end
    local calls = apiCalls

    countingEnabled(false)
    collectgarbage("collect")
    collectgarbage("collect")
    collectgarbage("stop")
    local kbBefore = collectgarbage("count")
    local t0 = os.clock()
    for i = 1, iterations do fn(i) end
    local elapsed = os.clock() - t0
    local kbAfter = collectgarbage("count")
    collectgarbage("restart")
    countingEnabled(true)

    local r = {
        name = name, iterations = iterations,
        totalMs = elapsed * 1000, msPerIter = (elapsed * 1000) / iterations,
        apiCalls = calls, apiPerIter = calls / iterations,
        bytesPerIter = ((kbAfter - kbBefore) * 1024) / iterations,
    }
    results[#results + 1] = r
    return r
end

local N = 2000

-- 1. Opening and closing the built showroom: the toggle a key binding or `/st show` drives.
measure("showroomToggle", N, function()
    NS.Showroom.Toggle()
end)
NS.Showroom.Hide()

-- The mock's own Show and Hide record each call, and that record allocates. So the same flip on the
-- bare frame is measured, unreported, and the toggle's ceiling is charged only what is over it.
local mockFlipBytes
do
    local f = mock.frames["LibKa0sSkinTesterShowroom"]
    collectgarbage("collect")
    collectgarbage("collect")
    collectgarbage("stop")
    local kb = collectgarbage("count")
    for i = 1, N do if i % 2 == 0 then f:Hide() else f:Show() end end
    mockFlipBytes = ((collectgarbage("count") - kb) * 1024) / N
    collectgarbage("restart")
    f:Hide()
end

-- 2. A skin change with the showroom open: the `repaint` bucket's path, driven through the library's
--    Skin:SetChoice so the measured work is the repaint the player waits on. Alternates between two
--    skins so every iteration is a real change.
NS.Showroom.Show()
local SKINS = { "ka0s", "obsidian" }
local repaint = measure("skinRepaint", 500, function(i)
    NS.ApplySkinChoice("ka0s", SKINS[i % 2 + 1])
end)
assert_(repaint.apiPerIter > 0,
    "a skin change made no API call on the showroom: the repaint scenario measured nothing")
NS.ApplySkinChoice("ka0s", "ka0s")

-- 3. Settings writes, the path a player drags a slider along: scale and opacity, each a reapply.
local p = NS.addon.db.profile
local applyScale = measure("applyScale", N, function(i)
    p.scale = 0.8 + ((i % 40) / 100)
    NS.Showroom.ApplyWindowSettings()
end)
local applyAlpha = measure("applyAlpha", N, function(i)
    p.alpha = 0.6 + ((i % 40) / 100)
    NS.Showroom.ApplyWindowSettings()
end)
for _, r in ipairs({ applyScale, applyAlpha }) do
    assert_(r.apiPerIter <= 2,
        ("%s made %.1f API calls, expected at most 2 (SetScale, SetAlpha)"):format(r.name, r.apiPerIter))
end
NS.Showroom.Hide()

-- ── ceilings ────────────────────────────────────────────────────────────────────────────────
--
-- The toggle and the reapply change no string and build no table, so they must allocate nothing:
-- those ceilings are hard (the toggle's over the mock's own flip, measured above). The repaint is
-- pinned, in bytes and in API calls, at the figure measured on 2026-11-01 with the collector stopped
-- (221860.8 bytes, 1360 calls, SF-ST-2: +200 calls and +575 bytes over the 1160 and 221285.9 of SF-FIX, measured at SF-FIX and at SF-ST-2, the Blizzard dropdown painted by the library's own WowStyle1 path in place of the sample's stock list and glyph). It is not derived from this run: a ceiling
-- computed from its own measurement cannot fail, and skinRepaint read that way while it rose from 12
-- to 1083 API calls per change.
--
-- Why that much is justified. The API count tracks the sections: 430 at the first showroom, 544, 614,
-- 756, 826, 1034, then 1083 across the merges, each adding samples, then 1085 at the LibKa0s v1.84.0
-- re-vendor: WidgetsDragHandle minor 10 clears the measurer's text and sets its host's scale on each
-- fit, and the showroom's one strip re-fits after every repaint; then 1092 with the dropdown samples (ST-D1), 1127 at the LibKa0s v1.85.0 re-vendor with its HUD and Mark samples (FS-ST-RV, measured on an export of that commit), and 1153 with cause A5's samples repainted (FS-ST-FIX). Then 1160 and 221285.9 bytes with the Source dropdown (SF-ST-1, 21540ee): measured 1151 calls and 220229.9 bytes at 21540ee^ and 1160 and 221285.9 at it, +9 calls and +1056 bytes, the one widget's sample repainted; the layout move to its own row changes neither. About 87% of the bytes are
-- the library's Skin:Repaint walking every recorded frame; the addon's own OnLooksChanged redraws are
-- about 20 KB. A skin change is one click, not a per-frame path.
--
-- Raise a ceiling only by re-measuring and saying why; a rise IS the finding. A LibKa0s re-vendor or a
-- new sample moves the repaint's figures, so that is the moment to re-measure and re-pin them.
local REPAINT_MAX_BYTES, REPAINT_MAX_API = 221880, 1360
assert_(repaint.apiPerIter <= REPAINT_MAX_API,
    ("skinRepaint made %.1f API calls, over its pinned %d"):format(repaint.apiPerIter, REPAINT_MAX_API))
local CEILINGS = {
    showroomToggle = math.floor(mockFlipBytes + 0.5) + 24,
    skinRepaint    = REPAINT_MAX_BYTES,
    applyScale     = 24,
    applyAlpha     = 24,
}
for _, r in ipairs(results) do
    local ceiling = CEILINGS[r.name]
    if ceiling then
        assert_(r.bytesPerIter <= ceiling,
            ("%s allocated %.1f bytes/iter, over its %d-byte ceiling"):format(
                r.name, r.bytesPerIter, ceiling))
    end
end

-- ── report ──────────────────────────────────────────────────────────────────────────────────

print(("Ka0s Skin Tester \226\128\148 offline perf  (v%s, label '%s')"):format(
    tostring(NS.addon.VERSION or "?"), opts.label))
print()
-- Five columns, exactly: tests/_kit/run-automated-tests.sh counts scenarios structurally as the
-- five-field rows under this header, so a sixth column makes every row invisible to it.
print(("%-20s %8s %11s %9s %11s"):format("scenario", "iters", "ms/iter", "api/iter", "bytes/iter"))
for _, r in ipairs(results) do
    print(("%-20s %8d %11.5f %9.1f %11.1f"):format(
        r.name, r.iterations, r.msPerIter, r.apiPerIter, r.bytesPerIter))
end
print()
print("timings are for orientation only \226\128\148 compare scenarios within a run, never across machines")
if #failures > 0 then
    print()
    print(("%d assertion%s FAILED:"):format(#failures, #failures == 1 and "" or "s"))
    for _, f in ipairs(failures) do print("  - " .. f) end
end

-- ── the record ──────────────────────────────────────────────────────────────────────────────

if opts.out then
    local buckets = {}
    for _, r in ipairs(results) do
        buckets[r.name] = { calls = r.iterations, totalMs = r.totalMs, maxMs = r.msPerIter,
                            apiPerIter = r.apiPerIter, bytesPerIter = r.bytesPerIter }
    end
    local fh, err = io.open(opts.out, "w")
    if not fh then
        io.stderr:write("cannot write " .. opts.out .. ": " .. tostring(err) .. "\n")
        os.exit(2)
    end
    fh:write(NS.Perf.EncodeJSON({
        schema = 1, addon = "LibKa0sSkinTester", source = "offline",
        version = tostring(NS.addon.VERSION or "?"), interface = 0, timestamp = os.time(),
        label = opts.label, buckets = buckets, failures = failures,
    }), "\n")
    fh:close()
    print("wrote " .. opts.out)
end

local _ = Kit   -- the kit is loaded for parity with the suite's environment, not called here

os.exit(#failures == 0 and 0 or 1)
