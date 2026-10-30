local _, NS = ...
-- modules/ShowroomHud.lua — the HUD faces section (LibKa0s v1.81.0: LK-04, ruling R-4, and LK-01,
-- ruling R-1). Every skin names a HUD face of its own, its text's family at the heavier weight, drawn
-- 12px under an OUTLINE: one line per skin, each set in that skin's own `hud.font`, `hud.fontSize` and
-- `hud.outline` and naming the face, so the nine can be judged side by side whatever skin is worn.
-- Like the picker's rows, these show the skins, so Ignore fonts leaves them alone. Under them, one
-- line in the face the worn skin hands a HUD element (S.BarStyle), which Ignore fonts gives back to
-- the host's own face, live.
--
--   NS.Hud.order   the skin keys, in the library's order
--   NS.Hud.lines   [skin key] = its FontString, .faceKey the face it names
--   NS.Hud.worn    the BarStyle line, .faceKey the face it wears (nil under Ignore fonts)
--
-- Values read from the skins, not paint the library records: everything redraws on OnLooksChanged.

local R, L = NS.Showroom, NS.L

NS.Hud = { order = {}, lines = {} }
local H = NS.Hud

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

local function drawWorn()
    local fs, st = H.worn, R.Paint("BarStyle") or {}
    fs.faceKey = st.fontKey
    if st.fontKey then
        setFace(fs, st.fontKey, st.fontSize, st.outline)
        fs:SetText(("%s  (%s)"):format(SAMPLE, st.fontKey))
    else
        if _G.GameFontHighlight then fs:SetFontObject(_G.GameFontHighlight) end
        fs:SetText(("%s  (Ignore fonts: the host's own face)"):format(SAMPLE))
    end
end

local labels = {}   -- [skin key] = its label

local function redraw()
    if not H.worn then return end
    for _, key in ipairs(H.order) do drawSkin(key, labels[key]) end
    drawWorn()
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
    redraw()
    return g:Height()
end)

if NS.Skin and NS.Skin.OnLooksChanged then NS.Skin.OnLooksChanged(redraw) end
