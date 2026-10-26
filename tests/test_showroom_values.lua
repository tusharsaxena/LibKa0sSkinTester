-- tests/test_showroom_values.lua — the Values section (ST-06): what the getters answer, and every
-- semantic color, displayed and redrawn on a skin change.

local T = _G.SKINTESTER_TEST
local test, assertEqual, assertTrue = T.test, T.assertEqual, T.assertTrue

local OWNER = "LibKa0sSkinTester"
local installPaint = dofile("tests/_kit/mock_paint.lua")
local GETTERS = { "GetAccentColor", "GetPanelColor", "GetFont", "GlowColor", "ChartStyle", "BarStyle" }

local function opened()
    local NS, _, mock = T.enableAddon{ mock = function(m) installPaint(m) end }
    NS.Showroom.Show()
    return NS, mock
end

local function semKeys(mock)
    local Skin, n = mock.LibStub("LibKa0s-Skin-1.0"), 0
    local _, key = Skin:GetChoice(OWNER)
    for k in pairs(Skin:ResolveSkin(key)) do
        if k:find("^sem%.") then n = n + 1 end
    end
    return n
end

local function near(a, b) return type(a) == "number" and math.abs(a - b) < 1e-6 end

test("values: every getter is displayed", function()
    local NS = opened()
    for _, name in ipairs(GETTERS) do
        assertTrue(NS.Values.shown[name] == true, name .. " is displayed")
    end
end)

test("values: every sem token has a line", function()
    local NS, mock = opened()
    local lines = 0
    for key in pairs(NS.Values.lines) do
        assertTrue(key:find("^sem%.") ~= nil, key)
        lines = lines + 1
    end
    assertEqual(lines, semKeys(mock), "one line per sem token")
    assertTrue(lines >= 20, "the resolved table carries the semantic colors")
end)

test("values: a skin change redraws them", function()
    local NS, mock = opened()
    NS.Selector.Pick("azeroth")
    local r, g, b = mock.LibStub("LibKa0s-Skin-1.0"):Color(OWNER, "sem.good")
    local line = NS.Values.lines["sem.good"]
    local got = mock.__paint(line.text).textColor
    assertTrue(near(got[1], r) and near(got[2], g) and near(got[3], b), "the label wears azeroth's sem.good")
    local sw = mock.__paint(line.swatch).color
    assertTrue(near(sw[1], r) and near(sw[2], g) and near(sw[3], b), "and so does the swatch")
end)
