-- tests/test_showroom_values.lua — the Values section (ST-06): what the getters answer, every
-- semantic color and every item quality tier (ST-01 of the skinning rollout), each category under its
-- own heading, displayed and redrawn on a skin change.

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

test("values: the two token categories each have a heading, in the heading role", function()
    local NS, mock = opened()
    local r, g, b = mock.LibStub("LibKa0s-Skin-1.0"):Color(OWNER, "text.heading")
    for key, text in pairs({ sem = "Semantic colors (sem.*)", q = "Quality tiers (q.*)" }) do
        local head = NS.Values.heads[key]
        assertTrue(head ~= nil, key .. " has a heading")
        assertEqual(head:GetText(), text)
        local got = mock.__paint(head).textColor
        assertTrue(near(got[1], r) and near(got[2], g) and near(got[3], b), key .. "'s heading is text.heading")
    end
end)

test("values: every quality tier in the schema has a line, poor to legendary", function()
    -- red under: a Values section that lists sem.* only.
    local NS, mock = opened()
    local want = {}
    for _, entry in ipairs(mock.LibStub("LibKa0s-Skin-1.0").SCHEMA) do
        if entry.name:find("^q%.") then want[#want + 1] = entry.name end
    end
    assertEqual(table.concat(want, ","), "q.poor,q.common,q.uncommon,q.rare,q.epic,q.legendary")
    for _, key in ipairs(want) do
        assertTrue(NS.Values.tiers[key] ~= nil, key .. " has a line")
    end
    local n = 0
    for _ in pairs(NS.Values.tiers) do n = n + 1 end
    assertEqual(n, #want, "one line per tier, and nothing else")
end)

test("values: each tier line wears its own color, and follows a skin change", function()
    local NS, mock = opened()
    local Skin = mock.LibStub("LibKa0s-Skin-1.0")
    local function check(skin)
        for key, tier in pairs(NS.Values.tiers) do
            local r, g, b = Skin:Color(OWNER, key)
            assertTrue(r ~= nil, skin .. " resolves " .. key)
            assertEqual(tier.text:GetText(), key)
            local got = mock.__paint(tier.text).textColor
            assertTrue(near(got[1], r) and near(got[2], g) and near(got[3], b), skin .. ": " .. key .. "'s label")
            local sw = mock.__paint(tier.swatch).color
            assertTrue(near(sw[1], r) and near(sw[2], g) and near(sw[3], b), skin .. ": " .. key .. "'s swatch")
        end
    end
    check("ka0s")
    NS.Selector.Pick("ember")
    check("ember")
end)

test("values: a tier the skin leaves unset reads none, with no swatch", function()
    -- The schema lets a skin leave a tier nil (the client's own color stands); every shipped skin sets
    -- all six, so the read is stubbed for one tier around a redraw.
    local NS, mock = opened()
    local Skin = mock.LibStub("LibKa0s-Skin-1.0")
    local color = Skin.Color
    Skin.Color = function(self, owner, name)
        if name == "q.poor" then return nil end
        return color(self, owner, name)
    end
    NS.Selector.Pick("glass")
    Skin.Color = color
    local tier = NS.Values.tiers["q.poor"]
    assertEqual(tier.text:GetText(), "q.poor: none")
    assertTrue(mock.__paint(tier.swatch).shown == false, "the swatch is hidden")
    local r, g, b = Skin:Color(OWNER, "text.muted")
    local got = mock.__paint(tier.text).textColor
    assertTrue(near(got[1], r) and near(got[2], g) and near(got[3], b), "the label is muted text")
end)
