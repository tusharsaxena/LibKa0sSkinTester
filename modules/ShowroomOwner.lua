local _, NS = ...
-- modules/ShowroomOwner.lua — the Addon surfaces section: what LibKa0s v1.80.0 gave an addon for the
-- skinning rollout (Ka0sAddonsCommonTasks docs/2026-10-29-SKINNING_ROLLOUT, LK-01..05), each sample
-- painted through R.Paint:
--
--   an owner token        a note line in `st.note`, this addon's own token (core/SkinSetup.lua)
--   a danger button       Button with opts.tokens naming the fill, edge and label
--   a caution callout     Card with opts.tokens naming the fill, edge and title
--   an AceGUI TreeGroup   acquired here and handed to the library's PaintAce. An AceGUI widget is
--                         a settings-panel surface, so it follows the Scope's "settings panel"
--                         half: stock while the Scope leaves the panel the client's (the default),
--                         painted once it is cleared. PaintAce is asked again on every
--                         OnLooksChanged, so a Scope change or a skin switch shows at once.
--   an icon border        IconBorder with opts.fromSkin: icon.borderStyle and icon.borderSize
--   a stock window        a SettingsFrameTemplate miniature painted with opts.stockDefault: the
--                         client's art under Ka0s Default, the skin's under every other skin
--
-- Built only through the sample's own frames: no GameTooltip, no StaticPopup, no Blizzard window.

local R, L = NS.Showroom, NS.L
local ICON = "Interface\\Icons\\INV_Misc_QuestionMark"
local STOCK_TEMPLATE = "SettingsFrameTemplate"

local tree   -- the TreeGroup sample, once built; repainted on every OnLooksChanged

local function boxed(cell, w, h)
    local f = CreateFrame("Frame", nil, cell, "BackdropTemplate")
    f:SetSize(w, h)
    f:SetPoint("TOPLEFT")
    return f
end

local function line(parent, text, template)
    local fs = parent:CreateFontString(nil, "OVERLAY", template or "GameFontHighlight")
    fs:SetText(text)
    return fs
end

local function ownerToken(g, paint)
    local cell = g:Add(220, 18, "Owner token (st.note)")
    local fs = line(cell, "A note in this addon's own gray")
    fs:SetPoint("LEFT", cell, "LEFT", 0, 0)
    paint("Text", fs, "st.note")
    return fs
end

local function dangerButton(g, paint)
    local btn = R.SampleButton(g:Add(140, 24, "Button, opts.tokens (danger)"), 140, 24, "Delete run")
    btn:SetPoint("TOPLEFT")
    paint("Button", btn, { tokens = { bg = "st.dangerFill", border = "sem.danger", text = "st.dangerText" } })
    return btn
end

local function cautionCallout(g, paint)
    local box = boxed(g:Add(240, 56, "Card, opts.tokens (caution)"), 240, 56)
    local title = line(box, "Waiting for the pull", "GameFontNormal")
    title:SetPoint("TOPLEFT", box, "TOPLEFT", 8, -8)
    local text = line(box, "The race starts on the first hit.", "GameFontHighlightSmall")
    text:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -4)
    paint("Card", box, { title = title, text = text,
        tokens = { bg = "st.cautionFill", border = "sem.warn", title = "sem.warn" } })
    return box
end

local function treeGroup(g, paint)
    local cell = g:Add(300, 120, "TreeGroup via PaintAce (Scope: panel)")
    local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
    if not AceGUI then return nil, cell end
    tree = AceGUI:Create("TreeGroup")
    if type(tree.SetTree) == "function" then
        tree:SetTree({
            { value = "general", text = "General", children = { { value = "skin", text = "Skin" } } },
            { value = "strings", text = "Strings" },
            { value = "about", text = "About" },
        })
    end
    if type(tree.SetTreeWidth) == "function" then tree:SetTreeWidth(120, false) end
    if type(tree.SelectByValue) == "function" then tree:SelectByValue("general") end
    tree:SetWidth(300)
    tree:SetHeight(120)
    local f = tree.frame
    f:SetParent(cell)
    f:ClearAllPoints()
    f:SetPoint("TOPLEFT", cell, "TOPLEFT", 0, 0)
    f:Show()
    return tree, cell, paint("PaintAce", tree)
end

local function iconBorder(g, paint)
    local framed = boxed(g:Add(36, 36, "IconBorder, fromSkin"), 36, 36)
    local icon = framed:CreateTexture(nil, "ARTWORK")
    icon:SetAllPoints(framed)
    icon:SetTexture(ICON)
    paint("IconBorder", framed, { fromSkin = true })
    return framed
end

-- A template's parentKey child: a raw field holding a frame or region, else nil.
local function child(f, key)
    local v = f and rawget(f, key)
    if type(v) == "table" then return v end
end

-- A miniature of a window built to match Blizzard's settings window (Quick Comms' callout popup):
-- SettingsFrameTemplate's NineSlice with the title on it, its Bg and its close button, every call
-- with opts.stockDefault. A client without the template gets a plain frame, painted the same way.
local function stockWindow(g, paint)
    local cell = g:Add(240, 90, "Shell, stockDefault (stock in Ka0s Default)")
    local ok, win = pcall(CreateFrame, "Frame", nil, cell, STOCK_TEMPLATE)
    if not ok then win = CreateFrame("Frame", nil, cell, "BackdropTemplate") end
    win:SetSize(240, 90)
    win:ClearAllPoints()
    win:SetPoint("TOPLEFT", cell, "TOPLEFT", 0, 0)
    paint("Shell", win, { stockDefault = true, stock = { child(win, "Bg") } })
    local nine = child(win, "NineSlice")
    if nine then
        paint("FadeNineSlice", win, { stockDefault = true })
        local title = child(nine, "Text")
        if title then
            title:SetText("Settings-style window")
            paint("TitleBar", nine, { stockDefault = true, text = title, noBg = true })
        end
    end
    local close = child(win, "ClosePanelButton")
    if close then
        close:SetScript("OnClick", nil)   -- a sample: its parent is a showroom cell, not a window
        paint("CloseButton", close, { stockDefault = true })
    end
    local body = line(win, "Stock art under Ka0s Default", "GameFontHighlightSmall")
    body:SetPoint("CENTER", win, "CENTER", 0, -6)
    paint("Text", body, "body")
    return win
end

R.AddSection("addon", L["Addon surfaces"], function(body, paint)
    local g = R.Grid(body)
    body.note = ownerToken(g, paint)
    body.danger = dangerButton(g, paint)
    body.callout = cautionCallout(g, paint)
    body.iconFrame = iconBorder(g, paint)
    g:Break()
    body.tree, body.treeCell, body.treePainted = treeGroup(g, paint)
    body.stockWindow = stockWindow(g, paint)
    return g:Height()
end)

if NS.Skin and NS.Skin.OnLooksChanged then
    NS.Skin.OnLooksChanged(function()
        if tree then R.Paint("PaintAce", tree) end
    end)
end
