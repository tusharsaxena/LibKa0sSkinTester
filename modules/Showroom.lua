local addonName, NS = ...
-- modules/Showroom.lua — the skin showroom window: built on first open, painted through the owner's
-- skin facade, toggled by `/st show`, the launcher's Show window entry and the key binding.
--
-- A plain non-secure frame (standalone-windows): toplevel in the window tier, closed by Escape,
-- dragged by its title bar with the position saved, scaled and faded by the Master controls rows.
-- Every color and font it shows comes from the skin (skinning-§3): nothing here types one.
--
-- THE PAINT WRAPPER. Every sample, and the window's own chrome, is painted through R.Paint, which
-- calls the owner's facade and records the primitive's name in R.used. That record is the showroom's
-- coverage claim (tests/test_showroom_coverage.lua): a sample painted around the wrapper is one the
-- claim cannot see.
--
--   R.Paint(name, target, ...)     the facade's `name`, recorded; answers what it answered
--   R.AddSection(key, title, fn)   a section, laid out in registration order; fn(body, paint) answers
--                                  its height, where paint(name, ...) is R.Paint
--   R.Caption(parent, text)        a FontString in the skin's muted text: a sample's label
--   R.Section(key)                 a built section's frame (with .title); nil before the first open

NS.Showroom = NS.Showroom or {}
local R = NS.Showroom
local L = NS.L
local Perf = NS.Perf
local LAYERS = NS.Constants.LAYERS

local WINDOW_NAME = "LibKa0sSkinTesterShowroom"
local WIDTH, HEIGHT = 960, 640
local TITLE_H, FOOTER_H = 28, 22
local SECTION_TITLE_H, SECTION_GAP = 24, 16
local SCROLL_STEP = 60

R.used = R.used or {}
local sections = {}      -- { key, title, build }, in registration order

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

function R.Paint(name, target, ...)
    R.used[name] = true
    local fn = S()[name]
    if type(fn) == "function" then return fn(target, ...) end
end

local function paint(name, ...) return R.Paint(name, ...) end

function R.AddSection(key, title, buildFn)
    sections[#sections + 1] = { key = key, title = title, build = buildFn }
end

function R.Caption(parent, text)
    local fs = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    fs:SetText(text)
    R.Paint("Text", fs, "muted")
    return fs
end

--- The skin the showroom wears, by its label, for the footer.
local function wornLabel()
    local Skin = LibStub and LibStub("LibKa0s-Skin-1.0", true)
    if not Skin then return "?" end
    local source, key = Skin:GetChoice(addonName)
    if source == "eui" then return "EllesmereUI" end
    for _, def in ipairs(Skin:Skins()) do
        if def.key == key then return def.label or key end
    end
    return key
end

local function refreshFooter()
    if frame then frame.footer.text:SetText(L["Wearing %s"]:format(wornLabel())) end
end

-- Mouse-wheel scrolling over the sections, clamped to the scroll range.
local function onWheel(scroll, delta)
    local range = scroll:GetVerticalScrollRange() or 0
    local y = (scroll:GetVerticalScroll() or 0) - delta * SCROLL_STEP
    scroll:SetVerticalScroll(math.max(0, math.min(range, y)))
end

-- The sections, stacked in a scroll child: each a title in the heading role over a rule, then the
-- body its build filled.
local function buildSections(content, width)
    local y = 0
    content.sections = {}
    for _, sec in ipairs(sections) do
        local holder = CreateFrame("Frame", nil, content)
        holder:SetWidth(width)
        holder:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -(y + SECTION_TITLE_H))
        local title = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        title:SetPoint("BOTTOMLEFT", holder, "TOPLEFT", 0, 6)
        title:SetText(sec.title)
        R.Paint("Text", title, "heading")
        holder.title = title
        local h = tonumber(sec.build(holder, paint)) or 0
        holder:SetHeight(h)
        content.sections[sec.key] = holder
        y = y + SECTION_TITLE_H + h + SECTION_GAP
    end
    content:SetHeight(math.max(1, y))
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

    local footer = CreateFrame("Frame", nil, f, "BackdropTemplate")
    footer:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 0, 0)
    footer:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, 0)
    footer:SetHeight(FOOTER_H)
    footer.text = footer:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    footer.text:SetPoint("LEFT", footer, "LEFT", 8, 0)
    f.footer = footer

    -- The body: the swatch selector on top, the sections scrolling below it.
    local body = CreateFrame("Frame", nil, f)
    body:SetPoint("TOPLEFT", bar, "BOTTOMLEFT", 8, -8)
    body:SetPoint("BOTTOMRIGHT", footer, "TOPRIGHT", -8, 8)
    f.body = body

    f.selector = NS.Selector.Build(body)
    f.selector:SetPoint("TOPLEFT", body, "TOPLEFT", 0, 0)

    local scroll = CreateFrame("ScrollFrame", nil, body)
    scroll:SetPoint("TOPLEFT", f.selector, "BOTTOMLEFT", 0, -12)
    scroll:SetPoint("BOTTOMRIGHT", body, "BOTTOMRIGHT", 0, 0)
    scroll:EnableMouseWheel(true)
    scroll:SetScript("OnMouseWheel", onWheel)
    local content = CreateFrame("Frame", nil, scroll)
    content:SetWidth(WIDTH - 16)
    scroll:SetScrollChild(content)
    f.scroll, f.content = scroll, content

    frame = f
    R.Paint("Shell", f)
    R.Paint("TitleBar", bar, { text = bar.title })
    if close then R.Paint("CloseButton", close) end
    R.Paint("Footer", footer, { text = footer.text })
    buildSections(content, WIDTH - 16)
    refreshFooter()
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

--- The swatch selector of the built window; nil before the first open.
function R.Selector()
    return frame and frame.selector
end

function R.Section(key)
    return frame and frame.content.sections[key]
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
    local used = 0
    for _ in pairs(R.used) do used = used + 1 end
    return { built = frame ~= nil, shown = R.IsShown(), sections = #sections, primitives = used }
end

-- A skin change repaints every frame recorded for this owner (the library's Repaint); the bracket
-- measures the whole skin change as the player sees it, from the library's notification.
if NS.Skin and NS.Skin.OnLooksChanged then
    NS.Skin.OnLooksChanged(function()
        local t0 = Perf.on and debugprofilestop()
        if frame then NS.Selector.Refresh(frame.selector) end
        refreshFooter()
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

