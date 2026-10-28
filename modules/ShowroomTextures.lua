local _, NS = ...
-- modules/ShowroomTextures.lua — the Textures section: every element that draws a bar of data, each
-- fill painted with the skin's bar texture through S.BarTexture (LibKa0s-Skin-1.0 minor 6). Three
-- status bars (the accent, the good and the bad color), a five-row horizontal bar chart and a stacked
-- bar of five segments, both in the skin's chart series. Each sample is labeled with the texture key
-- in effect (`bar.texture`), so a skin switch or the Skin tab's Texture override reads off it live.
--
--   NS.Textures.bars     the three StatusBars, in order: accent, good, bad
--   NS.Textures.rows     the bar chart's five fill Textures, top to bottom
--   NS.Textures.segments the stacked bar's five segment Textures, left to right
--   NS.Textures.labels   the FontStrings that name the texture key, one per sample
--
-- The fills are recorded by the library, so a repaint re-applies the texture by itself. The colors
-- and the labels are values read from the skin, so they redraw on OnLooksChanged.

local R, L = NS.Showroom, NS.L

NS.Textures = { bars = {}, rows = {}, segments = {}, labels = {} }
local X = NS.Textures

local BAR_W, BAR_H = 220, 16
local CHART_W, ROW_H, ROW_GAP = 260, 12, 4
local STACK_W, STACK_H = 300, 18

--- The three status bars: the token each is colored by, and how full it is.
local STATUS = {
    { token = "text.accent", value = 0.72, caption = "StatusBar (accent, 72%)" },
    { token = "sem.good",    value = 0.45, caption = "StatusBar (good, 45%)" },
    { token = "sem.bad",     value = 0.88, caption = "StatusBar (bad, 88%)" },
}
--- The bar chart's five rows, as a fraction of the chart's width.
local ROWS = { 1.0, 0.8, 0.62, 0.45, 0.3 }
--- The stacked bar's five segments, as a fraction of its width.
local SEGMENTS = { 0.3, 0.25, 0.2, 0.15, 0.1 }

local draws = {}   -- one redraw per sample, run at build and on every change of the look

local function S() return NS.Skin end

local function rgba(c)
    if type(c) == "table" and type(c[1]) == "number" then return c[1], c[2], c[3], c[4] or 1 end
    return 1, 1, 1, 1
end

local function seriesColor(i)
    local series = S().Token("chart.series")
    return rgba(type(series) == "table" and series[i])
end

--- The texture key in effect, as the label under every sample reads it.
function X.TextureKey()
    local key = S().Token("bar.texture")
    return key ~= nil and tostring(key) or "none"
end

local function keyLabel(cell)
    local fs = cell:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    fs:SetPoint("BOTTOMLEFT", cell, "BOTTOMLEFT", 0, 0)
    X.labels[#X.labels + 1] = fs
    R.Paint("Text", fs, "muted")
    return fs
end

local function backing(parent)
    local bg = parent:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(parent)
    return bg
end

local function paintBacking(bg)
    local r, g, b, a = rgba(S().Token("bar.bg"))
    bg:SetColorTexture(r, g, b, a)
end

local function statusBar(g, spec)
    local cell = g:Add(BAR_W, BAR_H + 16, spec.caption)
    local bar = CreateFrame("StatusBar", nil, cell)
    bar:SetSize(BAR_W, BAR_H)
    bar:SetPoint("TOPLEFT")
    bar:SetMinMaxValues(0, 1)
    bar:SetValue(spec.value)
    local bg = backing(bar)
    X.bars[#X.bars + 1] = bar
    draws[#draws + 1] = function()
        paintBacking(bg)
        R.Paint("BarTexture", bar, rgba(S().Token(spec.token)))
    end
end

local function barChart(g)
    local height = #ROWS * (ROW_H + ROW_GAP)
    local cell = g:Add(CHART_W, height + 16, "Bar chart (series 1-5)")
    for i, frac in ipairs(ROWS) do
        local track = CreateFrame("Frame", nil, cell)
        track:SetSize(CHART_W, ROW_H)
        track:SetPoint("TOPLEFT", cell, "TOPLEFT", 0, -(i - 1) * (ROW_H + ROW_GAP))
        local bg = backing(track)
        local fill = track:CreateTexture(nil, "ARTWORK")
        fill:SetPoint("TOPLEFT")
        fill:SetSize(CHART_W * frac, ROW_H)
        X.rows[i] = fill
        draws[#draws + 1] = function()
            paintBacking(bg)
            R.Paint("BarTexture", fill, seriesColor(i))
        end
    end
end

local function stackedBar(g)
    local cell = g:Add(STACK_W, STACK_H + 16, "Stacked bar (series 1-5)")
    local x = 0
    for i, frac in ipairs(SEGMENTS) do
        local seg = cell:CreateTexture(nil, "ARTWORK")
        seg:SetPoint("TOPLEFT", cell, "TOPLEFT", x, 0)
        seg:SetSize(STACK_W * frac, STACK_H)
        x = x + STACK_W * frac
        X.segments[i] = seg
        draws[#draws + 1] = function() R.Paint("BarTexture", seg, seriesColor(i)) end
    end
end

local function redraw()
    for _, draw in ipairs(draws) do draw() end
    local text = ("Texture: %s"):format(X.TextureKey())
    for _, fs in ipairs(X.labels) do fs:SetText(text) end
end

R.AddSection("textures", L["Textures"], function(body)
    local g = R.Grid(body)
    for _, spec in ipairs(STATUS) do statusBar(g, spec) end
    barChart(g)
    stackedBar(g)
    -- One key label per sample, under its fill and above its caption.
    for _, bar in ipairs(X.bars) do keyLabel(bar:GetParent()) end
    keyLabel(X.rows[1]:GetParent():GetParent())
    keyLabel(X.segments[1]:GetParent())
    redraw()
    return g:Height()
end)

if NS.Skin and NS.Skin.OnLooksChanged then NS.Skin.OnLooksChanged(redraw) end
