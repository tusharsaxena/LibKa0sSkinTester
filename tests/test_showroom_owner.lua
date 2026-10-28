-- tests/test_showroom_owner.lua — the Addon surfaces section (ST-01 of Ka0sAddonsCommonTasks
-- docs/2026-10-29-SKINNING_ROLLOUT): LibKa0s v1.80.0's rollout surfaces, each on show and painted
-- through NS.Showroom.Paint. An owner token this addon registers, a danger button and a caution callout
-- through opts.tokens, an AceGUI TreeGroup through PaintAce, an icon border that follows
-- icon.borderStyle / icon.borderSize, and a settings-style window kept stock under Ka0s Default.
--
-- The skin assertions run under the kit's paint recorder (tests/_kit/mock_paint.lua). The
-- stock-window cases also model SettingsFrameTemplate's anatomy (a NineSlice with the title on it, a
-- Bg texture, a ClosePanelButton), which the base mock does not build.

local T = _G.SKINTESTER_TEST
local test, assertEqual, assertTrue = T.test, T.assertEqual, T.assertTrue

local OWNER = "LibKa0sSkinTester"
local installPaint = dofile("tests/_kit/mock_paint.lua")

--- SettingsFrameTemplate as the client builds it, on the recorder's frames.
local function modelSettingsTemplate(m)
    local create = m.CreateFrame
    m.CreateFrame = function(kind, name, parent, template, ...)
        local f = create(kind, name, parent, template, ...)
        if template == "SettingsFrameTemplate" then
            m.__paintNineSlice(f)
            f.Bg = f:CreateTexture(nil, "BACKGROUND")
            f.NineSlice.Text = f.NineSlice:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            -- Not Ka0s Default's title.text (gold), so a title the library recolored shows.
            f.NineSlice.Text:SetTextColor(0.9, 0.9, 0.9, 1)
            local close = create("Button", nil, f)
            local art = close:CreateTexture()
            rawset(close, "GetNormalTexture", function() return art end)
            f.ClosePanelButton, f.closeArt = close, art
        end
        return f
    end
end

local function opened(opts)
    opts = opts or {}
    local NS, _, mock = T.enableAddon{ mock = function(m)
        installPaint(m)
        if opts.template then modelSettingsTemplate(m) end
    end }
    NS.Showroom.Show()
    return NS, mock, NS.Showroom.Section("addon")
end

local function lib(mock) return mock.LibStub("LibKa0s-Skin-1.0") end

local function near(a, b) return type(a) == "number" and type(b) == "number" and math.abs(a - b) < 1e-6 end

--- The recorded color `got` against the owner's token `name` (rgb, and alpha when `withAlpha`).
local function assertToken(mock, got, name, what, withAlpha)
    assertTrue(type(got) == "table", what .. ": nothing was painted")
    local r, g, b, a = lib(mock):Color(OWNER, name)
    assertTrue(r ~= nil, what .. ": the owner reads no " .. name)
    local same = near(got[1], r) and near(got[2], g) and near(got[3], b)
    if withAlpha then same = same and near(got[4], a or 1) end
    assertTrue(same, ("%s: %s,%s,%s,%s is not %s (%s,%s,%s,%s)"):format(what, tostring(got[1]),
        tostring(got[2]), tostring(got[3]), tostring(got[4]), name, r, g, b, tostring(a)))
end

local function isStock(mock, win)
    for _, k in ipairs(mock.__nineSliceKeys) do
        if mock.__paint(win.NineSlice[k]).alpha ~= 1 then return false, "NineSlice." .. k .. " faded" end
    end
    if mock.__paint(win.Bg).alpha ~= 1 then return false, "Bg faded" end
    if mock.__paint(win.closeArt).alpha ~= 1 then return false, "the close art faded" end
    local c = mock.__paint(win.NineSlice.Text).textColor
    if not (near(c[1], 0.9) and near(c[2], 0.9) and near(c[3], 0.9)) then return false, "the title recolored" end
    return true
end

-- ── the section ──────────────────────────────────────────────────────────────────────────────

test("addon surfaces: the section is built, and every sample went through the wrapper", function()
    local NS, _, sec = opened()
    assertTrue(sec ~= nil and (sec:GetHeight() or 0) > 0, "built, with a height")
    for _, key in ipairs({ "note", "danger", "callout", "iconFrame", "tree", "stockWindow" }) do
        assertTrue(sec[key] ~= nil, key .. " is on show")
    end
    for _, name in ipairs({ "Text", "Button", "Card", "IconBorder", "PaintAce", "Shell" }) do
        assertTrue(NS.Showroom.used[name] == true, name .. " went through NS.Showroom.Paint")
    end
end)

-- ── owner tokens ─────────────────────────────────────────────────────────────────────────────

test("addon surfaces: the owner tokens resolve: default, a skin's own entry, else the follow", function()
    local NS, mock = opened()
    local Skin = lib(mock)
    local r, g, b = Skin:Color(OWNER, "st.note")
    assertTrue(near(r, 0.533) and near(g, 0.533) and near(b, 0.533), "Ka0s Default answers default")
    NS.Selector.Pick("contrast")
    r = Skin:Color(OWNER, "st.note")
    assertTrue(near(r, 0.85), "High Contrast answers its own entry")
    NS.Selector.Pick("obsidian")
    local fr, fg, fb = Skin:Color(OWNER, "text.muted")
    r, g, b = Skin:Color(OWNER, "st.note")
    assertTrue(near(r, fr) and near(g, fg) and near(b, fb), "Obsidian answers text.muted's value")
end)

