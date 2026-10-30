-- tests/test_showroom_widgets.lua — the Library widgets section (ST-01 of Ka0sAddonsCommonTasks
-- docs/2026-10-30-SKIN_LIBRARY_FOLLOWUPS): the custom LibKa0s widgets v1.81.0 newly skins (LK-06a..d,
-- LK-08), each owned by this addon and on a window, so neither Scope switch's panel half reaches it:
-- a drag handle whose tooltip takes gtip.title / gtip.value / gtip.footer, an autocomplete, a line
-- chart, a resize grip in icon.grip, a drawer head and a nav entry whose hover art takes
-- list.hoverArt, and three launchers: a copy window, the debug console and the skin picker.

local T = _G.SKINTESTER_TEST
local test, assertEqual, assertTrue, assertFalse = T.test, T.assertEqual, T.assertTrue, T.assertFalse

local OWNER = "LibKa0sSkinTester"
local PICKER = "LibKa0sSkinPickerLibKa0sSkinTester"
local installPaint = dofile("tests/_kit/mock_paint.lua")

--- A Button's three art slots as the client keeps them: Set<Slot>Texture(path) lays the path on a
--- texture the button owns and Get<Slot>Texture answers it. The base mock answers its catch-all
--- there, which is no Texture, so the resize grip's art could not be read without this.
local SLOTS = { "Normal", "Highlight", "Pushed" }
local function modelButtonArt(m)
    local create = m.CreateFrame
    m.CreateFrame = function(kind, ...)
        local f = create(kind, ...)
        if kind == "Button" then
            for _, slot in ipairs(SLOTS) do
                local tex
                rawset(f, "Set" .. slot .. "Texture", function(self, path)
                    tex = tex or self:CreateTexture()
                    tex:SetTexture(path)
                end)
                rawset(f, "Get" .. slot .. "Texture", function() return tex end)
            end
        end
        return f
    end
end

--- A FontString made from a template answers that template as its font object until something
--- sets a face, as the client's does. The base mock answers nil, so a face the skin put on could not
--- be handed back, and Ignore fonts would look like it did nothing.
local function modelTemplateFonts(m)
    local create = m.CreateFrame
    m.CreateFrame = function(...)
        local f = create(...)
        local make = rawget(f, "CreateFontString")
        if make then
            rawset(f, "CreateFontString", function(self, name, layer, template)
                local fs = make(self, name, layer, template)
                local get = fs.GetFontObject
                rawset(fs, "GetFontObject", function(s)
                    local obj = get(s)
                    if obj == nil and rawget(s, "__font") == nil then return template end
                    return obj
                end)
                return fs
            end)
        end
        return f
    end
end

local function opened()
    local NS, _, mock = T.enableAddon{ mock = function(m) installPaint(m); modelButtonArt(m); modelTemplateFonts(m) end }
    NS.Showroom.Show()
    return NS, mock, NS.Showroom.Section("widgets")
end

local function lib(mock) return mock.LibStub("LibKa0s-Skin-1.0") end

local function near(a, b) return type(a) == "number" and type(b) == "number" and math.abs(a - b) < 1e-3 end

local function sameColor(got, want)
    return type(got) == "table" and type(want) == "table"
        and near(got[1], want[1]) and near(got[2], want[2]) and near(got[3], want[3])
end

