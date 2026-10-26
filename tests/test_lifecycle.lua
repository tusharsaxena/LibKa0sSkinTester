-- tests/test_lifecycle.lua — the addon shell: OnInitialize / OnEnable wiring,
-- the file-load hooksecurefunc post-hooks, the GROUP_ROSTER_UPDATE state
-- machine, the chat-link handler, and the action slash commands.
local T = _G.SKINTESTER_TEST
local test, assertEqual, assertTrue, assertFalse, assertNil =
    T.test, T.assertEqual, T.assertTrue, T.assertFalse, T.assertNil

-- ---------------------------------------------------------------------------
-- Namespace + bootstrap invariants
-- ---------------------------------------------------------------------------

test("lifecycle: the addon exposes no public global (WhatGroup WG-01)", function()
    local NS = T.bootAddon()
    assertNil(rawget(_G, "LibKa0sSkinTester"), "the addon must stay in its private namespace")
    assertTrue(NS.addon ~= nil, "NS.addon is the only handle")
end)

test("lifecycle: NS IS the addon object (AceAddon mixes into the namespace)", function()
    local NS = T.bootAddon()
    assertEqual(NS.addon, NS, "NS.addon aliases the same table")
end)

test("lifecycle: earlier files' fields survive NewAddon", function()
    local NS = T.bootAddon()
    -- locales, Util, Compat and Database all hang fields on NS BEFORE
    -- AceAddon:NewAddon runs; NewAddon must preserve them.
    for _, field in ipairs({ "L", "Util", "Constants", "Windows", "SafeToString" }) do
        assertTrue(NS[field] ~= nil, "NewAddon dropped NS." .. field)
    end
    assertEqual(type(NS.RunMigrations), "function")
end)

test("lifecycle: the shared chat prefix is the cyan [ST] tag", function()
    local NS = T.bootAddon()
    assertEqual(NS.PREFIX, "|cff00FFFF[ST]|r")
end)

test("lifecycle: NS.Print, LibKa0sSkinTester._print and NS.Util.print are one seam", function()
    local NS = T.bootAddon()
    assertEqual(NS.Print, NS.Util.print)
    assertEqual(NS.addon._print, NS.Util.print)
end)

test("lifecycle: debug state is session-only and starts off", function()
    local NS = T.bootAddon()
    assertFalse(NS.State.debug)
    assertNil(NS.addon.db.profile.debug, "it is never persisted (WhatGroup WG-12)")
end)

-- ---------------------------------------------------------------------------
-- OnInitialize / OnEnable
-- ---------------------------------------------------------------------------

test("lifecycle: OnInitialize builds the db from the schema defaults", function()
    local NS = T.bootAddon()
    assertTrue(NS.addon.db ~= nil)
    assertEqual(NS.addon.db.profile.enabled, true)
    assertEqual(NS.addon.db.global.schemaVersion, 1)
end)

test("lifecycle: OnInitialize registers both slash verbs", function()
    local NS, _, mock = T.bootAddon()
    local AceConsole = mock.LibStub("AceConsole-3.0")
    assertEqual(AceConsole.commands["st"], "ACECONSOLE_ST")
    assertEqual(AceConsole.commands["skintester"], "ACECONSOLE_SKINTESTER")
    -- Both route to OnSlashCommand. The kit's handler looks the method up when the verb is typed,
    -- so a spy put in its place hears exactly what each verb delivers.
    local heard = {}
    NS.addon.OnSlashCommand = function(_, input) heard[#heard + 1] = input end
    AceConsole:__slash("st", "one")
    AceConsole:__slash("skintester", "two")
    assertEqual(table.concat(heard, ","), "one,two")
end)

test("lifecycle: no events are registered before OnEnable", function()
    local NS = T.bootAddon()
    assertNil(NS.addon.__events["GROUP_ROSTER_UPDATE"])
end)

-- ---------------------------------------------------------------------------
-- File-load post-hooks (installed at load, NOT in OnEnable — taint)
-- ---------------------------------------------------------------------------

-- ---------------------------------------------------------------------------
-- The details chat link, clicked through Blizzard's own SetItemRef
-- ---------------------------------------------------------------------------
--
-- Every click below goes through `mock.SetItemRef`, the transcription of Blizzard's (wow_mock.lua,
-- fidelity note 7), with the link the notification actually printed. Firing a recorded post-hook
-- by hand, which these cases did until 2026-09-12, skips the part of the click that failed in the
-- client: Blizzard's own body, which ran first and fell through to the ItemRef tooltip for an
-- unregistered link type before any hook of ours could run.

-- ---------------------------------------------------------------------------
-- InitSummary (debug-logging-§5)
-- ---------------------------------------------------------------------------

test("lifecycle: InitSummary reflects live runtime state", function()
    local NS = T.bootAddon()
    NS.addon.Settings.Helpers.Set("enabled", false)
    NS.addon.Settings.Helpers.Set("skin.skin", "obsidian")
    local s = NS.addon:InitSummary()
    assertTrue(s:find("enabled=false", 1, true) ~= nil, s)
    assertTrue(s:find("skin=ka0s:obsidian", 1, true) ~= nil, s)
end)

