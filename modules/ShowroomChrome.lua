local _, NS = ...
-- modules/ShowroomChrome.lua — the Chrome section: the tab strip. The window around every section is
-- the rest of the chrome (Shell, TitleBar, CloseButton, Footer), painted by modules/Showroom.lua.

local R, L = NS.Showroom, NS.L

R.AddSection("chrome", L["Window chrome"], function(body, paint)
    local g = R.Grid(body)

    local strip = g:Add(330, 24, "Tab x3 + SetTabSelection (click one)")
    local tabs = {}
    local function select(which)
        for _, tab in ipairs(tabs) do
            tab.selected = tab == which
            paint("SetTabSelection", tab, tab.selected)
        end
    end
    for i = 1, 3 do
        local tab = R.SampleButton(strip, 104, 24, ("Tab %d"):format(i))
        tab:SetPoint("LEFT", strip, "LEFT", (i - 1) * 110, 0)
        tab.selected = i == 1
        tab:SetScript("OnClick", function(self) select(self) end)
        paint("Tab", tab, { selected = tab.selected, text = tab.text })
        tabs[i] = tab
    end
    select(tabs[1])
    body.tabs = tabs

    local frameCell = g:Add(300, 24, "Shell, TitleBar, CloseButton, Footer")
    local note = frameCell:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    note:SetPoint("LEFT", frameCell, "LEFT", 0, 0)
    note:SetText("The window around these samples")
    paint("Text", note, "body")

    return g:Height()
end)
