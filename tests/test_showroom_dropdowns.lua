-- tests/test_showroom_dropdowns.lua — the Controls section's dropdown row (ST-D1 of
-- Ka0sAddonsCommonTasks docs/2026-10-31-FINDINGS_REMEDIATION): every dropdown kind the collection
-- draws, each in its cell through the route an addon uses. The library's W.Dropdown; AceGUI's
-- Dropdown and the library's Ka0sMedia_* pickers through PaintAce, following the Scope's panel half;
-- LSM30_*, which nothing paints, labeled so; and a Blizzard DropdownButton as
-- PremadeGroupsFilterExtension's panel draws one.
--
-- The kit's AceGUI has no stock Dropdown, so the picker cases name the type themselves, and
-- WowStyle1DropdownTemplate's anatomy (Background, Arrow, Text) is modeled here: the base mock builds
-- none of it.

local T = _G.SKINTESTER_TEST
local test, assertEqual, assertTrue = T.test, T.assertEqual, T.assertTrue

local OWNER = "LibKa0sSkinTester"
local TEMPLATE = "WowStyle1DropdownTemplate"
local installPaint = dofile("tests/_kit/mock_paint.lua")

local function modelTemplate(m)
    local create = m.CreateFrame
    m.CreateFrame = function(kind, name, parent, template, ...)
        local f = create(kind, name, parent, template, ...)
        if template == TEMPLATE then
            f.Background, f.Arrow = f:CreateTexture(nil, "BACKGROUND"), f:CreateTexture(nil, "ARTWORK")
            f.Text = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            rawset(f, "SetupMenu", function(self, gen) self.__menu = gen end)
        end
        return f
    end
end

--- `opts.prepare(mock)` runs after the addon's load and before the showroom's first open.
local function opened(opts)
    opts = opts or {}
    local NS, _, mock = T.enableAddon{ mock = function(m)
        installPaint(m)
        modelTemplate(m)
        if opts.mock then opts.mock(m) end
    end }
    if opts.prepare then opts.prepare(mock) end
    NS.Showroom.Show()
    return NS, mock, NS.Showroom.Section("controls")
end

local function lib(mock) return mock.LibStub("LibKa0s-Skin-1.0") end

--- The library's pickers registered, as a client with AceGUI's stock Dropdown has them.
local function withPickers(mock)
    local O, Skin = mock.LibStub("LibKa0s-Options-1.0"), lib(mock)
    local names = { font = "Ka0sMedia_Font", statusbar = "Ka0sMedia_Statusbar" }
    O.__MediaWidgetType = function(kind)
        Skin:AliasAceType(names[kind], "Dropdown")
        return names[kind]
    end
end

--- `f` hangs off one anchor on a grid cell of `sec`, so it scrolls with the section.
local function assertInCell(f, name, sec)
    assertEqual(f:GetNumPoints(), 1, name .. " has one anchor")
    local point, cell = f:GetPoint(1)
    assertEqual(point, "TOPLEFT", name .. " anchors by its corner")
    assertTrue(type(cell) == "table", name .. " names what it anchors to")
    local _, holder = cell:GetPoint(1)
    assertTrue(holder == sec, name .. "'s anchor is a cell of the section")
end

local function owned(mock, w)
    local st = lib(mock).__ace[w]
    return st ~= nil and st.owner == OWNER
end

test("controls: the library's dropdown row is drawn, sized, labeled and in its cell", function()
    -- red under: a build that dropped the row, or one that left the button off its cell or empty.
    local _, mock, sec = opened()
    local dd = sec.dropdown
    assertTrue(dd:IsShown(), "shown")
    assertEqual(dd:GetWidth(), 160)
    assertTrue((dd:GetHeight() or 0) > 0, "with a height")
    assertEqual(dd.text:GetText(), "First choice")
    assertEqual(dd:GetPoint(1), "TOPLEFT", "anchored in its cell, which is its parent")
    assertEqual(lib(mock).painted[dd].owner, OWNER)
end)

test("controls: AceGUI's Dropdown is in its cell and follows the Scope's panel half, live", function()
    -- red under: a PaintAce asked once at build, or a widget left parented to UIParent.
    local NS, mock, sec = opened()
    local w = sec.aceDropdown
    assertEqual(w.type, "Dropdown")
    assertInCell(w.frame, "the AceGUI dropdown", sec)
    assertTrue(not owned(mock, w), "stock while the Scope leaves the panel the client's (the default)")
    NS.ApplySkinIgnore(false, nil)
    assertTrue(owned(mock, w), "painted once the Scope is cleared")
    NS.ApplySkinIgnore(true, nil)
    assertTrue(not owned(mock, w), "handed back when the Scope leaves the panel again")
end)

