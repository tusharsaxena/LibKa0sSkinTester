-- tests/test_showroom.lua — the showroom window and its paint wrapper (ST-04).
--
-- Every sample in the showroom is painted through NS.Showroom.Paint, which calls the owner's facade and
-- records the primitive's name in NS.Showroom.used. That record is what the coverage suite reads, so a
-- sample painted around the wrapper is a sample the coverage claim cannot see. The skin assertions run
-- under the kit's paint recorder (tests/_kit/mock_paint.lua), installed before any source loads.

local T = _G.SKINTESTER_TEST
local test, assertEqual, assertTrue = T.test, T.assertEqual, T.assertTrue

local OWNER = "LibKa0sSkinTester"
local installPaint = dofile("tests/_kit/mock_paint.lua")

local function painted()
    return T.enableAddon{ mock = function(m) installPaint(m) end }
end

local function lib(mock) return mock.LibStub("LibKa0s-Skin-1.0") end
local function window(mock) return mock.frames["LibKa0sSkinTesterShowroom"] end

local function near(a, b) return type(a) == "number" and type(b) == "number" and math.abs(a - b) < 1e-6 end

--- The recorded color `got` (a { r, g, b, a } table) against the owner's token `name`.
local function assertToken(mock, got, name, what)
    assertTrue(type(got) == "table", what .. ": nothing was painted")
    local r, g, b = lib(mock):Color(OWNER, name)
    assertTrue(r ~= nil, what .. ": the skin has no " .. name)
    assertTrue(near(got[1], r) and near(got[2], g) and near(got[3], b),
        ("%s: %s,%s,%s is not %s (%s,%s,%s)"):format(what, tostring(got[1]), tostring(got[2]),
            tostring(got[3]), name, r, g, b))
end

test("showroom: the window is painted through the wrapper", function()
    local NS = T.enableAddon()
    NS.Showroom.Show()
    for _, name in ipairs({ "Shell", "TitleBar", "CloseButton", "Footer" }) do
        assertTrue(NS.Showroom.used[name] == true, name .. " went through NS.Showroom.Paint")
    end
end)

test("showroom: Paint answers the primitive's answer and records the name once", function()
    local NS = T.enableAddon()
    local seen
    NS.Skin.Probe = function(target, a) seen = { target, a }; return "answered" end
    assertEqual(NS.Showroom.Paint("Probe", "t", 7), "answered")
    assertEqual(seen[1], "t"); assertEqual(seen[2], 7)
    assertTrue(NS.Showroom.used.Probe, "recorded")
    NS.Skin.Probe = nil
end)

test("showroom: sections lay out in registration order, each under its title", function()
    local NS = T.enableAddon()
    local order = {}
    NS.Showroom.AddSection("zz_a", "Alpha", function(body, paint)
        order[#order + 1] = "a"
        paint("Panel", body)
        return 40
    end)
    NS.Showroom.AddSection("zz_b", "Beta", function() order[#order + 1] = "b"; return 10 end)
    NS.Showroom.Show()
    assertEqual(table.concat(order, ","), "a,b", "built once each, in order")
    local a, b = NS.Showroom.Section("zz_a"), NS.Showroom.Section("zz_b")
    assertEqual(a:GetHeight(), 40, "a section is as tall as its build answered")
    assertEqual(a.title:GetText(), "Alpha")
    assertTrue(NS.Showroom.used.Panel, "the build's paint is the wrapper")
    local _, _, _, _, yA = a:GetPoint(1)
    local _, _, _, _, yB = b:GetPoint(1)
    assertTrue(yB < yA, "the later section sits lower")
end)

test("showroom: a caption is muted text", function()
    local NS, _, mock = painted()
    NS.Showroom.Show()
    local fs = NS.Showroom.Caption(window(mock), "Button (primary)")
    assertEqual(fs:GetText(), "Button (primary)")
    assertToken(mock, mock.__paint(fs).textColor, "text.muted", "the caption")
end)

test("showroom: opened after a skin change, it wears the new skin", function()
    local NS, _, mock = painted()
    NS.Selector.Pick("ember")
    NS.Showroom.Show()
    assertToken(mock, mock.__paint(window(mock)).backdropColor, "win.bg", "the shell under ember")
end)

test("showroom: a skin change repaints the open window", function()
    -- red under: samples painted once, outside the library's record (a skin change would leave them).
    local NS, _, mock = painted()
    NS.Showroom.Show()
    local caption = NS.Showroom.Caption(window(mock), "sample")
    NS.Selector.Pick("contrast")
    assertToken(mock, mock.__paint(window(mock)).backdropColor, "win.bg", "the shell under contrast")
    assertToken(mock, mock.__paint(caption).textColor, "text.muted", "a caption under contrast")
    assertTrue(window(mock).footer.text:GetText():find("High Contrast", 1, true) ~= nil,
        "the footer names the skin worn")
end)
