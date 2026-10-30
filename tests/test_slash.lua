-- tests/test_slash.lua — the slash surface: the COMMANDS table this addon owns, the host verbs, and
-- the LibKa0s-Slash-1.0 descriptor's wiring. The dispatcher, the formatter and the parser are the
-- library's and are tested there; what is asserted here is that THIS addon's rows, paths and verbs
-- reach them.

local T = _G.SKINTESTER_TEST
local test, assertEqual, assertTrue, assertFalse = T.test, T.assertEqual, T.assertTrue, T.assertFalse

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

local function H(NS) return NS.addon.Settings.Helpers end

-- ── the table ────────────────────────────────────────────────────────────────────────────────

test("slash: COMMANDS order is the help order, seventeen positional triples", function()
    local NS = T.newAddon()
    local names = {}
    for _, c in ipairs(NS.addon.COMMANDS) do
        assertEqual(type(c[1]), "string"); assertEqual(type(c[2]), "string"); assertEqual(type(c[3]), "function")
        names[#names + 1] = c[1]
    end
    assertEqual(table.concat(names, " "),
        "help show widths config skin enable disable version list get set reset resetall profile debug diagnostics perf")
end)

test("slash: every description has an enUS entry", function()
    local NS = T.newAddon()
    for _, c in ipairs(NS.addon.COMMANDS) do
        assertTrue(rawget(NS.L, c[2]) ~= nil, c[1] .. "'s description is not in locales/enUS.lua")
    end
end)

test("slash: the chat command and its alias are registered through AceConsole", function()
    local _, _, mock = T.bootAddon()
    local console = mock.__libs["AceConsole-3.0"]
    assertTrue(console.commands["st"] ~= nil, "/st")
    assertTrue(console.commands["skintester"] ~= nil, "/skintester")
end)

-- ── the reserved verbs ───────────────────────────────────────────────────────────────────────

test("slash: the help header is the library's, with this addon's alias sentence", function()
    local NS, _, mock = T.enableAddon()
    local out = run(NS, mock, "help")
    assertTrue(anyLine(out, "v" .. NS.addon.VERSION), "the version")
    assertTrue(anyLine(out, "/skintester"), "names the alias")
    assertTrue(#out > #NS.addon.COMMANDS, "and lists every command")
end)

test("slash: version prints the tagged version", function()
    local NS, _, mock = T.enableAddon()
    local out = run(NS, mock, "version")
    assertEqual(#out, 1)
    assertTrue(out[1]:find(NS.PREFIX, 1, true) == 1, "tagged")
    assertTrue(out[1]:find("v0.1.0", 1, true) ~= nil, "the TOC's version")
end)

test("slash: a bare /st opens the settings panel, and so does config", function()
    local NS, _, mock = T.enableAddon()
    local opened = #mock.openedTo
    NS.addon:OnSlashCommand("")
    NS.addon:OnSlashCommand("config")
    assertEqual(#mock.openedTo, opened + 2)
end)

test("slash: list groups the rows under their sections, with current values", function()
    local NS, _, mock = T.enableAddon()
    H(NS).Set("scale", 1.5)
    local out = run(NS, mock, "list")
    assertTrue(anyLine(out, "[general]"), "the Master controls rows' section")
    assertTrue(anyLine(out, "[skin]"), "the Skin tab rows' section")
    assertTrue(anyLine(out, "skin.skin"), "the skin row")
    assertTrue(anyLine(out, "1.5"), "the current scale, not the default")
end)

test("slash: get and set reach the write seam for a number row, clamped to its range", function()
    local NS, _, mock = T.enableAddon()
    run(NS, mock, "set scale 1.5")
    assertEqual(H(NS).Get("scale"), 1.5)
    run(NS, mock, "set scale 9")
    assertEqual(H(NS).Get("scale"), 2, "clamped to the row's max")
    run(NS, mock, "set scale 0.1")
    assertEqual(H(NS).Get("scale"), 0.5, "and to its min")
    assertTrue(anyLine(run(NS, mock, "get scale"), "scale"), "get prints the path")
    run(NS, mock, "set scale abc")
    assertEqual(H(NS).Get("scale"), 0.5, "a non-number is refused and writes nothing")
end)

test("slash: a bool row takes the library's words and `toggle`", function()
    local NS, _, mock = T.enableAddon()
    for _, w in ipairs({ "off", "0", "false", "NO" }) do
        run(NS, mock, "set enabled " .. w)
        assertFalse(H(NS).Get("enabled"), w .. " is false")
        run(NS, mock, "set enabled on")
        assertTrue(H(NS).Get("enabled"), "on is true")
    end
    run(NS, mock, "set enabled toggle")
    assertFalse(H(NS).Get("enabled"), "toggle flips it")
    run(NS, mock, "set enabled toggle")
    assertTrue(H(NS).Get("enabled"), "and back")
    local out = run(NS, mock, "set enabled maybe")
    assertTrue(anyLine(out, "toggle"), "a bad word lists the accepted ones, toggle among them")
end)

test("slash: the skin row accepts a registered skin and refuses an unknown key", function()
    local NS, _, mock = T.enableAddon()
    run(NS, mock, "set skin.skin obsidian")
    assertEqual(H(NS).Get("skin.skin"), "obsidian")
    run(NS, mock, "set skin.skin nope")
    assertEqual(H(NS).Get("skin.skin"), "obsidian", "an unknown skin is refused")
end)

test("slash: reset takes a path; a bare reset explains itself and writes nothing", function()
    local NS, _, mock = T.enableAddon()
    H(NS).Set("scale", 1.5)
    local out = run(NS, mock, "reset")
    assertTrue(anyLine(out, "/st reset <path>") or anyLine(out, "/st reset"), "the usage")
    assertEqual(H(NS).Get("scale"), 1.5, "a bare reset wrote nothing")
    run(NS, mock, "reset scale")
    assertEqual(H(NS).Get("scale"), 1)
end)

test("slash: enable and disable write the Enable row and move the latch", function()
    local NS, _, mock = T.enableAddon()
    run(NS, mock, "disable")
    assertFalse(H(NS).Get("enabled"))
    assertTrue(NS.IsStoodDown())
    run(NS, mock, "enable")
    assertTrue(H(NS).Get("enabled"))
    assertFalse(NS.IsStoodDown())
end)

test("slash: debug toggles the WINDOW, `on`/`off` the flag, and an unknown word the window", function()
    local NS, _, mock = T.enableAddon()
    run(NS, mock, "debug on")
    assertTrue(NS.State.debug)
    run(NS, mock, "debug off")
    assertFalse(NS.State.debug)
    local shown = NS.DebugLog:IsShown()
    run(NS, mock, "debug")
    assertTrue(NS.DebugLog:IsShown() ~= shown, "bare debug toggled the window")
    run(NS, mock, "debug wibble")
    assertEqual(NS.DebugLog:IsShown(), shown, "an unknown word toggled it back")
    assertFalse(NS.State.debug, "and the flag never moved")
end)

test("slash: perf is registered by the addon and answers through the library", function()
    local NS, _, mock = T.enableAddon()
    local out = run(NS, mock, "perf")
    assertTrue(#out >= 1, "the harness answered")
    assertFalse(anyLine(out, "unknown command"), "perf is a known verb here")
end)

-- ── the feature verb ─────────────────────────────────────────────────────────────────────────

test("slash: show toggles the showroom while enabled", function()
    local NS, _, mock = T.enableAddon()
    run(NS, mock, "show")
    assertTrue(mock.frames["LibKa0sSkinTesterShowroom"]:IsShown(), "opened")
    run(NS, mock, "show")
    assertFalse(mock.frames["LibKa0sSkinTesterShowroom"]:IsShown(), "closed")
end)

test("slash: degraded, the CLI verbs name the missing library and nothing raises", function()
    local NS, _, mock = T.newAddon{ skip = T.loadAddon.libFiles }
    NS.addon:OnInitialize()
    local out = run(NS, mock, "set scale 1.5")
    assertTrue(anyLine(out, "LibKa0s library is missing"), "set names the absence")
    out = run(NS, mock, "enable")
    assertTrue(anyLine(out, "/st enable is unavailable"), "enable takes route (b): the library-absent line")
end)


-- ── the /st collision ────────────────────────────────────────────────────────────────────────
-- `/st` is two letters and another addon may hold it. The check runs at PLAYER_LOGIN (OnEnable),
-- once every addon has registered: a foreign `/st` keeps it, this addon keeps `/skintester`, and
-- one tagged line says so.

local function foreignSt(mock)
    local calls = 0
    mock.SlashCmdList.OTHER = function() calls = calls + 1 end
    mock.SLASH_OTHER1 = "/st"
    return function() return calls end
end

test("slash: /skintester opens the window", function()
    local NS, _, mock = T.enableAddon()
    local console = mock.__libs["AceConsole-3.0"]
    mock.SlashCmdList[console.commands["skintester"]]("show")
    assertTrue(mock.frames["LibKa0sSkinTesterShowroom"]:IsShown(), "opened")
    local _ = NS
end)

test("slash: a foreign /st is reported once and left alone", function()
    local NS, _, mock = T.bootAddon()
    local calls = foreignSt(mock)
    local mark = #mock.prints
    NS.addon:OnEnable()
    assertEqual(#mock.prints - mark, 1, "one line")
    assertTrue(mock.prints[#mock.prints]:find("/skintester", 1, true) ~= nil, "naming /skintester")
    local console = mock.__libs["AceConsole-3.0"]
    assertTrue(console.commands["st"] == nil, "this addon let go of /st")
    assertTrue(mock.SlashCmdList.OTHER ~= nil and mock.SLASH_OTHER1 == "/st", "the other addon keeps it")
    mock.SlashCmdList.OTHER("")
    assertEqual(calls(), 1, "and /st still reaches it")
    mock.SlashCmdList[console.commands["skintester"]]("show")
    assertTrue(mock.frames["LibKa0sSkinTesterShowroom"]:IsShown(), "/skintester still opens the window")
end)

test("slash: with no foreign /st, nothing is said and both commands stay", function()
    local NS, _, mock = T.bootAddon()
    local mark = #mock.prints
    NS.addon:OnEnable()
    assertEqual(#mock.prints - mark, 0, "silent")
    local console = mock.__libs["AceConsole-3.0"]
    assertTrue(console.commands["st"] ~= nil and console.commands["skintester"] ~= nil)
end)
