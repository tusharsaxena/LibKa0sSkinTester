-- tests/test_skin_media.lua — the font and texture overrides (LibKa0s-Skin-1.0 minor 6, ST-01):
-- stored as skin.font and skin.texture ("" is the skin's own), written only through the skin write
-- seam (NS.WriteSkinChoice's fourth argument), and applied with Skin:SetOverride at load, on every
-- profile event and on a row's own write.

local T = _G.SKINTESTER_TEST
local test, assertEqual, assertTrue, assertNil = T.test, T.assertEqual, T.assertTrue, T.assertNil

local OWNER = "LibKa0sSkinTester"
-- Override keys that resolve without LibSharedMedia, which the mock leaves unregistered: a path
-- resolves as itself, so the library lays it over the skin's tokens.
local FACE    = "Interface\\AddOns\\Tester\\face.ttf"
local STRIPES = "Interface\\AddOns\\Tester\\stripes"

local function lib(mock) return mock.LibStub("LibKa0s-Skin-1.0") end
local function profileSkin(NS) return NS.addon.db.profile.skin end

test("media: a fresh profile stores the skin's own font and texture, and the picker unseen", function()
    local NS = T.bootAddon()
    assertEqual(profileSkin(NS).font, "")
    assertEqual(profileSkin(NS).texture, "")
    assertEqual(profileSkin(NS).pickerSeen, false)
end)

test("media: the write seam's fourth argument writes both keys, false as the empty string", function()
    -- red under: WriteSkinChoice dropping its fourth argument (the Skin tab's dropdowns and the
    -- copy would move the look and never store it).
    local NS = T.bootAddon()
    NS.WriteSkinChoice(nil, nil, nil, { font = FACE, texture = STRIPES })
    assertEqual(profileSkin(NS).font, FACE)
    assertEqual(profileSkin(NS).texture, STRIPES)
    NS.WriteSkinChoice(nil, nil, nil, { font = false, texture = STRIPES })
    assertEqual(profileSkin(NS).font, "", "false is the skin's own")
    assertEqual(profileSkin(NS).texture, STRIPES)
    NS.WriteSkinChoice("ka0s", "obsidian")
    assertEqual(profileSkin(NS).texture, STRIPES, "a call without media leaves both keys alone")
end)

test("media: another addon's copy reaches the store through WriteChoice", function()
    -- The "Copy to every Ka0s addon" path: the library moves the override, then calls this
    -- owner's set with media as its fourth argument.
    local NS, _, mock = T.bootAddon()
    local Sk = lib(mock)
    Sk:SetOverride(OWNER, FACE, STRIPES)
    Sk:WriteChoice(OWNER, "ka0s", "ember", nil, { font = FACE, texture = STRIPES })
    assertEqual(profileSkin(NS).skin, "ember")
    assertEqual(profileSkin(NS).font, FACE)
    assertEqual(profileSkin(NS).texture, STRIPES)
end)

test("media: a row's write applies its own half live", function()
    local NS, _, mock = T.bootAddon()
    local H = NS.addon.Settings.Helpers
    H.Set("skin.texture", STRIPES)
    local font, texture = lib(mock):GetOverride(OWNER)
    assertNil(font, "the font half is untouched")
    assertEqual(texture, STRIPES)
    assertEqual(NS.Skin.Token("bar.texture"), STRIPES, "and the owner's tokens carry it")
    H.Set("skin.font", FACE)
    assertEqual(NS.Skin.Token("font.body"), FACE)
    H.Set("skin.texture", "")
    assertNil(select(2, lib(mock):GetOverride(OWNER)), "the empty string clears it")
end)

test("media: the stored overrides are applied at load", function()
    -- red under: ApplySkinChoice's whole-pair path not applying the stored overrides.
    local first = T.bootAddon()
    first.addon.Settings.Helpers.Set("skin.font", FACE)
    first.addon.Settings.Helpers.Set("skin.texture", STRIPES)
    local sv = _G.LibKa0sSkinTesterDB
    local NS, _, mock = T.newAddon()
    _G.LibKa0sSkinTesterDB = sv
    NS.addon:OnInitialize()
    local font, texture = lib(mock):GetOverride(OWNER)
    assertEqual(font, FACE)
    assertEqual(texture, STRIPES)
end)

test("media: a profile switch applies the incoming profile's overrides, and back", function()
    local NS, _, mock = T.bootAddon()
    NS.addon.Settings.Helpers.Set("skin.texture", STRIPES)
    NS.addon.db:SetProfile("Alt")
    assertNil(select(2, lib(mock):GetOverride(OWNER)), "Alt keeps the skin's own")
    NS.addon.db:SetProfile("Default")
    assertEqual(select(2, lib(mock):GetOverride(OWNER)), STRIPES, "Default's is back")
end)

test("media: a profile reset clears the overrides", function()
    local NS, _, mock = T.bootAddon()
    NS.addon.Settings.Helpers.Set("skin.font", FACE)
    NS.addon.db:ResetProfile()
    assertEqual(profileSkin(NS).font, "")
    assertNil(lib(mock):GetOverride(OWNER), "the applied override went with it")
end)

test("media: Ignore fonts wins over a font override", function()
    -- D3: with Ignore fonts on, the library gives every string the game's face (its own suite holds
    -- P.font to that); what this host owes is that both settings reach the library together and
    -- the override is kept, so turning Ignore fonts off brings it straight back.
    local NS, _, mock = T.bootAddon()
    local H, Sk = NS.addon.Settings.Helpers, lib(mock)
    H.Set("skin.font", FACE)
    H.Set("skin.ignoreFonts", true)
    assertTrue(Sk:__FontsIgnored(OWNER), "the fonts are ignored")
    assertEqual(Sk:GetOverride(OWNER), FACE, "and the override is kept")
    assertEqual(profileSkin(NS).font, FACE)
    H.Set("skin.ignoreFonts", false)
    assertTrue(not Sk:__FontsIgnored(OWNER), "Ignore fonts off")
    assertEqual(NS.Skin.Token("font.body"), FACE, "the override face is back on the tokens")
end)

test("media: without the skin engine the apply is a quiet no-op", function()
    local NS = T.bootAddon{ skip = { "libs/LibKa0s/Skin.lua" } }
    assertEqual(NS.ApplySkinMedia(), false)
    NS.addon.Settings.Helpers.Set("skin.texture", STRIPES)
    assertEqual(profileSkin(NS).texture, STRIPES, "the store still takes the write")
end)
