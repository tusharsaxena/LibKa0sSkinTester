local addonName, NS = ...
-- modules/ShowroomOverlays.lua — the Overlays section: a tooltip on hover (a tooltip frame of this
-- addon's, never GameTooltip), a standing menu, a confirm popup as a miniature (a plain frame painted
-- Shell and Button, never a StaticPopup), the library's test strip, the fades beside an unfaded twin,
-- an icon border and a bar fill.

local R, L = NS.Showroom, NS.L
local ICON = "Interface\\Icons\\INV_Misc_QuestionMark"
local BAR = "Interface\\TargetingFrame\\UI-StatusBar"

local tooltip   -- built with the section, painted once, reused on every hover

local function widgets() return LibStub and LibStub("LibKa0s-Widgets-1.0", true) end

local function boxed(cell, w, h, template)
    local f = CreateFrame("Frame", nil, cell, template or "BackdropTemplate")
    f:SetSize(w, h)
    return f
end

local function hoverTooltip(cell, paint)
    tooltip = tooltip or CreateFrame("GameTooltip", "LibKa0sSkinTesterSampleTooltip", UIParent,
        "GameTooltipTemplate")
    paint("Tooltip", tooltip)
    local btn = R.SampleButton(cell, 120, 24, "Hover me")
    btn:SetPoint("TOPLEFT")
    paint("Button", btn)
    btn:SetScript("OnEnter", function(self)
        tooltip:SetOwner(self, "ANCHOR_RIGHT")
        tooltip:SetText("A tooltip")
        tooltip:AddLine("Painted by the skin", 1, 1, 1)
        tooltip:Show()
    end)
    btn:SetScript("OnLeave", function() tooltip:Hide() end)
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

R.AddSection("overlays", L["Overlays"], function(body, paint)
    local g = R.Grid(body)

    hoverTooltip(g:Add(120, 24, "Tooltip (hover)"), paint)
    standingMenu(g:Add(140, 66, "MenuFrame"), paint)
    confirmPopup(g:Add(220, 80, "Confirm popup (Shell + Button)"), paint)
    testStrip(g:Add(260, 18, "TestStrip (the library's)"), paint)

    local fades = g:Add(250, 24, "FadeRegions (left) beside stock")
    local faded = R.SampleButton(fades, 120, 24, "Faded", "UIPanelButtonTemplate")
    faded:SetPoint("LEFT")
    paint("FadeRegions", faded)
    R.SampleButton(fades, 120, 24, "Stock", "UIPanelButtonTemplate"):SetPoint("LEFT", faded, "RIGHT", 8, 0)

    local slices = g:Add(250, 50, "FadeNineSlice (left) beside stock")
    local sliced = boxed(slices, 120, 50, "InsetFrameTemplate")
    sliced:SetPoint("LEFT")
    paint("FadeNineSlice", sliced)
    boxed(slices, 120, 50, "InsetFrameTemplate"):SetPoint("LEFT", sliced, "RIGHT", 8, 0)

    local framed = boxed(g:Add(36, 36, "IconBorder"), 36, 36)
    framed:SetPoint("TOPLEFT")
    local icon = framed:CreateTexture(nil, "ARTWORK")
    icon:SetAllPoints(framed)
    icon:SetTexture(ICON)
    paint("IconBorder", framed, { size = 2 })

    local bar = CreateFrame("StatusBar", nil, g:Add(200, 16, "ApplyBarFill"))
    bar:SetSize(200, 16)
    bar:SetPoint("TOPLEFT")
    bar:SetStatusBarTexture(BAR)
    bar:SetMinMaxValues(0, 1)
    bar:SetValue(0.6)
    paint("ApplyBarFill", bar)

    return g:Height()
end)
