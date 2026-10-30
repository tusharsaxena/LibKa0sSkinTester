local addonName, NS = ...
-- modules/ShowroomFonts.lua — the Faces and widths section and the `/st widths` probe (LibKa0s
-- v1.82.0; ST-01 of Ka0sAddonsCommonTasks docs/2026-10-30-SKIN_FONTS_AND_FEEDBACK, rulings D-02,
-- D-06 and D-08). Three things the release changed, shown side by side:
--
--   the faces    one line per skin, its body sample in its own `font.body` at `font.bodySize` and
--                its title sample in `font.title` at `font.titleSize`, naming both: Prototype for
--                Ka0s Default, Expressway for Obsidian, Fira Sans Medium for WoW Forever's body.
--   the outline  this addon's Font outline (the Skin tab's, `skin.outline`) and what it gives window
--                and HUD text; every face line draws under it, so All text, HUD text only and Off
--                can be told apart here, live.
--   the widths   each skin's text is meant to be as wide as Ka0s Default's (D-08). Every face line
--                carries its measured width ratio against Ka0s Default for a fixed corpus, per role
--                (body, title, HUD); `/st widths` prints the same numbers to chat.
--
--   NS.Fonts.CORPUS    the fixed strings measured, summed
--   NS.Fonts.ROLES     the three roles: their face, size and outline tokens
--   NS.Fonts.Measure() rows in the library's skin order: { key, label, body, title, hud }, each role
--                      { face, size, width, ratio } (width nil where the face does not resolve,
--                      ratio nil where Ka0s Default's width is unknown or zero)
--   NS.Fonts.Probe()   the hidden FontString the widths are measured on
--   NS.Fonts.Lines()   the probe's printed lines; NS.Fonts.PrintWidths() prints them
--   NS.Fonts.order / .lines [skin key] = { body, title, ratio } FontStrings; .outline the mode line
--
-- Widths are measured with each skin's own stated outline (OUTLINE in every skin), as D-08 measured
-- them, whatever this addon's Font outline says: the probe compares skins, not settings.

local R, L = NS.Showroom, NS.L

NS.Fonts = { order = {}, lines = {} }
local F = NS.Fonts

F.BASELINE = "ka0s"
F.CORPUS = {
    "The quick brown fox jumps over the lazy dog.",
    "PACK MY BOX WITH FIVE DOZEN LIQUOR JUGS",
    "Ka0s Skin Tester  12,345  0:42  98%  +5.0%",
}
F.ROLES = {
    { key = "body",  face = "font.body",  size = "font.bodySize",  outline = "font.outline" },
    { key = "title", face = "font.title", size = "font.titleSize", outline = "font.outline" },
    { key = "hud",   face = "hud.font",   size = "hud.fontSize",   outline = "hud.outline" },
}

local OUTLINE_WORDS = { all = "All text", hud = "HUD text only", off = "Off" }
local LINE_W, LINE_H = 440, 16
local BODY_SAMPLE, TITLE_SAMPLE = "Body: the quick brown fox 0123456789", "Title: Choose a skin"

local function Skin() return LibStub and LibStub("LibKa0s-Skin-1.0", true) end

--- A face key's path through LibSharedMedia, or nil where it does not resolve.
local function fontPath(key)
    local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
    if not (LSM and type(LSM.Fetch) == "function" and type(key) == "string") then return nil end
    return LSM:Fetch("font", key, true)
end

local probe
function F.Probe()
    if not probe then
        local host = CreateFrame("Frame", nil, UIParent)
        host:Hide()
        probe = host:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    end
    return probe
end

local function stringWidth(fs)
    if fs.GetUnboundedStringWidth then return fs:GetUnboundedStringWidth() or 0 end
    return fs:GetStringWidth() or 0
end

--- The corpus's summed width in `face` at `size` under `outline`; nil where the face does not resolve
--- or the client refuses it. The probe is shared across every skin and role, so a refused SetFont
--- (false) would leave the previous face in place and its width read as this one's.
function F.Width(face, size, outline)
    local path = fontPath(face)
    if not path then return nil end
    local fs = F.Probe()
    if fs:SetFont(path, tonumber(size) or 12, outline or "") == false then return nil end
    local w = 0
    for _, line in ipairs(F.CORPUS) do
        fs:SetText(line)
        w = w + stringWidth(fs)
    end
    return w
end

local function measureRole(t, role)
    local face, size = t[role.face], tonumber(t[role.size]) or 12
    return { face = face, size = size, width = F.Width(face, size, t[role.outline]) }
end

local function addRatios(rows, base)
    for _, row in ipairs(rows) do
        for _, role in ipairs(F.ROLES) do
            local m, b = row[role.key], base and base[role.key]
            if m.width and b and b.width and b.width > 0 then m.ratio = m.width / b.width end
        end
    end
end

function F.Measure()
    local lib, rows, base = Skin(), {}, nil
    if not lib then return rows end
    for _, def in ipairs(lib:Skins()) do
        local t, row = lib:ResolveSkin(def.key), { key = def.key, label = def.label or def.key }
        for _, role in ipairs(F.ROLES) do row[role.key] = measureRole(t, role) end
        rows[#rows + 1] = row
        if def.key == F.BASELINE then base = row end
    end
    addRatios(rows, base)
    return rows
end

local function ratioText(m)
    if m.ratio then return ("%.3fx"):format(m.ratio) end
    return m.width and "n/a" or "unmeasured"
end

local function roleText(m)
    return ("%s %s %s"):format(tostring(m.face), tostring(m.size), ratioText(m))
end

function F.Lines()
    local rows = F.Measure()
    if #rows == 0 then return { L["Widths: the skin engine did not load."] } end
    local out = { L["Widths of a fixed corpus against Ka0s Default (1.000x is parity):"] }
    for _, row in ipairs(rows) do
        out[#out + 1] = ("%s: body %s, title %s, hud %s"):format(row.label, roleText(row.body),
            roleText(row.title), roleText(row.hud))
    end
    return out
end

function F.PrintWidths()
    local out = F.Lines()
    for _, line in ipairs(out) do NS.Print(line) end
    return out
end

-- ── the section ─────────────────────────────────────────────────────────────────────────────────

local function outlineMode()
    local lib = Skin()
    return lib and type(lib.GetOutline) == "function" and lib:GetOutline(addonName) or "all"
end

--- Window text's flags under this addon's Font outline, for the skin's stated `font.outline`: ""
--- (window text's stock flags) while this addon ignores fonts, as the library's FontFlags answers.
local function windowFlags(t)
    local lib = Skin()
    if lib and type(lib.GetIgnore) == "function" and select(2, lib:GetIgnore(addonName)) then return "" end
    if outlineMode() ~= "all" then return "" end
    return t["font.outline"] or ""
end

local function setFace(fs, key, size, flags)
    local path = fontPath(key)
    if path then fs:SetFont(path, tonumber(size) or 12, flags or "") end
end

local function newString(cell, template)
    local fs = cell:CreateFontString(nil, "OVERLAY", template or "GameFontHighlight")
    fs:SetJustifyH("LEFT")
    return fs
end

local function faceLine(g, def)
    local cell = g:Add(LINE_W, LINE_H * 3, ("%s: %s"):format(def.label or def.key, L["faces and width ratios"]))
    local line = { body = newString(cell), title = newString(cell), ratio = newString(cell, "GameFontHighlightSmall") }
    line.body:SetPoint("TOPLEFT")
    line.title:SetPoint("TOPLEFT", 0, -LINE_H)
    line.ratio:SetPoint("TOPLEFT", 0, -2 * LINE_H)
    R.Paint("Text", line.ratio, "muted")
    F.lines[def.key] = line
end

local function drawLine(key, t, row)
    local line, flags = F.lines[key], windowFlags(t)
    line.body.faceKey, line.title.faceKey = t["font.body"], t["font.title"]
    setFace(line.body, t["font.body"], t["font.bodySize"], flags)
    setFace(line.title, t["font.title"], t["font.titleSize"], flags)
    line.body:SetText(("%s  (%s %s)"):format(BODY_SAMPLE, tostring(t["font.body"]), tostring(t["font.bodySize"])))
    line.title:SetText(("%s  (%s %s)"):format(TITLE_SAMPLE, tostring(t["font.title"]), tostring(t["font.titleSize"])))
    line.ratio:SetText(row and ("body %s  title %s  hud %s"):format(ratioText(row.body), ratioText(row.title),
        ratioText(row.hud)) or "")
end

local function drawOutline()
    local lib, mode = Skin(), outlineMode()
    local S = NS.Skin
    local from = S and S.FROM_SKIN or "@skin"
    local fonts = lib and type(lib.GetIgnore) == "function" and select(2, lib:GetIgnore(addonName))
    F.outline:SetText(("Font outline: %s. Window text draws \"%s\", HUD text \"%s\"%s"):format(
        OUTLINE_WORDS[mode] or mode, tostring(R.Paint("FontFlags", from, "window")),
        tostring(R.Paint("FontFlags", from)), fonts and " (Ignore fonts wins)" or ""))
end

local function redraw()
    if not F.outline then return end
    drawOutline()
    local lib = Skin()
    if not lib then return end
    local byKey = {}
    for _, row in ipairs(F.Measure()) do byKey[row.key] = row end
    for _, key in ipairs(F.order) do drawLine(key, lib:ResolveSkin(key), byKey[key]) end
end

R.AddSection("fonts", L["Faces and widths"], function(body)
    local g = R.Grid(body)
    local cell = g:Add(LINE_W, LINE_H, L["The Skin tab's Font outline, this addon's"])
    F.outline = newString(cell)
    F.outline:SetPoint("LEFT")
    g:Break()
    local lib = Skin()
    for _, def in ipairs(lib and lib:Skins() or {}) do
        F.order[#F.order + 1] = def.key
        faceLine(g, def)
    end
    redraw()
    return g:Height()
end)

if NS.Skin and NS.Skin.OnLooksChanged then NS.Skin.OnLooksChanged(redraw) end
