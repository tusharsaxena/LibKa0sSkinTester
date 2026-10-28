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

test("showroom: a skin card's label keeps to one line under any skin's type size", function()
    -- The owner's round-5 showroom notes: High Contrast's larger type wrapped two cards' names onto a
    -- second line, over the swatches. The label never wraps, and a name wider than the card is
    -- scaled down to fit rather than cut.
    local NS = painted()
    NS.Showroom.Show()
    local sel = NS.Showroom.Selector()
    local wide, short = sel.cards.contrast.label, sel.cards.glass.label
    rawset(wide, "GetUnboundedStringWidth", function(self) return 172 * self:GetTextScale() end)
    rawset(short, "GetUnboundedStringWidth", function(self) return 40 * self:GetTextScale() end)
    NS.Selector.Pick("contrast")
    for _, card in ipairs(sel.order) do
        assertEqual(card.label:CanWordWrap(), false, card.key .. "'s label does not wrap")
        assertEqual(card.label:GetMaxLines(), 1, card.key .. "'s label is one line")
    end
    assertEqual(wide:GetTextScale(), 0.5, "a name twice the card's room is drawn at half size")
    assertEqual(short:GetTextScale(), 1, "a name that fits keeps its size")
    rawset(wide, "GetUnboundedStringWidth", function(self) return 60 * self:GetTextScale() end)
    NS.Selector.Pick("ka0s")
    assertEqual(wide:GetTextScale(), 1, "and a skin whose type fits puts the full size back")
end)

-- ST-03: the owner asked for a visible scrollbar, shown only when the sections overflow. The mock's
-- ScrollFrame has no scroll model, so each case gives it one: a range, a position and a setter that
-- fires OnVerticalScroll, as the client does.
local function scrollModel(f, range)
    local m = { range = range, y = 0 }
    rawset(f.scroll, "GetVerticalScrollRange", function() return m.range end)
    rawset(f.scroll, "GetVerticalScroll", function() return m.y end)
    rawset(f.scroll, "SetVerticalScroll", function(self, y) m.y = y; self.__fire("OnVerticalScroll", y) end)
    local bar = f.scrollBar
    rawset(bar, "SetMinMaxValues", function(_, lo, hi) m.lo, m.hi = lo, hi end)
    rawset(bar, "SetValue", function(self, v) m.value = v; self.__fire("OnValueChanged", v) end)
    return m
end

test("showroom scrollbar: hidden while the sections fit, shown once they overflow", function()
    local NS, _, mock = painted()
    NS.Showroom.Show()
    local f = window(mock)
    local m = scrollModel(f, 0)
    f.scroll.__fire("OnScrollRangeChanged")
    assertEqual(f.scrollBar:IsShown(), false, "no overflow, no bar")
    m.range = 900
    f.scroll.__fire("OnScrollRangeChanged")
    assertEqual(f.scrollBar:IsShown(), true, "an overflow shows the bar")
    assertEqual(m.lo, 0); assertEqual(m.hi, 900, "the bar's range is the scroll range")
    m.range = 0
    f.scroll.__fire("OnScrollRangeChanged")
    assertEqual(f.scrollBar:IsShown(), false, "and hides it again when the sections fit")
end)

test("showroom scrollbar: the wheel moves the sections and the knob together", function()
    local NS, _, mock = painted()
    NS.Showroom.Show()
    local f = window(mock)
    local m = scrollModel(f, 900)
    f.scroll.__fire("OnMouseWheel", -1)
    assertEqual(m.y, 60, "one notch down scrolls one step")
    assertEqual(m.value, 60, "and the knob follows")
    f.scrollBar.__fire("OnMouseWheel", -100)
    assertEqual(m.y, 900, "the wheel over the bar scrolls too, clamped to the range")
    f.scroll.__fire("OnMouseWheel", 100)
    assertEqual(m.y, 0, "and clamped at the top")
end)

test("showroom scrollbar: dragging the knob scrolls the sections, and a sync does not scroll back", function()
    local NS, _, mock = painted()
    NS.Showroom.Show()
    local f = window(mock)
    local m = scrollModel(f, 900)
    f.scrollBar.__fire("OnValueChanged", 450)
    assertEqual(m.y, 450, "a drag to the middle scrolls to the middle")
    local writes = 0
    rawset(f.scroll, "SetVerticalScroll", function() writes = writes + 1 end)
    f.scroll.__fire("OnScrollRangeChanged")
    assertEqual(writes, 0, "setting the bar from the scroll frame never writes the scroll back")
end)

test("showroom scrollbar: the corridor and the knob are the skin's", function()
    local NS, _, mock = painted()
    NS.Showroom.Show()
    local f = window(mock)
    assertToken(mock, mock.__paint(f.track).color, "scroll.track", "the corridor")
    NS.Selector.Pick("contrast")
    assertToken(mock, mock.__paint(f.track).color, "scroll.track", "the corridor under contrast")
    assertTrue(mock.__paint(f.thumb).shown ~= false, "the knob is drawn")
end)