test("controls: the media pickers are the library's types, painted and handed back like the Dropdown", function()
    -- red under: a sample acquired as a plain Dropdown, or a picker kept out of the repaint.
    local NS, mock, sec = opened{ prepare = withPickers }
    local font, bar = sec.fontPicker, sec.barPicker
    assertEqual(font.type, "Ka0sMedia_Font")
    assertEqual(bar.type, "Ka0sMedia_Statusbar")
    NS.ApplySkinIgnore(false, nil)
    for name, w in pairs({ font = font, bar = bar }) do
        assertInCell(w.frame, name, sec)
        assertTrue(owned(mock, w), name .. " painted once the Scope is cleared")
    end
    NS.ApplySkinIgnore(true, nil)
    assertTrue(not owned(mock, font), "handed back")
end)

test("controls: a media picker this client lacks is the plain Dropdown, and says so", function()
    -- red under: a cell left empty where the library has no picker to give.
    local _, _, sec = opened()
    assertEqual(sec.fontPicker.type, "Dropdown", "the kit's AceGUI has no picker")
    assertEqual(sec.fontPicker.list["Ka0s Prototype"], "Plain Dropdown: no picker here")
end)

test("controls: an LSM30 sample shows stock when registered and a label when it is not", function()
    -- red under: a cell left empty without SharedMediaWidgets, or a stock sample claimed as painted.
    local _, _, bare = opened()
    assertEqual(bare.lsmFont.text:GetText(), "LSM30_Font not loaded")
    local NS, mock, sec = opened{ prepare = function(m)
        m.__libs["AceGUI-3.0"].__widgetVersions.LSM30_Font = 1
        m.__libs["LibSharedMedia-3.0"] = { HashTable = function() return { ["Ka0s Prototype"] = "path" } end }
    end }
    local w = sec.lsmFont
    assertEqual(w.type, "LSM30_Font")
    assertInCell(w.frame, "the LSM30 sample", sec)
    NS.ApplySkinIgnore(false, nil)
    assertTrue(not owned(mock, w), "nothing paints it, whatever the Scope says")
end)

test("controls: the Blizzard dropdown drops the template's art and wears the skin", function()
    -- red under: S.Dropdown with no opts.stock: its list knows no Background, and the template's Arrow
    -- is the whole gold button, so it would be tinted in place of faded.
    local NS, mock, sec = opened()
    local dd = sec.blizzDropdown
    assertInCell(dd, "the Blizzard dropdown", sec)
    assertEqual(dd.Background:GetAlpha(), 0, "the text holder is faded")
    assertEqual(dd.Arrow:GetAlpha(), 0, "the gold button is faded")
    assertTrue(not rawequal(dd.arrow, dd.Arrow), "the glyph is the sample's own texture")
    local function checkArrow(skin)
        local want, got = lib(mock):ResolveSkin(skin)["icon.arrow"], mock.__paint(dd.arrow).vertex
        assertEqual(type(want), "table", skin .. " has an arrow color")
        for i = 1, 3 do assertTrue(math.abs(got[i] - want[i]) < 1e-3, skin .. ": the glyph wears icon.arrow") end
    end
    NS.Selector.Pick("obsidian")
    checkArrow("obsidian")
    NS.Selector.Pick("ember")
    checkArrow("ember")
    NS.ApplySkinIgnore(true, nil)
    assertEqual(dd.Background:GetAlpha(), 0, "a window's: the panel half of the Scope leaves it skinned")
end)

test("controls: the Blizzard dropdown's menu offers both choices and marks the pick", function()
    local _, _, sec = opened()
    local radios = {}
    sec.blizzDropdown.__menu(nil, { CreateRadio = function(_, text, isOn, set)
        radios[#radios + 1] = { text = text, isOn = isOn, set = set }
    end })
    assertEqual(#radios, 2)
    assertTrue(radios[1].isOn() and not radios[2].isOn(), "the first choice starts picked")
    radios[2].set()
    assertTrue(radios[2].isOn() and not radios[1].isOn(), "a pick moves")
end)

test("controls: a client without the Blizzard template shows a label in its cell", function()
    -- red under: an unguarded CreateFrame, which would take the whole section down.
    local _, _, sec = opened{ mock = function(m)
        local create = m.CreateFrame
        m.CreateFrame = function(kind, ...)
            if kind == "DropdownButton" then error("unknown frame type") end
            return create(kind, ...)
        end
    end }
    assertEqual(sec.blizzDropdown.text:GetText(), "Template not in this client")
end)
