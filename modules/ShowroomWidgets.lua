local addonName, NS = ...
-- modules/ShowroomWidgets.lua — the Library widgets section: the custom LibKa0s widgets v1.81.0 newly
-- skins (Ka0sAddonsCommonTasks docs/2026-10-30-SKIN_LIBRARY_FOLLOWUPS, LK-06a..d and LK-08, ruling
-- R-5), each owned by this addon. The showroom is a window, so none passes `panel`: each wears the
-- skin whatever Ignore settings panel says (decision D-01), and Ignore fonts gives its strings their
-- template face back.
--
--   a drag handle        its label in the skin's body face; hover it: the tooltip's title, body and
--                        footer in gtip.title, gtip.value and gtip.footer (LK-08)
--   an autocomplete      type in the box: the suggestion rows in menu.text and the body face (LK-06a)
--   a line chart         its tick labels in text.disabled and the body face (LK-06a)
--   a resize grip        Core.MakeResizable with opts.owner: icon.grip, the client's art where a
--                        skin leaves it false (LK-06b)
--   a drawer head        its chevron in icon.arrow, its label and summary in the body face, and its
--                        hover art in list.hoverArt (LK-06c)
--   a nav entry          its hover art in list.hoverArt (LK-06c)
--   three launchers      a copy window (its grip, LK-06b), the debug console (its title-bar labels,
--                        LK-06b) and the skin picker ("Choose a skin" over the addon's name, LK-11)
--
-- Built only through the sample's own frames; the tooltip is the client's GameTooltip, as the drag
-- handle draws it in every host.

local R, L = NS.Showroom, NS.L

-- The settings drawer's own art (OptionsDrawer), so the sample shows what a settings page shows.
local CHEVRON = "Interface\\ChatFrame\\ChatFrameExpandArrow"
local HOVER = "Interface\\QuestFrame\\UI-QuestLogTitleHighlight"
local COPY_NAME = "LibKa0sSkinTesterSampleCopy"
local DAY = 86400

local function widgets() return LibStub and LibStub("LibKa0s-Widgets-1.0", true) end
local function core() return LibStub and LibStub("LibKa0s-Core-1.0", true) end
local function Skin() return LibStub and LibStub("LibKa0s-Skin-1.0", true) end

local function boxed(cell, w, h)
    local f = CreateFrame("Frame", nil, cell, "BackdropTemplate")
    f:SetSize(w, h)
    f:SetPoint("TOPLEFT")
    return f
end

local function label(parent, text, template)
    local fs = parent:CreateFontString(nil, "OVERLAY", template or "GameFontHighlight")
    fs:SetPoint("LEFT", parent, "LEFT", 8, 0)
    fs:SetText(text)
    return fs
end

-- The client's ADD highlight, shown under the pointer: the art list.hoverArt tints.
local function hoverArt(f)
    local tex = f:CreateTexture(nil, "HIGHLIGHT")
    tex:SetAllPoints(f)
    tex:SetTexture(HOVER)
    if tex.SetBlendMode then tex:SetBlendMode("ADD") end
    tex:SetAlpha(0.35)
    return tex
end

local function dragHandle(g, body)
    local cell = g:Add(220, 18, "DragHandle (hover: gtip.title, gtip.value, gtip.footer)")
    local W = widgets()
    if not (W and W.DragHandle) then return end
    local spec = {
        label = "Hover me: a drag handle", moveFrame = cell, owner = addonName,
        tooltip = {
            title = "Drag handle",
            body = { "The body, in gtip.value." },
            footer = { "The footer, in gtip.footer." },
        },
    }
    local handle = W.DragHandle(cell, spec)
    if not handle then return end
    handle:ApplyWidth(220)
    handle:SetPoint("TOPLEFT", cell, "TOPLEFT", 0, 0)
    handle:Show()
    body.handle, body.handleSpec = handle, spec
end

--- The autocomplete's provider: every skin whose label holds the typed text, as a row.
local function skinsMatching(text)
    local out, lib, needle = {}, Skin(), tostring(text or ""):lower()
    for _, def in ipairs(lib and lib:Skins() or {}) do
        local name = def.label or def.key
        if name:lower():find(needle, 1, true) then out[#out + 1] = { text = name, value = def.key } end
    end
    return out
end

local function autocomplete(g, body)
    local cell = g:Add(200, 22, "Autocomplete (type \"o\")")
    local box = CreateFrame("EditBox", nil, cell, "InputBoxTemplate")
    box:SetSize(190, 22)
    box:SetPoint("TOPLEFT", cell, "TOPLEFT", 6, 0)
    box:SetAutoFocus(false)
    R.Paint("EditBox", box)
    local W = widgets()
    body.completeProvider = skinsMatching
    if not (W and W.Autocomplete) then return end
    body.complete = W.Autocomplete(box, {
        owner = addonName, provider = skinsMatching,
        onPick = function(item) box:SetText(item.text) end,
    })
end

local function lineChart(g, body)
    local w, h = 260, 110
    local cell = g:Add(w, h, "LineChart (tick labels: text.disabled, the body face)")
    local W = widgets()
    if not (W and W.LineChart) then return end
    local chart = W.LineChart(cell, { owner = addonName })
    chart:SetSize(w, h)
    chart:SetPoint("TOPLEFT", cell, "TOPLEFT", 0, 0)
    local x0 = 1790000000
    local a, b = {}, {}
    for i = 0, 6 do
        a[#a + 1] = { x = x0 + i * DAY, y = 20 + (i * 7) % 23 }
        b[#b + 1] = { x = x0 + i * DAY, y = 12 + (i * 11) % 17 }
    end
    chart:SetData({ xMin = x0, xMax = x0 + 6 * DAY, integer = true,
        series = { { points = a, colorIndex = 1 }, { points = b, colorIndex = 2 } } })
    chart:Render(w, h)
    body.chart = chart
end

local function resizeGrip(g, body, paint)
    local box = boxed(g:Add(160, 60, "MakeResizable, opts.owner (icon.grip)"), 160, 60)
    paint("Panel", box)
    paint("Text", label(box, "Drag the corner"), "body")
    local C = core()
    if C and C.MakeResizable then C.MakeResizable(box, { owner = addonName }) end
    body.gripBox = box
end

local function drawerHead(g, body, paint)
    local head = boxed(g:Add(220, 26, "Drawer, opts.chevron + opts.hover"), 220, 26)
    head:EnableMouse(true)
    local name = label(head, "Drawer")
    local summary = head:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    summary:SetPoint("RIGHT", head, "RIGHT", -26, 0)
    summary:SetText("hover me")
    local chevron = head:CreateTexture(nil, "ARTWORK")
    chevron:SetSize(14, 14)
    chevron:SetPoint("RIGHT", head, "RIGHT", -8, 0)
    chevron:SetTexture(CHEVRON)
    local hover = hoverArt(head)
    paint("Drawer", head, { label = name, summary = summary, chevron = chevron, hover = hover })
    body.drawer, body.drawerChevron, body.drawerHover = head, chevron, hover
end

local function navEntry(g, body, paint)
    local item = boxed(g:Add(160, 22, "NavItem, opts.hover"), 160, 22)
    item:EnableMouse(true)
    local hover = hoverArt(item)
    paint("NavItem", item, { label = label(item, "Hover me"), hover = hover })
    body.nav, body.navHover = item, hover
end

local function launcher(g, caption, text, onClick, paint)
    local btn = R.SampleButton(g:Add(160, 24, caption), 160, 24, text)
    btn:SetPoint("TOPLEFT")
    btn:SetScript("OnClick", onClick)
    paint("Button", btn)
    return btn
end

local COPY_TEXT = "A copy window, owned by this addon.\nIts resize grip, bottom right, wears icon.grip."

local function launchers(g, body, paint)
    local W = widgets()
    body.copyWindow = W and W.CopyWindow and W.CopyWindow({ addonName = addonName, name = COPY_NAME,
        title = "Copy window", width = 420, height = 220 })
    body.copyButton = launcher(g, "CopyWindow (its grip)", "Open a copy window", function()
        if body.copyWindow then body.copyWindow:Show(COPY_TEXT) end
    end, paint)
    body.consoleButton = launcher(g, "The debug console (its labels)", "Open the console", function()
        if NS.DebugLog and NS.DebugLog.Show then NS.DebugLog:Show() end
    end, paint)
    body.pickerButton = launcher(g, "The skin picker (its layout)", "Show the picker", function()
        if NS.ShowSkinPicker then NS.ShowSkinPicker() end
    end, paint)
end

R.AddSection("widgets", L["Library widgets"], function(body, paint)
    local g = R.Grid(body)
    dragHandle(g, body)
    autocomplete(g, body)
    resizeGrip(g, body, paint)
    g:Break()
    lineChart(g, body)
    drawerHead(g, body, paint)
    navEntry(g, body, paint)
    g:Break()
    launchers(g, body, paint)
    return g:Height()
end)
