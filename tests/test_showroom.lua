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

-- ── cause A5 of Ka0sAddonsCommonTasks docs/2026-11-01-FULL_SKINNING: every sample tells the truth ──

local function opened()
    local NS, _, mock = painted()
    NS.Showroom.Show()
    return NS, mock
end

local function shadowed(obj, method)
    local calls, real = {}, obj[method]
    rawset(obj, method, function(self, ...)
        calls[#calls + 1] = { ... }
        return real(self, ...)
    end)
    return calls
end

test("a5: the hover tooltip is a frame of this addon's, in tooltip.* and gtip.*", function()
    local NS, mock = opened()
    local tip = NS.Showroom.sampleTooltip
    assertTrue(tip ~= nil and mock.__paint(tip).frameType ~= "GameTooltip", "never a GameTooltip")
    local Skin = mock.LibStub("LibKa0s-Skin-1.0")
    local t = Skin:ResolveSkin("obsidian")
    NS.Selector.Pick("obsidian")
    local bd = { tip:GetBackdropColor() }
    assertEqual(bd[1], t["tooltip.bg"][1], "the frame wears tooltip.bg")
    local title, line = shadowed(tip.title, "SetTextColor"), shadowed(tip.line, "SetTextColor")
    NS.Showroom.Section("overlays").tipButton:GetScript("OnEnter")(NS.Showroom.Section("overlays").tipButton)
    assertToken(mock, title[#title], "gtip.title", "the title")
    assertToken(mock, line[#line], "gtip.value", "the line")
end)

test("a5: the ApplyBarFill sample draws the skin's texture and accent, and follows a change", function()
    local NS, mock = opened()
    local LSM = mock.LibStub:NewLibrary("LibSharedMedia-3.0", 1) or mock.LibStub("LibSharedMedia-3.0")
    LSM.Fetch = function(_, kind, key) return ("Media\\%s\\%s"):format(kind, tostring(key)) end
    local bar = NS.Showroom.Section("overlays").fillBar
    local tex = shadowed(bar, "SetStatusBarTexture")
    NS.Selector.Pick("obsidian")
    assertEqual(#tex >= 1, true, "the bar was given a texture again")
    local want = NS.Skin.BarStyle().texture
    assertEqual(tex[#tex][1], want, "the skin's bar.texture")
    assertTrue(want ~= "Interface\\TargetingFrame\\UI-StatusBar", "not the client's bar")
    local r = bar:GetStatusBarColor()
    assertEqual(r, mock.LibStub("LibKa0s-Skin-1.0"):ResolveSkin("obsidian")["text.accent"][1], "the accent")
end)

test("a5: the fade's label and the icon border follow the skin", function()
    local NS, mock = opened()
    local sec = NS.Showroom.Section("overlays")
    local function edge()   -- the Top edge's height: the first region of the primitive's holder
        return (select(1, sec.framed:GetChildren())):GetRegions():GetHeight()
    end
    -- LibKa0s R3-L3: the outline is 1 px in every skin, whatever its icon.borderSize says.
    assertEqual(edge(), 1, "Ka0s Default's edge")
    NS.Selector.Pick("obsidian")
    local t = mock.LibStub("LibKa0s-Skin-1.0"):ResolveSkin("obsidian")
    local tc = { sec.faded.text:GetTextColor() }
    assertEqual(tc[1], t["text.body"][1], "text.body on the label")
    assertEqual(edge(), 1, "Obsidian's edge")
end)

test("a5: every IconBorder sample asks for the skin's own edge", function()
    local NS = painted()
    local real, asked = NS.Skin.IconBorder, {}
    NS.Skin.IconBorder = function(frame, opts)
        asked[#asked + 1] = opts
        return real(frame, opts)
    end
    NS.Showroom.Show()
    NS.Skin.IconBorder = real
    -- R4-ST3: Addon surfaces' duplicate beside the caution callout is gone (round 4, image 22).
    assertEqual(#asked, 2, "Controls' square and Overlays'")
    for _, opts in ipairs(asked) do assertTrue(opts.fromSkin == true, "fromSkin") end
end)

test("R3-L3: every IconBorder sample names its icon, so the library's 0.07 zoom reaches it", function()
    -- red under: an icon texture only a local held, which S.IconBorder does not search for (LibKa0s
    -- R3-L3 zooms the Texture handed in, opts.icon, else frame.icon / frame.Icon).
    local NS = painted()
    local real, frames = NS.Skin.IconBorder, {}
    NS.Skin.IconBorder = function(frame, opts)
        frames[#frames + 1] = frame
        return real(frame, opts)
    end
    NS.Showroom.Show()
    NS.Skin.IconBorder = real
    assertEqual(#frames, 2, "Controls' square and Overlays'")
    for i, f in ipairs(frames) do
        local icon = rawget(f, "icon")
        assertTrue(type(icon) == "table" and type(icon.SetTexCoord) == "function", "sample " .. i .. " names its icon")
    end
end)

test("R3-FIX: Controls' square keeps S.SquareIcon's 0.08 crop through IconBorder's 0.07 zoom and a switch", function()
    -- red under: a zoom that set 0.07 outright, loosening the host's tighter crop (LibKa0s R3-FIX).
    local NS = painted()
    local real, squares = NS.Skin.SquareIcon, {}
    NS.Skin.SquareIcon = function(frame, ...)
        squares[#squares + 1] = frame
        return real(frame, ...)
    end
    NS.Showroom.Show()
    NS.Skin.SquareIcon = real
    local icon = squares[1] and rawget(squares[1], "icon")
    assertTrue(type(icon) == "table", "Controls painted a SquareIcon with an icon")
    local function crop(what)
        local ulx, uly, _, _, _, _, lrx, lry = icon:GetTexCoord()
        assertTrue(near(ulx, 0.08) and near(uly, 0.08) and near(lrx, 0.92) and near(lry, 0.92),
            what .. ": the 0.08 crop stands")
    end
    crop("after the show")
    NS.Selector.Pick("obsidian")
    crop("after a switch to Obsidian")
    NS.Selector.Pick("ka0s")
    crop("after a switch back")
end)

test("a5: the slider's own track is handed over and a selected nav entry has a fill to tint", function()
    local NS, mock = opened()
    local sec = NS.Showroom.Section("controls")
    assertTrue((mock.__paint(sec.slider.track).alpha or 1) == 0 or mock.__paint(sec.slider.track).shown == false,
        "the host's track is faded under the primitive's")
    local item = NS.Showroom.Section("panels").selectedNav
    assertTrue(mock.__paint(item).color ~= nil, "the selection is a texture with something on it")
    local vr = mock.__paint(item).vertex
    assertEqual(vr[1], mock.LibStub("LibKa0s-Skin-1.0"):ResolveSkin("ka0s")["nav.selBg"][1], "in nav.selBg")
end)

test("a5: the window's title bar stands at title.height", function()
    local _, mock = opened()
    local f = mock.frames["LibKa0sSkinTesterShowroom"]
    assertEqual(f.titleBar:GetHeight(), mock.LibStub("LibKa0s-Skin-1.0"):ResolveSkin("ka0s")["title.height"])
end)

test("a5: the scrollbar stands at scroll.width", function()
    local _, mock = opened()
    assertEqual(window(mock).scrollBar:GetWidth(), mock.LibStub("LibKa0s-Skin-1.0"):ResolveSkin("ka0s")["scroll.width"])
end)

test("a5: every readout line is painted body text", function()
    local NS, mock = opened()
    local V = NS.Values
    local t = mock.LibStub("LibKa0s-Skin-1.0"):ResolveSkin("obsidian")
    NS.Selector.Pick("obsidian")
    for name, fs in pairs({ flags = V.flags, hudSize = V.hudSize, color = V.getters.GlowColor, bar = V.barLine,
                            outline = NS.Fonts.outline, worn = NS.Hud.worn }) do
        local c = { fs:GetTextColor() }
        assertEqual(c[1], t["text.body"][1], name .. " is in text.body")
    end
end)

test("a5: the BarStyle sample's fill is colored from the skin", function()
    local NS, mock = opened()
    local bar = NS.Values.bar
    local calls = shadowed(bar, "SetStatusBarColor")
    NS.Selector.Pick("obsidian")
    assertEqual(calls[#calls][1], mock.LibStub("LibKa0s-Skin-1.0"):ResolveSkin("obsidian")["bar.fill"][1])
end)
