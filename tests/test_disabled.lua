-- tests/test_disabled.lua — the stand-down conformance suite (slash-commands-§7 MUST).
--
-- Every assertion is on what the kit's recording mocks saw (the registration set, the live timer
-- set, the shown frames, the SavedVariables writes and the printed lines), never on what a
-- function returned: a suite written against a handler's early return certifies a draw gate.
--
-- THIS ADDON REGISTERS NO EVENT, MESSAGE OR BUCKET. So step 1's "R_on is non-empty" is replaced
-- by a pin that R_on IS empty, enabled and disabled alike (docs/ARCHITECTURE.md, Documented
-- deviations). The day a first registration is added, step 1 turns red, and its teardown has to
-- arrive with it. The stand-down here is the showroom: it closes, and every route back to the
-- screen refuses while either hold is held.
--
-- Step 7 is the slash surface and it is NOT the stand-down. Steps 1-6 and 10 are.

local T = _G.SKINTESTER_TEST
local test         = T.test
local assertEqual  = T.assertEqual
local assertTrue   = T.assertTrue
local assertFalse  = T.assertFalse
local assertNil    = T.assertNil

local NAME    = "LibKa0sSkinTester"
local WINDOW  = "LibKa0sSkinTesterShowroom"
local BUTTON  = "LibKa0sSkinTesterToggleShowroom"
local REFUSAL = "Ka0s Skin Tester is disabled"
local PERF_LINE = "Not available during a performance capture."

-- ── surveys: every one reads THROUGH the mock ────────────────────────────────────────────────

