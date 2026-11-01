local addonName, NS = ...
-- modules/ShowroomOverlays.lua — the Overlays section: a tooltip on hover (a frame of this addon's,
-- never GameTooltip, in tooltip.* with its lines in gtip.*), a standing menu, a confirm popup as a miniature (a plain frame painted
-- Shell and Button, never a StaticPopup), the library's test strip, the fades beside an unfaded twin,
-- an icon border and a bar fill, and a small mark on a texture (S.Mark) and in a line (S.MarkText).

local R, L = NS.Showroom, NS.L
local ICON = "Interface\\Icons\\INV_Misc_QuestionMark"
local BAR = NS.Constants.FALLBACK_BAR_TEXTURE   -- only with the library absent: BarStyle answers the skin's
local WHITE = "Interface\\Buttons\\WHITE8X8"
local TIP_BACKDROP = { bgFile = WHITE, edgeFile = WHITE, edgeSize = 1 }

local tooltip   -- built with the section, painted once, reused on every hover
local drawMarkLine   -- writes the MarkText line, set when the section is built
local drawFillBar    -- gives the ApplyBarFill sample the skin's texture, set when the section is built

local function widgets() return LibStub and LibStub("LibKa0s-Widgets-1.0", true) end

local function boxed(cell, w, h, template)
    local f = CreateFrame("Frame", nil, cell, template or "BackdropTemplate")
    f:SetSize(w, h)
    return f
end

-- S.Tooltip recolors a backdrop, so the frame carries one of its own: GameTooltipTemplate has none
-- and the primitive never reaches GameTooltip (skinning-§7).
local function tooltipFrame(paint)
    local tip = CreateFrame("Frame", "LibKa0sSkinTesterSampleTooltip", UIParent, "BackdropTemplate")
    tip:SetSize(170, 48)
    tip:SetFrameStrata(NS.Constants.LAYERS.STRATA.MODAL)
    tip:SetBackdrop(TIP_BACKDROP)
    tip.title = tip:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    tip.title:SetPoint("TOPLEFT", tip, "TOPLEFT", 8, -8)
    tip.title:SetText("A tooltip")
    tip.line = tip:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    tip.line:SetPoint("TOPLEFT", tip.title, "BOTTOMLEFT", 0, -4)
    tip.line:SetText("Painted by the skin")
    tip:Hide()
    paint("Tooltip", tip)
    return tip
end

local function tipLine(fs, token)
    local r, g, b = NS.Skin.Color(token)
    R.Paint("Font", fs, r, g, b)
end

local function hoverTooltip(cell, paint)
    tooltip = tooltip or tooltipFrame(paint)
    R.sampleTooltip = tooltip
    local btn = R.SampleButton(cell, 120, 24, "Hover me")
    btn:SetPoint("TOPLEFT")
    paint("Button", btn)
    btn:SetScript("OnEnter", function(self)
        tipLine(tooltip.title, "gtip.title")
        tipLine(tooltip.line, "gtip.value")
        tooltip:ClearAllPoints()
        tooltip:SetPoint("BOTTOMLEFT", self, "TOPRIGHT", 4, 4)
        tooltip:Show()
    end)
    btn:SetScript("OnLeave", function() tooltip:Hide() end)
    return btn
end

local function standingMenu(cell, paint)
    local menu = boxed(cell, 140, 66)
    menu:SetPoint("TOPLEFT")
    for i, text in ipairs({ "Copy link", "Hide row", "Report" }) do
        local fs = menu:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        fs:SetPoint("TOPLEFT", menu, "TOPLEFT", 8, -6 - (i - 1) * 20)
        fs:SetText(text)
        paint("Text", fs, "body")
    end
    paint("MenuFrame", menu)
end

local function confirmPopup(cell, paint)
    local pop = boxed(cell, 220, 80)
    pop:SetPoint("TOPLEFT")
    local text = pop:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    text:SetPoint("TOP", pop, "TOP", 0, -12)
    text:SetText("Reset every setting?")
    paint("Shell", pop)
    paint("Text", text, "body")
    for i, word in ipairs({ "Accept", "Cancel" }) do
        local btn = R.SampleButton(pop, 90, 22, word)
        btn:SetPoint("BOTTOM", pop, "BOTTOM", (i == 1 and -50 or 50), 10)
        paint("Button", btn, { primary = i == 1 })
    end
