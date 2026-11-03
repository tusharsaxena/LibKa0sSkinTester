-- tests/test_showroom_owner.lua — the Addon surfaces section (ST-01 of Ka0sAddonsCommonTasks
-- docs/2026-10-29-SKINNING_ROLLOUT): LibKa0s v1.80.0's rollout surfaces, each on show and painted
-- through NS.Showroom.Paint. An owner token this addon registers, a danger button and a caution callout
-- through opts.tokens, an AceGUI TreeGroup through PaintAce, and a settings-style window skinned in
-- every skin (LibKa0s v1.81.0 retired opts.stockDefault, ruling R-2). Its icon border went in R4-ST3
-- (a duplicate of Overlays'); the 1 px edge case below runs on Overlays' sample instead.
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
    for _, key in ipairs({ "note", "danger", "callout", "tree", "stockWindow" }) do
        assertTrue(sec[key] ~= nil, key .. " is on show")
    end
    -- R4-ST3: no icon border here; Overlays' and Controls' samples show it (round 4, image 22).
    assertTrue(sec.iconFrame == nil, "no duplicate IconBorder beside the caution callout")
    for _, name in ipairs({ "Text", "Button", "Card", "PaintAce", "Shell" }) do
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
    -- R4-ST1: this addon's Scope leaves the panel skinned by default (a documented deviation).
    local st = Skin.__ace[sec.tree]
    assertTrue(st ~= nil and st.owner == OWNER, "painted for this owner by default")
    NS.ApplySkinIgnore(true, nil)
    st = Skin.__ace[sec.tree]
    assertTrue(st == nil or st.owner ~= OWNER, "handed back while the panel is ignored")
    NS.ApplySkinIgnore(false, nil)
    st = Skin.__ace[sec.tree]
    assertTrue(st ~= nil and st.owner == OWNER, "painted again once the Scope is cleared")
end)

test("addon surfaces: the TreeGroup keeps its 120 height and shows a page (R4-ST2)", function()
    -- red under: AceGUI's auto-height left on, which an empty List layout collapses to 20 px with
    -- the tree's rows hanging below both panes (round 4, images 4-7). The headless AceGUI is a stub
    -- with no LayoutFinished, so the call is pinned here and the geometry is the owner's smoke check.
    local _, _, sec = opened()
    local t = sec.tree
    assertEqual(t.autoAdjustHeight, false, "SetAutoAdjustHeight(false): the host owns the height")
    assertEqual(t.height, 120, "and the height it asked for")
    assertEqual(t.layout, "Fill", "the content pane fills with its page")
    assertEqual(#t.children, 1, "one placeholder page")
    assertEqual(t.children[1].type, "Label")
    assertEqual(t.children[1].text, "The General page", "reads as the selected row's page")
end)

-- ── the icon border ──────────────────────────────────────────────────────────────────────────
-- R4-ST3 removed Addon surfaces' own sample (a duplicate); the edge is pinned on Overlays' one.

test("overlays: the IconBorder sample draws a 1 px edge in icon.outline, in every skin", function()
    local NS, mock = opened()
    local Skin = lib(mock)
    local framed = NS.Showroom.Section("overlays").framed
    local function edges()
        local rec = Skin.painted[framed]
        return rec and rec.regions or {}
    end
    local top = edges().edgeTop
    assertTrue(top ~= nil and mock.__paint(top).shown, "a top edge is drawn under Ka0s Default")
    -- LibKa0s R4-L3: the frame edge reads icon.outline (#4D4D57 under Ka0s Default); icon.border stays the HUD's.
    assertToken(mock, mock.__paint(top).color, "icon.outline", "the edge color")
    -- LibKa0s R3-L3: 1 px in every skin; since R3-FIX every skin's icon.borderSize says 1 too.
    assertEqual(Skin:Token(OWNER, "icon.borderSize"), 1, "Ka0s Default's token says 1")
    assertEqual(top:GetHeight(), 1, "the edge is 1 px all the same")
    NS.Selector.Pick("obsidian")
    assertEqual(edges().edgeTop:GetHeight(), 1, "and 1 px after the switch")
end)

-- ── a template window, skinned in every skin (R-2) ──────────────────────────────────────────

test("addon surfaces: the settings-style window wears Ka0s Default under Ka0s Default", function()
    -- red under: LibKa0s v1.80.0 with opts.stockDefault, which kept it the client's under Ka0s Default.
    local _, mock, sec = opened{ template = true }
    local win = sec.stockWindow
    assertTrue(not isStock(mock, win), "the template's art is faded and the window painted")
    assertToken(mock, mock.__paint(win.NineSlice.Text).textColor, "title.text", "the title under Ka0s Default")
end)

test("addon surfaces: the settings-style window follows a skin switch and stays skinned back on Ka0s Default", function()
    local NS, mock, sec = opened{ template = true }
    local win = sec.stockWindow
    NS.Selector.Pick("obsidian")
    assertTrue(not isStock(mock, win), "Obsidian fades the template's art and paints the window")
    assertToken(mock, mock.__paint(win.NineSlice.Text).textColor, "title.text", "the title under Obsidian")
    NS.Selector.Pick("ka0s")
    assertTrue(not isStock(mock, win), "back on Ka0s Default it is still skinned")
    assertToken(mock, mock.__paint(win.NineSlice.Text).textColor, "title.text", "the title back on Ka0s Default")
end)
