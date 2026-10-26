local _, NS = ...
-- modules/ShowroomLists.lua — the Lists section: a sort header, a row in each of its four states, and
-- a scroll bar with the track and thumb drawn by the caller.

local R, L = NS.Showroom, NS.L

local ROW_W, ROW_H = 300, 20

local function rowText(row, text)
    local fs = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    fs:SetPoint("LEFT", row, "LEFT", 6, 0)
    fs:SetText(text)
    row.text = fs
    return fs
end

R.AddSection("lists", L["Lists"], function(body, paint)
    local g = R.Grid(body)

    local header = CreateFrame("Frame", nil, g:Add(ROW_W, ROW_H, "SortHeaderBar"), "BackdropTemplate")
    header:SetSize(ROW_W, ROW_H)
    header:SetPoint("TOPLEFT")
    local texts = {}
    for i, name in ipairs({ "Name", "Count", "When" }) do
        local fs = header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        fs:SetPoint("LEFT", header, "LEFT", 6 + (i - 1) * 100, 0)
        fs:SetText(name)
        texts[i] = fs
    end
    local arrow = header:CreateTexture(nil, "OVERLAY")
    arrow:SetSize(10, 10)
    arrow:SetPoint("LEFT", texts[1], "RIGHT", 4, 0)
    arrow:SetTexture("Interface\\Buttons\\UI-SortArrow")
    paint("SortHeaderBar", header, { texts = texts, arrows = { arrow } })

    local rows = g:Add(ROW_W, ROW_H * 4, "ListRow (normal, stripe, hover, selected)")
    for i, state in ipairs({ "normal", "stripe", "hover", "selected" }) do
        local row = CreateFrame("Frame", nil, rows)
        row:SetSize(ROW_W, ROW_H)
        row:SetPoint("TOPLEFT", rows, "TOPLEFT", 0, -(i - 1) * ROW_H)
        paint("Text", rowText(row, ("A row, %s"):format(state)), "body")
        paint("ListRow", row, state)
    end

    local bar = CreateFrame("Frame", nil, g:Add(14, ROW_H * 4, "ScrollBar (track, thumb)"))
    bar:SetSize(14, ROW_H * 4)
    bar:SetPoint("TOPLEFT")
    local track = bar:CreateTexture(nil, "BACKGROUND")
    track:SetAllPoints(bar)
    local thumb = bar:CreateTexture(nil, "ARTWORK")
    thumb:SetPoint("TOPLEFT", bar, "TOPLEFT", 2, -14)
    thumb:SetSize(10, 28)
    paint("ScrollBar", bar, { track = track, thumb = thumb })

    return g:Height()
end)
