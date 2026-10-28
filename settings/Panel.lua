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
-- that lands on a profile whose key is false (a new or reset profile starts false). Closing it, by
-- its close control, its gear or Escape, sets the key. Picking a skin and the eye do not close it.
--
-- Never in combat and never while the addon is disabled. The addon registers no game event (see
-- core/LibKa0sSkinTester.lua's stand-down note), so a trigger in combat is skipped, not deferred:
-- the next login or profile event asks again, because the key is still false.

local PICKER_SEEN_PATH = "skin.pickerSeen"

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
        if S and Tester.db then S.Set(PICKER_SEEN_PATH, true) end
    end,
    strings   = { PREVIEW_TIP = NS.L["Preview: open the skin showroom"] },
}
NS.SKIN_PICKER_SPEC = PICKER_SPEC

--- Show the skin picker when this profile has not closed it yet. Answers true when it is up.
function NS.MaybeShowSkinPicker()
    local S, db = NS.SchemaRuntime, Tester.db
    if not (S and db and db.profile) then return false end
    if S.Get(PICKER_SEEN_PATH) == true or not db.profile.enabled then return false end
    if InCombatLockdown and InCombatLockdown() then return false end
    if type(Helpers.SkinPicker) ~= "function" then return false end
    return Helpers.SkinPicker(PICKER_SPEC) ~= nil
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
