-- tests/test_showroom_fonts.lua — the Faces and widths section and the `/st widths` probe (LibKa0s
-- v1.82.0; ST-01 of Ka0sAddonsCommonTasks docs/2026-10-30-SKIN_FONTS_AND_FEEDBACK, D-02, D-06, D-08).
--
-- LibSharedMedia is not in the harness, so a case that measures registers a stand-in that answers a
-- path per key, and gives the probe a width: the corpus's length times the size it was set at, times
-- a per-face factor, so a ratio is a number the case can work out.

local T = _G.SKINTESTER_TEST
local test, assertEqual, assertTrue = T.test, T.assertEqual, T.assertTrue

local OWNER = "LibKa0sSkinTester"
local installPaint = dofile("tests/_kit/mock_paint.lua")

local function opened()
    local NS, _, mock = T.enableAddon{ mock = function(m) installPaint(m) end }
    NS.Showroom.Show()
    return NS, mock
end

local function lib(mock) return mock.LibStub("LibKa0s-Skin-1.0") end

local function fakeLSM(mock)
    local LSM = mock.LibStub:NewLibrary("LibSharedMedia-3.0", 1) or mock.LibStub("LibSharedMedia-3.0")
    LSM.Fetch = function(_, kind, key) return ("Fonts\\%s\\%s.ttf"):format(kind, tostring(key)) end
    return LSM
end

--- Give the probe a width: #text * size, so equal sizes give equal widths.
local function armProbe(NS, mock)
    local fs = NS.Fonts.Probe()
    rawset(fs, "GetUnboundedStringWidth", function(self)
        local font = mock.__paint(self).font
        return #(self:GetText() or "") * (font and font[2] or 0)
    end)
    return fs
end

local function corpusLength(NS)
    local n = 0
    for _, line in ipairs(NS.Fonts.CORPUS) do n = n + #line end
    return n
end

