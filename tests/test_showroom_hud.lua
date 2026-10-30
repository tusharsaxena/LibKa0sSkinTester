-- tests/test_showroom_hud.lua — the HUD faces section (ST-01 of Ka0sAddonsCommonTasks
-- docs/2026-10-30-SKIN_LIBRARY_FOLLOWUPS; LibKa0s v1.81.0's LK-04, ruling R-4, and LK-01, ruling R-1):
-- one line per skin in that skin's own HUD face, size and outline, so every face can be judged side by
-- side, and one line in the face the worn skin hands a HUD (S.BarStyle), which Ignore fonts gives
-- back to the host's own face.
--
-- LibSharedMedia is not in the harness, so a case that checks the drawn face registers a stand-in
-- that answers a path per key, then asks the section to redraw with a skin pick.

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

--- A LibSharedMedia stand-in: every font key fetches as a path named after it.
local function fakeLSM(mock)
    local LSM = mock.LibStub:NewLibrary("LibSharedMedia-3.0", 1) or mock.LibStub("LibSharedMedia-3.0")
    LSM.Fetch = function(_, kind, key) return ("Fonts\\%s\\%s.ttf"):format(kind, tostring(key)) end
    return LSM
end

test("hud: the section is built, one line per skin, in the library's order", function()
    local NS, mock = opened()
    local sec = NS.Showroom.Section("hud")
    assertTrue(sec ~= nil and (sec:GetHeight() or 0) > 0, "built, with a height")
    local want = {}
    for _, def in ipairs(lib(mock):Skins()) do want[#want + 1] = def.key end
    assertEqual(table.concat(NS.Hud.order, ","), table.concat(want, ","))
    assertEqual(#want, 9, "every shipped skin")
end)

test("hud: each skin's line names that skin's own HUD face, all nine of them", function()
    -- red under: LibKa0s before LK-04 (v1.81.0), whose eight non-Ka0s skins left hud.font to Friz.
    local NS, mock = opened()
    local Skin = lib(mock)
    local faces = {}
    for _, key in ipairs(NS.Hud.order) do
        local fs = NS.Hud.lines[key]
        local face = Skin:ResolveSkin(key)["hud.font"]
        assertEqual(fs.faceKey, face, key .. "'s line")
        assertTrue(fs:GetText():find(face, 1, true) ~= nil, key .. "'s text names its face")
        faces[face] = (faces[face] or 0) + 1
    end
    -- D-02 of docs/2026-10-30-SKIN_FONTS_AND_FEEDBACK (LibKa0s v1.82.0): Prototype for Ka0s Default,
    -- Expressway for Obsidian. Pinned once here; every other case reads the skin's own token.
    assertEqual(NS.Hud.lines.ka0s.faceKey, "Ka0s Prototype")
    assertEqual(NS.Hud.lines.obsidian.faceKey, "Ka0s Expressway")
    assertEqual(NS.Hud.lines.ember.faceKey, "Ka0s Bitter Bold")
    assertEqual(NS.Hud.lines.wow.faceKey, "Friz Quadrata TT", "WoW Default names the client's face")
    local n = 0
    for _ in pairs(faces) do n = n + 1 end
    assertEqual(n, 9, "nine skins, nine faces")
end)

test("hud: each skin's line is drawn in its face, at its hud.fontSize, under its hud.outline", function()
    local NS, mock = opened()
    fakeLSM(mock)
    NS.Selector.Pick("azeroth")   -- a skin change redraws the section
    local Skin = lib(mock)
    for _, key in ipairs(NS.Hud.order) do
        local t = Skin:ResolveSkin(key)
        local font = mock.__paint(NS.Hud.lines[key]).font
        assertTrue(type(font) == "table", key .. ": a face was set")
        assertEqual(font[1], ("Fonts\\font\\%s.ttf"):format(t["hud.font"]), key .. "'s face")
        assertEqual(font[2], t["hud.fontSize"], key .. "'s size")
        assertEqual(font[3], t["hud.outline"], key .. "'s outline")
    end
end)

test("hud: the worn line follows the skin worn, through BarStyle", function()
    local NS, mock = opened()
    assertTrue(NS.Showroom.used.BarStyle == true, "BarStyle went through the wrapper")
    local Skin = lib(mock)
    assertEqual(NS.Hud.worn.faceKey, Skin:ResolveSkin("ka0s")["hud.font"], "Ka0s Default's HUD face")
    NS.Selector.Pick("obsidian")
    assertEqual(NS.Hud.worn.faceKey, Skin:ResolveSkin("obsidian")["hud.font"], "Obsidian's")
    fakeLSM(mock)
    NS.Selector.Pick("ember")
    local font = mock.__paint(NS.Hud.worn).font
    assertEqual(font[1], ("Fonts\\font\\%s.ttf"):format(Skin:ResolveSkin("ember")["hud.font"]),
        "drawn in Ember's face")
end)

test("hud: under Ignore fonts the worn line takes the host's own face, and the skin lines keep theirs", function()
    -- red under: LibKa0s before LK-01 (v1.81.0), whose BarStyle kept the skin's face under Ignore fonts.
    local NS, mock = opened()
    local face = lib(mock):ResolveSkin("obsidian")["hud.font"]
    NS.Selector.Pick("obsidian")
    NS.ApplySkinIgnore(nil, true)
    assertEqual(NS.Hud.worn.faceKey, nil, "no skin face under Ignore fonts")
    assertTrue(NS.Hud.worn:GetText():find("Ignore fonts", 1, true) ~= nil, "the line says why")
    assertTrue(mock.__paint(NS.Hud.worn).fontObject ~= nil, "the host's own font object")
    assertEqual(NS.Hud.lines.obsidian.faceKey, face, "a skin's line still shows its face")
    NS.ApplySkinIgnore(nil, false)
    assertEqual(NS.Hud.worn.faceKey, face, "turning it off gives the skin's face back")
    assertEqual(lib(mock):Token(OWNER, "hud.font"), face)
end)