end

local function testStrip(cell, paint)
    local W = widgets()
    local strip
    if W and W.TestStrip then
        strip = W.TestStrip(cell, { text = "Test mode: the data below is not real", owner = addonName })
    else
        strip = boxed(cell, 260, 18)
    end
    strip:SetPoint("TOPLEFT")
    strip:SetWidth(260)
    strip:Show()
    paint("Strip", strip, { kind = "test" })
end

-- S.Mark tints on its own after a skin change; a string cannot be repainted, so MarkText is written
-- again by the redraw below the section. NS.Icon answers nil with the library absent.
local function marks(cell, paint)
    local info = NS.Icon("info")
    local mark = cell:CreateTexture(nil, "ARTWORK")
    mark:SetSize(16, 16)
    mark:SetPoint("LEFT")
    paint("Mark", mark, { art = info })
    local good = cell:CreateTexture(nil, "ARTWORK")
    good:SetSize(16, 16)
    good:SetPoint("LEFT", mark, "RIGHT", 6, 0)
    paint("Mark", good, { art = NS.Icon("confirm"), token = "sem.good" })
    local line = cell:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    line:SetPoint("LEFT", good, "RIGHT", 6, 0)
    paint("Text", line, "body")
    drawMarkLine = function()
        line:SetText(("%s in a line"):format(info and R.Paint("MarkText", info, 14) or ""))
    end
    drawMarkLine()
    return mark, good, line
end

R.AddSection("overlays", L["Overlays"], function(body, paint)
    local g = R.Grid(body)

    body.tipButton = hoverTooltip(g:Add(120, 24, "Tooltip (hover)"), paint)
    standingMenu(g:Add(140, 66, "MenuFrame"), paint)
    confirmPopup(g:Add(220, 80, "Confirm popup (Shell + Button)"), paint)
    testStrip(g:Add(260, 18, "TestStrip (the library's)"), paint)

    local fades = g:Add(250, 24, "FadeRegions (left) beside stock")
    local faded = R.SampleButton(fades, 120, 24, "Faded", "UIPanelButtonTemplate")
    faded:SetPoint("LEFT")
    paint("FadeRegions", faded)
    paint("Text", faded.text, "body")
    body.faded = faded
    R.SampleButton(fades, 120, 24, "Stock", "UIPanelButtonTemplate"):SetPoint("LEFT", faded, "RIGHT", 8, 0)

    local slices = g:Add(250, 50, "FadeNineSlice (left) beside stock")
    local sliced = boxed(slices, 120, 50, "InsetFrameTemplate")
    sliced:SetPoint("LEFT")
    paint("FadeNineSlice", sliced)
    boxed(slices, 120, 50, "InsetFrameTemplate"):SetPoint("LEFT", sliced, "RIGHT", 8, 0)

    local framed = boxed(g:Add(36, 36, "IconBorder, fromSkin"), 36, 36)
    framed:SetPoint("TOPLEFT")
    local icon = framed:CreateTexture(nil, "ARTWORK")
    icon:SetAllPoints(framed)
    icon:SetTexture(ICON)
    paint("IconBorder", framed, { fromSkin = true })
    body.framed = framed

    local bar = CreateFrame("StatusBar", nil, g:Add(200, 16, "ApplyBarFill"))
    bar:SetSize(200, 16)
    bar:SetPoint("TOPLEFT")
    bar:SetMinMaxValues(0, 1)
    bar:SetValue(0.6)
    body.fillBar = bar
    drawFillBar = function()
        bar:SetStatusBarTexture((R.Paint("BarStyle") or {}).texture or BAR)
        paint("ApplyBarFill", bar)
    end
    drawFillBar()

    body.mark, body.markGood, body.markLine = marks(g:Add(160, 16, "Mark (tint, sem.good), MarkText"), paint)

    return g:Height()
end)

if NS.Skin and NS.Skin.OnLooksChanged then
    NS.Skin.OnLooksChanged(function()
        if drawMarkLine then drawMarkLine() end
        if drawFillBar then drawFillBar() end
    end)
end