test("lifecycle: InitSummary is safe before the db exists", function()
    local NS = T.newAddon()   -- no OnInitialize → no db
    local ok, s = pcall(function() return NS.addon:InitSummary() end)
    assertTrue(ok, "the summary must not raise pre-login")
    assertTrue(s:find("LibKa0sSkinTester v", 1, true) ~= nil)
end)

-- ---------------------------------------------------------------------------
-- /st config
-- ---------------------------------------------------------------------------

local function runCmd(NS, name, rest)
    for _, c in ipairs(NS.addon.COMMANDS) do
        -- Positional triples, and the handler takes `rest` ALONE: the library calls
        -- entry[3](rest), never entry[3](self, rest).
        if c[1] == name then return c[3](rest) end
    end
    error("no command: " .. tostring(name))
end

test("lifecycle: /st config opens the parent settings category", function()
    local NS, _, mock = T.enableAddon()
    runCmd(NS, "config")
    assertEqual(#mock.openedTo, 1)
    assertEqual(mock.openedTo[1], mock.categories[1]:GetID())
end)

test("lifecycle: /st config is refused during combat (options-ui-§2)", function()
    local NS, _, mock = T.enableAddon()
    mock.combat = true
    runCmd(NS, "config")
    assertEqual(#mock.openedTo, 0, "no defer-and-replay; it simply refuses")
    assertTrue(mock.prints[#mock.prints]:find("combat", 1, true) ~= nil)
end)

-- options-ui-§9: the category still registers at login with no user action; in combat the library
-- parks it and lands it at combat end, before `/st config` can be run out of combat.
-- red under: LibKa0s Options registering immediately under InCombatLockdown (pre-LK-25)
test("lifecycle: a login taken in combat registers the panel at combat end", function()
    local NS, env, mock = T.bootAddon()
    mock.combat = true
    NS.addon:OnEnable()
    assertEqual(#mock.categories, 0, "the login registration is parked in combat")
    mock.combat = false
    local park = env.LibStub("LibKa0s-Options-1.0").__parkFrame
    assertTrue(park ~= nil and park.__events.PLAYER_REGEN_ENABLED, "the park listens for combat end")
    park.__fire("OnEvent", "PLAYER_REGEN_ENABLED")
    assertEqual(#mock.categories, 2, "the category is in the AddOns list once combat ends")
    runCmd(NS, "config")
    assertEqual(#mock.categories, 2, "and runConfig's fallback call registers nothing more")
    assertEqual(#mock.openedTo, 1)
end)

-- ---------------------------------------------------------------------------
-- /st test and /st show
-- ---------------------------------------------------------------------------

-- ---------------------------------------------------------------------------
-- /st reset
-- ---------------------------------------------------------------------------

-- `reset` takes a PATH now (convergence #1). The global wipe moved to `resetall`, which kept the
-- confirmation the destructive path has always had — on BOTH entry points, since it and the panel's
-- Defaults button reach one OnAccept body.

test("lifecycle: /st reset <path> resets one setting, with no confirmation", function()
    local NS, _, mock = T.bootAddon()
    local H = NS.addon.Settings.Helpers
    H.Set("scale", 1.5)
    H.Set("alpha", 0.5)
    local before = #mock.popups
    runCmd(NS, "reset", "scale")
    assertEqual(H.Get("scale"), 1, "the named row went back to its default")
    assertEqual(H.Get("alpha"), 0.5, "and nothing else moved")
    assertEqual(#mock.popups, before, "a one-row reset is not destructive enough to confirm")
end)

test("lifecycle: a bare /st reset explains the change rather than resetting or erroring", function()
    -- It ships with a deprecation message rather than silently: the old form still PARSES as
    -- something, so "Usage: /st reset <path>" would tell a user their syntax is wrong rather than
    -- that the verb changed.
    local NS, _, mock = T.bootAddon()
    NS.addon.Settings.Helpers.Set("scale", 1.5)
    local mark = #mock.prints
    runCmd(NS, "reset")
    assertEqual(NS.addon.Settings.Helpers.Get("scale"), 1.5, "nothing was reset")
    local said, pointed = false, false
    for i = mark + 1, #mock.prints do
        if mock.prints[i]:find("takes a setting path", 1, true) then said = true end
        if mock.prints[i]:find("/st resetall", 1, true) then pointed = true end
    end
    assertTrue(said, "it says what changed")
    assertTrue(pointed, "and names the replacement for the old behavior")
end)

test("lifecycle: /st resetall asks for confirmation rather than resetting outright", function()
    local NS, _, mock = T.bootAddon()
    NS.addon.Settings.Helpers.Set("scale", 1.5)
    runCmd(NS, "resetall")
    assertEqual(mock.popups[#mock.popups], "LIBKA0SSKINTESTER_RESET_ALL")
    assertEqual(NS.addon.Settings.Helpers.Get("scale"), 1.5)
end)

test("lifecycle: /st resetall and the Defaults button share one OnAccept body", function()
    local NS, env = T.bootAddon()
    NS.addon.Settings.Helpers.Set("scale", 1.5)
    runCmd(NS, "resetall")
    env.StaticPopupDialogs["LIBKA0SSKINTESTER_RESET_ALL"].OnAccept()
    assertEqual(NS.addon.Settings.Helpers.Get("scale"), 1)
end)
