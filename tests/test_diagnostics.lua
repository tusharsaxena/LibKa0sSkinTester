-- tests/test_diagnostics.lua — this addon's sections of `/st diagnostics` (debug-logging-§14).
--
-- The report's contract (both forms, while disabled, append, the markers, logging turned on) is the
-- kit's test_diagnostics_contract suite, run against this addon's dispatcher. What is pinned here is
-- what only this addon knows: its sections, and that they read state without acting on it.

local T = _G.SKINTESTER_TEST
local test, assertEqual, assertTrue, assertFalse = T.test, T.assertEqual, T.assertTrue, T.assertFalse

local BEGIN = "[Diag] ==== Ka0s Skin Tester diagnostics begin ===="

local function report(NS, input)
    NS.addon:OnSlashCommand(input or "diagnostics")
    local buf, first = NS.DebugLog.buffer, nil
    for i = #buf, 1, -1 do
        if buf[i]:find(BEGIN, 1, true) then first = i break end
    end
    assertTrue(first ~= nil, "a report was written")
    local out = {}
    for i = first, #buf do out[#out + 1] = buf[i] end
    return out
end

local function has(lines, needle)
    for _, l in ipairs(lines) do if l:find(needle, 1, true) then return true end end
    return false
end

local function count(lines, needle)
    local n = 0
    for _, l in ipairs(lines) do if l:find(needle, 1, true) then n = n + 1 end end
    return n
end

-- ── the sections ─────────────────────────────────────────────────────────────────────────────

test("diagnostics: identity names schema, profile, enabled, stood-down and the holds", function()
    local NS = T.enableAddon()
    local lines = report(NS)
    assertTrue(has(lines, "schema stored=1 code=1"), "both schema versions")
    assertTrue(has(lines, "profile=Default"), "the active profile")
    assertTrue(has(lines, "enabled=true stoodDown=false"), "the switch and the latch")
    assertTrue(has(lines, "holds"), "the holds line")
end)

test("diagnostics: the always rows print at default, and a changed row prints with its default", function()
    local NS = T.enableAddon()
    NS.addon.Settings.Helpers.Set("scale", 1.5)
    local lines = report(NS)
    assertTrue(has(lines, "enabled"), "enabled, always")
    assertTrue(has(lines, "skin.skin"), "the skin, always")
    assertTrue(has(lines, "scale = 1.5"), "the changed row")
end)

test("diagnostics: the skin section names the engine, the stored and applied skin, and the skins", function()
    local NS = T.enableAddon()
    NS.addon.Settings.Helpers.Set("skin.skin", "obsidian")
    local lines = report(NS)
    assertTrue(has(lines, "skin engine=6"), "the skin engine's minor")
    assertTrue(has(lines, "stored=ka0s:obsidian applied=ka0s:obsidian"), "stored and applied agree")
    assertTrue(has(lines, "owner=true pendingReload=false"), "the owner registration")
    assertTrue(has(lines, "obsidian"), "and the skins are listed")
end)

test("diagnostics: the showroom section reads the window and never builds it", function()
    -- red under: a section that calls NS.Showroom.Show to report on it.
    local NS, _, mock = T.enableAddon()
    local lines = report(NS)
    assertTrue(has(lines, "showroom: built=false shown=false"), "an unbuilt window reads as such")
    assertTrue(mock.frames["LibKa0sSkinTesterShowroom"] == nil, "and the report built nothing")
    NS.Showroom.Show()
    lines = report(NS)
    assertTrue(has(lines, "showroom: built=true shown=true"), "a shown window reads as such")
end)

test("diagnostics: the report reads and never acts: no registration, hold, timer or save", function()
    local NS, _, mock = T.enableAddon()
    NS.addon.Settings.Helpers.Set("enabled", false)
    local regs, timers = #mock.__registrations(), #mock.__timers()
    local holds = table.concat(NS.Lifecycle:Holds(), ",")
    mock.__resetSvWrites()
    report(NS)
    assertEqual(#mock.__registrations(), regs, "no event registered")
    assertEqual(#mock.__timers(), timers, "no timer armed")
    assertEqual(table.concat(NS.Lifecycle:Holds(), ","), holds, "no hold taken or released")
    assertEqual(#mock.__svWrites(), 0, "nothing written to SavedVariables")
    assertTrue(NS.IsStoodDown(), "and the addon is still down")
end)

test("diagnostics: a raising section costs exactly one line, and the report still ends", function()
    -- red under: sections run outside the library's per-section pcall.
    local NS = T.enableAddon()
    NS.Showroom.Snapshot = function() error("boom") end
    local lines = report(NS)
    assertEqual(count(lines, "section showroom failed:"), 1, "one line for the raise")
    assertTrue(has(lines, "rejected events"), "the section after it still ran")
    assertTrue(lines[#lines]:find("diagnostics end:", 1, true) ~= nil, "and the end marker is last")
end)

test("diagnostics: an over-cap report ends `truncated`, then the end marker", function()
    local NS = T.enableAddon()
    NS.DebugLog:RunDiagnostics({ maxLines = 8 })
    local buf = NS.DebugLog.buffer
    assertTrue(buf[#buf - 1]:find("truncated:", 1, true) ~= nil, "the truncated line")
    assertTrue(buf[#buf]:find("diagnostics end: 8 line(s)", 1, true) ~= nil, "then the end marker")
end)

-- ── the chat lines ───────────────────────────────────────────────────────────────────────────

local function writtenLine(n)
    return "Diagnostic report written to the debug console: " .. n .. " lines. Use Copy to share it."
end

test("diagnostics: with logging off, the enable ack then one localized chat line", function()
    local NS, _, mock = T.enableAddon()
    assertFalse(NS.DebugLog:IsEnabled(), "logging starts off")
    local mark = #mock.prints
    local lines = report(NS)
    assertEqual(#mock.prints - mark, 2, "the enable ack, then the report line")
    assertTrue(mock.prints[#mock.prints]:find(writtenLine(#lines), 1, true) ~= nil)
    assertTrue(NS.DebugLog:IsEnabled(), "and logging is on for the session")
end)

test("diagnostics: with logging already on, exactly one chat line", function()
    local NS, _, mock = T.enableAddon()
    NS.DebugLog:SetEnabled(true)
    local mark = #mock.prints
    local lines = report(NS)
    assertEqual(#mock.prints - mark, 1, "exactly one chat line")
    assertTrue(mock.prints[#mock.prints]:find(writtenLine(#lines), 1, true) ~= nil)
end)

test("diagnostics: without LibKa0s-DebugLog both forms print the library-absent line, writing nothing", function()
    -- red under: the stub's DebugVerb answering false for `diagnostics`, which toggles the window.
    local NS, _, mock = T.enableAddon{
        skip = { "libs/LibKa0s/DebugLog.lua", "libs/LibKa0s/DebugLogDiagnostics.lua" },
    }
    for _, form in ipairs({ "diagnostics", "debug diagnostics" }) do
        local mark = #mock.prints
        NS.addon:OnSlashCommand(form)
        assertEqual(#mock.prints - mark, 1, form .. " answers one line")
        assertTrue(mock.prints[#mock.prints]:find(
            "/st diagnostics is unavailable: the LibKa0s library did not load.", 1, true) ~= nil)
    end
    assertEqual(#NS.DebugLog.buffer, 0, "and nothing was written")
end)