test("fonts: the section is built, one face line per skin, in the library's order", function()
    local NS, mock = opened()
    assertTrue(NS.Showroom.Section("fonts") ~= nil, "built")
    local want = {}
    for _, def in ipairs(lib(mock):Skins()) do want[#want + 1] = def.key end
    assertEqual(table.concat(NS.Fonts.order, ","), table.concat(want, ","))
    for _, key in ipairs(want) do assertTrue(NS.Fonts.lines[key] ~= nil, key .. " has a line") end
end)

test("fonts: each line names its skin's body and title faces, the new faces among them", function()
    -- red under: LibKa0s before v1.82.0 (SkinDefs minor 17), whose Ka0s Default drew Oxanium.
    local NS, mock = opened()
    for _, key in ipairs(NS.Fonts.order) do
        local t, line = lib(mock):ResolveSkin(key), NS.Fonts.lines[key]
        assertEqual(line.body.faceKey, t["font.body"], key .. "'s body face")
        assertEqual(line.title.faceKey, t["font.title"], key .. "'s title face")
        assertTrue(line.body:GetText():find(t["font.body"], 1, true) ~= nil, key .. " names its body face")
    end
    assertEqual(NS.Fonts.lines.ka0s.body.faceKey, "Ka0s Prototype")
    assertEqual(NS.Fonts.lines.obsidian.title.faceKey, "Ka0s Expressway")
    assertEqual(NS.Fonts.lines.forever.body.faceKey, "Ka0s Fira Sans Medium")
end)

test("fonts: the lines draw in each face at its size, under this addon's Font outline", function()
    local NS, mock = opened()
    fakeLSM(mock)
    NS.Selector.Pick("azeroth")   -- a skin change redraws the section
    local t = lib(mock):ResolveSkin("obsidian")
    local font = mock.__paint(NS.Fonts.lines.obsidian.body).font
    assertEqual(font[1], ("Fonts\\font\\%s.ttf"):format(t["font.body"]))
    assertEqual(font[2], t["font.bodySize"])
    assertEqual(font[3], "OUTLINE", "All text, the default")
    lib(mock):SetOutline(OWNER, "hud")
    font = mock.__paint(NS.Fonts.lines.obsidian.title).font
    assertEqual(font[3], "", "HUD text only takes window text's outline, live")
    assertTrue(NS.Fonts.outline:GetText():find("HUD text only", 1, true) ~= nil, "the mode line says so")
end)

test("fonts: with Ignore fonts ticked the face lines draw window text's stock flags, as the mode line says", function()
    -- red under: windowFlags reading only the Font outline (OUTLINE under All text, Ignore fonts or not).
    local NS, mock = opened()
    fakeLSM(mock)
    NS.ApplySkinIgnore(nil, true)
    NS.Selector.Pick("azeroth")   -- a skin change redraws the section
    local font = mock.__paint(NS.Fonts.lines.obsidian.body).font
    assertEqual(font[3], "", "Ignore fonts wins over All text")
    assertTrue(NS.Fonts.outline:GetText():find('Window text draws ""', 1, true) ~= nil, NS.Fonts.outline:GetText())
end)

test("fonts: the outline line follows the Font outline and says Ignore fonts wins", function()
    local NS, mock = opened()
    assertTrue(NS.Fonts.outline:GetText():find('Font outline: All text. Window text draws "OUTLINE", HUD text "OUTLINE"',
        1, true) ~= nil, NS.Fonts.outline:GetText())
    lib(mock):SetOutline(OWNER, "off")
    assertTrue(NS.Fonts.outline:GetText():find('Off. Window text draws "", HUD text ""', 1, true) ~= nil)
    NS.ApplySkinIgnore(nil, true)
    assertTrue(NS.Fonts.outline:GetText():find("Ignore fonts wins", 1, true) ~= nil)
end)

test("fonts: Measure gives every skin a width per role and Ka0s Default a ratio of 1", function()
    local NS, mock = opened()
    fakeLSM(mock)
    armProbe(NS, mock)
    local rows = NS.Fonts.Measure()
    assertEqual(#rows, #NS.Fonts.order, "one row per skin")
    local n = corpusLength(NS)
    for _, row in ipairs(rows) do
        local t = lib(mock):ResolveSkin(row.key)
        assertEqual(row.body.width, n * t["font.bodySize"], row.key .. "'s body width")
        assertEqual(row.title.width, n * t["font.titleSize"], row.key .. "'s title width")
        assertEqual(row.hud.width, n * t["hud.fontSize"], row.key .. "'s HUD width")
        if row.key == "ka0s" then
            assertEqual(row.body.ratio, 1, "the baseline")
            assertEqual(row.hud.ratio, 1)
        end
    end
end)

test("fonts: /st widths prints a header and one line per skin against Ka0s Default", function()
    -- red under: no widths verb (the dispatcher answers "unknown command").
    local NS, mock = opened()
    fakeLSM(mock)
    armProbe(NS, mock)
    local mark = #mock.prints
    NS.addon:OnSlashCommand("widths")
    local out = {}
    for i = mark + 1, #mock.prints do out[#out + 1] = mock.prints[i] end
    assertEqual(#out, 1 + #NS.Fonts.order, "a header and a line per skin")
    assertTrue(out[1]:find("against Ka0s Default", 1, true) ~= nil, "the header")
    local base = lib(mock):ResolveSkin("ka0s")
    assertTrue(out[2]:find(("body %s %s 1.000x"):format(base["font.body"], tostring(base["font.bodySize"])), 1, true)
        ~= nil, out[2])
end)

test("fonts: a face the client cannot resolve reads unmeasured, and nothing raises", function()
    local NS = opened()
    local lines = NS.Fonts.Lines()
    assertTrue(lines[2]:find("unmeasured", 1, true) ~= nil, "no LibSharedMedia: nothing measured")
end)

test("fonts: a face the client refuses reads unmeasured, never the previous face's width", function()
    -- red under: F.Width ignoring SetFont's answer (the shared probe keeps the last face that took).
    local NS, mock = opened()
    fakeLSM(mock)
    local fs = armProbe(NS, mock)
    rawset(fs, "SetFont", function() return false end)
    for _, row in ipairs(NS.Fonts.Measure()) do
        assertEqual(row.body.width, nil, row.key .. "'s body")
        assertEqual(row.hud.ratio, nil, row.key .. "'s HUD ratio")
    end
    assertTrue(NS.Fonts.Lines()[2]:find("unmeasured", 1, true) ~= nil)
end)

test("fonts: /st widths is refused while the addon is disabled", function()
    local NS, mock = opened()
    NS.addon:OnSlashCommand("disable")
    local mark = #mock.prints
    NS.addon:OnSlashCommand("widths")
    assertEqual(#mock.prints - mark, 1, "one refusal line")
    assertTrue(mock.prints[#mock.prints]:find("is disabled", 1, true) ~= nil)
end)

test("fonts: without the skin engine the section builds and the probe says why", function()
    local NS = T.enableAddon{ skip = { "libs/LibKa0s/Skin.lua" } }
    NS.Showroom.Show()
    assertTrue(NS.Showroom.Section("fonts") ~= nil, "built, with no face lines")
    assertEqual(#NS.Fonts.Lines(), 1)
    assertTrue(NS.Fonts.Lines()[1]:find("did not load", 1, true) ~= nil)
end)
