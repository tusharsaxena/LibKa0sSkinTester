local _, NS = ...
-- modules/Showroom.lua — the skin showroom window: built on first open, painted through the owner's
-- skin facade, toggled by `/st show`, the launcher's Show window entry and the key binding.
--
-- A plain non-secure frame (standalone-windows): toplevel in the window tier, closed by Escape,
-- dragged by its title bar with the position saved, scaled and faded by the Master controls rows.
-- Every color and font it shows comes from the skin (skinning-§3): nothing here types one.

NS.Showroom = NS.Showroom or {}
local R = NS.Showroom
local L = NS.L
local Perf = NS.Perf
local LAYERS = NS.Constants.LAYERS

local WINDOW_NAME = "LibKa0sSkinTesterShowroom"
local WIDTH, HEIGHT = 960, 640
local TITLE_H = 28

local frame              -- built on first Show
local escListed = false  -- UISpecialFrames is written once, at the first show, not at load

--- The facade every sample paints through, read at call time so a profile switch is followed.
local function S() return NS.Skin end

local function profile()
    local db = NS.addon and NS.addon.db
    return db and db.profile
end

local function onDragStop(self)
    self:StopMovingOrSizing()
    NS.Windows.Save(WINDOW_NAME, self)
end

local function anchorDefault(f)
    f:ClearAllPoints()
    f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
end

local function build()
    local t0 = Perf.on and debugprofilestop()
    local f = CreateFrame("Frame", WINDOW_NAME, UIParent, "BackdropTemplate")
    f:SetSize(WIDTH, HEIGHT)
    f:SetFrameStrata(LAYERS.STRATA.WINDOW)
    f:SetToplevel(true)
    f:SetClampedToScreen(true)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:Hide()
    if not NS.Windows.Restore(WINDOW_NAME, f) then anchorDefault(f) end

    local bar = CreateFrame("Frame", nil, f, "BackdropTemplate")
    bar:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
    bar:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, 0)
    bar:SetHeight(TITLE_H)
    bar:EnableMouse(true)
    bar:RegisterForDrag("LeftButton")
    bar:SetScript("OnDragStart", function() f:StartMoving() end)
    bar:SetScript("OnDragStop", function() onDragStop(f) end)
    bar.title = bar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    bar.title:SetPoint("CENTER", bar, "CENTER", 0, 0)
    bar.title:SetText(NS.BRAND_NAME .. " \226\128\148 " .. L["Skin showroom"])
    f.titleBar = bar

    local close = NS.MakeCloseButton(bar, function() R.Hide() end)
    if close then
        close:SetPoint("RIGHT", bar, "RIGHT", -6, 0)
        f.close = close
    end

    -- The body later items fill: the swatch selector on top, the sections below it.
    local body = CreateFrame("Frame", nil, f)
    body:SetPoint("TOPLEFT", bar, "BOTTOMLEFT", 8, -8)
    body:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -8, 8)
    f.body = body

    local skin = S()
    skin.Shell(f)
    skin.TitleBar(bar, { text = bar.title })
    if close then skin.CloseButton(close) end

    frame = f
    R.ApplyWindowSettings()
    if t0 then Perf.Note("build", debugprofilestop() - t0) end
    NS.Debug("Showroom", "built")
    return f
end

--- Applies the Master controls' scale and opacity to a built window; a no-op before the first open.
function R.ApplyWindowSettings()
    if not frame then return end
    local p = profile() or {}
    frame:SetScale(tonumber(p.scale) or 1)
    frame:SetAlpha(tonumber(p.alpha) or 1)
end

--- Reset position: forgets the saved anchor and centers the window.
function R.ResetPosition()
    NS.Windows.Forget(WINDOW_NAME)
    if frame then anchorDefault(frame) end
    NS.Debug("Showroom", "position reset")
end

function R.IsShown()
    return frame ~= nil and frame:IsShown() == true
end

--- Opens the window, unless the addon is stood down, in which case the refusal line says why.
function R.Show()
    local refusal = NS.StandDownRefusal()
    if refusal then return NS.Print(refusal) end
    local f = frame or build()
    if not escListed and type(UISpecialFrames) == "table" then
        escListed = true
        table.insert(UISpecialFrames, WINDOW_NAME)
    end
    f:Show()
    NS.Debug("Showroom", "shown")
end

function R.Hide()
    if frame and frame:IsShown() then
        frame:Hide()
        NS.Debug("Showroom", "hidden")
    end
end

--- `/st show`, the launcher's Show window entry (toggleWindow) and the key binding: one handler.
function R.Toggle()
    if R.IsShown() then return R.Hide() end
    R.Show()
end

--- The latch's teardown: the window closes and stays closed until the addon stands up again.
function R.StandDown() R.Hide() end

--- Nothing reopens on stand-up; the window opens only when the player asks.
function R.StandUp() end

--- A read-only view for the diagnostics report: counters, never a build.
function R.Snapshot()
    return { built = frame ~= nil, shown = R.IsShown(), sections = 0, primitives = 0 }
end

-- A skin change repaints every frame recorded for this owner (the library's Repaint); the bracket
-- measures the whole skin change as the player sees it, from the library's notification.
if NS.Skin and NS.Skin.OnLooksChanged then
    NS.Skin.OnLooksChanged(function()
        local t0 = Perf.on and debugprofilestop()
        NS.Debug("Showroom", "skin changed")
        if t0 then Perf.Note("repaint", debugprofilestop() - t0) end
    end)
end

-- The Show window key binding (launcher-§6). The button's name is permanent: the client stores the
-- player's key against it, so a rename silently unbinds it.
NS.TOGGLE_BUTTON  = "LibKa0sSkinTesterToggleShowroom"
NS.TOGGLE_COMMAND = ("CLICK %s:LeftButton"):format(NS.TOGGLE_BUTTON)
do
    local button = CreateFrame("Button", NS.TOGGLE_BUTTON, UIParent)   -- plain, not secure
    button:RegisterForClicks("AnyDown")                               -- one press, one toggle
    button:SetScript("OnClick", function() R.Toggle() end)
    button:Hide()
    -- The section title in Options -> Keybindings, the brand (launcher-§1).
    BINDING_HEADER_LIBKA0SSKINTESTER = NS.BRAND_NAME
    -- The label's global name holds a space and a colon, so no identifier can spell it.
    rawset(_G, ("BINDING_NAME_%s"):format(NS.TOGGLE_COMMAND), L["Toggle the skin showroom"])
    -- In Bindings.xml order; the General page's Keybindings tab and the suite read it.
    NS.BINDINGS = {
        { command = NS.TOGGLE_COMMAND, tooltip = L["Shows or hides the skin showroom."] },
    }
end

