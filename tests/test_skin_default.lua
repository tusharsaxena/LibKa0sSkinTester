-- tests/test_skin_default.lua — the default skin is per client (LibKa0s v1.94.0, Skin minor 18;
-- skinning-§2): a fresh profile wears WoW Forever on the Forever client and Ka0s Default on Retail.
-- Every other suite boots on Ka0s Default by name (tests/run.lua, bootAddon); these boot with
-- `clientDefault`, so they see what a new player sees.
local T = _G.SKINTESTER_TEST
local test, assertEqual = T.test, T.assertEqual

local OWNER = "LibKa0sSkinTester"
-- Pinned from the kit profile, never read back from the addon.
local CLIENT_SKIN = dofile("tests/_kit/mock_client.lua").current() == "forever" and "forever" or "ka0s"

test("skin default: a fresh profile stores and wears the client's default skin", function()
    -- red under: defaults/Profile.lua naming "ka0s" instead of NS.DEFAULT_SKIN.
    local NS, _, mock = T.enableAddon{ clientDefault = true }
    assertEqual(NS.DEFAULT_SKIN, CLIENT_SKIN, "the seam's answer")
    assertEqual(NS.addon.db.profile.skin.skin, CLIENT_SKIN, "the profile's default")
    local source, skin = mock.LibStub("LibKa0s-Skin-1.0"):GetChoice(OWNER)
    assertEqual(source, "ka0s", "a Ka0s skin")
    assertEqual(skin, CLIENT_SKIN, "worn: WoW Forever on Forever, Ka0s Default on Retail")
end)

test("skin default: Reset puts the profile back on the client's default skin", function()
    local NS = T.enableAddon{ clientDefault = true }
    NS.addon.Settings.Helpers.Set("skin.skin", "obsidian")
    assertEqual(NS.addon.db.profile.skin.skin, "obsidian", "picked")
    NS.addon.db:ResetProfile()
    assertEqual(NS.addon.db.profile.skin.skin, CLIENT_SKIN, "reset to the client's default")
end)
