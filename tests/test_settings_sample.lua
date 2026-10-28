-- tests/test_settings_sample.lua — the Sample controls settings page (ST-07): one row of each widget
-- type the settings renderer draws, on a page of its own, so the skin can be seen on a settings page
-- as well as in the showroom. The page wears this addon's skin the way every Ka0s settings page does
-- (LibKa0s-Options' owner proxy); what is pinned here is that it exists, carries one of each, and is
-- painted for this owner.

local T = _G.SKINTESTER_TEST
local test, assertEqual, assertTrue = T.test, T.assertEqual, T.assertTrue

local OWNER = "LibKa0sSkinTester"

local function openSample(pick)
    local NS, env, mock = T.enableAddon()
    if pick then NS.Selector.Pick(pick) end
    mock.frames["LibKa0sSkinTesterSamplePanel"]:Show()
    mock.fireCTimers()
    return NS, env, mock
end

local function widget(mock, widgetType, labelText)
    return mock.findWidget(function(w)
        return w.type == widgetType and (w.labelText == labelText or w.text == labelText)
    end)
end

test("settings: the sample page carries one row of each widget type", function()
    local NS = T.newAddon()
    local kinds = {}
    for _, row in ipairs(NS.addon.Settings.Schema) do
        if row.page == "sample" then kinds[row.type] = (kinds[row.type] or 0) + 1 end
    end
    assertEqual(kinds.bool, 2, "a checkbox, and the color swatch's class-color companion")
    assertEqual(kinds.number, 1, "a slider")
    assertEqual(kinds.string, 1, "a dropdown")
    assertEqual(kinds.color, 1, "a color swatch")
end)

test("settings: the sample page wears the owner's skin once the panel is skinned", function()
    -- A new profile leaves the settings panel the client's (the Scope's default); the sample page
    -- is there to show the skin on a settings page, so this case turns that off first.
    local NS, _, mock = T.enableAddon()
    NS.addon:OnSlashCommand("set skin.ignorePanel false")
    NS.Selector.Pick("obsidian")
    mock.frames["LibKa0sSkinTesterSamplePanel"]:Show()
    mock.fireCTimers()
    local cb = widget(mock, "CheckBox", "A checkbox")
    assertTrue(cb ~= nil, "the checkbox rendered")
    local st = mock.LibStub("LibKa0s-Skin-1.0").__ace[cb]
    assertTrue(st ~= nil and st.owner == OWNER, "and it was painted for this addon")
end)

test("settings: on a new profile the sample page is the client's", function()
    -- red under: a default that skins the settings panel.
    local _, _, mock = openSample("obsidian")
    local cb = widget(mock, "CheckBox", "A checkbox")
    assertTrue(cb ~= nil, "the checkbox rendered")
    local st = mock.LibStub("LibKa0s-Skin-1.0").__ace[cb]
    assertTrue(st == nil or st.owner == nil, "and nothing painted it")
end)

test("settings: the sample rows stay on their page", function()
    -- red under: a rowsForPage that answers every row for every page.
    local _, _, mock = openSample()
    assertTrue(widget(mock, "CheckBox", "A checkbox") ~= nil, "the sample page shows its checkbox")
    local NS2, _, mock2 = T.enableAddon()
    mock2.frames["LibKa0sSkinTesterGeneralPanel"]:Show()
    mock2.fireCTimers()
    assertTrue(widget(mock2, "CheckBox", "A checkbox") == nil, "and the General page does not")
    local _ = NS2
end)

test("settings: no copy button on the sample page", function()
    local _, _, mock = openSample()
    local copy = mock.findWidget(function(w)
        return (w.text or w.labelText or ""):find("Copy to every", 1, true) ~= nil
    end)
    assertTrue(copy == nil, "the copy action is the Skin tab's, not this page's")
end)
