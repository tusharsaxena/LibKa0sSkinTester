-- tests/test_showroom_textures.lua — the Textures section (ST-01): three status bars, a bar chart
-- and a stacked bar, every fill painted with the skin's bar texture through S.BarTexture, each
-- labeled with the texture key in effect, and all of it following a skin switch and the Skin tab's
-- texture override live.

local T = _G.SKINTESTER_TEST
local test, assertEqual, assertTrue = T.test, T.assertEqual, T.assertTrue

local OWNER = "LibKa0sSkinTester"
local installPaint = dofile("tests/_kit/mock_paint.lua")

local function opened()
    local NS, _, mock = T.enableAddon{ mock = function(m) installPaint(m) end }
    NS.Showroom.Show()
    return NS, mock
end

local function lib(mock) return mock.LibStub("LibKa0s-Skin-1.0") end

local function near(a, b) return type(a) == "number" and type(b) == "number" and math.abs(a - b) < 1e-6 end

local function assertColor(got, r, g, b, what)
    assertTrue(type(got) == "table", what .. ": nothing was painted")
    assertTrue(near(got[1], r) and near(got[2], g) and near(got[3], b),
        ("%s: %s,%s,%s is not %s,%s,%s"):format(what, tostring(got[1]), tostring(got[2]),
            tostring(got[3]), tostring(r), tostring(g), tostring(b)))
end

--- An override key that resolves without LibSharedMedia, which the mock leaves unregistered: a
--- path resolves as itself (SkinPaint's P.media rule), so the library takes it.
local STRIPES = "Interface\\AddOns\\Tester\\stripes"

test("textures: the section is built with three bars, five rows and five segments", function()
    local NS = opened()
    local sec = NS.Showroom.Section("textures")
    assertTrue(sec ~= nil and (sec:GetHeight() or 0) > 0, "the section is built and has a height")
    assertEqual(#NS.Textures.bars, 3)
    assertEqual(#NS.Textures.rows, 5)
    assertEqual(#NS.Textures.segments, 5)
    assertEqual(#NS.Textures.labels, 5, "one key label per sample")
    assertTrue(NS.Showroom.used.BarTexture == true, "painted through the wrapper")
    local values = {}
    for i, bar in ipairs(NS.Textures.bars) do values[i] = ("%.2f"):format(bar:GetValue()) end
    assertEqual(table.concat(values, " "), "0.72 0.45 0.88")
end)

test("textures: the status bars wear the accent, good and bad colors, in the bar texture", function()
    local NS, mock = opened()
    for i, token in ipairs({ "text.accent", "sem.good", "sem.bad" }) do
        local survey = mock.__paint(NS.Textures.bars[i])
        local r, g, b = lib(mock):Color(OWNER, token)
        assertColor(survey.statusBarColor, r, g, b, "bar " .. i .. " (" .. token .. ")")
        assertTrue(survey.statusBarTexture ~= nil, "bar " .. i .. " has a texture")
    end
end)

test("textures: the chart rows and stacked segments wear the series colors", function()
    local NS, mock = opened()
    local series = NS.Skin.Token("chart.series")
    assertTrue(type(series) == "table" and #series >= 5, "the skin has five series colors")
    for i = 1, 5 do
        local c = series[i]
        for _, pair in ipairs({ { NS.Textures.rows[i], "row" }, { NS.Textures.segments[i], "segment" } }) do
            local survey = mock.__paint(pair[1])
            local got = survey.texture and survey.vertex or survey.color
            assertColor(got, c[1], c[2], c[3], pair[2] .. " " .. i)
        end
    end
end)

test("textures: every label names the texture key in effect", function()
    local NS = opened()
    local want = "Texture: " .. tostring(NS.Skin.Token("bar.texture"))
    for i, fs in ipairs(NS.Textures.labels) do assertEqual(fs:GetText(), want, "label " .. i) end
end)

test("textures: a skin switch recolors the bars and relabels them", function()
    -- red under: colors read once at build, outside the OnLooksChanged redraw.
    local NS, mock = opened()
    NS.Selector.Pick("ember")
    local r, g, b = lib(mock):Color(OWNER, "text.accent")
    assertColor(mock.__paint(NS.Textures.bars[1]).statusBarColor, r, g, b, "the accent bar under ember")
    local c = NS.Skin.Token("chart.series")[2]
    local survey = mock.__paint(NS.Textures.rows[2])
    assertColor(survey.texture and survey.vertex or survey.color, c[1], c[2], c[3], "row 2 under ember")
    assertEqual(NS.Textures.labels[1]:GetText(), "Texture: " .. tostring(NS.Skin.Token("bar.texture")))
end)

test("textures: a texture override repaints every fill and relabels it, live", function()
    -- red under: fills painted with a typed path rather than S.BarTexture (no override reaches them).
    local NS, mock = opened()
    lib(mock):SetOverride(OWNER, nil, STRIPES)
    assertEqual(NS.Textures.TextureKey(), STRIPES)
    for i, bar in ipairs(NS.Textures.bars) do
        assertEqual(mock.__paint(bar).statusBarTexture, STRIPES, "bar " .. i)
    end
    for i, tex in ipairs(NS.Textures.rows) do
        assertEqual(mock.__paint(tex).texture, STRIPES, "row " .. i)
    end
    for i, tex in ipairs(NS.Textures.segments) do
        assertEqual(mock.__paint(tex).texture, STRIPES, "segment " .. i)
    end
    for i, fs in ipairs(NS.Textures.labels) do assertEqual(fs:GetText(), "Texture: " .. STRIPES, "label " .. i) end
    lib(mock):SetOverride(OWNER, nil, false)
    assertTrue(NS.Textures.TextureKey() ~= STRIPES, "clearing the override puts the skin's own back")
end)

test("textures: the section builds without the skin engine", function()
    local NS = T.enableAddon{ skip = { "libs/LibKa0s/Skin.lua" } }
    NS.Showroom.Show()
    assertTrue(NS.Showroom.Section("textures") ~= nil, "built, painting nothing")
    assertEqual(NS.Textures.labels[1]:GetText(), "Texture: none")
end)

--- True when the file at `rel` (from the repo root) can be opened.
local function shipped(rel)
    local fh = io.open((T.root or ".") .. "/" .. rel, "rb")
    if fh then fh:close() end
    return fh ~= nil
end

test("textures: Ka0s Default draws its own Ka0s Default bar, shipped in the vendored copy", function()
    -- red under: LibKa0s before SO-06, whose Ka0s Default (and so this section) drew "Blizzard".
    local NS, mock = opened()
    assertEqual(NS.Skin.Token("bar.texture"), "Ka0s Default")
    assertEqual(NS.Textures.labels[1]:GetText(), "Texture: Ka0s Default", "the labels name it")
    local Media = mock.LibStub("LibKa0s-Media-1.0", true)
    local entry = Media and Media.TEXTURES["Ka0s Default"]
    assertTrue(entry ~= nil, "the library's statusbar catalog carries it")
    assertTrue(shipped("libs/LibKa0s/media/textures/" .. entry.file), "and the re-vendor shipped its file")
end)
