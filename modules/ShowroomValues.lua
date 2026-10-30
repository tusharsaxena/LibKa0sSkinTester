local addonName, NS = ...
-- modules/ShowroomValues.lua — the Values section: what the six getters answer, then four token
-- categories of the skin worn, each token as a labeled swatch under its category's heading: every
-- semantic color (`sem.*`), every item quality tier (`q.*`, poor to legendary), every tooltip color
-- (`gtip.*`, LibKa0s v1.81.0's `gtip.footer` among them) and the two art tints v1.81.0 added
-- (`list.hoverArt`, `icon.grip`), which read "false, the client's art" where a skin leaves the
-- client's art as drawn (Ka0s Default, WoW Default). The getters paint
-- nothing, so they are shown by what they answer: the accent, panel and glow colors as swatches, the
-- body font as a line set in it, the HUD bar style as a sample bar, the chart style as its series.
--
--   NS.Values.shown   the getter names on display; the coverage suite counts them
--   NS.Values.lines   [sem key] = { swatch, text }, one per `sem.*` token the skin resolves
--   NS.Values.tiers   [q key] = { swatch, text }, one per `q.*` token in the schema, in its order;
--                     a tier the skin leaves unset reads "<key>: none" with no swatch
--   NS.Values.tips    [gtip key] = { swatch, text }, one per `gtip.*` token in the schema
--   NS.Values.art     [art key] = { swatch, text }: `list.hoverArt` and `icon.grip`
--   NS.Values.heads   [category] = the heading FontString ("sem", "q", "gtip", "art")
--
-- Everything redraws on OnLooksChanged: these are values read once, not paint the library records.

local R, L = NS.Showroom, NS.L
local BAR = "Interface\\TargetingFrame\\UI-StatusBar"
local SWATCH = 16
local SEM_W = 150

NS.Values = { shown = {}, lines = {}, tiers = {}, tips = {}, art = {}, heads = {} }
local V = NS.Values
local draws = {}   -- one redraw per display, run at build and on every skin change

local function Skin() return LibStub and LibStub("LibKa0s-Skin-1.0", true) end

local function setSwatch(tex, r, g, b, a)
    if type(r) == "number" then
        tex:SetColorTexture(r, g, b, a or 1)
        tex:Show()
    else
        tex:Hide()
    end
end

local function colorOf(c)
    if type(c) == "table" and type(c[1]) == "number" then return c[1], c[2], c[3], c[4] or 1 end
end

local function swatchLine(cell, name)
    local tex = cell:CreateTexture(nil, "ARTWORK")
    tex:SetSize(SWATCH, SWATCH)
    tex:SetPoint("LEFT", cell, "LEFT", 0, 0)
    local fs = cell:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    fs:SetPoint("LEFT", tex, "RIGHT", 6, 0)
    fs:SetText(name)
    return tex, fs
end

--- A getter shown as a swatch of the color it answers, or as "nil" when the skin sets none.
local function colorGetter(g, name, none)
    local tex, fs = swatchLine(g:Add(160, SWATCH, name), name)
    V.shown[name] = true
    draws[#draws + 1] = function()
        local r, gg, b, a = R.Paint(name)
        setSwatch(tex, r, gg, b, a)
        fs:SetText(type(r) == "number" and ("%.2f %.2f %.2f"):format(r, gg, b) or none)
    end
end

local function fontGetter(g)
    local fs = g:Add(300, 18, "GetFont"):CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    fs:SetPoint("LEFT")
    V.shown.GetFont = true
    draws[#draws + 1] = function()
        local path = R.Paint("GetFont")
        if path then fs:SetFont(path, 14, "") end
        fs:SetText(("Body font: %s"):format(tostring(path)))
    end
end

local function barGetter(g)
    local cell = g:Add(220, 30, "BarStyle")
    local bar = CreateFrame("StatusBar", nil, cell)
    bar:SetSize(220, 16)
    bar:SetPoint("TOPLEFT")
    bar:SetMinMaxValues(0, 1)
    bar:SetValue(0.7)
    local bg = bar:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(bar)
    local fs = cell:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    fs:SetPoint("TOPLEFT", bar, "BOTTOMLEFT", 0, -2)
    V.shown.BarStyle = true
    draws[#draws + 1] = function()
        local st = R.Paint("BarStyle") or {}
        bar:SetStatusBarTexture(st.texture or BAR)
        setSwatch(bg, colorOf(st.bg))
        fs:SetText(("%s, %s %s"):format(tostring(st.textureKey), tostring(st.fontKey), tostring(st.fontSize)))
    end
end

local function chartGetter(g)
    local cell = g:Add(12 * (SWATCH + 2), SWATCH, "ChartStyle (series)")
    local texs = {}
    for i = 1, 12 do
        local tex = cell:CreateTexture(nil, "ARTWORK")
        tex:SetSize(SWATCH, SWATCH)
        tex:SetPoint("LEFT", cell, "LEFT", (i - 1) * (SWATCH + 2), 0)
        texs[i] = tex
    end
    V.shown.ChartStyle = true
    draws[#draws + 1] = function()
        local series = (R.Paint("ChartStyle") or {}).series
        for i, tex in ipairs(texs) do
            setSwatch(tex, colorOf(type(series) == "table" and series[i]))
        end
    end
end

local function semKeys()
    local lib, keys = Skin(), {}
    if not lib then return keys end
    local _, skin = lib:GetChoice(addonName)
    for key in pairs(lib:ResolveSkin(skin)) do
        if key:find("^sem%.") then keys[#keys + 1] = key end
    end
    table.sort(keys)
    return keys
end

local function semLines(g)
    for _, key in ipairs(semKeys()) do
        local tex, fs = swatchLine(g:Add(SEM_W, SWATCH, ""), key)
        V.lines[key] = { swatch = tex, text = fs }
    end
    draws[#draws + 1] = function()
        local lib = Skin()
        for key, line in pairs(V.lines) do
            local r, gg, b, a = lib:Color(addonName, key)
            setSwatch(line.swatch, r, gg, b, a)
            if type(r) == "number" then R.Paint("Font", line.text, r, gg, b) end
        end
    end
end

-- The schema's names under one prefix, in the schema's order: every one, set or not, since a skin
-- may leave a token unset (the quality tiers: the client's colors stand).
local function schemaKeys(pattern)
    local lib, keys = Skin(), {}
    for _, entry in ipairs(lib and lib.SCHEMA or {}) do
        if entry.name:find(pattern) then keys[#keys + 1] = entry.name end
    end
    return keys
end

-- One labeled swatch per key into `store`, each label in its own color; a key the skin leaves
-- without a color reads "<key><none>" in muted text, with no swatch.
local function colorLines(g, keys, store, none)
    for _, key in ipairs(keys) do
        local tex, fs = swatchLine(g:Add(SEM_W, SWATCH, ""), key)
        store[key] = { swatch = tex, text = fs }
    end
    draws[#draws + 1] = function()
        local lib = Skin()
        for _, key in ipairs(keys) do
            local line = store[key]
            local r, gg, b, a = lib:Color(addonName, key)
            setSwatch(line.swatch, r, gg, b, a)
            if type(r) == "number" then
                line.text:SetText(key)
                R.Paint("Font", line.text, r, gg, b)
            else
                line.text:SetText(key .. none)
                R.Paint("Text", line.text, "muted")
            end
        end
    end
end

-- The quality tiers, in the schema's order (poor, common, uncommon, rare, epic, legendary).
local function tierLines(g) colorLines(g, schemaKeys("^q%."), V.tiers, ": none") end

-- The tooltip colors, in the schema's order; gtip.footer (v1.81.0) is the drag handle's footer band.
local function tipLines(g) colorLines(g, schemaKeys("^gtip%."), V.tips, ": none") end

-- The two art tints v1.81.0 added: `false` leaves the client's art as drawn.
local ART = { "list.hoverArt", "icon.grip" }
local function artLines(g) colorLines(g, ART, V.art, ": false, the client's art") end

-- A category's heading on a row of its own, in the skin's heading role.
local function heading(g, key, text)
    g:Break()
    local fs = g:Add(SEM_W * 2, 16, ""):CreateFontString(nil, "OVERLAY", "GameFontNormal")
    fs:SetPoint("LEFT")
    fs:SetText(text)
    R.Paint("Text", fs, "heading")
    V.heads[key] = fs
    g:Break()
end

local function redraw()
    for _, draw in ipairs(draws) do draw() end
end

R.AddSection("values", L["Values"], function(body)
    local g = R.Grid(body)
    colorGetter(g, "GetAccentColor", "nil")
    colorGetter(g, "GetPanelColor", "nil")
    colorGetter(g, "GlowColor", "nil: the host's own glow stands")
    fontGetter(g)
    barGetter(g)
    chartGetter(g)
    if Skin() then
        heading(g, "sem", L["Semantic colors (sem.*)"])
        semLines(g)
        heading(g, "q", L["Quality tiers (q.*)"])
        tierLines(g)
        heading(g, "gtip", L["Tooltip colors (gtip.*)"])
        tipLines(g)
        heading(g, "art", L["Art tints (false: the client's art)"])
        artLines(g)
    end
    redraw()
    return g:Height()
end)

if NS.Skin and NS.Skin.OnLooksChanged then NS.Skin.OnLooksChanged(redraw) end
