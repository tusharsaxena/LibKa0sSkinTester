-- tests/skin_surfaces.lua — the skin-switch test's facts (Kit.skinSwitch, kit revision 58): every
-- surface this addon paints, off one opened showroom.
--
-- WHAT IS DECLARED. The window's own chrome, by name, and every captioned sample cell of every
-- section, read off `body.cells` (R.Grid), so a sample added later is declared the day it is added.
-- A cell left out is named in LEFT_OUT with the reason, which is what an audit reads.
--
-- KIT REVISION 58 (SD-SK-ST). Each setter family a surface draws has to move on its own, so a surface
-- whose family a ruling keeps fixed says so in HOLD, with the ruling; a data fill drawn on a plain
-- Texture asks for its texture to move in EXPECT, since the kit asks that of StatusBars only.
--
-- It answers a function of the runner's `enableAddon`, because the instance has to exist when the
-- kit reads the facts: a surface's frames repaint only through that instance's own library.

local installPaint = dofile("tests/_kit/mock_paint.lua")

local OWNER = "LibKa0sSkinTester"
local SECTIONS = { "chrome", "controls", "lists", "text", "panels", "overlays", "addon", "widgets",
                   "values", "textures", "fonts", "hud" }

-- The kit's AceGUI is a stub with no widget parts, so a painter has nothing to reach and no setter
-- runs. tests/test_showroom_owner.lua and tests/test_showroom_dropdowns.lua pin that each of these
-- is handed to PaintAce again on every OnLooksChanged.
local ACE_STUB = "an AceGUI sample on the kit's stub widget"

-- What the Scope's Ignore fonts half keeps stock, so the kit's second pass leaves it out.
local SCOPED = { ["text: Font"] = "fonts" }

-- The "Stock" twins beside the FadeRegions and FadeNineSlice samples (modules/ShowroomOverlays.lua)
-- stay stock under every skin, so the fade reads against them (owner U-20, 2026-11-20). They are
-- never painted: the FadeRegions cell is declared for its faded half, and the FadeNineSlice cell,
-- whose faded half is the template's own art, is left out.
local LEFT_OUT = {
    ["controls: AceGUI Dropdown, PaintAce (Scope: panel)"] = ACE_STUB,
    ["controls: Ka0sMedia_Font, PaintAce (Scope: panel)"] = ACE_STUB,
    ["controls: Ka0sMedia_Statusbar, PaintAce (Scope: panel)"] = ACE_STUB,
    ["addon: TreeGroup via PaintAce (Scope: panel)"] = ACE_STUB,
    ["overlays: FadeNineSlice (left) beside stock"] =
        "fades the template's art in every skin, its stock twin shows it (owner U-20, 2026-11-20)",
}

-- Whose texture has to move on a switch. The two charts are data fills on plain Textures, drawn in
-- the skin's bar.texture (modules/ShowroomTextures.lua), which the kit asks of StatusBars only; the
-- StatusBar fills are named too, so their place in the list says what they are; the shells wear the
-- skin's window art and gradient. No StatusBar here is drawn clear, so no surface says clear = true.
local EXPECT = {
    ["textures: Bar chart (series 1-5)"] = "texture",
    ["textures: Stacked bar (series 1-5)"] = "texture",
    ["textures: StatusBar (accent, 72%)"] = "texture",
    ["textures: StatusBar (good, 45%)"] = "texture",
    ["textures: StatusBar (bad, 88%)"] = "texture",
    ["values: BarStyle"] = "texture",
    ["hud: BarFillColor, BarGloss"] = "texture",
    ["overlays: ApplyBarFill"] = "texture",
    ["overlays: Confirm popup (Shell, Header + Button)"] = "texture",
    ["addon: Shell on SettingsFrameTemplate"] = "texture",
}

-- One HUD line per skin, each in that skin's own face, size and outline whatever is worn (owner R-4,
-- docs/2026-10-30-SKIN_LIBRARY_FOLLOWUPS/00_PLAN.md of Ka0sAddonsCommonTasks): only its color, the
-- worn skin's HudTextColor, follows a switch (SD-SK-ST.2). The Faces and widths cells are the same
-- ruling, and pass unheld because their ratio line wears the worn skin's face.
local HUD_LINE_HOLD = "font"

--- A LibSharedMedia that answers every key, so a face or a bar key shows on the setter it reaches.
local function fakeLSM(mock)
    local LSM = mock.LibStub:NewLibrary("LibSharedMedia-3.0", 1) or mock.LibStub("LibSharedMedia-3.0")
    LSM.Fetch = function(_, kind, key) return ("Fonts\\%s\\%s.ttf"):format(kind, tostring(key)) end
end

local function chrome(mock)
    local window = mock.frames["LibKa0sSkinTesterShowroom"]
    local function surface(name, object, expect)
        return { name = name, expect = expect, build = function() return object end }
    end
    return {
        surface("the window's shell", window, "texture"),   -- the skin's window art and gradient
        surface("the title bar", window.titleBar),
        surface("the footer", window.footer),
        surface("the scroll bar", window.scrollBar),
        surface("the skin selector", window.selector),
    }
end

return function(enableAddon)
    local NS, _, mock = enableAddon{ mock = function(m) installPaint(m) end }
    fakeLSM(mock)
    NS.Showroom.Show()
    local Skin = mock.LibStub("LibKa0s-Skin-1.0")
    local hold = {}
    for _, def in ipairs(Skin:Skins()) do
        hold[("hud: hud.font (%s)"):format(def.label or def.key)] = HUD_LINE_HOLD
    end

    local surfaces = chrome(mock)
    for _, key in ipairs(SECTIONS) do
        local holder = NS.Showroom.Section(key)
        surfaces[#surfaces + 1] = { name = key .. ": the title", build = function() return holder.title end }
        local captions = {}
        for caption in pairs(holder.cells) do captions[#captions + 1] = caption end
        table.sort(captions)
        for _, caption in ipairs(captions) do
            local id = key .. ": " .. caption
            if not LEFT_OUT[id] then
                surfaces[#surfaces + 1] = { name = id, scope = SCOPED[id], expect = EXPECT[id], hold = hold[id],
                                            build = function() return holder.cells[caption] end }
            end
        end
    end
    return { owner = OWNER, skin = Skin, surfaces = surfaces }
end
