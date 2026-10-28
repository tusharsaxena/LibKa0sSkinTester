-- tests/test_skin_picker.lua — the first-run skin picker's triggers (settings/Panel.lua,
-- NS.MaybeShowSkinPicker; LibKa0s OptionsSkinPicker minor 1, ST-01).
--
-- The window itself is the library's and its own suite holds it; what this addon owns is WHEN it
-- shows (skin.pickerSeen false: after login, after a profile event), when it does not (seen, in
-- combat, disabled), the spec it hands over (the write seams, the General page's Skin tab, the
-- eye) and that a close is recorded through the schema runtime.
--
-- Since PK-02 a pick only previews: Apply (and the gear) save it through this addon's write seam,
-- and the close control puts the skin the window opened with back. Every one of those routes marks
-- the profile seen. One window serves every Ka0s addon: behind another addon's picker this one
-- queues (MaybeShowSkinPicker answers false, "queued"), a stand-down takes it out of the queue
-- unseen, and another addon's "Apply to all" marks it seen through its own onClose. The second
-- addon in those cases is a second Options instance and skin owner on the same library tables.
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

--- The settings category registered under `label`, or nil.
local function category(mock, label)
    for _, c in ipairs(mock.categories) do
        if c.label == label then return c end
    end
end

--- Click a control the way the client does.
local function click(btn) btn:GetScript("OnClick")(btn, "LeftButton") end

--- Open the window's list and click the row for skin `key`. The host mock has no GetChildren, so
--- the rows are found among every recorded frame by their parent, the list.
local function pickRow(mock, f, key)
    click(f.dd)
    for _, r in ipairs(mock.frames) do
        if type(r) == "table" and r.__parent == f.list and r.key == key then return click(r) end
    end
    error("no row for " .. key)
end

local function profileSkin(NS) return NS.addon.db.profile.skin.skin end
local function applied(mock) return select(2, mock.LibStub("LibKa0s-Skin-1.0"):GetChoice("LibKa0sSkinTester")) end

