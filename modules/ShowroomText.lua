local _, NS = ...
-- modules/ShowroomText.lua — the Text section: one line in each of the nine text roles, then the body
-- font (Font) and the body font in the body color (White).

local R, L = NS.Showroom, NS.L

local ROLES = { "body", "muted", "heading", "headingAlt", "accent", "disabled", "link", "linkHot", "title" }
local LINE = "The quick brown fox jumps over the lazy dog 0123456789"

R.AddSection("text", L["Text"], function(body, paint)
    local g = R.Grid(body)
    for _, role in ipairs(ROLES) do
        local fs = g:Add(420, 16, ("Text (%s)"):format(role)):CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        fs:SetPoint("TOPLEFT")
        fs:SetText(LINE)
        paint("Text", fs, role)
    end
    local font = g:Add(420, 16, "Font"):CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    font:SetPoint("TOPLEFT")
    font:SetText(LINE)
    paint("Font", font)
    local white = g:Add(420, 16, "White"):CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    white:SetPoint("TOPLEFT")
    white:SetText(LINE)
    paint("White", white)
    return g:Height()
end)
