local addonName, NS = ...
-- core/SkinSetup.lua — the LibKa0s-Skin-1.0 seam (skinning-§3): this addon is a skin owner, and the
-- skin it wears is the one the showroom displays.
--
--   NS.Skin                 the owner's facade, Skin:For("LibKa0sSkinTester"): the paint vocabulary
--                           and Token / Color / Resolve / OnLooksChanged. Every sample the showroom
--                           draws is painted through it.
--   NS.SkinChoice()         the stored (source, skin) pair, read through the schema runtime;
--                           "ka0s", "ka0s" before AceDB exists.
--   NS.WriteSkinChoice(s,k,i) the write seam: each half through the schema runtime's Set, the one seam
--                           `/st set` and the panel write through (architecture-§5); `i`, the Scope's
--                           `{ panel, fonts }`, writes the two exceptions.
--   NS.ApplySkinIgnore(p,f) moves the applied Scope with Skin:SetIgnore, live; no argument applies
--                           the stored pair, a nil half keeps that half.
--   NS.ApplySkinChoice(s,k) moves the applied skin with Skin:SetChoice, which repaints every frame
--                           recorded for this owner and then fires OnLooksChanged. No argument applies
--                           the stored pair and the stored Scope; a nil half keeps that half. A skin key no registered
--                           skin carries applies Ka0s Default: the library keeps any non-empty
--                           string, and a hand-edited or stale profile must not wear a skin nobody
--                           can pick.
--   NS.SKIN_OPTIONS         the skin row's values, every registered skin in the library's order,
--   NS.SKIN_SOURCE_OPTIONS  and the source row's. settings/Schema.lua reads both at load.
--   NS.SkinPaintAceTree(c)  Skin:PaintAceTree with the owner bound, for AceGUI widgets this addon
--                           acquires itself.
--
-- LOAD-BEARING: after core/CoreSetup.lua and before core/LibKa0sSkinTester.lua, whose OnInitialize
-- applies the stored pair, and before settings/Schema.lua, which reads NS.SKIN_OPTIONS at load.
-- RegisterOwner calls `get` once, here, before AceDB exists, and gets Ka0s Default.
--
-- WHY A ROW'S onChange PASSES ONE HALF: the Appearance tab, and another addon's "Copy to every Ka0s
-- addon", call Skin:SetChoice first and write the store after, one half at a time. A reaction that
-- re-applied the whole stored pair would apply a half-written pair in between: a second repaint, to
-- a skin nobody picked. Applying only the row's own half makes each write a no-op, while a bare
-- `/st set skin.skin obsidian` still repaints.

local Skin = LibStub and LibStub("LibKa0s-Skin-1.0", true)

local SOURCE_PATH, SKIN_PATH = "skin.source", "skin.skin"
local PANEL_PATH, FONTS_PATH = "skin.ignorePanel", "skin.ignoreFonts"
local DEFAULT = "ka0s"
NS.SKIN_SOURCE_PATH, NS.SKIN_PATH = SOURCE_PATH, SKIN_PATH

NS.SKIN_SOURCE_OPTIONS = {
    { value = "ka0s", text = "Ka0s skins" },
    { value = "eui",  text = "EllesmereUI" },
}

