local addonName, NS = ...
-- modules/ShowroomControls.lua — the Controls section: buttons in every state, the paging arrows, an
-- icon button, a search box (the library's own widget, owned by this addon), check buttons, a slider,
-- and a row of every dropdown kind the collection draws. The library widgets paint themselves through
-- their owner's facade; each is painted again through the wrapper so the coverage record sees it (a
-- repeat paint of one target is one record).
--
-- THE DROPDOWNS (ST-D1). Each goes through the route an addon's own goes through, in its cell, so it
-- scrolls with the section:
--
--   W.Dropdown            the library's button, owned by this addon: a window's, every skin paints it
--   AceGUI Dropdown       acquired here and handed to PaintAce; a settings-panel surface, so stock
--   Ka0sMedia_Font,       while the Scope leaves the panel the client's (the default), and repainted
--   Ka0sMedia_Statusbar   on every OnLooksChanged, as the TreeGroup is. The pickers are the ones the
--                         settings renderer draws, each showing a real key; their faces load on the
--                         first open. The only media picker in the collection (the owner's ruling
--                         of 2026-11-01), so no other kind has a cell
--   WowStyle1Dropdown...  a Blizzard DropdownButton as PremadeGroupsFilterExtension's panel draws
--                         one: a window's, painted with S.Dropdown. S.Dropdown fades the
--                         template's Background and its whole-button Arrow and lays its own chevron
--                         over it (LibKa0s minor 16, #71). The list it opens is the client's Menu, which no primitive paints
--
-- A surface this client lacks gets its cell all the same, a label saying what is missing (unavailable).

local R, L = NS.Showroom, NS.L
local ICON = "Interface\\Icons\\INV_Misc_QuestionMark"
local BLIZZ_TEMPLATE = "WowStyle1DropdownTemplate"
local CHOICES = { "First choice", "Second choice" }
local ACE_W, ACE_H = 200, 26
local CELL_W = 270   -- a dropdown's cell: wider than the dropdown, so its caption clears the next one
local FONT_KEY, BAR_KEY = "Ka0s Prototype", "Ka0s Default"

local aceSamples = {}   -- the widgets PaintAce paints, once built; repainted on every OnLooksChanged

local function widgets() return LibStub and LibStub("LibKa0s-Widgets-1.0", true) end
local function aceGUI() return LibStub and LibStub("AceGUI-3.0", true) end

local function searchBox(cell)
    local W = widgets()
    if W and W.SearchBox then
        return W.SearchBox(cell, 180, { hint = "Search the showroom", owner = addonName })
    end
    local box = CreateFrame("EditBox", nil, cell, "InputBoxTemplate")
    box:SetSize(180, 22)
    box:SetAutoFocus(false)
    return box
end

local function dropdown(cell)
    local W = widgets()
    if W and W.Dropdown then
        local dd = W.Dropdown(cell, 160, { owner = addonName })
        dd:SetOptions({ { value = 1, label = "First choice" }, { value = 2, label = "Second choice" } })
        dd:SelectValue(1)
        return dd
    end
    return R.SampleButton(cell, 160, 22, "First choice")
end

--- A cell's label for a surface this client cannot show; answers it, so a suite can read it.
local function unavailable(cell, w, h, text)
    local btn = R.SampleButton(cell, w, h, text)
    btn:SetPoint("TOPLEFT")
    btn:Disable()
    R.Paint("Button", btn)
    return btn
end

--- An AceGUI widget laid in its cell, the way the TreeGroup sample lays one in.
local function seat(cell, w, width)
    if w.SetLabel then w:SetLabel() end   -- the cell's caption is its label
    w:SetWidth(width)
    local f = w.frame
    f:SetParent(cell)
    f:ClearAllPoints()
    f:SetPoint("TOPLEFT", cell, "TOPLEFT", 0, 0)
    f:Show()
    return w
end

local function aceDropdown(g, paint)
    local cell = g:Add(CELL_W, ACE_H, "AceGUI Dropdown, PaintAce (Scope: panel)")
    local AceGUI = aceGUI()
    if not AceGUI then return unavailable(cell, ACE_W, ACE_H, "No AceGUI in this client") end
    local w = seat(cell, AceGUI:Create("Dropdown"), ACE_W)
    w:SetList({ first = CHOICES[1], second = CHOICES[2] }, { "first", "second" })
    w:SetValue("first")
    aceSamples[#aceSamples + 1] = w
    paint("PaintAce", w)
    return w
end

-- The library's picker for `kind`, as its own Appearance rows make one: registered on asking, and
-- lazy, so the faces wait for the first open. nil where the library has no picker (its callers then
-- draw AceGUI's plain Dropdown).
local function acquirePicker(AceGUI, kind)
    local O = LibStub("LibKa0s-Options-1.0", true)
    local wtype = O and O.__MediaWidgetType and O.__MediaWidgetType(kind)
    if not wtype then return nil end
    if O.__createLazyMedia then return O.__createLazyMedia(AceGUI, wtype) end
    return AceGUI:Create(wtype)
end

local function mediaPicker(g, paint, kind, wtype, key)
    local cell = g:Add(CELL_W, ACE_H, wtype .. ", PaintAce (Scope: panel)")
    local AceGUI = aceGUI()
    if not AceGUI then return unavailable(cell, ACE_W, ACE_H, "No AceGUI in this client") end
    local w = acquirePicker(AceGUI, kind)
    if w then
        seat(cell, w, ACE_W):SetList()   -- no list: every key of this kind
    else
        w = seat(cell, AceGUI:Create("Dropdown"), ACE_W)
        w:SetList({ [key] = "Plain Dropdown: no picker here" }, { key })
    end
    w:SetValue(key)
    aceSamples[#aceSamples + 1] = w
    paint("PaintAce", w)
    return w
end

local function blizzardDropdown(g, paint)
    local cell = g:Add(CELL_W, ACE_H, BLIZZ_TEMPLATE .. " (its list: stock)")
    local ok, dd = pcall(CreateFrame, "DropdownButton", nil, cell, BLIZZ_TEMPLATE)
    if not ok then return unavailable(cell, ACE_W, ACE_H, "Template not in this client") end
    dd:SetWidth(ACE_W)
    dd:SetPoint("TOPLEFT", cell, "TOPLEFT", 0, 0)
    dd:SetDefaultText(CHOICES[1])
    local chosen = 1
    dd:SetupMenu(function(_, root)
        for i, text in ipairs(CHOICES) do
            root:CreateRadio(text, function() return chosen == i end, function() chosen = i end)
        end
    end)
    paint("Dropdown", dd)
    return dd
end

--- A white texture in `token`'s color, what a host's own slider part is before the primitive tints it.
local function tinted(tex, token)
    tex:SetColorTexture(1, 1, 1, 1)
    local r, g, b, a = NS.Skin.Color(token)
    if r then tex:SetVertexColor(r, g, b, a) end
end

local function dropdownRow(g, body, paint)
    g:Break()
    local dd = dropdown(g:Add(160, 22, "Dropdown (click: MenuFrame)"))
    dd:SetPoint("TOPLEFT")
    paint("Dropdown", dd)
    body.dropdown = dd
    body.blizzDropdown = blizzardDropdown(g, paint)
    body.aceDropdown = aceDropdown(g, paint)
    g:Break()
    body.fontPicker = mediaPicker(g, paint, "font", "Ka0sMedia_Font", FONT_KEY)
    body.barPicker = mediaPicker(g, paint, "statusbar", "Ka0sMedia_Statusbar", BAR_KEY)
    g:Break()
end

R.AddSection("controls", L["Controls"], function(body, paint)
    local g = R.Grid(body)

    local normal = R.SampleButton(g:Add(110, 24, "Button"), 110, 24, "Normal")
    normal:SetPoint("TOPLEFT")
    paint("Button", normal)

    local primary = R.SampleButton(g:Add(110, 24, "Button (primary)"), 110, 24, "Primary")
    primary:SetPoint("TOPLEFT")
    paint("Button", primary, { primary = true })

    local disabled = R.SampleButton(g:Add(110, 24, "Button (disabled)"), 110, 24, "Disabled")
    disabled:SetPoint("TOPLEFT")
    disabled:Disable()
    paint("Button", disabled)

    local white = R.SampleButton(g:Add(110, 24, "WhiteButtonLabel"), 110, 24, "White label")
    white:SetPoint("TOPLEFT")
    paint("WhiteButtonLabel", white)

    for _, on in ipairs({ true, false }) do
        local cell = g:Add(110, 24, on and "StateButtonLabel (on)" or "StateButtonLabel (off)")
        local btn = R.SampleButton(cell, 110, 24, on and "On" or "Off")
        btn:SetPoint("TOPLEFT")
        paint("StateButtonLabel", btn, on)
    end

    local pages = g:Add(60, 24, "PageButton (prev, next)")
    for i, dir in ipairs({ "prev", "next" }) do
        local btn = CreateFrame("Button", nil, pages, "BackdropTemplate")
        btn:SetSize(26, 24)
        btn:SetPoint("LEFT", pages, "LEFT", (i - 1) * 32, 0)
        btn.icon = btn:CreateTexture(nil, "ARTWORK")
        btn.icon:SetAllPoints(btn)
        paint("PageButton", btn, dir)
    end

    local square = CreateFrame("Button", nil, g:Add(32, 32, "SquareIcon (crop) + IconBorder"), "BackdropTemplate")
    square:SetSize(32, 32)
    square:SetPoint("TOPLEFT")
    square.icon = square:CreateTexture(nil, "ARTWORK")
    square.icon:SetAllPoints(square)
    square.icon:SetTexture(ICON)
    paint("SquareIcon", square, { crop = true })
    -- S.SquareIcon crops to 0.08; IconBorder's 0.07 zoom only tightens, so the 0.08 crop stands, and it
    -- draws its 1 px outline in icon.border, in every skin (LibKa0s R3-L3, R3-FIX).
    paint("IconBorder", square, { fromSkin = true })

    local box = searchBox(g:Add(180, 22, "EditBox (SearchBox, with its hint)"))
    box:SetPoint("TOPLEFT")
    paint("EditBox", box)

    dropdownRow(g, body, paint)

    for _, checked in ipairs({ true, false }) do
        local cell = g:Add(24, 24, checked and "Checkbox (checked)" or "Checkbox (unchecked)")
        local cb = CreateFrame("CheckButton", nil, cell, "UICheckButtonTemplate")
        cb:SetSize(24, 24)
        cb:SetPoint("TOPLEFT")
        cb:SetChecked(checked)
        paint("Checkbox", cb)
    end

    local slider = CreateFrame("Slider", nil, g:Add(180, 18, "Slider"), "BackdropTemplate")
    slider:SetSize(180, 18)
    slider:SetPoint("TOPLEFT")
    slider:SetOrientation("HORIZONTAL")
    slider:SetMinMaxValues(0, 100)
    slider:SetValue(40)
    -- Drawn the way a host draws its own slider: white textures tinted, which the primitive re-tints
    -- with SetVertexColor in every skin (every skin sets its slider tokens); blank textures would show
    -- nothing where a skin left one alone.
    -- The track is the host's own, so it goes in opts.stock: faded where the skin draws one.
    slider.track = slider:CreateTexture(nil, "BACKGROUND")
    slider.track:SetPoint("LEFT", slider, "LEFT", 0, 0)
    slider.track:SetPoint("RIGHT", slider, "RIGHT", 0, 0)
    slider.track:SetHeight(4)
    tinted(slider.track, "slider.track")
    local fill = slider:CreateTexture(nil, "ARTWORK")
    fill:SetPoint("LEFT", slider.track, "LEFT", 0, 0)
    fill:SetSize(72, 4)
    tinted(fill, "slider.fill")
    local thumb = slider:CreateTexture(nil, "OVERLAY")
    thumb:SetSize(10, 16)
    tinted(thumb, "slider.thumb")
    slider:SetThumbTexture(thumb)
    paint("Slider", slider, { fill = fill, thumb = thumb, stock = { slider.track } })
    body.slider, slider.thumb = slider, thumb

    return g:Height()
end)

if NS.Skin and NS.Skin.OnLooksChanged then
    NS.Skin.OnLooksChanged(function()
        for _, w in ipairs(aceSamples) do R.Paint("PaintAce", w) end
    end)
end
