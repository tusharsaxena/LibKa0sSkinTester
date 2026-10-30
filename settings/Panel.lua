local addonName, NS = ...
-- settings/Panel.lua — the settings pages: the landing page's spec, the General page (Master
-- controls, Skin, Keybindings), the first-run skin picker and the settings-category registration.
--
-- LOAD-BEARING: after settings/OptionsSetup.lua, whose instance this file calls at file scope
-- (MasterControls, AppearanceTab, KeybindingsTab, ResetAllTooltip), and after modules/Showroom.lua,
-- which publishes NS.BINDINGS (the # Modules -> # Settings group order guarantees it).

local Tester   = NS.addon
local Settings = Tester.Settings
local Helpers  = Settings.Helpers
local C        = NS.C

-- ── the landing page (options-ui-§5) ─────────────────────────────────────────────────────────
-- The library's BuildLandingPage draws the logo, the TOC notes and the command list pool-safely;
-- the host draws none of them (options-ui-§19).

local MAIN_LOGO_TEXTURE = ("Interface\\AddOns\\%s\\media\\logos\\%s.logo.tga")
    :format(addonName, addonName:lower())

function Helpers.BuildMainContent(ctx)
    Helpers.BuildLandingPage(ctx, {
        logo     = MAIN_LOGO_TEXTURE,
        notes    = function() return NS.Meta("Notes") or "" end,
        sections = { {
            heading = NS.L["Slash Commands"],
            rows    = function()
                local Sl = NS.SlashCommands
                return Sl and Sl:LandingRows() or {}
            end,
        } },
    })
end

-- ── Master controls (options-ui-§15) ─────────────────────────────────────────────────────────
-- Composed from one declaration, only the rows this addon has state for: no lock and no test mode
-- (the showroom is a window, not a positionable display, and its samples ARE the preview), and no
-- General visibility (a window the player opens and closes). Scale and opacity are the showroom's.

local function confirmResetAll()
    Settings.EnsureResetPopup()
    StaticPopup_Show("LIBKA0SSKINTESTER_RESET_ALL")
end

local MASTER_ROWS, MASTER_TAIL = Helpers.MasterControls{
    prefix           = "",
    page             = "general",
    -- The display name, for the Enable row's label only ("Enable Skin Tester"); the folder name
    -- would read "Enable LibKa0sSkinTester".
    addonName        = "Skin Tester",
    debugConsolePath = "state.debugConsole",
    minimapPath      = "global.minimap.shown",
    -- The two rows this addon has no state for. Not `frameless`: the showroom is a window, so
    -- scale, opacity and Reset position stay. Minimap button packs beside Debug console.
    omit             = { visibility = true, locked = true },
    defaults         = {
        enabled      = C.enabled,
        scale        = C.scale,
        alpha        = C.alpha,
        debugConsole = false,
    },
    notes            = {
        scale = "Scales the skin showroom.",
        alpha = "Opacity of the skin showroom.",
    },
    onResetPosition  = function() NS.Showroom.ResetPosition() end,
    onResetAll       = confirmResetAll,
}

-- Each composed row's reaction: the latch for `enabled`, the window for scale and opacity.
local MASTER_HOOKS = {
    enabled = function(v)
        if NS.Lifecycle then NS.Lifecycle:Set(NS.HOLD_DISABLED, not v) end
    end,
    scale   = function() NS.Showroom.ApplyWindowSettings() end,
    alpha   = function() NS.Showroom.ApplyWindowSettings() end,
}
for _, row in ipairs(MASTER_ROWS) do
    row.section  = "general"
    row.onChange = MASTER_HOOKS[row.path]
end
Settings.StampClosureRows(MASTER_ROWS)
NS.SchemaRuntime.AddRows(MASTER_ROWS, 1)

local AFTER_GROUP = {}
if Helpers.MASTER_GROUP then AFTER_GROUP[Helpers.MASTER_GROUP] = MASTER_TAIL end

-- ── the host tabs: Skin, then Keybindings last ───────────────────────────────────────────────
-- The Skin tab (skinning-§3; keyed "Appearance", labeled "Skin") is the library's entry: the skin
-- source, the nine skins, the font and texture, the Scope, "Copy to every Ka0s addon..." and the
-- note. Its `get` and `set` are core/SkinSetup.lua's read and write seams, so a pick lands through
-- the schema runtime like every other setting, and the tab's group is the skipRender skin.* rows of
-- settings/Schema.lua. Keybindings (options-ui-§20) is the library's too, drawing NS.BINDINGS, and
-- stays last.
local GENERAL_OPTS = { tabs = {
    Helpers.AppearanceTab({ owner = addonName, get = NS.SkinChoice, set = NS.WriteSkinChoice }),
    Helpers.KeybindingsTab({ bindings = NS.BINDINGS }),
} }

local function buildGeneralPage(parentCategory)
    local ctx = Helpers.CreatePanel("LibKa0sSkinTesterGeneralPanel", "General", {
        pageKey         = "general",
        defaultsButton  = true,
        defaultsTooltip = Helpers.ResetAllTooltip(Helpers.KEYBINDS_UNCHANGED),
    })
    ctx.panel.defaultsOnClick = confirmResetAll
    Helpers.SetRenderer(ctx, function(c)
        Helpers.ClearScroll(c)
        Helpers.RenderTabbedSchema(c, "general", AFTER_GROUP, nil, GENERAL_OPTS)
    end)
    return _G.Settings.RegisterCanvasLayoutSubcategory(parentCategory, ctx.panel, "General")
end

Helpers.RegisterOptionsPage("general", "General", buildGeneralPage)

-- ── the first-run skin picker (LibKa0s OptionsSkinPicker minor 1) ────────────────────────────
-- A small window that asks for a skin before any settings page is opened. It shows while the
-- profile's skin.pickerSeen is false: once after login, and after a profile switch, copy or reset
-- that lands on a profile whose key is false (a new or reset profile starts false). A pick only
-- previews; Apply and the gear save it through NS.WriteSkinChoice, and the close control and Escape
-- undo only the preview, putting back the skin the profile stores as it reads at the close. Every one of those routes sets the key; the eye does
-- not close it.
--
-- One window serves every Ka0s addon in the client (the library's lib.__pickerQueue): behind another
-- addon's picker this one waits, and shows when that one closes. Another addon's "Apply to all Ka0s
-- addons" dismisses it unshown through its own onClose, which sets the key here too: the player has
-- chosen this addon's skin.
--
-- The addon never asks for it in combat or while disabled. It registers no game event (see
-- core/LibKa0sSkinTester.lua's stand-down note), so a trigger in combat is skipped, not deferred:
-- the next login or profile event asks again, because the key is still false. A queued picker shows
-- when the one ahead of it closes, and never mid-combat: a close in combat leaves the library's
-- queue waiting for the end of combat (LibKa0s PK-03), and while it waits SkinPicker answers
-- nil, "queued" here too. The queued entry gets no second look at `enabled` or the key; that is safe
-- because the stand-down and every profile event take it out first (docs/settings-panel.md, smoke
-- PICKER-16).
--
-- The addon takes it down too, and that is not the player closing it: on the stand-down (`/st
-- disable`, a disabled profile) and at the start of every profile switch, copy or reset, before the
-- incoming skin is applied (core/LibKa0sSkinTester.lua's reloadProfile). The profile event then asks
-- again, so a profile that has not seen it gets a fresh showing, its dropdown and the skin a close
-- puts back both read from the incoming profile. That hide writes nothing, so the profile it leaves
-- stays unseen: a window up puts a pending preview back and runs onClose under the hostHiding flag,
-- and a queued one leaves the queue with no onClose at all.

local PICKER_SEEN_PATH = "skin.pickerSeen"

-- True only while the addon itself hides the picker; onClose then records nothing.
local hostHiding = false

local PICKER_SPEC = {
    owner     = addonName,
    get       = NS.SkinChoice,
    set       = NS.WriteSkinChoice,
    page      = "general",
    tab       = "Appearance",
    -- The eye: the showroom is this addon's own frames, and it has no test mode.
    onPreview = function() NS.Showroom.Show() end,
    onClose   = function()
        local S = NS.SchemaRuntime
        if hostHiding or not (S and Tester.db) then return end
        S.Set(PICKER_SEEN_PATH, true)
    end,
    strings   = { PREVIEW_TIP = NS.L["Preview: open the skin showroom"] },
}
NS.SKIN_PICKER_SPEC = PICKER_SPEC

--- Take the picker down for the addon, not the player: the profile is not marked seen. A no-op
--- when it is not up.
function NS.StandDownSkinPicker()
    if type(Helpers.HideSkinPicker) ~= "function" then return end
    hostHiding = true
    local ok, err = pcall(Helpers.HideSkinPicker)
    hostHiding = false
    if not ok then NS.DebugErrorOnce("Skin", "StandDownSkinPicker", err) end
end

--- Show the skin picker when this profile has not closed it yet. Answers true when it is up, and
--- false, "queued" when another Ka0s addon's picker is up, or the queue waits out combat, and this
--- one waits behind it. A profile
--- that has seen it, or a disabled addon, takes down one that is up or queued.
function NS.MaybeShowSkinPicker()
    local S, db = NS.SchemaRuntime, Tester.db
    if not (S and db and db.profile) then return false end
    if S.Get(PICKER_SEEN_PATH) == true or not db.profile.enabled then
        NS.StandDownSkinPicker()
        return false
    end
    if InCombatLockdown and InCombatLockdown() then return false end
    if type(Helpers.SkinPicker) ~= "function" then return false end
    local win, state = Helpers.SkinPicker(PICKER_SPEC)
    if win ~= nil then return true end
    return false, state
end

--- The reserved `/st skin` verb's act (LibKa0s v1.82.0, OptionsSkinPicker minor 3, ruling D-16):
--- O.SkinVerb with the spec the first-run start builds, so it shows the picker a new profile shows
--- whatever skin.pickerSeen says. The library prints its own lines (combat on every call, queued,
--- unavailable); without LibKa0s the stub answers nil, "absent" and this prints the library-absent
--- line. Answers the picker's frame, or nil and the reason.
function NS.RunSkinVerb()
    local verb = type(Helpers.SkinVerb) == "function" and Helpers.SkinVerb
    local win, why
    if verb then win, why = verb(PICKER_SPEC) else why = "absent" end
    if win == nil and why == "absent" then
        NS.Print(NS.L["%s is unavailable: the LibKa0s library did not load."]:format("/st skin"))
    end
    return win, why
end

--- The showroom's "Show the picker" (its Library widgets section): `/st skin`'s act, the same
--- O.SkinVerb route, not while disabled (the verb's dispatcher gate refuses that; a button has none).
--- A close marks the profile seen, which it may already be. Answers true when it is up, else false
--- and the library's reason ("combat", "queued", "unavailable").
function NS.ShowSkinPicker()
    local db = Tester.db
    if not (db and db.profile and db.profile.enabled) then return false end
    local win, why = NS.RunSkinVerb()
    if win ~= nil then return true end
    return false, why
end

-- ── Sample controls ──────────────────────────────────────────────────────────────────────────
-- One row of each widget type, untabbed, under its group heading. No Skin tab and no copy
-- action: the skin is picked on General, and this page only shows it.
local function buildSamplePage(parentCategory)
    local ctx = Helpers.CreatePanel("LibKa0sSkinTesterSamplePanel", "Sample controls", {
        pageKey        = "sample",
        defaultsButton = true,
    })
    Helpers.SetRenderer(ctx, function(c)
        Helpers.ClearScroll(c)
        Helpers.RenderSchema(c, "sample")
    end)
    return _G.Settings.RegisterCanvasLayoutSubcategory(parentCategory, ctx.panel, "Sample controls")
end

Helpers.RegisterOptionsPage("sample", "Sample controls", buildSamplePage)

--- Registers the settings category, once; called from OnEnable and from `/st config`.
function Settings.Register()
    if Tester._settingsRegistered or not _G.Settings
       or not _G.Settings.RegisterCanvasLayoutCategory
       or not _G.Settings.RegisterCanvasLayoutSubcategory then
        return
    end
    Helpers.CreateOptionsPanel()
    Tester._settingsRegistered = true
end
