-- tests/test_skin_picker.lua — the first-run skin picker's triggers (settings/Panel.lua,
-- NS.MaybeShowSkinPicker; LibKa0s OptionsSkinPicker minor 1, ST-01).
--
-- The window itself is the library's and its own suite holds it; what this addon owns is WHEN it
-- shows (skin.pickerSeen false: after login, after a profile event), when it does not (seen, in
-- combat, disabled), the spec it hands over (the write seams, the General page's Skin tab, the
-- eye) and that a close is recorded through the schema runtime.

local T = _G.SKINTESTER_TEST
local test, assertEqual, assertTrue, assertFalse = T.test, T.assertEqual, T.assertTrue, T.assertFalse

local PREFIX = "LibKa0sSkinPickerLibKa0sSkinTester"

--- The picker window the library built for this owner, or nil before the first show.
local function picker(mock)
    for name, f in pairs(mock.frames) do
        if type(name) == "string" and name:sub(1, #PREFIX) == PREFIX then return f end
    end
end

local function shown(mock)
    local f = picker(mock)
    return f ~= nil and f:IsShown() and true or false
end

local function seen(NS) return NS.addon.db.profile.skin.pickerSeen end

test("picker: a fresh profile shows it once the addon is enabled", function()
    local NS, _, mock = T.enableAddon()
    assertTrue(shown(mock), "the picker is up after login")
    assertFalse(seen(NS), "showing it is not seeing it")
end)

test("picker: not before login", function()
    -- red under: calling it from OnInitialize, before the latch has its answer.
    local _, _, mock = T.bootAddon()
    assertFalse(shown(mock))
end)

test("picker: the spec names this owner's seams, the General page's Skin tab and the eye", function()
    local NS = T.enableAddon()
    local spec = NS.SKIN_PICKER_SPEC
    assertEqual(spec.owner, "LibKa0sSkinTester")
    assertTrue(spec.get == NS.SkinChoice, "get is the read seam")
    assertTrue(spec.set == NS.WriteSkinChoice, "set is the write seam")
    assertEqual(spec.page, "general")
    assertEqual(spec.tab, "Appearance", "the tab's key, not its label")
    assertEqual(type(spec.onPreview), "function")
    assertEqual(spec.strings.PREVIEW_TIP, "Preview: open the skin showroom")
end)

test("picker: closing it marks the profile, and the next login does not show it", function()
    local NS = T.enableAddon()
    NS.addon.Settings.Helpers.HideSkinPicker()
    assertTrue(seen(NS), "the close went through the schema runtime")
    local sv = _G.LibKa0sSkinTesterDB
    local again, _, mock = T.newAddon()
    _G.LibKa0sSkinTesterDB = sv
    again.addon:OnInitialize()
    again.addon:OnEnable()
    assertFalse(shown(mock), "a profile that closed it does not see it again")
end)

test("picker: the eye opens the showroom and leaves the picker up", function()
    local NS, _, mock = T.enableAddon()
    local f = picker(mock)
    assertTrue(f.preview ~= nil and f.preview:IsShown(), "the eye is drawn")
    f.preview:GetScript("OnClick")(f.preview, "LeftButton")
    assertTrue(NS.Showroom.IsShown(), "the showroom is open")
    assertTrue(shown(mock), "the picker stays")
    assertFalse(seen(NS))
end)

test("picker: the gear closes it and marks the profile", function()
    local NS, _, mock = T.enableAddon()
    local f = picker(mock)
    f.settings:GetScript("OnClick")(f.settings, "LeftButton")
    assertFalse(shown(mock), "the gear closes the picker")
    assertTrue(seen(NS))
end)

test("picker: not while the addon is disabled", function()
    local first = T.bootAddon()
    first.addon.Settings.Helpers.Set("enabled", false)
    local sv = _G.LibKa0sSkinTesterDB
    local NS, _, mock = T.newAddon()
    _G.LibKa0sSkinTesterDB = sv
    NS.addon:OnInitialize()
    NS.addon:OnEnable()
    assertFalse(shown(mock), "a disabled addon shows nothing")
    assertFalse(seen(NS), "and the profile has still not seen it")
end)

test("picker: a login in combat skips it, and the next trigger shows it", function()
    local NS, _, mock = T.enableAddon{ mock = function(m) m.combat = true end }
    assertFalse(shown(mock), "never in combat")
    assertFalse(seen(NS), "skipped, not seen")
    mock.combat = false
    NS.addon.db:SetProfile("Alt")
    assertTrue(shown(mock), "the next profile event asks again")
end)

test("picker: a profile reset shows it again", function()
    local NS, _, mock = T.enableAddon()
    NS.addon.Settings.Helpers.HideSkinPicker()
    assertFalse(shown(mock))
    NS.addon.db:ResetProfile()
    assertFalse(seen(NS), "the reset profile starts unseen")
    assertTrue(shown(mock), "and the picker is back")
end)

test("picker: a new profile shows it; one that closed it does not", function()
    local NS, _, mock = T.enableAddon()
    NS.addon.Settings.Helpers.HideSkinPicker()
    NS.addon.db:SetProfile("Alt")
    assertTrue(shown(mock), "a new profile has not seen it")
    NS.addon.Settings.Helpers.HideSkinPicker()
    NS.addon.db:SetProfile("Default")
    assertFalse(shown(mock), "Default closed it")
    assertFalse(NS.MaybeShowSkinPicker(), "and asking again answers false")
end)
