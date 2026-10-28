-- tests/test_panel.lua — the Blizzard canvas settings panel (settings/Panel.lua):
-- registration, the deferred lazy build, schema→widget rendering, the widget
-- write-back path, refresher re-sync, and the landing page.
--
-- The panel builds nothing synchronously: OnShow only schedules a
-- C_Timer.After(0, …) hop (so no AceGUI frame is ever created inside one of
-- Blizzard's secure-execute chains). Suites therefore drive it in two beats —
-- fire OnShow, then `mock.fireCTimers()` — which is exactly the client's
-- sequence, and means the deferral itself is under test rather than bypassed.
local T = _G.SKINTESTER_TEST
local test, assertEqual, assertTrue, assertFalse, assertNil =
    T.test, T.assertEqual, T.assertTrue, T.assertFalse, T.assertNil

local function panels(mock)
    return mock.frames["LibKa0sSkinTesterParentPanel"], mock.frames["LibKa0sSkinTesterGeneralPanel"]
end

-- Open a panel the way the client does: Show it (which fires OnShow), then the
-- next frame. `Show` rather than a bare `__fire("OnShow")`, because the library
-- refuses to refresh a page whose panel does not report itself shown — so a
-- panel driven by firing the handler alone would render once and then never
-- re-sync (options-ui-§11).
local function open(mock, panel)
    panel:Show()
    mock.fireCTimers()
end

-- The LAST widget matching a predicate. A re-render releases its widgets and
-- builds new ones, so a search from the front keeps finding the stale copy.
local function lastWidget(mock, widgetType, labelText)
    local found
    for _, w in ipairs(mock.aceWidgets) do
        if w.type == widgetType and (w.labelText == labelText or w.text == labelText) then
            found = w
        end
    end
    return found
end

-- Build the General page and return (NS, env, mock).
local function openGeneral()
    local NS, env, mock = T.enableAddon()
    local _, general = panels(mock)
    open(mock, general)
    return NS, env, mock
end

local function widget(mock, widgetType, labelText)
    return mock.findWidget(function(w)
        return w.type == widgetType and (w.labelText == labelText or w.text == labelText)
    end)
end

-- The tab strip's buttons are NOT AceGUI widgets: `LibKa0s-Options-1.0` builds them with
-- CreateFrame inside the page's chrome band (options-ui-§13), so they live in `mock.frames`
-- rather than in `mock.aceWidgets`. Last match wins, for the reason `lastWidget` gives — a tab
-- click rebuilds the whole strip and the stale buttons stay in the mock's ledger.
local function tabButton(mock, label)
    local found
    for _, f in ipairs(mock.frames) do
        if f.__kind == "Button" and f.__text == label then found = f end
    end
    return found
end

-- Click a tab and let it re-render. The re-render is SYNCHRONOUS: the deferral this addon wraps
-- around SetRenderer covers the library's OnShow path, and a tab click is not that path — it is a
-- ClearScroll plus a fresh RenderTabbedSchema inside an already-open panel.
local function selectTab(mock, label)
    local b = tabButton(mock, label)
    assertTrue(b ~= nil, "no tab labeled " .. label)
    b.__fire("OnClick")
    return b
end

-- ---------------------------------------------------------------------------
-- Registration
-- ---------------------------------------------------------------------------

test("panel: OnEnable registers the parent category and the General subcategory", function()
    local _, _, mock = T.enableAddon()
    assertEqual(#mock.categories, 3)
    assertEqual(mock.categories[1].label, "Ka0s Skin Tester")
    assertEqual(mock.categories[2].label, "General")
end)

test("panel: the parent category is added to the AddOns list", function()
    local _, _, mock = T.enableAddon()
    assertEqual(mock.registeredCategory, mock.categories[1])
end)

test("panel: Register is idempotent — a second call registers nothing more", function()
    local NS, _, mock = T.enableAddon()
    NS.addon.Settings.Register()
    NS.addon.Settings.Register()
    assertEqual(#mock.categories, 3)
end)

-- End combat the way the client does for LibKa0s Options' registration park (minor 24): the
-- library's private park frame hears PLAYER_REGEN_ENABLED. Answers the park frame, so a case can
-- assert the event was let go after the replay.
local function endCombat(env, mock)
    mock.combat = false
    local lib = env.LibStub("LibKa0s-Options-1.0")
    local f = lib.__parkFrame
    assertTrue(f ~= nil and f.__events.PLAYER_REGEN_ENABLED,
        "the library parked the registration and listens for the end of combat")
    f.__fire("OnEvent", "PLAYER_REGEN_ENABLED")
    return f
end

-- options-ui-§9: the category still registers at login with no user action; in combat the library
-- parks it and lands it at combat end. LibKa0sSkinTester's `Settings.Register` carries no combat guard of
-- its own: an `InCombatLockdown()` early-return there would leave the idempotence flag unset and
-- LibKa0sSkinTester missing from the Settings → AddOns list after any `/reload` taken in combat, which is
-- exactly what WG-A-12 filed. Restoring such a guard turns this case red.
-- red under: LibKa0s Options registering immediately under InCombatLockdown (pre-LK-25)
test("panel: a registration taken in combat is parked and lands at PLAYER_REGEN_ENABLED, with no second host call", function()
    local NS, env, mock = T.bootAddon()
    mock.combat = true
    NS.addon.Settings.Register()
    assertTrue(NS.addon._settingsRegistered, "the idempotence flag is set; the library owns the replay")
    assertEqual(#mock.categories, 0, "nothing registers under InCombatLockdown()")
    local f = endCombat(env, mock)
    assertEqual(#mock.categories, 3, "the parked registration lands at combat end")
    assertFalse(f.__events.PLAYER_REGEN_ENABLED and true or false,
        "the park lets go of PLAYER_REGEN_ENABLED once drained")
    NS.addon.Settings.Register()
    assertEqual(#mock.categories, 3, "a second Register registers nothing more")
end)

-- red under: LibKa0s Options registering immediately under InCombatLockdown (pre-LK-25)
test("panel: a login taken in combat is parked and lands at combat end, with no second registration", function()
    local NS, env, mock = T.bootAddon()
    mock.combat = true
    NS.addon:OnEnable()
    assertEqual(#mock.categories, 0, "the login registration is parked in combat")
    endCombat(env, mock)
    assertEqual(#mock.categories, 3, "and lands at combat end with no user action")
    NS.addon.Settings.Register()
    assertEqual(#mock.categories, 3, "the landed registration stands; the second call is a no-op")
end)

test("panel: registration validates the schema", function()
    local NS = T.enableAddon()
    assertEqual(NS.addon.Settings.Helpers.ValidateSchema(), 0,
        "the shipped schema must register cleanly")
end)

test("panel: both panels start hidden", function()
    local _, _, mock = T.enableAddon()
    local main, general = panels(mock)
    assertFalse(main:IsShown())
    assertFalse(general:IsShown())
end)

-- ---------------------------------------------------------------------------
-- The deferred build (taint contract)
-- ---------------------------------------------------------------------------

test("panel: registration creates no AceGUI widgets", function()
    local _, _, mock = T.enableAddon()
    assertEqual(#mock.aceWidgets, 0,
        "nothing is built at PLAYER_LOGIN — not even the Defaults button")
end)

test("panel: OnShow itself builds nothing; the deferred hop does", function()
    local _, _, mock = T.enableAddon()
    local _, general = panels(mock)
    general.__fire("OnShow")
    assertEqual(#mock.aceWidgets, 0, "the synchronous OnShow body stays a no-op")
    assertTrue(#mock.timers > 0, "a next-frame hop is queued instead")
    mock.fireCTimers()
    assertTrue(#mock.aceWidgets > 0, "the widgets appear on the next frame")
end)

test("panel: the build is one-shot across repeated shows", function()
    local _, _, mock = T.enableAddon()
    local _, general = panels(mock)
    open(mock, general)
    local built = #mock.aceWidgets
    open(mock, general)
    open(mock, general)
    assertEqual(#mock.aceWidgets, built, "re-opening does not rebuild the page")
end)

test("panel: two OnShows before the hop runs still build only once", function()
    local _, _, mock = T.enableAddon()
    local _, general = panels(mock)
    general.__fire("OnShow")
    general.__fire("OnShow")
    mock.fireCTimers()
    local cbs = 0
    for _, w in ipairs(mock.aceWidgets) do
        if w.type == "CheckBox" and w.labelText == "Enable Skin Tester" then cbs = cbs + 1 end
    end
    assertEqual(cbs, 1, "the `scheduled` guard prevents a double build")
end)

test("panel: the Defaults button is built lazily, on the General page only", function()
    local _, _, mock = T.enableAddon()
    local main, general = panels(mock)
    open(mock, main)
    assertNil(widget(mock, "Button", "Defaults"),
        "the landing page opts out of a Defaults button")
    open(mock, general)
    assertTrue(widget(mock, "Button", "Defaults") ~= nil)
end)

test("panel: the reset dialog is not registered before it is needed (taint)", function()
    local _, env = T.enableAddon()
    assertNil(env.StaticPopupDialogs["LIBKA0SSKINTESTER_RESET_ALL"],
        "writing to StaticPopupDialogs at load taints GameMenu callbacks")
end)

-- ---------------------------------------------------------------------------
-- Schema → widget rendering
-- ---------------------------------------------------------------------------

-- ---------------------------------------------------------------------------
-- The session-only Debug console checkbox (WhatGroup WG-12 — never persisted)
-- ---------------------------------------------------------------------------

test("panel: the Debug console renders as an ordinary Master controls checkbox", function()
    -- It was a bespoke SessionCheckbox drawn through `pairWith` beside "Enable". options-ui-§15
    -- makes it one of the canonical eight, so it is a schema row drawn by the ordinary checkbox
    -- maker now — and still session-only, which the settings suite pins at the storage seam.
    -- red under: re-adding a pairWith entry for it, which would draw it twice.
    local NS, _, mock = openGeneral()
    local n = 0
    for _, w in ipairs(mock.aceWidgets) do
        if w.type == "CheckBox" and w.labelText == "Debug console" then n = n + 1 end
    end
    assertEqual(n, 1, "drawn exactly once")
    assertTrue(NS.addon.Settings.Helpers.FindSchema("state.debugConsole") ~= nil,
        "and it is a schema row, on the canonical path")
end)

test("panel: ticking Debug console shows the window without touching db.profile", function()
    local NS, _, mock = openGeneral()
    widget(mock, "CheckBox", "Debug console"):Fire("OnValueChanged", true)
    assertTrue(NS.DebugLog:IsShown(), "the console window opened")
    assertNil(NS.addon.db.profile.debug, "nothing was persisted")
    assertFalse(NS.State.debug, "and logging itself stays off")
end)

test("panel: unticking Debug console hides the window", function()
    local NS, _, mock = openGeneral()
    local cb = widget(mock, "CheckBox", "Debug console")
    cb:Fire("OnValueChanged", true)
    cb:Fire("OnValueChanged", false)
    assertFalse(NS.DebugLog:IsShown())
end)

test("panel: opening the console while General is OPEN moves the checkbox", function()
    -- The console's descriptor carries onVisibilityChanged, so a window opened by `/st debug` (or
    -- closed with Esc or its ×) repaints a panel that is already on screen — in place, through the
    -- widget's own refresher, with no rebuild.
    local NS, _, mock = openGeneral()
    local cb = lastWidget(mock, "CheckBox", "Debug console")
    assertEqual(cb:GetValue(), false)
    NS.DebugLog:Show()
    assertEqual(cb:GetValue(), true, "the checkbox followed the window")
    NS.DebugLog:Hide()
    assertEqual(cb:GetValue(), false, "and followed it back")
end)

test("panel: re-opening General re-syncs the Debug console checkbox", function()
    local NS, _, mock = openGeneral()
    assertEqual(lastWidget(mock, "CheckBox", "Debug console"):GetValue(), false)
    -- The console can be opened by `/st debug` while the panel is CLOSED, in which case the
    -- library flags the page dirty rather than refreshing it, and the re-render happens on the
    -- next show. Either way the checkbox must read the window's live state once the page is up.
    local _, general = panels(mock)
    general:Hide()
    NS.DebugLog:Show()
    open(mock, general)
    assertEqual(lastWidget(mock, "CheckBox", "Debug console"):GetValue(), true)
end)

-- ---------------------------------------------------------------------------
-- Widget write-back + refreshers
-- ---------------------------------------------------------------------------

test("panel: a re-render REPLACES the refresher list rather than growing it", function()
    -- Keeping the old closures would make every later write pcall an ever-growing pile of dead
    -- ones, each still holding a released widget (options-ui-§11).
    local NS, _, mock = openGeneral()
    local ctx = NS.addon.Settings.Helpers.__panelFor("general")
    local first = #ctx.refreshers
    local _, general = panels(mock)
    general:Hide()
    NS.addon.Settings.Helpers.RefreshAllPanels()   -- flags the hidden page dirty
    open(mock, general)                            -- which re-renders it on show
    assertEqual(#ctx.refreshers, first, "the list was reassigned, not appended to")
end)

-- ---------------------------------------------------------------------------
-- Scrollbar patch (options-ui-§10 — always-visible gutter)
-- ---------------------------------------------------------------------------

test("panel: the scroll container is patched to always show its scrollbar", function()
    local _, _, mock = openGeneral()
    local scroll = mock.findWidget(function(w) return w.type == "ScrollFrame" end)
    assertTrue(scroll ~= nil, "the page renders inside a ScrollFrame")
    -- `_ka0sAlwaysScrollbar`, not a per-addon marker: AceGUI pools ScrollFrames across every addon
    -- in the session, so two addons carrying differently-named markers would each patch a widget
    -- the other had already patched and stack two overrides on one FixScroll.
    assertTrue(scroll._ka0sAlwaysScrollbar, "the patch is applied")
    assertTrue(scroll.__stockFixScroll ~= nil, "and the stock implementation was preserved")
    assertTrue(scroll.scrollBarShown)
    assertTrue(scroll.scrollbar:IsShown())
end)

test("panel: the patch is one-shot per widget", function()
    local NS, _, mock = openGeneral()
    local scroll = mock.findWidget(function(w) return w.type == "ScrollFrame" end)
    local patched = scroll.FixScroll
    NS.addon.Settings.Helpers.PatchAlwaysShowScrollbar(scroll)
    assertEqual(scroll.FixScroll, patched, "re-patching is a no-op")
end)

test("panel: releasing the widget restores AceGUI's stock behavior", function()
    local _, _, mock = openGeneral()
    local scroll = mock.findWidget(function(w) return w.type == "ScrollFrame" end)
    scroll:OnRelease()
    assertNil(scroll._ka0sAlwaysScrollbar, "the pooled widget goes back clean")
    assertTrue(scroll.released, "the stock OnRelease still ran")
    assertTrue(scroll.scrollbar.__enabled, "the scrollbar is re-enabled for the next acquirer")
end)

-- ---------------------------------------------------------------------------
-- Landing page
-- ---------------------------------------------------------------------------

test("panel: the landing page lists one row per slash command", function()
    local NS, _, mock = T.enableAddon()
    local main = panels(mock)
    open(mock, main)
    for _, entry in ipairs(NS.addon.COMMANDS) do
        local found = mock.findWidget(function(w)
            return w.type == "Label" and w.text and w.text:find("/st " .. entry[1], 1, true)
        end)
        assertTrue(found ~= nil, "the landing page is missing /st " .. entry[1])
    end
end)

test("panel: the landing page shows the TOC Notes line", function()
    local _, _, mock = T.enableAddon()
    local main = panels(mock)
    open(mock, main)
    local desc = mock.findWidget(function(w)
        return w.type == "Label" and w.text == mock.metadata.Notes
    end)
    assertTrue(desc ~= nil, "the Notes one-liner is rendered from TOC metadata")
end)

test("panel: the landing page renders the Slash Commands heading and the logo", function()
    local _, _, mock = T.enableAddon()
    local main = panels(mock)
    open(mock, main)
    assertTrue(widget(mock, "Heading", "Slash Commands") ~= nil)
    local logo
    for _, tex in ipairs(mock.textures) do
        if tex:GetTexture() and tostring(tex:GetTexture()):find("libka0sskintester.logo", 1, true) then
            logo = tex
        end
    end
    assertTrue(logo ~= nil, "the brand logo texture is created")
end)

test("panel: the landing logo path is built from the folder this copy loaded from", function()
    -- The launcher's icon already follows the folder (test_launcher.lua); the landing page's logo
    -- is the same asset tree, so a copy loaded as another folder must draw its own logo too
    -- (library-stack-§8).
    -- red under: the hand-typed LibKa0sSkinTester literal
    local _, _, mock = T.enableAddon{ addonName = "LibKa0sSkinTesterCopy" }
    local main = panels(mock)
    open(mock, main)
    local want = "Interface\\AddOns\\LibKa0sSkinTesterCopy\\media\\logos\\libka0sskintestercopy.logo.tga"
    local logo
    for _, tex in ipairs(mock.textures) do
        if tex:GetTexture() == want then logo = tex end
    end
    assertTrue(logo ~= nil, "the landing logo names the folder it loaded from")
end)

-- Characterization (CCN split): the landing page is four independent sub-parts — logo, TOC notes
-- line, "Slash Commands" heading, one Label per command — and what a reader sees is the ORDER they
-- are added to the scroll in and the spacer heights BETWEEN them. Nothing else pinned that, so the
-- whole child list is asserted here, positionally.
test("panel: the landing page adds logo, notes, heading and command rows in that order", function()
    local NS, _, mock = T.enableAddon()
    local AceGUI = NS.addon.Settings.Helpers.AceGUI
    -- The mock's FontString stub no-ops SetJustifyH through its metatable, so the left-justify the
    -- notes line and every command row rely on is only observable by intercepting the label as the
    -- widget is created.
    local baseCreate = AceGUI.Create
    AceGUI.Create = function(s, widgetType)
        local w = baseCreate(s, widgetType)
        w.label.SetJustifyH = function(fs, v) w.justifyH = v; return fs end
        return w
    end
    local main = panels(mock)
    open(mock, main)
    AceGUI.Create = baseCreate

    local scroll
    for _, w in ipairs(mock.aceWidgets) do
        if w.type == "ScrollFrame" then scroll = w end
    end
    local kids = scroll.children

    assertEqual(kids[1].type, "SimpleGroup", "the logo group leads")
    assertEqual(kids[1].height, 300, "at the texture's native size")
    assertTrue(kids[1].fullWidth)
    assertNil(kids[1].layout, "with the deliberate nil layout, so the texture stays pixel-exact")
    assertEqual(kids[2].height, 8, "LANDING_GAP_LOGO")

    assertEqual(kids[3].type, "Label")
    assertEqual(kids[3].text, mock.metadata.Notes, "the TOC Notes one-liner")
    assertEqual(kids[3].justifyH, "LEFT")
    assertTrue(kids[3].fullWidth)
    assertEqual(kids[4].height, 12, "LANDING_GAP_DESC")

    assertEqual(kids[5].type, "Heading")
    assertEqual(kids[5].text, "Slash Commands")
    -- One 6 under the heading, not two: the library's Section emits it (LANDING_GAP_HEAD), and
    -- BuildLandingPage does not stack the private body's MAIN_GAP_BELOW_HEAD on top of it.
    assertEqual(kids[6].height, 6, "the Section's own trailing spacer")

    local rows = NS.SlashCommands:LandingRows()
    assertTrue(#rows > 0, "there is at least one command row to render")
    assertEqual(#kids, 6 + #rows, "and nothing beyond the rows")
    for i, line in ipairs(rows) do
        local row = kids[6 + i]
        assertEqual(row.type, "Label")
        assertEqual(row.text, line, "row " .. i .. " comes from LandingRows()")
        assertEqual(row.justifyH, "LEFT")
        assertTrue(row.fullWidth)
    end
end)

-- The library re-runs a page's renderer on exactly ONE re-entry path: the page was marked dirty by
-- a structural refresh while it was hidden. A plain Hide/Show is turned away by
-- `if ctx._rendered and not ctx._dirty then return end` and never re-enters BuildMainContent at
-- all — so a test driven that way pins nothing, whatever it asserts afterwards. Drive the real
-- path. What it pins is the ClearScroll at the top of BuildMainContent: ClearScroll REUSES the
-- same ScrollFrame and only releases its children, so without it the second render appends a
-- second logo and a second command list to the first one's widgets.
test("panel: a dirty landing page re-renders in place instead of stacking a second copy", function()
    local NS, _, mock = T.enableAddon()
    local main = panels(mock)
    open(mock, main)

    -- The LAST ScrollFrame, for the reason lastWidget() gives: a re-render can make a new one.
    local function landingScroll()
        local found
        for _, w in ipairs(mock.aceWidgets) do
            if w.type == "ScrollFrame" then found = w end
        end
        return found
    end

    local first = #landingScroll().children
    assertTrue(first > 0, "the landing page put widgets in the scroll on its first show")

    main:Hide()
    NS.addon.Settings.Helpers.RefreshAllPanels()   -- flags the hidden page dirty
    open(mock, main)                               -- which re-renders it on show

    assertEqual(#landingScroll().children, first, "one logo and one command list, not two")
end)

-- Owner report: the landing page showed the logo twice, the second under the Slash Commands
-- heading. A private body drew it as a texture on a pooled AceGUI frame and never took it off, so
-- the frame came back from the pool as another SimpleGroup still carrying it; the library's
-- BuildLandingPage hides it on release. The page body must go through the library's builder.
test("panel: the landing page is drawn by the library's BuildLandingPage, logo and commands", function()
    local NS = T.enableAddon()
    local H = NS.addon.Settings.Helpers
    local seen
    local real = H.BuildLandingPage
    H.BuildLandingPage = function(ctx, spec) seen = spec; return real(ctx, spec) end
    H.BuildMainContent({})
    H.BuildLandingPage = real
    -- red under: the private addLogo / addCommandRows body in settings/Panel.lua
    assertTrue(seen ~= nil, "BuildMainContent delegates to the library")
    assertTrue(seen.logo:find("media\\logos\\libka0sskintester.logo.tga", 1, true) ~= nil, seen.logo)
    assertNil(seen.logoSize, "no logoSize: the library's default is the mandated 300 (options-ui-§5)")
    assertEqual(#seen.sections, 1)
    assertEqual(seen.sections[1].heading, "Slash Commands")
    assertEqual(#seen.sections[1].rows(), #NS.addon.COMMANDS)
end)

-- ---------------------------------------------------------------------------
-- Item 020, the settings layout (WG-LY): placement, labels and tooltips
-- ---------------------------------------------------------------------------

--- The tooltip a widget raises, body lines only (the title is the label), as one string.
local function tooltipOf(mock, w)
    local tip = mock.GameTooltip
    tip.__lines = {}
    w:Fire("OnEnter")
    return table.concat(tip.__lines or {}, "\n")
end

test("panel: the header Defaults tooltip is the library's Reset all settings wording (WHA-L12)",
function()
    local NS, _, mock = openGeneral()
    local H = NS.addon.Settings.Helpers
    local want = H.ResetAllTooltip(H.KEYBINDS_UNCHANGED)
    assertTrue(want:find(H.KEYBINDS_UNCHANGED, 1, true) ~= nil, "the keys tail is appended")
    assertEqual(tooltipOf(mock, widget(mock, "Button", "Defaults")), want)
end)

-- ---------------------------------------------------------------------------
-- The General page, as this addon composes it
-- ---------------------------------------------------------------------------

test("panel: General's strip is Master controls, Skin, then Keybindings", function()
    local _, _, mock = openGeneral()
    for _, label in ipairs({ "Master controls", "Skin", "Keybindings" }) do
        assertTrue(tabButton(mock, label) ~= nil, "a tab labeled " .. label)
    end
    assertNil(tabButton(mock, "Notifications"), "no tab of another addon's")
end)

test("panel: Master controls holds only the rows this addon has state for", function()
    local _, _, mock = openGeneral()
    selectTab(mock, "Master controls")
    assertTrue(widget(mock, "CheckBox", "Enable Skin Tester") ~= nil, "Enable, named for the addon")
    assertTrue(widget(mock, "Slider", "Master scale") ~= nil, "Master scale")
    assertTrue(widget(mock, "Slider", "Master opacity") ~= nil, "Master opacity")
    assertTrue(widget(mock, "CheckBox", "Debug console") ~= nil, "Debug console")
    assertTrue(widget(mock, "CheckBox", "Minimap button") ~= nil, "Minimap button")
    -- red under: dropping `omit` from settings/Panel.lua's MasterControls spec
    assertNil(widget(mock, "CheckBox", "Lock frame"), "no Lock frame: nothing here is locked")
    assertNil(widget(mock, "CheckBox", "Test mode"), "no Test mode: the samples are the preview")
    assertNil(widget(mock, "Dropdown", "General visibility"), "no General visibility")
end)

test("panel: the scale slider commits on release, through the write seam", function()
    local NS, _, mock = openGeneral()
    selectTab(mock, "Master controls")
    local s = widget(mock, "Slider", "Master scale")
    s:Fire("OnValueChanged", 1.5)
    assertEqual(NS.addon.db.profile.scale, 1, "a drag alone does not commit")
    s:Fire("OnMouseUp", 1.5)
    assertEqual(NS.addon.db.profile.scale, 1.5)
end)

test("panel: unticking Enable stands the addon down through the row's onChange", function()
    local NS, _, mock = openGeneral()
    selectTab(mock, "Master controls")
    widget(mock, "CheckBox", "Enable Skin Tester"):Fire("OnValueChanged", false)
    assertFalse(NS.addon.db.profile.enabled)
    assertTrue(NS.IsStoodDown(), "the latch took the disabled hold")
end)

test("panel: Defaults raises the confirmation, and confirming restores the profile", function()
    local NS, env, mock = openGeneral()
    NS.addon.Settings.Helpers.Set("scale", 1.5)
    widget(mock, "Button", "Defaults"):Fire("OnClick")
    assertEqual(mock.popups[#mock.popups], "LIBKA0SSKINTESTER_RESET_ALL")
    assertEqual(NS.addon.Settings.Helpers.Get("scale"), 1.5, "nothing is reset until confirmed")
    env.StaticPopupDialogs["LIBKA0SSKINTESTER_RESET_ALL"].OnAccept()
    assertEqual(NS.addon.Settings.Helpers.Get("scale"), 1, "confirmed: back to the default")
end)

test("panel: Reset position forgets the saved point and centers the showroom", function()
    -- red under: re-anchoring without NS.Windows.Forget; the next open restores the old point.
    local NS = T.enableAddon()
    NS.Showroom.Show()
    NS.addon.db.global.windows.LibKa0sSkinTesterShowroom = { point = "TOPLEFT", relPoint = "TOPLEFT", x = 12, y = -34 }
    NS.Showroom.ResetPosition()
    assertNil(NS.addon.db.global.windows.LibKa0sSkinTesterShowroom, "the persisted point is gone")
end)

test("panel: the Skin tab is the library's, for this owner, and a pick lands in the profile", function()
    local NS, _, mock = openGeneral()
    selectTab(mock, "Skin")
    local cb = mock.findWidget(function(w) return w.type == "CheckBox" and tostring(w.labelText):find("Obsidian", 1, true) ~= nil end)
    assertTrue(cb ~= nil, "the library drew the Obsidian choice")
    cb:Fire("OnValueChanged", true)
    assertEqual(NS.addon.db.profile.skin.skin, "obsidian", "the pick reached the write seam")
    local _, applied = mock.LibStub("LibKa0s-Skin-1.0"):GetChoice("LibKa0sSkinTester")
    assertEqual(applied, "obsidian", "and the skin is applied")
end)