test("addon surfaces: the owner token line wears st.note, and follows a skin switch", function()
    -- red under: a line painted in a library role, or a typed color the switch never reaches.
    local NS, mock, sec = opened()
    assertToken(mock, mock.__paint(sec.note).textColor, "st.note", "under Ka0s Default")
    NS.Selector.Pick("contrast")
    assertToken(mock, mock.__paint(sec.note).textColor, "st.note", "under High Contrast")
    assertTrue(near(mock.__paint(sec.note).textColor[1], 0.85), "High Contrast's own entry")
end)

-- ── the slot remap ───────────────────────────────────────────────────────────────────────────

test("addon surfaces: the danger button paints its fill, edge and label from the named tokens", function()
    -- red under: a Button with no opts.tokens (the stock btn.bg fill and btn.text label).
    local NS, mock, sec = opened()
    local p = mock.__paint(sec.danger)
    assertToken(mock, p.backdropColor, "st.dangerFill", "the fill", true)
    assertToken(mock, p.backdropBorderColor, "sem.danger", "the edge")
    NS.Selector.Pick("obsidian")
    assertToken(mock, mock.__paint(sec.danger.text).textColor, "sem.danger", "the label follows sem.danger")
    assertToken(mock, mock.__paint(sec.danger).backdropColor, "btn.bg", "the fill follows btn.bg", true)
end)

test("addon surfaces: the caution callout paints its fill, edge and title from the named tokens", function()
    local NS, mock, sec = opened()
    local p = mock.__paint(sec.callout)
    assertToken(mock, p.backdropColor, "st.cautionFill", "the fill", true)
    assertToken(mock, p.backdropBorderColor, "sem.warn", "the edge")
    NS.Selector.Pick("azeroth")
    assertToken(mock, mock.__paint(sec.callout).backdropColor, "card.bg", "the fill follows card.bg", true)
    assertToken(mock, mock.__paint(sec.callout).backdropBorderColor, "sem.warn", "the edge under azeroth")
end)

-- ── the TreeGroup ────────────────────────────────────────────────────────────────────────────

test("addon surfaces: the TreeGroup follows the Scope's settings-panel half, live", function()
    -- red under: a PaintAce asked once at build, which would stay stock after the Scope is cleared.
    local NS, mock, sec = opened()
    local Skin = lib(mock)
    assertEqual(sec.tree.type, "TreeGroup")
    assertTrue(sec.treePainted ~= true, "stock while the Scope leaves the panel the client's (the default)")
    NS.ApplySkinIgnore(false, nil)
    local st = Skin.__ace[sec.tree]
    assertTrue(st ~= nil and st.owner == OWNER, "painted for this owner once the Scope is cleared")
    NS.ApplySkinIgnore(true, nil)
    st = Skin.__ace[sec.tree]
    assertTrue(st == nil or st.owner ~= OWNER, "handed back when the Scope leaves the panel again")
end)

-- ── the icon border ──────────────────────────────────────────────────────────────────────────

test("addon surfaces: the icon border draws icon.borderSize edges in icon.border, per skin", function()
    local NS, mock, sec = opened()
    local Skin = lib(mock)
    local function edges()
        local rec = Skin.painted[sec.iconFrame]
        return rec and rec.regions or {}
    end
    local top = edges().edgeTop
    assertTrue(top ~= nil and mock.__paint(top).shown, "a top edge is drawn under Ka0s Default")
    assertToken(mock, mock.__paint(top).color, "icon.border", "the edge color")
    assertEqual(Skin:Token(OWNER, "icon.borderSize"), 2, "Ka0s Default's icon border is 2px")
    assertEqual(top:GetHeight(), 2, "the edge is icon.borderSize thick")
    NS.Selector.Pick("obsidian")
    assertEqual(Skin:Token(OWNER, "icon.borderSize"), 1, "Obsidian's is 1px")
    assertEqual(edges().edgeTop:GetHeight(), 1, "and the edge follows the switch")
end)

-- ── stock under Ka0s Default ─────────────────────────────────────────────────────────────────

test("addon surfaces: the settings-style window is the client's under Ka0s Default", function()
    local _, mock, sec = opened{ template = true }
    local ok, why = isStock(mock, sec.stockWindow)
    assertTrue(ok, why)
end)

test("addon surfaces: the settings-style window is skinned under another skin, and stock again after", function()
    -- red under: a sample painted without opts.stockDefault (faded under Ka0s Default too).
    local NS, mock, sec = opened{ template = true }
    local win = sec.stockWindow
    NS.Selector.Pick("obsidian")
    assertTrue(not isStock(mock, win), "Obsidian fades the template's art and paints the window")
    assertToken(mock, mock.__paint(win.NineSlice.Text).textColor, "title.text", "the title under Obsidian")
    NS.Selector.Pick("ka0s")
    local ok, why = isStock(mock, win)
    assertTrue(ok, "back to Ka0s Default: " .. tostring(why))
end)
