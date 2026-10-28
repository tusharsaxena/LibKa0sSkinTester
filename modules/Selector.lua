local addonName, NS = ...
-- modules/Selector.lua — the swatch selector across the top of the showroom: one card per Ka0s skin,
-- in the library's order, each showing the skin's name and its four preview swatches. A click puts
-- the showroom in that skin; the selected card's name reads in the skin's accent.
--
-- One skin at a time, and only Ka0s skins. EllesmereUI gets no card: its paint is one-way, so a
-- showroom that tried it on could only be taken back with a reload. The Skin tab still offers
-- the EllesmereUI source, and while it is in force no card reads selected.
--
--   NS.Selector.Build(parent)  the row, a frame with .cards[key] and .order (each card .key, .label,
--                              .swatches and .selected); built once, with the showroom.
--   NS.Selector.Pick(key)      applies that Ka0s skin and saves it; answers changed. The current
--                              skin is no change: nothing is applied, saved or repainted.
--   NS.Selector.Refresh(row)   re-reads the applied skin and moves the selection, and fits each
--                              card's name to one line in the skin's type. The showroom calls it on
--                              every OnLooksChanged, so a pick made in the Skin tab or with
--                              `/st set skin.skin` moves it too.

NS.Selector = NS.Selector or {}
local M = NS.Selector

local CARD_W, CARD_H, GAP = 98, 56, 6
local LABEL_W = CARD_W - 12
local SWATCH_H = 14
local SOURCE = "ka0s"

local function S() return NS.Skin end
local function Skin() return LibStub and LibStub("LibKa0s-Skin-1.0", true) end

--- "#rrggbb" -> r, g, b in 0..1; nil for anything else.
local function hexColor(hex)
    local r, g, b = tostring(hex):match("^#?(%x%x)(%x%x)(%x%x)$")
    if not r then return nil end
    return tonumber(r, 16) / 255, tonumber(g, 16) / 255, tonumber(b, 16) / 255
end

--- The applied (source, skin): the library's, so the selection shows what is worn, not what is stored.
local function applied()
    local lib = Skin()
    if not lib then return SOURCE, "ka0s" end
    return lib:GetChoice(addonName)
end

--- One line, always: a name wider than the card (High Contrast's larger type) is scaled down to fit,
--- and back to full size under a skin whose type fits. The text scale leaves the skin's face alone.
local function fitLabel(label)
    if not label.SetTextScale then return end
    label:SetTextScale(1)
    local w = label.GetUnboundedStringWidth and label:GetUnboundedStringWidth() or label:GetStringWidth()
    if type(w) == "number" and w > LABEL_W then label:SetTextScale(LABEL_W / w) end
end

local function paintSelection(card, on)
    card.selected = on
    S().StateButtonLabel(card, on)
end

local function buildCard(row, def, i)
    local card = CreateFrame("Button", nil, row, "BackdropTemplate")
    card:SetSize(CARD_W, CARD_H)
    card:SetPoint("TOPLEFT", row, "TOPLEFT", (i - 1) * (CARD_W + GAP), 0)
    card.key = def.key

    local label = card:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    label:SetPoint("TOPLEFT", card, "TOPLEFT", 6, -6)
    label:SetPoint("TOPRIGHT", card, "TOPRIGHT", -6, -6)
    label:SetJustifyH("LEFT")
    label:SetWordWrap(false)
    label:SetMaxLines(1)
    label:SetText(def.label or def.key)
    card.label, card.text = label, label   -- `text` is where the paint looks for a button's label

    -- The four swatches are the skin's own preview colors, from its definition: the one place this
    -- addon draws a color it did not read from the skin it is wearing, because it is showing another.
    card.swatches = {}
    local sw = LABEL_W / 4
    for n = 1, 4 do
        local tex = card:CreateTexture(nil, "ARTWORK")
        tex:SetSize(sw, SWATCH_H)
        tex:SetPoint("BOTTOMLEFT", card, "BOTTOMLEFT", 6 + (n - 1) * sw, 6)
        local r, g, b = hexColor((def.swatches or {})[n])
        if r then tex:SetColorTexture(r, g, b, 1) else tex:Hide() end
        card.swatches[n] = tex
    end

    card:SetScript("OnClick", function(self) return M.Pick(self.key) end)
    S().Card(card)
    paintSelection(card, false)
    return card
end

function M.Build(parent)
    local row = CreateFrame("Frame", nil, parent)
    row.cards, row.order = {}, {}
    local lib = Skin()
    for i, def in ipairs(lib and lib:Skins() or {}) do
        local card = buildCard(row, def, i)
        row.cards[def.key] = card
        row.order[i] = card
    end
    row:SetSize(math.max(1, #row.order) * (CARD_W + GAP) - GAP, CARD_H)
    M.Refresh(row)
    return row
end

function M.Refresh(row)
    if not row then return end
    local source, skin = applied()
    for _, card in ipairs(row.order) do
        local on = source == SOURCE and card.key == skin
        if card.selected ~= on then paintSelection(card, on) end
        fitLabel(card.label)
    end
end

function M.Pick(key)
    local changed = NS.ApplySkinChoice(SOURCE, key)
    if changed then NS.WriteSkinChoice(SOURCE, key) end
    NS.Debug("Selector", "pick %s changed=%s", tostring(key), tostring(changed))
    return changed
end
