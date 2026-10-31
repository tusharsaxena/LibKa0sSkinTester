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
    assertEqual(kinds.string, 6, "a dropdown and the five media pickers")
    assertEqual(kinds.color, 1, "a color swatch")
end)

-- The five media pickers (LibKa0s v1.83.0, OptionsMedia minor 1, D-08; options-ui-§23): one of each
-- kind, named by the library's own type, so the owner can judge each preview on a settings page.
local PICKERS = {
    { path = "sample.font",       control = "Ka0sMedia_Font",       kind = "font",       label = "A font picker" },
    { path = "sample.statusbar",  control = "Ka0sMedia_Statusbar",  kind = "statusbar",  label = "A bar texture picker" },
    { path = "sample.border",     control = "Ka0sMedia_Border",     kind = "border",     label = "A border picker" },
    { path = "sample.background", control = "Ka0sMedia_Background", kind = "background", label = "A background picker" },
    { path = "sample.sound",      control = "Ka0sMedia_Sound",      kind = "sound",      label = "A sound picker" },
}

local function rowAt(NS, path)
    for _, row in ipairs(NS.addon.Settings.Schema) do
        if row.path == path then return row end
    end
end

--- A LibSharedMedia stand-in whose keys name their kind: the real one is not loaded headlessly.
local function fakeLSM(mock)
    local LSM = mock.LibStub:NewLibrary("LibSharedMedia-3.0", 1) or mock.LibStub("LibSharedMedia-3.0")
    LSM.HashTable = function(_, kind) return { [kind .. " one"] = "path", [kind .. " two"] = "path" } end
    LSM.Fetch = function(_, kind, key) return ("Media\\%s\\%s"):format(kind, tostring(key)) end
    return LSM
end

test("settings: the sample page carries one picker of each media kind, on the library's own types", function()
    -- red under: a sample row drawn as a plain Dropdown over media keys (anti-patterns #109).
    local NS = T.newAddon()
    for _, want in ipairs(PICKERS) do
        local row = rowAt(NS, want.path)
        assertTrue(row ~= nil, want.path .. " is a row")
        assertEqual(row.page, "sample", want.path .. " stays on its page")
        assertEqual(row.dialogControl, want.control, want.path .. "'s type")
        assertEqual(row.label, want.label, want.path .. "'s label")
        assertEqual(type(row.values), "function", want.path .. " asks for its keys at call time")
    end
end)

test("settings: each sample picker lists what LibSharedMedia holds of its kind", function()
    -- red under: a descriptor with no getLSM, whose LSMValues answers the one "no media" row.
    local NS, _, mock = T.enableAddon()
    fakeLSM(mock)
    for _, want in ipairs(PICKERS) do
        local values = rowAt(NS, want.path).values()
        assertEqual(values[want.kind .. " one"], want.kind .. " one", want.path)
        assertEqual(values[want.kind .. " two"], want.kind .. " two", want.path)
    end
end)

test("settings: each sample picker draws on the page, and with no media library it still opens", function()
    -- The kit's AceGUI has no stock Dropdown to build on, so __MediaWidgetType answers nil and the
    -- row draws the plain Dropdown a client without the picker draws. Which type a real client gets
    -- is pinned by the row's dialogControl above and by LibKa0s's own tests/test_options_media.lua.
    local _, _, mock = openSample()
    for _, want in ipairs(PICKERS) do
        assertTrue(widget(mock, "Dropdown", want.label) ~= nil, want.label .. " rendered")
    end
end)

test("settings: /st set takes a media key the sample picker lists, and refuses one it does not", function()
    local NS, _, mock = T.enableAddon()
    fakeLSM(mock)
    NS.addon:OnSlashCommand("set sample.font font two")
    assertEqual(NS.addon.db.profile.sample.font, "font two")
    NS.addon:OnSlashCommand("set sample.font not a font")
    assertEqual(NS.addon.db.profile.sample.font, "font two", "an unknown key changes nothing")
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
