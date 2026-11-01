-- tests/skin_surfaces.lua — the skin-switch test's facts (Kit.skinSwitch, kit revision 50): every
-- surface this addon paints, off one opened showroom.
--
-- WHAT IS DECLARED. The window's own chrome, by name, and every captioned sample cell of every
-- section, read off `body.cells` (R.Grid), so a sample added later is declared the day it is added.
-- A cell left out is named in LEFT_OUT with the reason, which is what an audit reads.
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

local LEFT_OUT = {
    ["controls: AceGUI Dropdown, PaintAce (Scope: panel)"] = ACE_STUB,
    ["controls: Ka0sMedia_Font, PaintAce (Scope: panel)"] = ACE_STUB,
    ["controls: Ka0sMedia_Statusbar, PaintAce (Scope: panel)"] = ACE_STUB,
    ["addon: TreeGroup via PaintAce (Scope: panel)"] = ACE_STUB,
    ["overlays: FadeNineSlice (left) beside stock"] = "fades the template's art in every skin, its twin shows it",
}

--- A LibSharedMedia that answers every key, so a face or a bar key shows on the setter it reaches.
local function fakeLSM(mock)
    local LSM = mock.LibStub:NewLibrary("LibSharedMedia-3.0", 1) or mock.LibStub("LibSharedMedia-3.0")
    LSM.Fetch = function(_, kind, key) return ("Fonts\\%s\\%s.ttf"):format(kind, tostring(key)) end
end

local function chrome(mock)
    local window = mock.frames["LibKa0sSkinTesterShowroom"]
    local function surface(name, object)
        return { name = name, build = function() return object end }
    end
    return {
        surface("the window's shell", window),
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
    local leftOut = setmetatable({}, { __index = LEFT_OUT })
    -- One line per skin, each in that skin's own face whatever is worn (modules/ShowroomHud.lua).
    for _, def in ipairs(Skin:Skins()) do
        leftOut[("hud: hud.font (%s)"):format(def.label or def.key)] = "shows a skin that may not be worn"
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
            if not leftOut[id] then
                surfaces[#surfaces + 1] = { name = id, scope = SCOPED[id],
                                            build = function() return holder.cells[caption] end }
            end
        end
    end
    return { owner = OWNER, skin = Skin, surfaces = surfaces }
end