--- Every registration the kit's survey sees, plus raw frame registrations from this repo's stub.
--- ONE frame is excluded, by identity: LibKa0s-Skin-1.0's EllesmereUI retry frame
--- (`lib.__euiEventFrame`, SkinEUI.lua), which the LIBRARY makes at RegisterOwner to hand owners to
--- EllesmereUI. It is skin-owner setup, which survives a stand-down like the launcher's
--- registration does, and it is the library's to tear down, not this addon's.
local function regNames(mock)
    local out = {}
    for _, r in ipairs(mock.__registrations()) do out[#out + 1] = r.kind .. ":" .. r.event end
    local Skin = mock.LibStub("LibKa0s-Skin-1.0", true)
    local libFrame = Skin and Skin.__euiEventFrame
    for _, f in ipairs(mock.frames) do
        if f ~= libFrame then
            for event in pairs(f.__events or {}) do out[#out + 1] = "frame:" .. event end
        end
    end
    table.sort(out)
    return out
end

local function joined(list) return table.concat(list, ", ") end

--- On screen: the showroom, shown and not faded to nothing.
local function showroomVisible(mock)
    local f = mock.frames[WINDOW]
    return f ~= nil and f:IsShown() and f:GetAlpha() > 0
end

local function up()
    local NS, _, mock = T.enableAddon()
    return NS, mock
end

local function helpers(NS) return NS.addon.Settings.Helpers end

--- Disable through THE SINGLE WRITE SEAM, the route the checkbox and the verb both take, and never
--- by calling NS.StandDown directly.
local function switchOff(NS) helpers(NS).Set("enabled", false) end
local function switchOn(NS)  helpers(NS).Set("enabled", true)  end

local function lines(NS, mock, input)
    local mark = #mock.prints
    NS.addon:OnSlashCommand(input)
    local out = {}
    for i = mark + 1, #mock.prints do out[#out + 1] = mock.prints[i] end
    return out
end

local function anyLine(ls, needle)
    for _, l in ipairs(ls) do if l:find(needle, 1, true) then return true end end
    return false
end

-- ── 1. Baseline ──────────────────────────────────────────────────────────────────────────────

test("disabled 1: enabled, the addon holds NO registration, and that is pinned", function()
    -- red under: any RegisterEvent / RegisterMessage added without updating this suite, which is the
    -- point: a first registration must come with its teardown and its own steps 3, 6 and 9.
    local NS, mock = up()
    NS.Showroom.Show()
    assertEqual(joined(regNames(mock)), "", "the enabled addon watches nothing")
    assertTrue(showroomVisible(mock), "and it is doing something: the showroom is open")
end)

-- ── 2 + 3. Disable through the seam ──────────────────────────────────────────────────────────

test("disabled 3: the registration set stays empty, by count and by name", function()
    -- red under: a stand-down that registers anything (an owed-Hide event, a combat watcher).
    local NS, mock = up()
    switchOff(NS)
    assertEqual(joined(regNames(mock)), "", "still nothing registered")
    assertTrue(NS.Lifecycle:IsHeld(NS.HOLD_DISABLED), "and the write took the disabled hold")
end)

test("disabled 3: the write seam is the route — the checkbox and the verb reach the same latch",
function()
    -- red under: wiring `/st disable` to db.profile.enabled directly, or to a second teardown path.
    local NS = up()
    NS.addon:OnSlashCommand("disable")
    assertTrue(NS.IsStoodDown(), "the verb stands the addon down")
    assertTrue(NS.Lifecycle:IsHeld(NS.HOLD_DISABLED), "through the same named hold")
end)

-- ── 4. Nothing is left armed ─────────────────────────────────────────────────────────────────

test("disabled 4: no timer, ticker or OnUpdate survives, and none is armed afterwards", function()
    -- red under: a showroom refresh ticker that StandDown does not cancel.
    local NS, mock = up()
    NS.Showroom.Show()
    switchOff(NS)
    assertEqual(#mock.__timers(), 0, "nothing is still going to wake up")
    mock.__fire("PLAYER_REGEN_DISABLED")
    mock.__fire("PLAYER_REGEN_ENABLED")
    NS.Showroom.Show()
    assertEqual(#mock.__timers(), 0, "and none was armed by anything that arrived afterwards")
end)

-- ── 5. Every frame that was shown is hidden ──────────────────────────────────────────────────

test("disabled 5: the showroom is hidden, and every route back to the screen refuses", function()
    -- red under: delete the StandDownRefusal check at the top of NS.Showroom.Show; the first half
    -- still passes on the imperative Hide, and the routes below reopen the window.
    local NS, mock = up()
    NS.Showroom.Show()
    assertTrue(showroomVisible(mock), "on screen while the addon is running")
    switchOff(NS)
    assertFalse(showroomVisible(mock), "off screen once it is not")
    NS.Showroom.Show()
    assertFalse(showroomVisible(mock), "Show did not bring it back")
    NS.Showroom.Toggle()
    assertFalse(showroomVisible(mock), "nor did the launcher's toggle seam")
    NS.addon:OnSlashCommand("show")
    assertFalse(showroomVisible(mock), "nor did /st show")
end)

-- ── 6. Fire anyway: no write, no line, no frame ──────────────────────────────────────────────

test("disabled 6: combat edges and a skin change write nothing, say nothing, show nothing", function()
    -- The addon watches no event, so no fire can reach a handler of its own (the deviation row).
    -- What CAN still reach it while disabled is the skin engine's OnLooksChanged, through a skin
    -- change another addon's "Copy to every Ka0s addon" makes; that must open nothing.
    -- red under: an OnLooksChanged handler that builds or shows the showroom.
    local NS, mock = up()
    switchOff(NS)
    mock.__resetSvWrites()
    local marked = #mock.prints
    assertEqual(mock.__fire("PLAYER_REGEN_DISABLED"), 0, "the combat edge reached nobody")
    assertEqual(mock.__fire("PLAYER_REGEN_ENABLED"), 0, "nor did its end")
    local Skin = mock.LibStub("LibKa0s-Skin-1.0")
    Skin:SetChoice(NAME, "ka0s", "obsidian")
    assertEqual(#mock.__svWrites(), 0, "zero SavedVariables writes")
    assertEqual(#mock.prints - marked, 0, "zero printed lines")
    assertFalse(showroomVisible(mock), "zero frames shown")
end)

-- ── 7. The slash surface (not the stand-down) ────────────────────────────────────────────────

test("disabled 7: every reserved verb answers normally, and the bare /st opens the panel", function()
    local NS, mock = up()
    switchOff(NS)
    local H = helpers(NS)
    assertTrue(anyLine(lines(NS, mock, "version"), "v" .. NS.addon.VERSION), "version prints")
    assertTrue(#lines(NS, mock, "list") > 1, "list reads the schema")
    assertTrue(anyLine(lines(NS, mock, "get skin.skin"), "skin.skin"), "get reads a setting")
    lines(NS, mock, "set scale 1.5")
    assertEqual(H.Get("scale"), 1.5, "set REPAIRS a setting while the addon is off")
    lines(NS, mock, "reset scale")
    assertEqual(H.Get("scale"), NS.C.scale, "reset restores its default")
    assertFalse(anyLine(lines(NS, mock, "debug on"), REFUSAL), "debug is a diagnostic, not a feature")
    NS.addon:OnSlashCommand("debug off")
    assertFalse(anyLine(lines(NS, mock, "diagnostics"), REFUSAL), "`diagnostics` is not refused")
    assertFalse(anyLine(lines(NS, mock, "perf"), REFUSAL), "`perf` is reserved and live")
    assertTrue(#lines(NS, mock, "help") > #NS.addon.COMMANDS, "the whole index prints")
    local opened = #mock.openedTo
    NS.addon:OnSlashCommand("")
    assertTrue(#mock.openedTo > opened, "the bare /st opens the settings panel")
    NS.addon:OnSlashCommand("config")
    assertTrue(#mock.openedTo > opened + 1, "and so does `config`")
end)

test("disabled 7: the feature verb answers exactly one refusal line by hold, and writes nothing",
function()
    local NS, mock = up()
    switchOff(NS)
    mock.__resetSvWrites()
    local out = lines(NS, mock, "show")
    assertEqual(#out, 1, "`show` answers on exactly one line")
    assertTrue(out[1]:find(REFUSAL, 1, true) ~= nil, "saying the addon is disabled")
    assertTrue(out[1]:find("/st enable", 1, true) ~= nil, "naming the verb that undoes it")
    assertEqual(#mock.__svWrites(), 0, "and the refusal reached no write seam")

    switchOn(NS)
    NS.Lifecycle:Hold(NS.HOLD_PERF)
    out = lines(NS, mock, "show")
    assertEqual(#out, 1, "under the perf hold alone, one line")
    assertEqual(out[1], NS.PREFIX .. " " .. PERF_LINE, "the collection's perf line, pinned")
    assertNil(out[1]:find(REFUSAL, 1, true), "never the disabled line")
    NS.Lifecycle:Release(NS.HOLD_PERF)
end)

-- ── 8. The launcher and the key binding ──────────────────────────────────────────────────────

test("disabled 8: left-click opens the panel; right-click's menu grays Show window", function()
    local NS, mock = up()
    switchOff(NS)
    local object = mock.ldbObjects[NAME]
    assertTrue(object ~= nil, "the broker object survives the stand-down")
    mock.__resetSvWrites()
    local mark, opened = #mock.prints, #mock.openedTo
    object.OnClick(mock.UIParent, "LeftButton")
    assertEqual(#mock.openedTo, opened + 1, "left-click opens the panel, in either state")
    assertEqual(#mock.prints - mark, 0, "and prints no refusal")
    object.OnClick(mock.UIParent, "RightButton")
    local menu = mock.menu.last
    assertTrue(menu ~= nil, "right-click opens the options menu")
    assertTrue(menu:Find("Enabled").enabled, "Enabled stays live")
    assertFalse(menu:Find("Show window").enabled, "Show window is grayed while disabled")
    menu:Click("Show window")
    assertEqual(#mock.__svWrites(), 0, "a click on a disabled addon writes NOTHING")
    assertFalse(showroomVisible(mock), "and shows nothing")
end)

test("disabled 8: the Show window key press refuses by hold: the disabled line, then the perf line",
function()
    local NS, mock = up()
    local button = mock.frames[BUTTON]
    assertTrue(button ~= nil, "the binding's button survives the stand-down")
    local function press() return button:GetScript("OnClick")(button, "LeftButton", true) end

    switchOff(NS)
    mock.__resetSvWrites()
    local mark = #mock.prints
    press()
    assertEqual(#mock.prints - mark, 1, "a press while disabled answers on exactly one line")
    assertTrue(mock.prints[#mock.prints]:find(REFUSAL, 1, true) ~= nil, "the disabled line")
    assertEqual(#mock.__svWrites(), 0, "and the press wrote NOTHING")
    assertFalse(showroomVisible(mock), "and showed nothing")

    switchOn(NS)
    NS.Lifecycle:Hold(NS.HOLD_PERF)
    mark = #mock.prints
    press()
    assertEqual(#mock.prints - mark, 1, "under the perf hold, one line")
    assertEqual(mock.prints[#mock.prints], NS.PREFIX .. " " .. PERF_LINE, "the perf line")
    assertFalse(showroomVisible(mock), "and the showroom stayed down")
    NS.Lifecycle:Release(NS.HOLD_PERF)
end)

test("disabled 8: with LibKa0s absent the button still exists and a press refuses on the stub's line",
function()
    local NS, _, mock = T.newAddon{ skip = T.loadAddon.libFiles }
    local button = mock.frames[BUTTON]
    assertTrue(button ~= nil, "the button is created without the library")
    NS.Lifecycle:Hold(NS.HOLD_DISABLED)
    local mark = #mock.prints
    button:GetScript("OnClick")(button, "LeftButton", true)
    local own = {}
    for i = mark + 1, #mock.prints do
        if not mock.prints[i]:find("library is missing", 1, true) then own[#own + 1] = mock.prints[i] end
    end
    assertEqual(#own, 1, "one line")
    assertEqual(own[1], NS.PREFIX .. " " .. NS.SlashCommands:DisabledLine(), "the stub's disabled line")
    NS.Lifecycle:Release(NS.HOLD_DISABLED)
end)

-- ── 9. Re-enable from current state ──────────────────────────────────────────────────────────

test("disabled 9: re-enabling restores the (empty) registration set and reopens nothing", function()
    local NS, mock = up()
    NS.Showroom.Show()
    switchOff(NS)
    switchOn(NS)
    assertEqual(joined(regNames(mock)), "", "the same set: still empty")
    assertFalse(showroomVisible(mock), "the window opens only when the player asks")
    NS.Showroom.Show()
    assertTrue(showroomVisible(mock), "and it does open again")
end)

test("disabled 9: a setting changed WHILE DISABLED is what the rebuild reflects", function()
    local NS, mock = up()
    NS.Showroom.Show()
    switchOff(NS)
    NS.addon:OnSlashCommand("set scale 1.5")
    switchOn(NS)
    NS.Showroom.Show()
    assertEqual(mock.frames[WINDOW]:GetScale(), 1.5, "the scale changed while off is the one shown")
end)

-- ── 10. The latch ────────────────────────────────────────────────────────────────────────────

test("disabled 10: releasing the perf hold does NOT resurrect an addon `disabled` still holds down",
function()
    -- red under: a Release that stands the addon up without asking the latch whether a hold remains.
    local NS = up()
    NS.Lifecycle:Hold(NS.HOLD_PERF)
    switchOff(NS)
    NS.Lifecycle:Release(NS.HOLD_PERF)
    assertTrue(NS.IsStoodDown(), "still down: `disabled` is still held")
    switchOn(NS)
    assertFalse(NS.IsStoodDown(), "and only the LAST release stands it up")
end)

test("disabled 10: the other order — disabled first, perf released last", function()
    local NS = up()
    switchOff(NS)
    NS.Lifecycle:Hold(NS.HOLD_PERF)
    switchOn(NS)
    assertTrue(NS.IsStoodDown(), "still down: the perf hold outlived the player's switch")
    assertEqual(joined(NS.Lifecycle:Holds()), "perf", "and it is the only one left")
    NS.Lifecycle:Release(NS.HOLD_PERF)
    assertFalse(NS.IsStoodDown(), "now it stands up")
end)

test("disabled 10: the latch persists nothing", function()
    local NS, mock = up()
    mock.__resetSvWrites()
    NS.Lifecycle:Hold(NS.HOLD_PERF)
    NS.Lifecycle:Release(NS.HOLD_PERF)
    assertEqual(#mock.__svWrites(), 0, "a perf hold and its release wrote nothing to disk")
end)

-- ── what survives ────────────────────────────────────────────────────────────────────────────

test("disabled: the chat command, the db, the launcher and the skin owner all survive", function()
    local NS, mock = up()
    switchOff(NS)
    local console = mock.__libs["AceConsole-3.0"]
    assertTrue(console.commands["st"] ~= nil, "the chat command is still registered")
    assertTrue(console.commands["skintester"] ~= nil, "and so is its alias")
    assertTrue(NS.addon.db ~= nil, "the AceDB handle survives")
    assertTrue(mock.ldbObjects[NAME] ~= nil, "the launcher registration survives")
    assertTrue(mock.LibStub("LibKa0s-Skin-1.0"):IsOwner(NAME), "and so does the skin owner")
end)

test("disabled: a profile switch that flips `enabled` is re-evaluated, both ways", function()
    local NS = up()
    NS.addon.db:SetProfile("off-profile")
    helpers(NS).Set("enabled", false)
    assertTrue(NS.IsStoodDown())
    NS.addon.db:SetProfile("Default")
    assertFalse(NS.IsStoodDown(), "the enabled default profile stood it back up")
end)
