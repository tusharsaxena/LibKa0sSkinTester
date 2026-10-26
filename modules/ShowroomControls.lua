local addonName, NS = ...
-- modules/ShowroomControls.lua — the Controls section: buttons in every state, the paging arrows, an
-- icon button, a search box and a dropdown (the library's own widgets, owned by this addon), check
-- buttons and a slider. The library widgets paint themselves through their owner's facade; each is
-- painted again through the wrapper so the coverage record sees it (a repeat paint of one target is
-- one record).

local R, L = NS.Showroom, NS.L
local ICON = "Interface\\Icons\\INV_Misc_QuestionMark"

local function widgets() return LibStub and LibStub("LibKa0s-Widgets-1.0", true) end

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

    local square = CreateFrame("Button", nil, g:Add(32, 32, "SquareIcon (crop)"), "BackdropTemplate")
    square:SetSize(32, 32)
    square:SetPoint("TOPLEFT")
    square.icon = square:CreateTexture(nil, "ARTWORK")
    square.icon:SetAllPoints(square)
    square.icon:SetTexture(ICON)
    paint("SquareIcon", square, { crop = true })

    local box = searchBox(g:Add(180, 22, "EditBox (SearchBox, with its hint)"))
    box:SetPoint("TOPLEFT")
    paint("EditBox", box)

    local dd = dropdown(g:Add(160, 22, "Dropdown (click: MenuFrame)"))
    dd:SetPoint("TOPLEFT")
    paint("Dropdown", dd)

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
    slider.track = slider:CreateTexture(nil, "BACKGROUND")
    slider.track:SetPoint("LEFT", slider, "LEFT", 0, 0)
    slider.track:SetPoint("RIGHT", slider, "RIGHT", 0, 0)
    slider.track:SetHeight(4)
    local fill = slider:CreateTexture(nil, "ARTWORK")
    fill:SetPoint("LEFT", slider.track, "LEFT", 0, 0)
    fill:SetSize(72, 4)
    local thumb = slider:CreateTexture(nil, "OVERLAY")
    thumb:SetSize(10, 16)
    slider:SetThumbTexture(thumb)
    paint("Slider", slider, { fill = fill, thumb = thumb })

    return g:Height()
end)
