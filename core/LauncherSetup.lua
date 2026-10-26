local addonName, NS = ...
-- core/LauncherSetup.lua — the launcher (launcher-§1): one LibDataBroker object, drawn as the
-- minimap button and as a broker row, built by LibKa0s-Launcher-1.0.
--
-- Left-click opens the settings panel and right-click opens the options menu (launcher-§2); both,
-- and the status tooltip, are the library's. The menu lists the two toggles this addon has, in the
-- fixed order: Enabled, then Show window (the skin showroom). Each calls the SAME handler its slash
-- verb calls. Built here, registered from OnEnable (db.global.minimap exists only after
-- OnInitialize); every seam below is read inside a closure, so this position is conventional.

local lib = LibStub and LibStub("LibKa0s-Launcher-1.0", true)

-- The logo: the same 128x128 TGA the TOC's ## IconTexture names (layout-§4).
local ICON = ("Interface\\AddOns\\%s\\media\\logos\\%s.logo.128.tga")
    :format(addonName, addonName:lower())

local function minimapStore()
    local db = NS.addon and NS.addon.db
    return db and db.global and db.global.minimap
end

if not lib then
    -- Degrade, never error: no button and no broker row, said once, and the Minimap button row
    -- still reads and writes LibDBIcon's own `hide` key.
    local missing = NS.LIBKA0S_MISSING .. ", so there is no minimap button and no broker plugin."
    local said = false
    NS.Launcher = {
        Register = function()
            if not said then
                said = true
                if NS.Print then NS.Print(missing) end
            end
            return false
        end,
        IsRegistered = function() return false end,
        Object       = function() return nil end,
        IsShown      = function()
            local t = minimapStore()
            return not (t and t.hide)
        end,
        SetShown     = function(_, shown)
            local t = minimapStore()
            if t then t.hide = not shown end
            return false
        end,
    }
    return
end

NS.Launcher = lib:New({
    name    = addonName,
    icon    = ICON,
    label   = NS.BRAND_NAME,
    minimap = minimapStore,
    openSettings = function() NS.addon:OpenSettings() end,
    isEnabled  = function() return not NS.IsStoodDown() end,
    setEnabled = function(on) NS.addon:SlashEnabled(on) end,
    print = function(line) NS.Print(line) end,
    debug = function(tag, message) NS.Debug(tag, message) end,
    debugAtEnable = function(tag, message) NS.DebugAtEnable(tag, "%s", message) end,
    version = function()
        local v = NS.Version()
        return v ~= "?" and v or nil
    end,
    isWindowShown = function() return NS.Showroom.IsShown() end,
    toggleWindow  = function() NS.Showroom.Toggle() end,
})
