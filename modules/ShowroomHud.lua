local _, NS = ...
-- modules/ShowroomHud.lua — the HUD faces section (LibKa0s v1.81.0: LK-04, ruling R-4, and LK-01,
-- ruling R-1). Every skin names a HUD face of its own, its text's family at the heavier weight, drawn
-- 12px under an OUTLINE: one line per skin, each set in that skin's own `hud.font`, `hud.fontSize` and
-- `hud.outline` and naming the face, so the nine can be judged side by side whatever skin is worn.
-- Like the picker's rows, these show the skins, so Ignore fonts leaves them alone. Under them, one
-- line in the face the worn skin hands a HUD element (S.BarStyle), which Ignore fonts gives back to
-- the host's own face, live. Then the HUD's own primitives (LibKa0s v1.85.0) as a host draws them: a
-- string through S.HudFont in S.HudTextColor, a label in S.HudLabelColor, a line of what S.HudShadow
-- answers, and a bar in S.BarFillColor with S.BarGloss on it.
--
--   NS.Hud.order   the skin keys, in the library's order
--   NS.Hud.lines   [skin key] = its FontString, .faceKey the face it names
--   NS.Hud.worn    the BarStyle line, .faceKey the face it wears (nil under Ignore fonts)
--   NS.Hud.surface { text, label, shadow, bar }, the v1.85.0 samples
--
-- Values read from the skins, not paint the library records: everything redraws on OnLooksChanged.

local R, L = NS.Showroom, NS.L

NS.Hud = { order = {}, lines = {} }
local H = NS.Hud

local BAR = NS.Constants.FALLBACK_BAR_TEXTURE
local LINE_W, LINE_H = 440, 18
local SAMPLE = "12,345  0:42  98%"

local function Skin() return LibStub and LibStub("LibKa0s-Skin-1.0", true) end

--- A face key's path through LibSharedMedia, or nil where it does not resolve.
local function fontPath(key)
    local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
    if not (LSM and type(LSM.Fetch) == "function" and type(key) == "string") then return nil end
    return LSM:Fetch("font", key, true)
end

--- Set `fs` in face `key` at `size` under `outline`; the template's own face where it does not resolve.
local function setFace(fs, key, size, outline)
    local path = fontPath(key)
    if path then fs:SetFont(path, tonumber(size) or 12, outline or "") end
end

local function newLine(g, caption)
    local fs = g:Add(LINE_W, LINE_H, caption):CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    fs:SetPoint("LEFT")
    return fs
end

local function drawSkin(key, label)
    local fs, t = H.lines[key], Skin():ResolveSkin(key)
    local face = t["hud.font"]
    fs.faceKey = face
    setFace(fs, face, t["hud.fontSize"], t["hud.outline"])
    fs:SetText(("%s  %s  (%s)"):format(label, SAMPLE, tostring(face)))
end

local function setColor(fs, r, g, b, a)
    if r then fs:SetTextColor(r, g, b, a) end
end

local function drawWorn()
    local fs, st = H.worn, R.Paint("BarStyle") or {}
    fs.faceKey = st.fontKey
    setColor(fs, NS.Skin.Color("text.body"))
    if st.fontKey then
        setFace(fs, st.fontKey, st.fontSize, st.outline)
        fs:SetText(("%s  (%s)"):format(SAMPLE, st.fontKey))
    else
        if _G.GameFontHighlight then fs:SetFontObject(_G.GameFontHighlight) end
        fs:SetText(("%s  (Ignore fonts: the host's own face)"):format(SAMPLE))
    end
end

-- S.HudShadow's three answers, in words: numbers, false for a skin that draws none, nil while the
-- owner ignores fonts.
local function shadowWords()
    local x, y = R.Paint("HudShadow")
    if x == false then return "HudShadow: none in this skin" end
    if x == nil then return "HudShadow: nil, the host's own stands" end
    return ("HudShadow: %s, %s"):format(tostring(x), tostring(y))
end

-- One table, refilled: S.HudFont keeps nothing of it, and this runs on every skin change.
local fontOpts = {}

local function drawSurface()
    local s, st = H.surface, R.Paint("BarStyle") or {}
    fontOpts.size, fontOpts.flags = st.fontSize, NS.Skin.FROM_SKIN
    R.Paint("HudFont", s.text, fontOpts)
    R.Paint("HudFont", s.label, fontOpts)
    R.Paint("HudFont", s.shadow, fontOpts)
    setColor(s.text, R.Paint("HudTextColor"))
    setColor(s.label, R.Paint("HudLabelColor"))
    setColor(s.shadow, R.Paint("HudTextColor"))
    s.shadow:SetText(shadowWords())
    s.bar:SetStatusBarTexture(st.texture or BAR)
    local r, g, b, a = R.Paint("BarFillColor")
    if r then s.bar:SetStatusBarColor(r, g, b, a) end
    R.Paint("BarGloss", s.bar)
end

local function surfaceSamples(g)
    local cell = g:Add(LINE_W, LINE_H * 3, "HudFont: HudTextColor, HudLabelColor, HudShadow")
    local s = { text = cell:CreateFontString(nil, "OVERLAY", "GameFontHighlight"),
                label = cell:CreateFontString(nil, "OVERLAY", "GameFontNormal"),
                shadow = cell:CreateFontString(nil, "OVERLAY", "GameFontHighlight") }
    s.text:SetPoint("TOPLEFT")
    s.text:SetText(SAMPLE)
    s.label:SetPoint("TOPLEFT", 0, -LINE_H)
    s.label:SetText("A HUD label")
    s.shadow:SetPoint("TOPLEFT", 0, -2 * LINE_H)
    s.bar = CreateFrame("StatusBar", nil, g:Add(LINE_W, 16, "BarFillColor, BarGloss"))
    s.bar:SetSize(LINE_W, 16)
    s.bar:SetPoint("TOPLEFT")
    s.bar:SetMinMaxValues(0, 1)
    s.bar:SetValue(0.6)
    H.surface = s
end

local labels = {}   -- [skin key] = its label

local function redraw()
    if not H.worn then return end
    for _, key in ipairs(H.order) do drawSkin(key, labels[key]) end
    drawWorn()
    drawSurface()
end

R.AddSection("hud", L["HUD faces"], function(body)
    local g = R.Grid(body)
    local lib = Skin()
    for _, def in ipairs(lib and lib:Skins() or {}) do
        H.order[#H.order + 1] = def.key
        labels[def.key] = def.label or def.key
        H.lines[def.key] = newLine(g, ("hud.font (%s)"):format(def.label or def.key))
    end
    g:Break()
    H.worn = newLine(g, "BarStyle (the skin worn; Ignore fonts gives the host's face back)")
    g:Break()
    surfaceSamples(g)
    redraw()
    return g:Height()
end)

if NS.Skin and NS.Skin.OnLooksChanged then NS.Skin.OnLooksChanged(redraw) end
