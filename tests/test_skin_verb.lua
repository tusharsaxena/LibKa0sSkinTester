-- tests/test_skin_verb.lua — the reserved `skin` verb (LibKa0s v1.82.0, OptionsSkinPicker minor 3's
-- O.SkinVerb; ST-01 of Ka0sAddonsCommonTasks docs/2026-10-30-SKIN_FONTS_AND_FEEDBACK, ruling D-16):
-- a `skin` row after `config` runs NS.RunSkinVerb, which hands O.SkinVerb the first-run spec, so
-- `/st skin` shows the picker a new profile shows whatever skin.pickerSeen says. Refused while the
-- addon is disabled (the dispatcher's gate), a gray line on every call in combat (the library's),
-- and the library-absent line without LibKa0s. The showroom's "Show the picker" takes the same route.

local T = _G.SKINTESTER_TEST
local test, assertEqual, assertTrue, assertFalse = T.test, T.assertEqual, T.assertTrue, T.assertFalse

local PREFIX = "LibKa0sSkinPickerLibKa0sSkinTester"
local REFUSAL = "is disabled"

local function picker(mock)
    for name, f in pairs(mock.frames) do
        if type(name) == "string" and name:sub(1, #PREFIX) == PREFIX then return f end
    end
end

local function shown(mock)
    local f = picker(mock)
    return f ~= nil and f:IsShown() and true or false
end

local function run(NS, mock, input)
    local mark = #mock.prints
    NS.addon:OnSlashCommand(input)
    local out = {}
    for i = mark + 1, #mock.prints do out[#out + 1] = mock.prints[i] end
    return out
end

local function anyLine(lines, fragment)
    for _, l in ipairs(lines) do if l:find(fragment, 1, true) then return true end end
    return false
end

--- Logged in, the first-run picker closed, so only the verb can bring it back.
local function seenProfile()
    local NS, _, mock = T.enableAddon()
    NS.StandDownSkinPicker()
    NS.addon.db.profile.skin.pickerSeen = true
    assertFalse(shown(mock), "the first-run picker is down")
    return NS, mock
end

local function strings(mock) return mock.LibStub("LibKa0s-Options-1.0").SKIN_PICKER_STRINGS end

test("skin verb: the row sits right after config, with the library's help words", function()
    local NS, _, mock = T.newAddon()
    local at
    for i, c in ipairs(NS.addon.COMMANDS) do
        if c[1] == "skin" then at = i end
    end
    assertTrue(at ~= nil, "a skin row")
    assertEqual(NS.addon.COMMANDS[at - 1][1], "config", "after config")
    assertEqual(NS.addon.COMMANDS[at][2], strings(mock).VERB_HELP, "one wording for every host")
end)

test("skin verb: /st skin shows the picker on a profile that has closed it", function()
    -- red under: no skin row (the dispatcher answers "unknown command").
    local NS, mock = seenProfile()
    local out = run(NS, mock, "skin")
    assertTrue(shown(mock), "the picker is up")
    assertFalse(anyLine(out, "unknown command"), "a known verb")
    assertEqual(picker(mock).title:GetText(), "Choose a skin")
end)

test("skin verb: NS.RunSkinVerb hands O.SkinVerb this addon's first-run spec", function()
    local NS = seenProfile()
    local H = NS.addon.Settings.Helpers
    local live, seen = H.SkinVerb, nil
    H.SkinVerb = function(spec) seen = spec; return nil, "queued" end
    local ok, why = NS.RunSkinVerb()
    H.SkinVerb = live
    assertTrue(seen == NS.SKIN_PICKER_SPEC, "the spec the first-run start builds")
    assertFalse(ok, "nothing shown")
    assertEqual(why, "queued", "the library's reason, passed on")
end)

test("skin verb: in combat every call prints the library's gray line and shows nothing", function()
    local NS, mock = seenProfile()
    mock.combat = true
    local first = run(NS, mock, "skin")
    local second = run(NS, mock, "skin")
    assertFalse(shown(mock), "no picker mid-combat")
    assertTrue(anyLine(first, strings(mock).VERB_COMBAT), "the first call says why")
    assertTrue(anyLine(second, strings(mock).VERB_COMBAT), "and so does every later one")
end)

test("skin verb: refused while the addon is disabled, and no picker shows", function()
    local NS, mock = seenProfile()
    NS.addon:OnSlashCommand("disable")
    local out = run(NS, mock, "skin")
    assertEqual(#out, 1, "one refusal line")
    assertTrue(out[1]:find(REFUSAL, 1, true) ~= nil, "the disabled line")
    assertFalse(shown(mock))
end)

test("skin verb: without LibKa0s the verb prints the library-absent line", function()
    local NO_LIBKA0S = {
        "libs/LibKa0s/Core.lua", "libs/LibKa0s/Options.lua", "libs/LibKa0s/Slash.lua",
        "libs/LibKa0s/Schema.lua", "libs/LibKa0s/Skin.lua",
    }
    local NS, _, mock = T.newAddon{ skip = NO_LIBKA0S }
    local out = run(NS, mock, "skin")
    assertTrue(anyLine(out, "/st skin is unavailable: the LibKa0s library did not load."), "names the verb")
end)

test("skin verb: the showroom's Show the picker goes through O.SkinVerb", function()
    local NS, mock = seenProfile()
    NS.Showroom.Show()
    local H = NS.addon.Settings.Helpers
    local live, calls = H.SkinVerb, 0
    H.SkinVerb = function(spec) calls = calls + 1; return live(spec) end
    NS.Showroom.Section("widgets").pickerButton.__fire("OnClick", "LeftButton")
    H.SkinVerb = live
    assertEqual(calls, 1, "one call through the verb's act")
    assertTrue(shown(mock), "and the picker is up")
end)