NS.SKIN_OPTIONS = {}
if Skin and type(Skin.Skins) == "function" then
    for _, def in ipairs(Skin:Skins()) do
        NS.SKIN_OPTIONS[#NS.SKIN_OPTIONS + 1] = { value = def.key, text = def.label or def.key }
    end
end
if #NS.SKIN_OPTIONS == 0 then NS.SKIN_OPTIONS[1] = { value = DEFAULT, text = "Ka0s Default" } end

local function runtime() return NS.SchemaRuntime end

function NS.SkinChoice()
    local S = runtime()
    if not (NS.addon and NS.addon.db and S) then return DEFAULT, DEFAULT end
    return S.Get(SOURCE_PATH) or DEFAULT, S.Get(SKIN_PATH) or DEFAULT
end

function NS.WriteSkinChoice(source, skin, ignore)
    local S = runtime()
    if not (NS.addon and NS.addon.db and S) then return end
    if source ~= nil then S.Set(SOURCE_PATH, source) end
    if skin ~= nil then S.Set(SKIN_PATH, skin) end
    if type(ignore) == "table" then
        S.Set(PANEL_PATH, ignore.panel == true)
        S.Set(FONTS_PATH, ignore.fonts == true)
    end
end

-- The stored Scope (LibKa0s-Skin-1.0 minor 5), nil-safely: false, false before the store exists.
local function storedIgnore()
    local S = runtime()
    if not (NS.addon and NS.addon.db and S) then return false, false end
    return S.Get(PANEL_PATH) == true, S.Get(FONTS_PATH) == true
end

-- The vocabulary a degraded facade answers, kept in the library's order; tests/test_surface_parity
-- holds it to the live lib.VOCAB, so a primitive added upstream turns this red until it is here.
NS.SKIN_VOCAB = {
    "Shell", "Panel", "Inset", "FadeRegions", "FadeNineSlice", "Button", "WhiteButtonLabel",
    "StateButtonLabel", "EditBox", "Checkbox", "Dropdown", "ScrollBar", "Tab", "SetTabSelection",
    "CloseButton", "PageButton", "SquareIcon", "SortHeaderBar", "Font", "White", "ApplyBarFill",
    "GetAccentColor", "GetPanelColor", "GetFont",
    "TitleBar", "Divider", "Footer", "Card", "Slider", "NavItem", "Drawer", "ListRow", "MenuFrame",
    "Tooltip", "Strip", "Cover", "Text", "ChartStyle", "BarStyle", "IconBorder", "GlowColor",
}

if not Skin then
    -- Degrade, never error. A skin tester without the skin engine has nothing to show, and says
    -- so in the showroom; what it must not do is raise. Every primitive is a no-op and every
    -- token reads nil, rather than a host copy of Ka0s Default that could drift from the library.
    local noop = function() end
    local S = { owner = addonName, apiVersion = 3, FROM_SKIN = "@skin" }
    for _, name in ipairs(NS.SKIN_VOCAB) do S[name] = noop end
    S.Token = function() return nil end
    S.Color = function() return nil end
    S.Resolve = function(_, value) return value end
    S.OnLooksChanged = function(fn) return fn end   -- the skin never changes without the library
    S.IsEnabled = function() return false end
    S.GetStyle = function() return "ka0s:" .. DEFAULT end
    NS.Skin = S
    NS.SkinAvailable = false
    function NS.ApplySkinChoice() return false, false end
    function NS.ApplySkinIgnore() return false, false end
    function NS.SkinPaintAceTree() return 0 end
    return
end

NS.Skin = Skin:For(addonName)
NS.SkinAvailable = true
Skin:RegisterOwner(addonName, {
    label = NS.BRAND_NAME,
    get   = NS.SkinChoice,
    set   = NS.WriteSkinChoice,
})

-- The one line a reload request earns where no popup of the library's says it (a profile event
-- leaving an EllesmereUI that painted this session).
local RELOAD_LINE = "Reload your interface (/reload) to finish changing the skin."

function NS.SkinPaintAceTree(container)
    if type(Skin.PaintAceTree) ~= "function" then return 0 end
    return Skin:PaintAceTree(addonName, container)
end

local KNOWN = {}
for _, opt in ipairs(NS.SKIN_OPTIONS) do KNOWN[opt.value] = true end

-- The applied Scope: Skin:SetIgnore, live. No argument applies the stored pair; a nil half keeps it.
function NS.ApplySkinIgnore(panel, fonts)
    if type(Skin.SetIgnore) ~= "function" then return false, false end
    if panel == nil and fonts == nil then panel, fonts = storedIgnore() end
    local changed, reload = Skin:SetIgnore(addonName, panel, fonts)
    if reload and NS.Print then NS.Print(RELOAD_LINE) end
    return changed, reload
end

-- No argument applies the stored pair and the stored Scope (load, profile events); a nil half keeps
-- that half and leaves the Scope alone (each Appearance row).
function NS.ApplySkinChoice(source, skin)
    local whole = source == nil and skin == nil
    if whole then source, skin = NS.SkinChoice() end
    if skin ~= nil and not KNOWN[skin] then skin = DEFAULT end
    local changed, reload = Skin:SetChoice(addonName, source, skin)
    if reload and NS.Print then NS.Print(RELOAD_LINE) end
    if whole then NS.ApplySkinIgnore() end
    return changed, reload
end
