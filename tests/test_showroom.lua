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
    return T.enableSeen{ mock = function(m) installPaint(m) end }
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
    local NS = T.enableSeen()
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
    assertTrue(window(mock).footer.left:GetText():find("High Contrast", 1, true) ~= nil,
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

-- ── AD-92-ST (LibKa0s#92): the sample tooltip opens by the body rule (standalone-windows' *Tooltip
-- placement*). "Hover me" is a control in the showroom's content, so its tooltip is a body element's:
-- beside the window group (the showroom alone), right then left, its top level with the button's
-- top, through LibKa0s-Tooltip-1.0's PlaceBeside. Before it the frame sat on the button's top-right
-- corner, 4 px off (a corner offset, which the rule names as ruled out).

--- Gives `f` a rect in screen units (scale 1), read through the client's geometry methods.
local function placeAt(f, left, bottom, width, height)
    rawset(f, "GetLeft", function() return left end)
    rawset(f, "GetBottom", function() return bottom end)
    rawset(f, "GetRight", function() return left + width end)
    rawset(f, "GetTop", function() return bottom + height end)
    rawset(f, "GetWidth", function() return width end)
    rawset(f, "GetHeight", function() return height end)
    rawset(f, "GetEffectiveScale", function() return 1 end)
end

--- Hovers "Hover me" and answers the sample tooltip, every SetPoint it took on that hover, the button.
local function hoverSample(NS)
    local btn = NS.Showroom.Section("overlays").tipButton
    local tip = NS.Showroom.sampleTooltip
    local points = shadowed(tip, "SetPoint")
    btn:GetScript("OnEnter")(btn)
    return tip, points, btn
end

test("AD-92-ST: the sample tooltip is placed by PlaceBeside, on the button, against the showroom", function()
    -- red under: the corner anchor (BOTTOMLEFT on the button's TOPRIGHT, 4, 4) with no placer call.
    local NS, mock = opened()
    local Tip = mock.LibStub("LibKa0s-Tooltip-1.0")
    local calls, real, shownFirst = {}, Tip.PlaceBeside, nil
    rawset(Tip, "PlaceBeside", function(tip, element, group, o)
        calls[#calls + 1] = { tip = tip, element = element, group = group, opts = o }
        shownFirst = tip:IsShown() == true
        return real(tip, element, group, o)
    end)
    local ok, err = pcall(hoverSample, NS)
    rawset(Tip, "PlaceBeside", real)
    assertTrue(ok, tostring(err))
    assertEqual(#calls, 1, "one PlaceBeside per hover")
    local c = calls[1]
    assertEqual(c.tip, NS.Showroom.sampleTooltip, "the sample's own frame")
    assertEqual(c.element, NS.Showroom.Section("overlays").tipButton, "placed by the hovered button")
    assertEqual(c.group, window(mock), "the window group is the showroom")
    assertTrue(shownFirst, "shown before it is placed, so its size is known")
    assertTrue(type(c.opts) == "table" and c.opts.comparisons == false,
        "no comparison anchor type: it is no item tooltip")
end)

test("AD-92-ST: the sample tooltip opens right of the showroom, top level with the button, 2 px off",
    function()
    local NS, mock = opened()
    local scr = dofile("tests/_kit/mock_screen.lua")(mock, { width = 1920, height = 1080 })
    placeAt(window(mock), 400, 200, 600, 600)
    placeAt(NS.Showroom.Section("overlays").tipButton, 450, 500, 120, 24)
    placeAt(NS.Showroom.sampleTooltip, 0, 0, 170, 48)
    local ok, tip, points = pcall(hoverSample, NS)
    scr.restore()
    assertTrue(ok, tostring(tip))
    local p = points[#points]
    assertTrue(p ~= nil, "the tooltip was placed")
    assertEqual(p[1], "TOPLEFT", "its top-left")
    assertEqual(p[2], mock.UIParent, "one absolute point on UIParent")
    assertEqual(p[3], "BOTTOMLEFT")
    assertEqual(p[4], 1000 + 2, "at the showroom's right edge + TIP_GAP")
    assertEqual(p[5], 524, "its top level with the button's top")
end)

test("AD-92-ST: with no room on the right the sample tooltip opens left of the showroom", function()
    local NS, mock = opened()
    local scr = dofile("tests/_kit/mock_screen.lua")(mock, { width = 1920, height = 1080 })
    placeAt(window(mock), 1300, 200, 600, 600)
    placeAt(NS.Showroom.Section("overlays").tipButton, 1350, 500, 120, 24)
    placeAt(NS.Showroom.sampleTooltip, 0, 0, 170, 48)
    local ok, tip, points = pcall(hoverSample, NS)
    scr.restore()
    assertTrue(ok, tostring(tip))
    local p = points[#points]
    assertTrue(p ~= nil, "the tooltip was placed")
    assertEqual(p[1], "TOPRIGHT", "its top-right")
    assertEqual(p[4], 1300 - 2, "at the showroom's left edge - TIP_GAP")
    assertEqual(p[5], 524, "its top level with the button's top")
end)

test("AD-92-ST: unreadable geometry attaches the sample above the button, never a corner or the cursor",
    function()
    -- red under: the corner anchor kept as the fallback, or any cursor read.
    local NS, mock = opened()
    local Tip = mock.LibStub("LibKa0s-Tooltip-1.0")
    local beside, attached = Tip.PlaceBeside, Tip.PlaceAttached
    rawset(Tip, "PlaceBeside", function() return nil end)
    rawset(Tip, "PlaceAttached", function() return nil end)
    local ok, tip, points, btn = pcall(hoverSample, NS)
    rawset(Tip, "PlaceBeside", beside); rawset(Tip, "PlaceAttached", attached)
    assertTrue(ok, tostring(tip))
    assertEqual(#points, 1, "one point")
    local p = points[1]
    assertEqual(p[1], "BOTTOM"); assertEqual(p[2], btn); assertEqual(p[3], "TOP")
    assertEqual(p[4], 0); assertEqual(p[5], Tip.TIP_GAP, "TIP_GAP above the button")
end)

test("AD-92-ST: no tooltip of this addon follows the cursor or sits on a corner offset", function()
    -- The addon's own code: core/, modules/ and settings/ (libs/ and the kit are the library's).
    local files = {}
    for _, dir in ipairs({ "core", "modules", "settings" }) do
        local p = io.popen('ls "' .. (T.root or ".") .. "/" .. dir .. '"')
        for name in p:lines() do
            if name:match("%.lua$") then files[#files + 1] = dir .. "/" .. name end
        end
        p:close()
    end
    assertTrue(#files > 10, "the addon's sources were listed")
    for _, rel in ipairs(files) do
        local fh = assert(io.open((T.root or ".") .. "/" .. rel, "rb"))
        local src = fh:read("*a"); fh:close()
        for _, bad in ipairs({ "ANCHOR_CURSOR", "GetCursorPosition", '"BOTTOMLEFT", self, "TOPRIGHT"' }) do
            assertTrue(src:find(bad, 1, true) == nil, rel .. " carries " .. bad)
        end
    end
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

test("R4-L4: every IconBorder sample sits in a window, so none asks for the HUD's icon.border edge", function()
    -- red under: a sample passing opts.hud = true (LibKa0s R4-L4), which would draw the HUD's black
    -- icon.border under Ka0s Default in place of the window's icon.outline (SHOW-47).
    local NS = painted()
    local real, asked = NS.Skin.IconBorder, {}
    NS.Skin.IconBorder = function(frame, opts)
        asked[#asked + 1] = opts
        return real(frame, opts)
    end
    NS.Showroom.Show()
    NS.Skin.IconBorder = real
    assertEqual(#asked, 2, "Controls' square and Overlays'")
    for i, opts in ipairs(asked) do assertTrue(opts.hud == nil, "sample " .. i .. " keeps the window outline") end
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

test("R4-ST4: title.bg is one layer, the bar's, and stays one through a skin switch", function()
    -- red under: a Shell painted without noTopBar, whose band draws title.bg under the TitleBar's own,
    -- so a translucent band (Glass at 0.10) reads about twice as strong. The collection's convention,
    -- as DropWatcher's test_skin_host.lua pins it.
    local NS, mock = painted()
    NS.Showroom.Show()
    local Skin, f = lib(mock), window(mock)
    local function oneLayer(label)
        local rec = Skin.painted[f]
        assertTrue(rec ~= nil, label .. ": the Shell painted the window")
        local top = rec.regions.top   -- never made under noTopBar, or made and hidden
        assertTrue(top == nil or not top:IsShown(), label .. ": no Shell band under the bar")
        local bar = Skin.painted[f.titleBar].regions
        assertTrue(bar.backdrop ~= nil or bar.fill ~= nil, label .. ": the bar's own box")
    end
    oneLayer("Ka0s Default")
    NS.Selector.Pick("glass")
    oneLayer("Glass")
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

-- R5-L3 (LibKa0s v1.85.0, Ka0sAddonsCommonTasks docs/2026-11-03-SMOKE_ROUND5, feedback item 5): every
-- header child sits on the title band's own frame at y 0, so it is on the band's geometric middle in
-- every skin; a child title bar under noTopBar takes the band's rect. Pinned the way LibKa0s's
-- tests/test_header_band.lua pins it. Frames record SetAllPoints here (the base mock's is a no-op).

local CENTERED = { LEFT = true, CENTER = true, RIGHT = true }

local function bandMock(m)
    installPaint(m)
    local create = m.CreateFrame
    m.CreateFrame = function(...)
        local f = create(...)
        if type(f) == "table" then
            rawset(f, "SetAllPoints", function(self, rel)
                self.__points, self.__allPoints = {}, rel or self.__parent
            end)
            local clear = f.ClearAllPoints
            rawset(f, "ClearAllPoints", function(self)
                self.__allPoints = nil
                return clear(self)
            end)
        end
        return f
    end
end

local function bandOpened()
    local NS, _, mock = T.enableAddon{ mock = bandMock }
    NS.Showroom.Show()
    return NS, mock
end

--- `region` has one or two points, each LEFT, CENTER or RIGHT, on `band` at y 0.
local function assertOnBand(region, band, what)
    local n = region:GetNumPoints()
    assertTrue(n >= 1 and n <= 2, what .. ": anchored")
    for i = 1, n do
        local point, rel, relPoint, _, y = region:GetPoint(i)
        assertTrue(CENTERED[point], ("%s: a %s point, never TOP*"):format(what, tostring(point)))
        assertEqual(relPoint, point, what .. ": to the band's own " .. tostring(point))
        assertTrue(rel == band, what .. ": anchored to the band")
        assertEqual(y, 0, what .. ": y 0, the band's middle")
    end
end

test("R5-RV: the showroom's title bar, title and close sit on S.Band in every skin", function()
    -- red under: the bar at a fixed 0,0 and its title and close anchored to the bar, so a 2 px edge
    -- (WoW Midnight) or EllesmereUI's 25 px bar leaves them off the band's middle.
    local NS, mock = bandOpened()
    local f = window(mock)
    for _, def in ipairs(lib(mock):Skins()) do
        NS.Selector.Pick(def.key)
        local band = NS.Skin.Band(f)
        assertTrue(band ~= nil, def.key .. ": a band frame")
        assertTrue(rawget(f.titleBar, "__allPoints") == band, def.key .. ": the bar takes the band's rect")
        assertOnBand(f.titleBar.title, band, def.key .. ": the title")
        assertOnBand(f.close, band, def.key .. ": the close mark")
        assertEqual(select(1, f.close:GetPoint(1)), "RIGHT", def.key .. ": the close mark on the right")
    end
    assertTrue(NS.Showroom.used.Band and NS.Showroom.used.Header, "both went through NS.Showroom.Paint")
end)

test("R5-WIN: the confirm popup's one band carries its question on its middle, in every skin", function()
    -- red under: the question TOP-anchored at -12 on a popup whose Shell now draws the title band
    -- over a backdrop window's fill (LibKa0s R5-L2), so it sits off the band's middle.
    local NS, mock = bandOpened()
    local pop = NS.Showroom.Section("overlays").confirmPopup
    assertTrue(pop ~= nil, "the popup is kept")
    for _, def in ipairs(lib(mock):Skins()) do
        NS.Selector.Pick(def.key)
        local band = NS.Skin.Band(pop)
        assertTrue(band ~= nil, def.key .. ": a band frame")
        assertOnBand(pop.text, band, def.key .. ": the question")
        assertEqual(select(1, pop.text:GetPoint(1)), "CENTER", def.key .. ": centered")
        local top = lib(mock).painted[pop].regions.top
        assertTrue(top ~= nil and top:IsShown(), def.key .. ": Shell's band is drawn, once (the popup has no bar)")
    end
end)

test("R5-WIN: the showroom's body sits 6 px in from its title bar and footer, as LootHistory's content", function()
    -- red under: the 8 px gutter, 2 px deeper than every other Ka0s window's content inset.
    local _, mock = bandOpened()
    local f = window(mock)
    local p, rel, rp, x, y = f.body:GetPoint(1)
    assertEqual(p .. rp, "TOPLEFTBOTTOMLEFT", "under the bar"); assertTrue(rel == f.titleBar, "the bar")
    assertEqual(x, 6, "6 px in"); assertEqual(y, -6, "6 px down")
    p, rel, rp, x, y = f.body:GetPoint(2)
    assertEqual(p .. rp, "BOTTOMRIGHTTOPRIGHT", "over the footer"); assertTrue(rel == f.footer, "the footer")
    assertEqual(x, -6, "6 px in"); assertEqual(y, 6, "6 px up")
end)

-- SR-ST (smoke round 1, rulings 3 and 4): the showroom is the one window this addon draws itself with a
-- title bar, and its close X is that bar's one control (Core.MakeCloseButton with this addon as owner).
-- Every title-bar control shows a one-line tooltip in the owner's gtip.title, rests in icon.tint and
-- lights close.hot under the pointer, in every skin.

--- The showroom's title-bar controls: every clickable frame on the bar or its band, the close X included.
local function titleControls(NS, f)
    local seen, out = {}, {}
    local function add(c)
        if c and not seen[c] then seen[c] = true; out[#out + 1] = c end
    end
    add(f.close)
    for _, holder in ipairs({ f.titleBar, NS.Skin.Band(f) }) do
        if holder and holder.GetChildren then
            for _, c in ipairs({ holder:GetChildren() }) do
                if type(c) == "table" and c.GetScript and c:GetScript("OnClick") then add(c) end
            end
        end
    end
    return out
end

--- The tooltip `control` shows on hover, as { text, color }; nil when it shows none.
local function titleTip(mock, control)
    local tip, got = mock.GameTooltip, nil
    local saved = rawget(tip, "SetText")
    rawset(tip, "SetText", function(self, text, r, g, b, ...)
        got = { text = text, color = { r, g, b } }
        return saved and saved(self, text, r, g, b, ...) or self
    end)
    local ok, err = pcall(function() control.__fire("OnEnter") end)
    pcall(function() control.__fire("OnLeave") end)
    rawset(tip, "SetText", saved)
    assertTrue(ok, tostring(err))
    return got
end

--- The color `control`'s art is painted: its icon's vertex color, else its glyph's text color.
local function artColor(mock, control)
    local art = rawget(control, "icon") or rawget(control, "glyph")
    assertTrue(art ~= nil, "the control draws art")
    local rec = mock.__paint(art)
    return rec.vertex or rec.textColor
end

test("SR-ST: every showroom title-bar control shows a tooltip in gtip.title, in every skin", function()
    -- red under: LibKa0s before SR-L2 (Core minor 18), whose MakeCloseButton close showed no tooltip.
    local NS, mock = opened()
    local f = window(mock)
    local controls = titleControls(NS, f)
    assertTrue(#controls >= 1 and f.close ~= nil, "the title bar carries its close X")
    for _, def in ipairs(lib(mock):Skins()) do
        NS.Selector.Pick(def.key)
        for i, c in ipairs(controls) do
            local what = ("%s: title-bar control %d"):format(def.key, i)
            local got = titleTip(mock, c)
            assertTrue(got ~= nil and type(got.text) == "string" and got.text ~= "", what .. ": a tooltip")
            assertToken(mock, got.color, "gtip.title", what .. "'s tooltip")
        end
    end
    assertEqual(titleTip(mock, f.close).text, "Close", "the close says Close")
end)

test("SR-ST: the showroom's close X rests in icon.tint and lights close.hot, in Ka0s Default and every skin", function()
    -- red under: LibKa0s before SR-L3, where a skin's own close.rest left the X off the other marks' tint.
    local NS, mock = opened()
    local f = window(mock)
    local keys = { "ka0s" }
    for _, def in ipairs(lib(mock):Skins()) do
        if def.key ~= "ka0s" then keys[#keys + 1] = def.key end
    end
    assertTrue(#keys >= 2, "Ka0s Default and at least one other skin")
    for _, key in ipairs(keys) do
        NS.Selector.Pick(key)
        assertToken(mock, artColor(mock, f.close), "icon.tint", key .. ": the X at rest")
        f.close.__fire("OnEnter")
        assertToken(mock, artColor(mock, f.close), "close.hot", key .. ": the X under the pointer")
        f.close.__fire("OnLeave")
        assertToken(mock, artColor(mock, f.close), "icon.tint", key .. ": the X at rest again")
    end
end)

-- AD-89-ST (LibKa0s#89; standalone-windows' *The footer*, v2.110.0): the showroom's footer is the
-- library's W.Footer, FOOTER.HEIGHT (24 px) tall with no fill, a hairline in the skin's `divider` and
-- the skin worn on its muted left line. The facade's Footer primitive, a band, stays on show as a
-- specimen in the Window chrome section, so the coverage claim still sees it.

test("AD-89-ST: the showroom's footer is W.Footer, FOOTER.HEIGHT tall, the skin worn on its left line", function()
    -- red under: the hand-built 22 px band (a BackdropTemplate frame with its own font string).
    local NS, _, mock = painted()
    NS.Showroom.Show()
    local f = window(mock)
    local W = mock.LibStub("LibKa0s-Widgets-1.0")
    assertEqual(W.FOOTER.HEIGHT, 24, "the library's footer is 24 px")
    assertEqual(f.footer:GetHeight(), W.FOOTER.HEIGHT, "the footer is FOOTER.HEIGHT tall")
    assertTrue(f.footer.line ~= nil and f.footer.left ~= nil and f.footer.SetLeft ~= nil, "built by W.Footer")
    assertEqual(f.footer.left:GetText(), "Wearing Ka0s Default", "the left line names the skin worn")
    assertTrue(mock.__paint(f.footer).backdropColor == nil, "no fill: the window shows through")
    assertToken(mock, mock.__paint(f.footer.left).textColor, "text.muted", "the left line")
    NS.Selector.Pick("contrast")
    assertTrue(f.footer.left:GetText():find("High Contrast", 1, true) ~= nil, "a skin change rewrites it")
    assertToken(mock, mock.__paint(f.footer.left).textColor, "text.muted", "the left line under contrast")
end)

test("AD-89-ST: the body ends FOOTER.HEIGHT plus its 6 px gap above the window's bottom edge", function()
    local NS, _, mock = painted()
    NS.Showroom.Show()
    local f = window(mock)
    local p, rel, rp, _, y = f.body:GetPoint(2)
    assertEqual(p .. rp, "BOTTOMRIGHTTOPRIGHT", "over the footer"); assertTrue(rel == f.footer, "the footer")
    assertEqual(y, 6, "6 px up from its top")
    p, rel, rp = f.footer:GetPoint(1)
    assertEqual(p .. rp, "BOTTOMLEFTBOTTOMLEFT", "the footer sits on the window's bottom edge")
    assertTrue(rel == f, "on the window")
end)

test("AD-89-ST: with no library widgets the footer is a bare frame of the same height and line", function()
    -- red under: a footer that indexes LibKa0s-Widgets-1.0 without checking it loaded.
    local NS, _, mock = T.enableAddon{ skip = { "libs/LibKa0s/Widgets.lua" } }
    NS.Showroom.Show()
    local f = window(mock)
    assertEqual(f.footer:GetHeight(), 24, "24 px, the library's figure")
    assertEqual(f.footer.left:GetText(), "Wearing Ka0s Default", "the left line names the skin worn")
end)

test("AD-89-ST: the facade's Footer band is on show as a specimen in the Window chrome section", function()
    -- red under: the band dropped with the hand-built footer, so lib.VOCAB's Footer goes unshown.
    local NS, _, mock = painted()
    NS.Showroom.Show()
    local cell = NS.Showroom.Section("chrome").cells["Footer (the facade's band, a specimen)"]
    assertTrue(cell ~= nil, "the specimen cell")
    assertTrue(NS.Showroom.used.Footer == true, "Footer went through NS.Showroom.Paint")
    assertToken(mock, mock.__paint(cell).backdropColor, "foot.bg", "the specimen's band")
    assertTrue(mock.__paint(window(mock).footer).backdropColor == nil, "and not on the window's footer")
end)

-- AD-86-ST (LibKa0s#86; standalone-windows' *Title-bar controls*, v2.113.0): the showroom's title marks
-- are the library's W.HeaderButtons strip, left to right settings · close, 18 px marks 6 px from the
-- corner and 6 px apart. Settings opens this addon's settings through the opener its launcher
-- registered; the showroom (MEDIUM) sits under the settings panel, so it stays shown.

test("AD-86-ST: the showroom's marks are W.HeaderButtons', settings beside the close", function()
    -- red under: the hand-placed Core close alone, with no settings mark.
    local _, mock = opened()
    local f = window(mock)
    local W = mock.LibStub("LibKa0s-Widgets-1.0")
    local hb = f.headerButtons
    assertTrue(hb ~= nil, "built by W.HeaderButtons")
    assertTrue(hb.close ~= nil and hb.close == f.close, "the strip's close is the window's close")
    assertTrue(hb.settings ~= nil and hb.settings == f.settings, "a settings mark")
    assertEqual(table.concat(hb.order, ","), "settings,close", "left to right: settings, close")
    assertEqual(hb.offsets.close, -W.HEADER.PAD, "the close 6 px from the corner")
    assertEqual(hb.offsets.settings, -(W.HEADER.PAD + W.HEADER.SIZE + W.HEADER.GAP), "settings 6 px inward of it")
    assertTrue(hb.optOut == nil, "no opt-out")
end)

test("AD-86-ST: the settings mark sits on S.Band's middle with the close, in every skin", function()
    local NS, mock = bandOpened()
    local f = window(mock)
    for _, def in ipairs(lib(mock):Skins()) do
        NS.Selector.Pick(def.key)
        local band = NS.Skin.Band(f)
        assertOnBand(f.settings, band, def.key .. ": the settings mark")
        assertEqual(select(1, f.settings:GetPoint(1)), "RIGHT", def.key .. ": on the right, inward of the close")
    end
end)

test("AD-86-ST: the settings mark opens this addon's settings, and the showroom stays shown", function()
    -- red under: no settings mark on the showroom's title bar.
    local NS, mock = opened()
    local f = window(mock)
    local opens = 0
    local saved = NS.addon.OpenSettings
    NS.addon.OpenSettings = function() opens = opens + 1 end
    local ok, err = pcall(function() f.settings.__fire("OnClick", "LeftButton") end)
    NS.addon.OpenSettings = saved
    assertTrue(ok, tostring(err))
    assertEqual(opens, 1, "the launcher's registered opener ran once")
    assertTrue(f:IsShown(), "the showroom sits under the settings panel, so it is not hidden")
end)

test("AD-86-ST: the settings mark says Open settings, rests in icon.tint and lights text.link, in every skin", function()
    local NS, mock = opened()
    local f = window(mock)
    for _, def in ipairs(lib(mock):Skins()) do
        NS.Selector.Pick(def.key)
        local got = titleTip(mock, f.settings)
        assertEqual(got and got.text, "Open settings", def.key .. ": the tooltip")
        assertToken(mock, got.color, "gtip.title", def.key .. ": the tooltip's color")
        assertToken(mock, artColor(mock, f.settings), "icon.tint", def.key .. ": at rest")
        f.settings.__fire("OnEnter")
        assertToken(mock, artColor(mock, f.settings), "text.link", def.key .. ": under the pointer")
        f.settings.__fire("OnLeave")
        assertToken(mock, artColor(mock, f.settings), "icon.tint", def.key .. ": at rest again")
    end
end)

test("AD-86-ST: with no library widgets the close alone, on the bar's right", function()
    -- red under: a title bar that indexes W.HeaderButtons without checking it loaded.
    local NS, _, mock = T.enableAddon{ skip = { "libs/LibKa0s/Widgets.lua" } }
    NS.Showroom.Show()
    local f = window(mock)
    assertTrue(f.settings == nil, "no settings mark without the library's strip")
    assertTrue(rawget(f, "headerButtons") == nil, "no strip")
    assertTrue(f.close ~= nil, "the fallback close is built")
    local point, rel, relPoint, x = f.close:GetPoint(1)
    assertEqual(point, "RIGHT", "the close sits on the right")
    -- The Header paint re-places the marks on its band (the bar's middle), so rel is that band.
    assertTrue(rel ~= nil, "anchored to a frame, not the screen")
    assertEqual(relPoint, "RIGHT", "on the bar's right edge")
    assertEqual(x, -6, "6 px in from the bar's right")
    assertTrue(f:IsShown(), "shown before the close")
    f.close.__fire("OnClick", "LeftButton")
    assertTrue(not f:IsShown(), "the fallback close hides the showroom")
end)

test("FB-ST-01: a disabled primary sample looks like the Disabled sample, in every skin", function()
    -- The owner, 2026-11-24 (Outfitter Reborn's New Outfit "Done"): "It should look like this (from
    -- skin tester)", meaning Normal / Primary / Disabled. SkinPaintControls 21 (LibKa0s v1.112.0)
    -- paints a disabled primary as the plain button box with text.disabled; the showroom shows it.
    -- red under: no "Button (primary, disabled)" sample, or a vendored SkinPaintControls older than
    -- 21 (the primary fill kept under the disabled label).
    local NS, _, mock = painted()
    NS.Showroom.Show()
    local sec = NS.Showroom.Section("controls")
    local pd, dis, pri = sec.primaryDisabled, sec.disabledButton, sec.primaryButton
    assertTrue(pd ~= nil and dis ~= nil and pri ~= nil, "the three button samples are kept on the section")
    assertEqual(pd:IsEnabled(), false, "the disabled primary is disabled")
    assertEqual(pd.text:GetText(), "Disabled", "its label")
    for _, def in ipairs(lib(mock):Skins()) do
        NS.Selector.Pick(def.key)
        local what = def.key .. ": the disabled primary"
        assertToken(mock, mock.__paint(pd).backdropColor, "btn.bg", what .. "'s box")
        assertToken(mock, mock.__paint(pd.text).textColor, "text.disabled", what .. "'s label")
        assertToken(mock, mock.__paint(pri).backdropColor, "btnPrimary.bg", def.key .. ": the enabled primary's box")
        local a, b = mock.__paint(pd).backdropColor, mock.__paint(dis).backdropColor
        assertTrue(near(a[1], b[1]) and near(a[2], b[2]) and near(a[3], b[3]), what .. " matches Disabled")
    end
end)
