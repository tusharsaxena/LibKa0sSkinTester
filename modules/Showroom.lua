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
--   R.Grid(body)                   a wrapping row layout of captioned cells, for a section's build
--   R.SampleButton(parent, w, h, text, template)   a Button with its label in .text

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
local BAR_W, BAR_GAP, MIN_THUMB = 8, 6, 24   -- the scrollbar's width, its gap from the sections, its shortest knob
local SECTIONS_W = WIDTH - 16 - BAR_GAP - BAR_W   -- the body's width less the scrollbar's gutter

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

local CELL_GAP, CELL_MIN_W, CAPTION_H = 14, 150, 18

--- A section's samples, left to right, wrapping at the body's width. g:Add(w, h, caption) answers a
--- fresh cell frame of that size with the caption under it; g:Height() is what a build answers.
function R.Grid(body)
    local g = { x = 0, y = 0, rowH = 0, width = body:GetWidth() or SECTIONS_W }
    function g:Add(w, h, caption)
        local span = math.max(w, CELL_MIN_W)
        if self.x > 0 and self.x + span > self.width then
            self.x, self.y, self.rowH = 0, self.y + self.rowH + CELL_GAP, 0
        end
        local cell = CreateFrame("Frame", nil, body)
        cell:SetSize(w, h)
        cell:SetPoint("TOPLEFT", body, "TOPLEFT", self.x, -self.y)
        local cap = R.Caption(body, caption)
        cap:SetPoint("TOPLEFT", cell, "BOTTOMLEFT", 0, -4)
        self.x = self.x + span + CELL_GAP
        self.rowH = math.max(self.rowH, h + CAPTION_H)
        return cell
    end
    function g:Height() return self.y + self.rowH end
    return g
end

function R.SampleButton(parent, w, h, text, template)
    local btn = CreateFrame("Button", nil, parent, template or "BackdropTemplate")
    btn:SetSize(w, h)
    local fs = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    fs:SetPoint("CENTER", btn, "CENTER", 0, 0)
    fs:SetText(text)
    btn.text = fs
    if btn.SetFontString then btn:SetFontString(fs) end
    return btn
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

-- The scrollbar follows the scroll frame (ST-03): its range and knob match the sections' overflow,
-- and it shows only while they overflow. `syncing` keeps the bar's own OnValueChanged from scrolling
-- back while the bar is being set.
local function syncBar()
    if not frame then return end
    local scroll, bar = frame.scroll, frame.scrollBar
    local range = tonumber(scroll:GetVerticalScrollRange()) or 0
    local y = tonumber(scroll:GetVerticalScroll()) or 0
    frame.syncing = true
    bar:SetMinMaxValues(0, math.max(0, range))
    bar:SetValue(math.max(0, math.min(range, y)))
    frame.syncing = false
    local track, view = tonumber(bar:GetHeight()) or 0, tonumber(scroll:GetHeight()) or 0
    if range > 0 and track > 0 and view > 0 then
        frame.thumb:SetHeight(math.max(MIN_THUMB, track * view / (view + range)))
    end
    bar:SetShown(range > 0)
end

-- Mouse-wheel scrolling over the sections or the bar, clamped to the scroll range.
local function onWheel(_, delta)
    local scroll = frame.scroll
    local range = tonumber(scroll:GetVerticalScrollRange()) or 0
    local y = (tonumber(scroll:GetVerticalScroll()) or 0) - delta * SCROLL_STEP
    scroll:SetVerticalScroll(math.max(0, math.min(range, y)))
    syncBar()
end

-- A drag of the knob, or a click on the corridor, scrolls the sections.
local function onBarValue(_, value)
    if not frame or frame.syncing then return end
    frame.scroll:SetVerticalScroll(value)
end

-- The scrollbar at the body's right edge, beside the sections: a corridor and one knob, painted by
-- the facade's ScrollBar (the debug console's shape). Hidden until syncBar finds an overflow.
local function buildScrollBar(f, body)
    local bar = CreateFrame("Slider", nil, body)
    bar:SetOrientation("VERTICAL")
    bar:SetWidth(BAR_W)
    bar:SetPoint("TOPRIGHT", f.scroll, "TOPRIGHT", BAR_GAP + BAR_W, 0)
    bar:SetPoint("BOTTOMRIGHT", f.scroll, "BOTTOMRIGHT", BAR_GAP + BAR_W, 0)
    bar:SetMinMaxValues(0, 0)
    bar:SetValueStep(1)
    bar:SetValue(0)
    bar:EnableMouseWheel(true)
    bar:SetScript("OnMouseWheel", onWheel)
    local track = bar:CreateTexture(nil, "BACKGROUND")
    track:SetAllPoints()
    local thumb = bar:CreateTexture(nil, "ARTWORK")
    thumb:SetSize(BAR_W, 36)
    bar:SetThumbTexture(thumb)
    bar:SetScript("OnValueChanged", onBarValue)
    bar:Hide()
    f.scrollBar, f.track, f.thumb = bar, track, thumb
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
    scroll:SetPoint("BOTTOMRIGHT", body, "BOTTOMRIGHT", -(BAR_GAP + BAR_W), 0)
    scroll:EnableMouseWheel(true)
    scroll:SetScript("OnMouseWheel", onWheel)
    scroll:SetScript("OnScrollRangeChanged", syncBar)
    scroll:SetScript("OnVerticalScroll", syncBar)
    scroll:SetScript("OnSizeChanged", syncBar)
    local content = CreateFrame("Frame", nil, scroll)
    content:SetWidth(SECTIONS_W)
    scroll:SetScrollChild(content)
    f.scroll, f.content = scroll, content
    buildScrollBar(f, body)

    frame = f
    R.Paint("Shell", f)
    R.Paint("TitleBar", bar, { text = bar.title })
    if close then R.Paint("CloseButton", close) end
    R.Paint("Footer", footer, { text = footer.text })
    R.Paint("ScrollBar", f.scrollBar, { track = f.track, thumb = f.thumb })
    buildSections(content, SECTIONS_W)
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
    syncBar()
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

