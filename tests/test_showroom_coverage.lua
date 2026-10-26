-- tests/test_showroom_coverage.lua — the showroom's claim: every name in the skin's vocabulary is on
-- show (ST-05, ST-06).
--
-- A paint primitive counts when a sample was painted with it through NS.Showroom.Paint (the record
-- NS.Showroom.used); a getter counts when the values section displays what it answers
-- (NS.Values.shown). The vocabulary is the live library's lib.VOCAB, so a primitive added upstream
-- turns this red until the showroom shows it.

local T = _G.SKINTESTER_TEST
local test, assertTrue, assertEqual = T.test, T.assertTrue, T.assertEqual

local function opened(opts)
    local NS, _, mock = T.enableAddon(opts)
    NS.Showroom.Show()
    return NS, mock
end

test("showroom: every lib.VOCAB name is shown", function()
    local NS, mock = opened()
    local shown = NS.Values and NS.Values.shown or {}
    local missing = {}
    for _, name in ipairs(mock.LibStub("LibKa0s-Skin-1.0").VOCAB) do
        if not (NS.Showroom.used[name] or shown[name]) then missing[#missing + 1] = name end
    end
    assertEqual(#missing, 0, "not shown: " .. table.concat(missing, ", "))
end)

test("showroom: every section is built and none is empty", function()
    local NS = opened()
    for _, key in ipairs({ "chrome", "controls", "lists", "text", "panels", "overlays" }) do
        local sec = NS.Showroom.Section(key)
        assertTrue(sec ~= nil, key .. " is built")
        assertTrue((sec:GetHeight() or 0) > 0, key .. " has a height")
    end
end)

test("showroom: the tabs sample moves its selection on a click", function()
    local NS = opened()
    local tabs = NS.Showroom.Section("chrome").tabs
    assertEqual(#tabs, 3)
    tabs[3]:GetScript("OnClick")(tabs[3], "LeftButton")
    for i, tab in ipairs(tabs) do assertEqual(tab.selected, i == 3, "tab " .. i) end
end)

test("showroom: the sections build without the library's widgets", function()
    -- red under: a section that indexes LibKa0s-Widgets-1.0 without checking it loaded.
    local NS = opened{ skip = { "libs/LibKa0s/Widgets.lua" } }
    assertTrue(NS.Showroom.Section("controls") ~= nil, "controls still builds")
end)
