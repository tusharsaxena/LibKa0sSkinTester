-- tests/test_skin_picker_preview.lua — the skin picker's preview, "window" mode (R6-PV; LibKa0s
-- OptionsSkinPicker minor 11, spec.preview; Ka0sAddonsCommonTasks docs/2026-11-03-SMOKE_ROUND6/,
-- the lead's call 2).
--
-- This addon has no test mode and no lock: its one surface is the showroom, so the picker's mode is
-- the showroom window itself. A picker that shows with the showroom closed opens it; the eye closes
-- and opens it; every close puts it back as it was when the picker opened. Each enter and exit goes
-- through NS.Showroom.Show and NS.Showroom.Hide, the calls `/st show`, the launcher's Show window
-- entry and the key binding use, so the stand-down refusal still applies. The library's own suite
-- holds the contract (tests/test_options_skin_picker_preview.lua there); this file holds the wiring.
local T = _G.SKINTESTER_TEST
local test, assertEqual, assertTrue, assertFalse = T.test, T.assertEqual, T.assertTrue, T.assertFalse

local PREFIX = "LibKa0sSkinPickerLibKa0sSkinTester"

local function picker(mock)
    for name, f in pairs(mock.frames) do
        if type(name) == "string" and name:sub(1, #PREFIX) == PREFIX then return f end
    end
end

local function up(mock)
    local f = picker(mock)
    return f ~= nil and f:IsShown() and true or false
end

local function click(btn) btn:GetScript("OnClick")(btn, "LeftButton") end

--- The spec the addon hands the library, caught on its way through O.SkinVerb.
local function spec(NS)
    local H = NS.addon.Settings.Helpers
    local live, given = H.SkinVerb, nil
    H.SkinVerb = function(s) given = s end
    NS.RunSkinVerb()
    H.SkinVerb = live
    return given
end

test("picker preview: the spec passes spec.preview in window mode, and no one-shot onPreview", function()
    -- red under: onPreview = function() NS.Showroom.Show() end, the enter-only eye.
    local NS = T.enableAddon()
    local s = spec(NS)
    assertEqual(type(s.preview), "table", "spec.preview is passed")
    assertEqual(s.preview.mode, "window")
    for _, k in ipairs({ "enter", "exit", "isActive", "isShown" }) do
        assertEqual(type(s.preview[k]), "function", k)
    end
    assertEqual(s.onPreview, nil, "the one-shot eye is gone")
    assertEqual(s.strings.PREVIEW_TIP, nil, "and its tooltip with it")
    assertEqual(s.strings.PREVIEW_WINDOW_ON, "Preview: the skin showroom is open. Click to close it.")
    assertEqual(s.strings.PREVIEW_WINDOW_OFF, "Preview: the skin showroom is closed. Click to open it.")
end)

test("picker preview: enter, exit and the reads go through the showroom's own seam", function()
    -- The same NS.Showroom calls the launcher's toggleWindow and isWindowShown make, read live.
    local NS = T.enableAddon()
    local p = spec(NS).preview
    local R, calls = NS.Showroom, {}
    local show, hide = R.Show, R.Hide
    R.Show = function() calls[#calls + 1] = "show"; return show() end
    R.Hide = function() calls[#calls + 1] = "hide"; return hide() end
    p.exit("eye")
    assertFalse(p.isActive(), "exit closed the showroom")
    assertFalse(p.isShown())
    p.enter("eye")
    assertTrue(p.isActive(), "enter opened it")
    assertTrue(p.isShown())
    R.Show, R.Hide = show, hide
    assertEqual(table.concat(calls, ","), "hide,show")
end)

test("picker preview: the first-run picker with the showroom closed opens it, the eye lit", function()
    -- red under: no show-time enter: the picker came up over an empty screen.
    local NS, _, mock = T.enableAddon()
    assertTrue(up(mock), "the first-run picker is up")
    assertTrue(NS.Showroom.IsShown(), "the showroom opened with it")
    assertTrue(picker(mock).preview.lit, "the eye is lit")
end)

test("picker preview: the eye closes the showroom and opens it again, the picker staying up", function()
    -- red under: the one-shot eye, whose second click re-showed a window already open.
    local NS, _, mock = T.enableAddon()
    local f = picker(mock)
    click(f.preview)
    assertFalse(NS.Showroom.IsShown(), "the eye closed it")
    assertFalse(f.preview.lit, "and is dimmed")
    assertTrue(up(mock), "the picker stays")
    click(f.preview)
    assertTrue(NS.Showroom.IsShown(), "the eye opened it again")
    assertTrue(f.preview.lit)
    assertTrue(up(mock))
end)

local ROUTES = {
    { "the close control", function(f) click(f.close) end },
    { "Escape",            function(f) f:Hide() end },
    { "Apply",             function(f) click(f.apply) end },
    { "the gear",          function(f) click(f.settings) end },
    { "HideSkinPicker",    function(_, NS) NS.addon.Settings.Helpers.HideSkinPicker() end },
    { "the stand-down",    function(_, NS) NS.StandDownSkinPicker() end },
}

for _, route in ipairs(ROUTES) do
    test("picker preview: " .. route[1] .. " closes the showroom the picker opened", function()
        -- red under: an eye and a show with no restore: the showroom stayed open after the close.
        local NS, _, mock = T.enableAddon()
        assertTrue(NS.Showroom.IsShown(), "opened by the picker")
        route[2](picker(mock), NS)
        assertFalse(up(mock), "the picker closed")
        assertFalse(NS.Showroom.IsShown(), "and the showroom is back to closed")
    end)
end

test("picker preview: a showroom already open is left open, and the close does not hide it", function()
    -- The showroom's own "Show the picker" button: the window is up before the picker.
    local NS, _, mock = T.enableAddon()
    click(picker(mock).close)
    assertFalse(NS.Showroom.IsShown())
    NS.Showroom.Show()
    assertTrue(NS.ShowSkinPicker(), "the picker is up again")
    assertTrue(NS.Showroom.IsShown(), "still open")
    click(picker(mock).close)
    assertFalse(up(mock))
    assertTrue(NS.Showroom.IsShown(), "the player's showroom stays open")
end)

test("picker preview: an eye that closed a showroom open at the start opens it again on close", function()
    local NS, _, mock = T.enableAddon()
    click(picker(mock).close)
    NS.Showroom.Show()
    NS.ShowSkinPicker()
    click(picker(mock).preview)
    assertFalse(NS.Showroom.IsShown(), "the eye closed it")
    click(picker(mock).close)
    assertTrue(NS.Showroom.IsShown(), "the close put it back as the picker found it")
end)

test("picker preview: a showroom the player closes while the picker is up stays closed", function()
    local NS, _, mock = T.enableAddon()
    NS.Showroom.Hide()
    click(picker(mock).close)
    assertFalse(NS.Showroom.IsShown(), "the close does not reopen it")
end)