--- The lines the tooltip drew on a hover of `frame`, each { text, color = { r, g, b } }.
local function hoverLines(mock, frame)
    local tip, seen = mock.GameTooltip, {}
    local saved = { rawget(tip, "SetOwner"), rawget(tip, "SetText"), rawget(tip, "AddLine") }
    local function rec(_, text, r, g, b) seen[#seen + 1] = { text = text, color = { r, g, b } } end
    rawset(tip, "SetOwner", function() end)
    rawset(tip, "SetText", rec)
    rawset(tip, "AddLine", rec)
    local ok, err = pcall(function() frame.__fire("OnEnter") end)
    rawset(tip, "SetOwner", saved[1]); rawset(tip, "SetText", saved[2]); rawset(tip, "AddLine", saved[3])
    assertTrue(ok, tostring(err))
    return seen
end

local function pickerFrame(mock)
    for name, f in pairs(mock.frames) do
        if type(name) == "string" and name:sub(1, #PICKER) == PICKER then return f end
    end
end

test("widgets: the section is built with every sample", function()
    local _, _, sec = opened()
    assertTrue(sec ~= nil and (sec:GetHeight() or 0) > 0, "built, with a height")
    for _, key in ipairs({ "handle", "complete", "chart", "gripBox", "drawer", "nav",
                           "copyButton", "consoleButton", "pickerButton" }) do
        assertTrue(sec[key] ~= nil, key .. " is on show")
    end
end)

test("widgets: the drag handle's tooltip draws gtip.title, gtip.value and gtip.footer, per skin", function()
    -- red under: LibKa0s before LK-08 (v1.81.0): fixed gold, white and 0.6 gray in every skin.
    local NS, mock, sec = opened()
    local Skin = lib(mock)
    local function check(skin)
        local seen = hoverLines(mock, sec.handle)
        local t = Skin:ResolveSkin(skin)
        assertTrue(#seen >= 4, skin .. ": a title, a body line, a spacer and a footer")
        assertTrue(sameColor(seen[1].color, t["gtip.title"]), skin .. ": the title is gtip.title")
        assertTrue(sameColor(seen[2].color, t["gtip.value"]), skin .. ": the body is gtip.value")
        assertTrue(sameColor(seen[#seen].color, t["gtip.footer"]), skin .. ": the footer is gtip.footer")
    end
    check("ka0s")
    NS.Selector.Pick("azeroth")
    check("azeroth")
end)

test("widgets: the drag handle, chart and autocomplete are owned by this addon, off the panel", function()
    local _, _, sec = opened()
    assertEqual(sec.handleSpec.owner, OWNER)
    assertTrue(sec.handleSpec.panel ~= true, "a window's strip, not the settings panel's")
    assertTrue(sec.complete ~= nil, "the autocomplete hooked its box")
    local items = sec.completeProvider("gl")
    assertTrue(#items >= 1 and items[1].text == "Glass", "the provider answers the skins by name")
    assertTrue(sec.chart:GetPlotRect() ~= nil, "the chart drew")
end)

test("widgets: the resize grip is the client's art under Ka0s Default and icon.grip under Obsidian", function()
    -- red under: MakeResizable without opts.owner, or LibKa0s before LK-06b (no icon.grip).
    local NS, mock, sec = opened()
    local grip = sec.gripBox.resizeGrip
    assertTrue(grip ~= nil, "the box has a grip")
    local art = grip:GetNormalTexture()
    assertTrue(mock.__paint(art).desaturated ~= true, "Ka0s Default draws the client's art")
    NS.Selector.Pick("obsidian")
    local want = lib(mock):ResolveSkin("obsidian")["icon.grip"] or lib(mock):Token(OWNER, "icon.grip")
    assertTrue(type(want) == "table", "Obsidian resolves a grip color")
    assertTrue(mock.__paint(art).desaturated == true, "desaturated under Obsidian")
    assertTrue(sameColor(mock.__paint(art).vertex, want), "tinted icon.grip")
end)

test("widgets: the drawer and nav hover art is the client's under Ka0s Default and list.hoverArt under Glass", function()
    -- red under: S.Drawer / S.NavItem without opts.hover (LK-06c).
    local NS, mock, sec = opened()
    for _, key in ipairs({ "drawerHover", "navHover" }) do
        assertTrue(mock.__paint(sec[key]).desaturated ~= true, key .. ": the client's art under Ka0s Default")
    end
    assertTrue(NS.Showroom.used.Drawer and NS.Showroom.used.NavItem, "both through the wrapper")
    NS.Selector.Pick("glass")
    local want = lib(mock):Token(OWNER, "list.hoverArt")
    assertTrue(type(want) == "table", "Glass resolves a hover color")
    for _, key in ipairs({ "drawerHover", "navHover" }) do
        assertTrue(mock.__paint(sec[key]).desaturated == true, key .. ": desaturated under Glass")
        assertTrue(sameColor(mock.__paint(sec[key]).vertex, want), key .. ": tinted list.hoverArt")
    end
    local arrow = lib(mock):Token(OWNER, "icon.arrow")
    assertTrue(sameColor(mock.__paint(sec.drawerChevron).vertex, arrow), "the chevron is icon.arrow")
end)

--- A LibSharedMedia stand-in: every font key fetches as a path named after it, so a skin's face
--- resolves in the harness (P.font gives the template back when no path resolves).
local function fakeLSM(mock)
    local LSM = mock.LibStub:NewLibrary("LibSharedMedia-3.0", 1) or mock.LibStub("LibSharedMedia-3.0")
    LSM.Fetch = function(_, kind, key) return ("Fonts\\%s\\%s.ttf"):format(kind, tostring(key)) end
end

--- The tick labels the chart drew and the rows the autocomplete shows for "o".
local function fontedStrings(sec)
    local out = {}
    for i, fs in ipairs(sec.chart.__labelPool) do
        if fs:IsShown() then out[#out + 1] = { "chart label " .. i, fs, "GameFontDisableSmall" } end
    end
    sec.complete.__box:SetText("o")
    sec.complete:Refresh()
    for i, row in ipairs(sec.complete.__rows) do
        if row:IsShown() then out[#out + 1] = { "autocomplete row " .. i, row.label, "GameFontHighlightSmall" } end
    end
    return out
end

local function bodyFace(mock, fs)
    local obj = mock.__paint(fs).fontObject
    local name = type(obj) == "table" and obj.GetName and obj:GetName()
    return type(name) == "string" and name:find("^LibKa0sSkin_LibKa0sSkinTester_body") ~= nil
end

test("widgets: the chart's tick labels and the autocomplete rows are in this addon's body face", function()
    -- red under: LibKa0s before LK-06a (v1.81.0), or W.LineChart / W.Autocomplete without opts.owner.
    local NS, mock, sec = opened()
    fakeLSM(mock)
    NS.Selector.Pick("glass")
    local Skin = lib(mock)
    local seen = fontedStrings(sec)
    local chart, rows = 0, 0
    for _, e in ipairs(seen) do
        if e[1]:find("^chart") then chart = chart + 1 else rows = rows + 1 end
        local rec = Skin.painted[e[2]]
        assertTrue(rec ~= nil and rec.owner == OWNER, e[1] .. ": a font paint owned by this addon")
        assertTrue(rec.calls.Font ~= nil, e[1] .. ": through S.Font")
        assertTrue(bodyFace(mock, e[2]), e[1] .. ": in the skin's body face")
    end
    assertTrue(chart >= 2 and rows >= 1, "tick labels and suggestion rows were drawn")
end)

test("widgets: Ignore fonts gives the chart's tick labels and the autocomplete rows their template face", function()
    -- red under: a face the library cannot hand back (LK-06a's __skinFont give-back).
    local NS, mock, sec = opened()
    fakeLSM(mock)
    NS.Selector.Pick("glass")
    local seen = fontedStrings(sec)
    NS.ApplySkinIgnore(nil, true)
    sec.complete:Refresh()
    for _, e in ipairs(seen) do
        assertEqual(mock.__paint(e[2]).fontObject, e[3], e[1] .. ": its template under Ignore fonts")
    end
    NS.ApplySkinIgnore(nil, false)
    sec.complete:Refresh()
    for _, e in ipairs(seen) do
        assertTrue(bodyFace(mock, e[2]), e[1] .. ": the body face again")
    end
end)

test("widgets: Ignore settings panel leaves the section skinned (a window, decision D-01)", function()
    -- red under: a sample that passes `panel`, or a wrapper that reads the panel half of the Scope.
    local NS, mock, sec = opened()
    fakeLSM(mock)
    NS.ApplySkinIgnore(true, nil)
    NS.Selector.Pick("glass")
    local Skin = lib(mock)
    local hover = Skin:Token(OWNER, "list.hoverArt")
    for _, key in ipairs({ "drawerHover", "navHover" }) do
        assertTrue(mock.__paint(sec[key]).desaturated == true, key .. ": desaturated")
        assertTrue(sameColor(mock.__paint(sec[key]).vertex, hover), key .. ": tinted list.hoverArt")
    end
    local grip = mock.__paint(sec.gripBox.resizeGrip:GetNormalTexture())
    assertTrue(grip.desaturated == true, "the grip is desaturated")
    assertTrue(sameColor(grip.vertex, Skin:Token(OWNER, "icon.grip")), "the grip is tinted icon.grip")
    for _, e in ipairs(fontedStrings(sec)) do
        assertTrue(bodyFace(mock, e[2]), e[1] .. ": still in the body face")
    end
end)

test("widgets: the copy window opens owned by this addon", function()
    local _, _, sec = opened()
    sec.copyButton.__fire("OnClick", "LeftButton")
    local f = sec.copyWindow:GetFrame()
    assertTrue(f ~= nil and f:IsShown(), "the copy window is up")
    assertTrue(f.resizeGrip ~= nil, "with its grip")
end)

test("widgets: the console button opens the debug console", function()
    local NS, _, sec = opened()
    assertFalse(NS.DebugLog:IsShown())
    sec.consoleButton.__fire("OnClick", "LeftButton")
    assertTrue(NS.DebugLog:IsShown(), "the console is up")
end)

test("widgets: the picker button shows the skin picker on a profile that has closed it", function()
    -- The picker's v1.81.0 layout (LK-11): "Choose a skin" over the addon's name on its own line.
    local NS, mock, sec = opened()
    NS.StandDownSkinPicker()
    NS.addon.db.profile.skin.pickerSeen = true
    sec.pickerButton.__fire("OnClick", "LeftButton")
    local f = pickerFrame(mock)
    assertTrue(f ~= nil and f:IsShown(), "the picker is up")
    assertEqual(f.title:GetText(), "Choose a skin")
    assertEqual(f.ownerLabel:GetText(), "Ka0s Skin Tester")
end)

test("widgets: the picker button does nothing in combat", function()
    local NS, mock, sec = opened()
    NS.StandDownSkinPicker()
    NS.addon.db.profile.skin.pickerSeen = true
    mock.combat = true
    sec.pickerButton.__fire("OnClick", "LeftButton")
    local f = pickerFrame(mock)
    assertTrue(f == nil or not f:IsShown(), "no picker mid-combat")
end)
