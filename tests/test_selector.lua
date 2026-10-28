-- tests/test_selector.lua — the swatch selector (ST-03): one card per Ka0s skin across the top of the
-- showroom, and a click that moves the skin the showroom wears.
--
-- The pick is the owner's own choice, Skin:SetChoice on this addon, and is saved through the same write
-- seam the Skin tab uses. Only Ka0s skins get cards: the showroom shows what a Ka0s skin paints,
-- and EllesmereUI's paint is one-way, so a card for it could never be taken back without a reload.

local T = _G.SKINTESTER_TEST
local test, assertEqual, assertTrue, assertFalse = T.test, T.assertEqual, T.assertTrue, T.assertFalse

local OWNER = "LibKa0sSkinTester"

local function lib(mock) return mock.LibStub("LibKa0s-Skin-1.0") end

--- The selector of an opened showroom.
local function opened()
    local NS, _, mock = T.enableAddon()
    NS.Showroom.Show()
    return NS, mock, NS.Showroom.Selector()
end

local function click(card) return card:GetScript("OnClick")(card, "LeftButton") end

--- A fresh addon booted over a saved profile.
local function bootWithSkin(skin)
    local NS, _, mock = T.newAddon()
    _G.LibKa0sSkinTesterDB = { profiles = { Default = { skin = { source = "ka0s", skin = skin } } } }
    NS.addon:OnInitialize()
    NS.addon:OnEnable()
    return NS, mock
end

test("selector: one card per Ka0s skin, in Skins() order", function()
    local _, mock, sel = opened()
    local skins = lib(mock):Skins()
    assertEqual(#sel.order, #skins, "one card per registered skin")
    assertEqual(#sel.order, 9, "the nine Ka0s skins")
    for i, def in ipairs(skins) do
        assertEqual(sel.order[i].key, def.key, "card " .. i)
        assertTrue(sel.cards[def.key] == sel.order[i], def.key .. " is keyed too")
        assertEqual(sel.cards[def.key].label:GetText(), def.label, def.key .. "'s label")
        assertEqual(#sel.cards[def.key].swatches, 4, def.key .. " shows its four swatches")
    end
end)

test("selector: clicking a card applies and saves the skin", function()
    local NS, mock, sel = opened()
    assertTrue(click(sel.cards.obsidian), "the click answers changed")
    local source, skin = lib(mock):GetChoice(OWNER)
    assertEqual(source, "ka0s")
    assertEqual(skin, "obsidian", "the showroom wears it")
    assertEqual(NS.addon.db.profile.skin.skin, "obsidian", "and it is saved")
    for _, card in ipairs(sel.order) do
        assertEqual(card.selected, card.key == "obsidian", card.key .. "'s selection")
    end
end)

test("selector: a pick made elsewhere moves the selection", function()
    -- red under: a selection that only follows the selector's own clicks (the Skin tab and
    -- `/st set skin.skin` move the skin too).
    local NS, _, sel = opened()
    NS.addon:OnSlashCommand("set skin.skin glass")
    assertTrue(sel.cards.glass.selected, "glass is selected")
    assertFalse(sel.cards.ka0s.selected, "and Default no longer is")
end)

test("selector: the saved skin is applied at load", function()
    local _, mock = bootWithSkin("glass")
    local _, skin = lib(mock):GetChoice(OWNER)
    assertEqual(skin, "glass")
end)

test("selector: the saved Scope is applied at load, and /st set moves one half", function()
    -- LibKa0s-Skin-1.0 minor 5. red under: an apply at load that sets the skin and not the Scope.
    local NS, _, mock = T.newAddon()
    _G.LibKa0sSkinTesterDB = { profiles = { Default = { skin = { source = "ka0s", skin = "ember",
        ignorePanel = true, ignoreFonts = false } } } }
    NS.addon:OnInitialize()
    NS.addon:OnEnable()
    local panel, fonts = lib(mock):GetIgnore(OWNER)
    assertEqual(panel, true, "the stored panel exception")
    assertEqual(fonts, false)
    NS.addon:OnSlashCommand("set skin.ignoreFonts true")
    panel, fonts = lib(mock):GetIgnore(OWNER)
    assertEqual(fonts, true, "the set applied")
    assertEqual(panel, true, "the other half kept")
end)

test("selector: an unknown saved skin falls back to ka0s", function()
    -- red under: an apply that hands the library any string (cleanSkin keeps every non-empty one).
    local NS, mock = bootWithSkin("nope")
    local _, skin = lib(mock):GetChoice(OWNER)
    assertEqual(skin, "ka0s")
    NS.Showroom.Show()
    assertTrue(NS.Showroom.Selector().cards.ka0s.selected, "and the Default card reads selected")
end)

test("selector: clicking the current card does nothing", function()
    local _, mock, sel = opened()
    local Skin, repaints = lib(mock), 0
    local real = Skin.Repaint
    Skin.Repaint = function(...) repaints = repaints + 1; return real(...) end
    local changed = click(sel.cards.ka0s)
    Skin.Repaint = real
    assertFalse(changed, "the current skin is no change")
    assertEqual(repaints, 0, "and nothing was repainted")
end)

test("selector: no EllesmereUI card and no copy button", function()
    local _, _, sel = opened()
    assertTrue(sel.cards.eui == nil, "no eui card")
    for _, card in ipairs(sel.order) do assertTrue(card.key ~= "eui") end
    local function walk(f)
        for _, fs in ipairs(f.__fontStrings or {}) do
            local text = fs:GetText()
            assertTrue(not (text and text:find("Copy to every", 1, true)), "a copy label: " .. tostring(text))
        end
        for _, kid in ipairs(f.__children or {}) do walk(kid) end
    end
    walk(sel)
end)
