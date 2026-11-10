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
--                         half: stock while the Scope leaves the panel the client's (a new profile does),
--                         painted once it is cleared. PaintAce is asked again on every
--                         OnLooksChanged, so a Scope change or a skin switch shows at once. Its
--                         height is the host's (no auto-height) and its content pane holds a
--                         placeholder page (R4-ST2).
--   a template window     a SettingsFrameTemplate miniature painted like any window: its art faded
--                         and the skin's drawn under every skin, Ka0s Default included (LibKa0s
--                         v1.81.0 retired opts.stockDefault, ruling R-2: the client's look is the
--                         WoW Default skin)
--
-- Built only through the sample's own frames: no GameTooltip, no StaticPopup, no Blizzard window.

local R, L = NS.Showroom, NS.L
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
    -- R4-ST2: the host owns the height, as PrettyChat's TreeGroup does (settings/Panel.lua). Left
    -- on, AceGUI's auto-height takes an empty List layout's 0 and collapses both panes to 20 px,
    -- with the tree's rows hanging below them. A Fill page in the content pane makes it read as a
    -- settings page, the selected row's.
    tree:SetAutoAdjustHeight(false)
    tree:SetLayout("Fill")
    local page = AceGUI:Create("Label")
    page:SetText(L["The General page"])
    tree:AddChild(page)
    tree:SetWidth(300)
    tree:SetHeight(120)
    local f = tree.frame
    f:SetParent(cell)
    f:ClearAllPoints()
    f:SetPoint("TOPLEFT", cell, "TOPLEFT", 0, 0)
    f:Show()
    return tree, cell, paint("PaintAce", tree)
end

-- A template's parentKey child: a raw field holding a frame or region, else nil.
local function child(f, key)
    local v = f and rawget(f, key)
    if type(v) == "table" then return v end
end

-- A miniature of a window built to match Blizzard's settings window (Quick Comms' callout popup):
-- SettingsFrameTemplate's NineSlice with the title on it, its Bg and its close button. Ka0s Default
-- paints it as every other skin does (R-2). A client without the template gets a plain frame,
-- painted the same way.
local function stockWindow(g, paint)
    local cell = g:Add(240, 90, "Shell on SettingsFrameTemplate")
    local ok, win = pcall(CreateFrame, "Frame", nil, cell, STOCK_TEMPLATE)
    if not ok then win = CreateFrame("Frame", nil, cell, "BackdropTemplate") end
    win:SetSize(240, 90)
    win:ClearAllPoints()
    win:SetPoint("TOPLEFT", cell, "TOPLEFT", 0, 0)
    paint("Shell", win, { stock = { child(win, "Bg") } })
    local nine = child(win, "NineSlice")
    if nine then
        paint("FadeNineSlice", win)
        local title = child(nine, "Text")
        if title then
            title:SetText("Settings-style window")
            paint("TitleBar", nine, { text = title, noBg = true })
        end
    end
    local close = child(win, "ClosePanelButton")
    if close then
        close:SetScript("OnClick", nil)   -- a sample: its parent is a showroom cell, not a window
        paint("CloseButton", close)
    end
    -- The template keeps its own anchors for the title and close (TOP and TOPRIGHT, placed for its
    -- 24 px header), off Shell's band. Both go onto the band's middle (LibKa0s R5-L3, R5-WIN), and a
    -- switch places them again.
    paint("Header", win, { title = nine and child(nine, "Text"), right = { close } })
    local body = line(win, "The skin's art in every skin", "GameFontHighlightSmall")
    body:SetPoint("CENTER", win, "CENTER", 0, -6)
    paint("Text", body, "body")
    return win
end

R.AddSection("addon", L["Addon surfaces"], function(body, paint)
    local g = R.Grid(body)
    body.note = ownerToken(g, paint)
    body.danger = dangerButton(g, paint)
    body.callout = cautionCallout(g, paint)
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
