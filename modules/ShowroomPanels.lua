local _, NS = ...
-- modules/ShowroomPanels.lua — the Panels section: the surfaces a window is built from (Panel, Inset,
-- Card), a rule, a settings drawer open and closed, the test and simulation strips, the combat cover
-- and a nav-rail entry selected and not.

local R, L = NS.Showroom, NS.L

local function boxed(cell, w, h)
    local f = CreateFrame("Frame", nil, cell, "BackdropTemplate")
    f:SetSize(w, h)
    f:SetPoint("TOPLEFT")
    return f
end

local function label(parent, text, template)
    local fs = parent:CreateFontString(nil, "OVERLAY", template or "GameFontHighlight")
    fs:SetPoint("LEFT", parent, "LEFT", 8, 0)
    fs:SetText(text)
    return fs
end

R.AddSection("panels", L["Panels"], function(body, paint)
    local g = R.Grid(body)

    paint("Panel", boxed(g:Add(140, 60, "Panel"), 140, 60))
    paint("Inset", boxed(g:Add(140, 60, "Inset"), 140, 60))

    local card = boxed(g:Add(140, 60, "Card"), 140, 60)
    local title = card:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", card, "TOPLEFT", 8, -8)
    title:SetText("1,024")
    local text = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    text:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -4)
    text:SetText("items seen")
    paint("Card", card, { title = title, text = text })

    local rule = g:Add(200, 8, "Divider"):CreateTexture(nil, "ARTWORK")
    rule:SetPoint("LEFT")
    rule:SetSize(200, 1)
    paint("Divider", rule)

    for _, open in ipairs({ true, false }) do
        local head = boxed(g:Add(220, 26, open and "Drawer (open, set)" or "Drawer (closed)"), 220, 26)
        local name = label(head, "Drawer")
        local summary = head:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        summary:SetPoint("RIGHT", head, "RIGHT", -8, 0)
        summary:SetText(open and "3 changed" or "defaults")
        paint("Drawer", head, { label = name, summary = summary, open = open, set = open })
    end

    for _, kind in ipairs({ "test", "sim" }) do
        local strip = boxed(g:Add(220, 18, ("Strip (%s)"):format(kind)), 220, 18)
        paint("Text", label(strip, kind == "sim" and "Simulation" or "Test mode", "GameFontNormalSmall"), "body")
        paint("Strip", strip, { kind = kind })
    end

    local covered = boxed(g:Add(180, 50, "Cover (text)"), 180, 50)
    paint("Text", label(covered, "Underneath"), "body")
    local dim = covered:CreateTexture(nil, "OVERLAY")
    dim:SetAllPoints(covered)
    local coverText = covered:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    coverText:SetPoint("CENTER")
    coverText:SetText("In combat")
    paint("Cover", dim, { text = coverText })

    for _, selected in ipairs({ true, false }) do
        local item = boxed(g:Add(160, 22, selected and "NavItem (selected)" or "NavItem"), 160, 22)
        local sel = item:CreateTexture(nil, "BACKGROUND")
        sel:SetAllPoints(item)
        if not selected then sel:Hide() end
        paint("NavItem", item, { label = label(item, "General"), sel = sel, selected = selected })
    end

    return g:Height()
end)
