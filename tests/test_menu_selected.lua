-- tests/test_menu_selected.lua — every menu in the showroom that marks a selected entry paints it
-- apart (FB2-ST-01 of Ka0sAddonsCommonTasks docs/2026-11-24-FEEDBACK_BATCH, decision D3; LibKa0s
-- v1.113.0, WidgetsDropdown minor 4; the standard's skinning-§4, v2.120.0).
--
-- The owner, 2026-11-24: "make the current selected always be a different color than the other
-- texts - e.g. gold in ka0s default". The showroom's menus are all the library's, so the rule comes
-- with the re-vendor and these cases hold it in this addon's own windows, under every shipped skin:
--
--   the Selector's Source dropdown     W.Dropdown, owned by this addon
--   the Controls section's dropdown    W.Dropdown, owned by this addon ("First choice" selected)
--   the Widgets section's cascade      W.ContextMenu, owned: a ticked row (Bags, Medium) is selected
--
-- A selected row's text is W.SelectedColor(owner), the color the shared menu itself answers, and it
-- stands at least 20 CIEDE2000 off a plain row's (the library's floor, its own ΔE00 seam). None of
-- these menus carries a value color (class, quality), so "off a value color" has no row to test
-- here. The AceGUI Dropdown and the Blizzard DropdownButton samples open the client's own menus,
-- which no Ka0s skin paints.

local T = _G.SKINTESTER_TEST
local test, assertEqual, assertTrue = T.test, T.assertEqual, T.assertTrue

local OWNER = "LibKa0sSkinTester"
local SEL_DE00_MIN = 20
local installPaint = dofile("tests/_kit/mock_paint.lua")

local function opened()
    local NS, _, mock = T.enableSeen{ mock = installPaint }
    NS.Showroom.Show()
    return NS, mock
end

local function rgb(c) return ("%.3f,%.3f,%.3f"):format(c[1], c[2], c[3]) end

local function painted(mock, row) return mock.__paint(row.fs).textColor end

local function skinKeys(mock)
    local out = {}
    for _, def in ipairs(mock.LibStub("LibKa0s-Skin-1.0"):Skins()) do out[#out + 1] = def.key end
    return out
end

--- Open a W.Dropdown and answer the shared menu, captured the first time the library builds it.
local function openDropdown(mock, dd, state)
    local saved = mock.CreateFrame
    mock.CreateFrame = function(...)
        local f = saved(...)
        state.menu = state.menu or f
        return f
    end
    dd.__fire("OnClick", "LeftButton")
    mock.CreateFrame = saved
    assertTrue(state.menu ~= nil and type(state.menu.buttons) == "table", "the shared menu opened")
    return state.menu
end

local function shownRow(menu, label)
    for _, b in ipairs(menu.buttons) do
        if b:IsShown() and b.fs:GetText() == label then return b end
    end
end

--- `sel` is the owner's selected color and stands far enough off `plain`.
local function assertApart(mock, sel, plain, what)
    local W = mock.LibStub("LibKa0s-Widgets-1.0")
    local r, g, b = W.SelectedColor(OWNER)
    assertEqual(rgb(sel), rgb({ r, g, b }), what .. ": the selected row is W.SelectedColor")
    local d = W.__menuDE00(sel, plain)
    assertTrue(d >= SEL_DE00_MIN, ("%s: the selected row stands %.1f ΔE00 off a plain one, want >= %d")
        :format(what, d, SEL_DE00_MIN))
end

test("menu selected: the Controls dropdown's selected row stands off its plain row under every skin", function()
    -- red under: LibKa0s before WidgetsDropdown 4, where Azeroth's selection (its accent) sat 16.3
    -- ΔE00 off its plain rows and read like them.
    local NS, mock = opened()
    local W, dd, state = mock.LibStub("LibKa0s-Widgets-1.0"), NS.Showroom.Section("controls").dropdown, {}
    local keys = skinKeys(mock)
    assertTrue(#keys >= 9, "every shipped skin walked, got " .. #keys)
    for _, key in ipairs(keys) do
        NS.Selector.Pick(key)
        local menu = openDropdown(mock, dd, state)
        local sel, plain = shownRow(menu, "First choice"), shownRow(menu, "Second choice")
        assertTrue(sel ~= nil and plain ~= nil, key .. ": both rows drawn")
        assertApart(mock, painted(mock, sel), painted(mock, plain), key)
        W.CloseMenu()
    end
end)

test("menu selected: the Selector's Source dropdown marks the applied source apart under every skin", function()
    -- red under: the same, on the row of skin cards.
    local NS, mock = opened()
    local W, dd, state = mock.LibStub("LibKa0s-Widgets-1.0"), NS.Showroom.Selector().source, {}
    assertTrue(dd ~= nil, "the Source dropdown is on the row")
    local labels = {}
    for _, o in ipairs(dd._options) do labels[o.value] = o.label end
    for _, key in ipairs(skinKeys(mock)) do
        NS.Selector.Pick(key)
        local menu = openDropdown(mock, dd, state)
        local sel, plain = shownRow(menu, labels.ka0s), shownRow(menu, labels.eui)
        assertTrue(sel ~= nil and plain ~= nil, key .. ": both sources drawn")
        assertApart(mock, painted(mock, sel), painted(mock, plain), key)
        W.CloseMenu()
    end
end)

test("menu selected: the cascade's ticked rows paint selected, not a tick beside plain text", function()
    -- red under: LibKa0s before WidgetsDropdown 4, where a ticked W.ContextMenu row kept menu.text.
    local NS, mock = opened()
    local W, sec = mock.LibStub("LibKa0s-Widgets-1.0"), NS.Showroom.Section("widgets")
    for _, key in ipairs(skinKeys(mock)) do
        NS.Selector.Pick(key)
        sec.cascadeButton.__fire("OnClick", "LeftButton")
        local menu = sec.cascadeMenu
        assertTrue(menu ~= nil and menu:IsShown(), key .. ": the cascade is up")
        local bags, bank = shownRow(menu, "Bags"), shownRow(menu, "Bank")
        assertApart(mock, painted(mock, bags), painted(mock, bank), key .. ": the multi group")
        local size = shownRow(menu, "Size")
        size:GetScript("OnClick")(size)
        local medium, large = shownRow(menu.__child, "Medium"), shownRow(menu.__child, "Large")
        assertApart(mock, painted(mock, medium), painted(mock, large), key .. ": the radio submenu")
        W.CloseMenu()
    end
end)

test("menu selected: Azeroth, the skin whose accent sits near its text, takes Ka0s Default's gold", function()
    -- red under: a selection that follows Azeroth's own menu.textSel (the owner's report on Loot History).
    local NS, mock = opened()
    local W, dd = mock.LibStub("LibKa0s-Widgets-1.0"), NS.Showroom.Section("controls").dropdown
    NS.Selector.Pick("azeroth")
    local menu = openDropdown(mock, dd, {})
    assertEqual(rgb(painted(mock, shownRow(menu, "First choice"))), rgb({ 1, 0.82, 0 }), "the gold")
    W.CloseMenu()
end)
