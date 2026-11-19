local _, NS = ...
-- modules/ShowroomChrome.lua — the Chrome section: the tab strip and the facade's Footer band. The
-- window around every section is the rest of the chrome (Shell, Band, Header, TitleBar, CloseButton),
-- painted by modules/Showroom.lua, its title marks the library's W.HeaderButtons (AD-86-ST); its footer is the library's W.Footer (AD-89-ST), which draws no
-- band, so the facade's Footer primitive is shown here as a specimen (lib.VOCAB keeps it).

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

    local band = g:Add(300, 24, "Footer (the facade's band, a specimen)")
    band.text = band:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    band.text:SetPoint("LEFT", band, "LEFT", 8, 0)
    band.text:SetText("Wearing the skin's foot.bg")
    paint("Footer", band, { text = band.text })

    local frameCell = g:Add(300, 24, "Shell, Band, Header, TitleBar, CloseButton, W.Footer")
    local note = frameCell:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    note:SetPoint("LEFT", frameCell, "LEFT", 0, 0)
    note:SetText("The window around these samples")
    paint("Text", note, "body")

    return g:Height()
end)