test("picker: the gear saves the pick, opens the General page itself, and marks the profile", function()
    -- red under: OptionsRegistry minor 3's OpenOptionsPanel(), which opened the parent (landing)
    -- category whatever page the spec named.
    local NS, _, mock = T.enableAddon()
    local f = picker(mock)
    pickRow(mock, f, "ember")
    local before = #mock.openedTo
    click(f.settings)
    assertFalse(shown(mock), "the gear closes the picker")
    assertTrue(seen(NS))
    assertEqual(profileSkin(NS), "ember", "the pending pick is saved first")
    assertEqual(#mock.openedTo, before + 1, "one category opened")
    assertEqual(mock.openedTo[#mock.openedTo], category(mock, "General"):GetID(), "the General page, not the landing")
end)

test("picker: a pick previews: the skin moves live, the profile keeps its own and is not marked", function()
    local NS, _, mock = T.enableAddon()
    local f = picker(mock)
    pickRow(mock, f, "ember")
    assertEqual(applied(mock), "ember", "the addon wears the preview")
    assertEqual(profileSkin(NS), "ka0s", "nothing was written")
    assertTrue(shown(mock), "the window stays")
    assertFalse(seen(NS))
end)

test("picker: Apply saves the pick through the schema runtime and marks the profile", function()
    local NS, _, mock = T.enableAddon()
    local f = picker(mock)
    pickRow(mock, f, "obsidian")
    click(f.apply)
    assertFalse(shown(mock), "Apply closes the picker")
    assertEqual(profileSkin(NS), "obsidian", "the pick is stored")
    assertEqual(applied(mock), "obsidian", "and still worn")
    assertTrue(seen(NS))
end)

test("picker: the close control puts the old skin back, writes nothing, and marks the profile", function()
    local NS, _, mock = T.enableAddon()
    local f = picker(mock)
    pickRow(mock, f, "ember")
    click(f.close)
    assertFalse(shown(mock))
    assertEqual(applied(mock), "ka0s", "the preview is put back")
    assertEqual(profileSkin(NS), "ka0s", "nothing was written")
    assertTrue(seen(NS), "closing it still counts as seen")
end)

test("picker: the title names this addon", function()
    local _, _, mock = T.enableAddon()
    assertEqual(picker(mock).title:GetText(), "Choose a skin for Ka0s Skin Tester")
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

--- The stored key of a named profile, read straight from the saved variables (a profile not in
--- use holds only what differs from the defaults, so an unseen one reads nil there).
local function seenIn(_, name)
    local p = _G.LibKa0sSkinTesterDB.profiles[name]
    return p and p.skin and p.skin.pickerSeen or false
end

test("picker: /st disable hides it, and the profile stays unseen", function()
    -- red under: a stand-down that only closes the showroom, leaving the picker up and working.
    local NS, _, mock = T.enableAddon()
    assertTrue(shown(mock))
    NS.addon:OnSlashCommand("disable")
    assertFalse(shown(mock), "a disabled addon shows no picker")
    assertFalse(seen(NS), "the host's hide is not the player closing it")
end)

test("picker: a switch to a disabled profile hides it, and neither profile is marked", function()
    local NS, _, mock = T.enableAddon()
    NS.addon.db:SetProfile("Off")
    NS.addon.Settings.Helpers.Set("enabled", false)
    NS.addon.db:SetProfile("Default")
    assertTrue(shown(mock), "Default is enabled and unseen")
    NS.addon.db:SetProfile("Off")
    assertFalse(shown(mock), "the disabled profile shows no picker")
    assertFalse(seenIn(NS, "Off"), "Off has not seen it")
    assertFalse(seenIn(NS, "Default"), "nor has Default")
end)

test("picker: a switch to a profile that closed it hides it, and writes nothing", function()
    local NS, _, mock = T.enableAddon()
    NS.addon.db:SetProfile("Alt")
    NS.addon.Settings.Helpers.HideSkinPicker()
    NS.addon.db:SetProfile("Default")
    assertTrue(shown(mock), "Default has not seen it")
    NS.addon.db:SetProfile("Alt")
    assertFalse(shown(mock), "Alt closed it, so it goes")
    assertTrue(seenIn(NS, "Alt"))
    assertFalse(seenIn(NS, "Default"), "Default is still unseen")
end)

-- ── one window across Ka0s addons (PK-02) ─────────────────────────────────────────────────────

local OTHER = "KaosOtherAddon"

--- A second Ka0s addon in the same client: a skin owner over `store` and an Options instance of its
--- own, on the library tables this addon's copy registered. Answers the instance and the store.
local function otherAddon(mock)
    local store = { source = "ka0s", skin = "ka0s", closed = 0 }
    mock.LibStub("LibKa0s-Skin-1.0"):RegisterOwner(OTHER, {
        label = "Other Addon",
        get   = function() return store.source, store.skin end,
        set   = function(src, sk) store.writes = (store.writes or 0) + 1; store.source, store.skin = src, sk end,
    })
    local O = mock.LibStub("LibKa0s-Options-1.0"):New({
        parentTitle = "Other Addon", mainPanelName = "KaosOtherMain", addonName = OTHER,
        print = function() end,
        get = function() end, set = function() end, applyDefault = function() end,
        rowsForPage = function() return {} end, allRows = function() return {} end,
    })
    local spec = {
        owner   = OTHER,
        get     = function() return store.source, store.skin end,
        set     = function(src, sk) store.source, store.skin = src, sk end,
        onClose = function() store.closed = store.closed + 1 end,
    }
    return O, store, spec
end

local function queue(mock) return mock.LibStub("LibKa0s-Options-1.0").__pickerQueue end

--- This addon booted, another addon's picker up first, then this addon's OnEnable.
local function behindOther()
    local NS, _, mock = T.bootAddon()
    local O, store, spec = otherAddon(mock)
    local other = O.SkinPicker(spec)
    NS.addon:OnEnable()
    return NS, mock, other, store
end

test("picker: behind another Ka0s addon's picker it queues, and shows when that one closes", function()
    -- red under: MaybeShowSkinPicker's bare `SkinPicker(spec) ~= nil`, which answered a lone false
    -- for a queued call.
    local NS, mock, other = behindOther()
    assertTrue(other:IsShown(), "the other addon's window stays up")
    assertFalse(shown(mock), "this addon's window is not shown beside it")
    assertEqual(#queue(mock).waiting, 1, "it waits in the one queue")
    local up, why = NS.MaybeShowSkinPicker()
    assertFalse(up, "asking again shows nothing")
    assertEqual(why, "queued")
    assertEqual(#queue(mock).waiting, 1, "one entry per owner")
    assertFalse(seen(NS), "waiting is not seeing")
    click(other.close)
    assertTrue(shown(mock), "this addon's picker is up next")
    assertFalse(seen(NS))
end)

test("picker: a stand-down while queued takes it out unseen, and nothing shows after", function()
    -- red under: a host that counted any HideSkinPicker as the player closing it.
    local NS, mock, other = behindOther()
    NS.addon:OnSlashCommand("disable")
    assertEqual(#queue(mock).waiting, 0, "out of the queue")
    assertTrue(other:IsShown(), "the other addon's window is not this addon's to hide")
    click(other.close)
    assertFalse(shown(mock), "this addon does not show after it")
    assertFalse(seen(NS), "and its profile is still unseen")
end)

test("picker: another addon's Apply to all marks this profile seen and gives it the skin", function()
    local NS, mock, other = behindOther()
    assertTrue(other.applyAll:IsShown(), "Apply to all is offered: this addon is another owner")
    pickRow(mock, other, "ember")
    click(other.applyAll)
    assertFalse(other:IsShown())
    assertFalse(shown(mock), "this addon's queued picker never shows")
    assertTrue(seen(NS), "its onClose ran: the profile counts it seen")
    assertEqual(profileSkin(NS), "ember", "the skin came through this addon's write seam")
end)

test("picker: this addon's Apply to all saves here and gives the other addon the skin", function()
    local NS, _, mock = T.bootAddon()
    local _, store = otherAddon(mock)
    NS.addon:OnEnable()
    local f = picker(mock)
    assertTrue(f.applyAll:IsShown(), "offered while another owner is registered")
    pickRow(mock, f, "glass")
    click(f.applyAll)
    assertFalse(shown(mock))
    assertTrue(seen(NS))
    assertEqual(profileSkin(NS), "glass")
    assertEqual(store.skin, "glass", "the other addon's own setter took the skin")
end)

test("picker: Apply to all is hidden while this addon is the only skin owner", function()
    local _, _, mock = T.enableAddon()
    assertFalse(picker(mock).applyAll:IsShown())
end)
