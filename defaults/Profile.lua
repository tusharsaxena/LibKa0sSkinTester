local _, NS = ...
-- defaults/Profile.lua — NS.C, the profile's default values (savedvariables-§2).
--
-- The schema (settings/Schema.lua) holds every setting's STRUCTURE and reads its default from
-- here, so a value is written once. LOAD-BEARING: before settings/Schema.lua, which takes NS.C as
-- a file-scope upvalue.

NS.C = {
    enabled = true,          -- master switch
    scale   = 1,             -- the showroom's scale   (0.5 .. 2)
    alpha   = 1,             -- the showroom's opacity (0 .. 1)
    skin = {
        source = "ka0s",     -- where the look comes from: Ka0s skins, or EllesmereUI
        skin   = "ka0s",     -- the Ka0s skin worn, and so shown in the showroom
        -- The Scope: OFF here, so the showroom's "(Scope: panel)" samples and the settings pages wear
        -- the skin. An accepted deviation from skinning-§3/§9 (owner ruling of 2026-11-03, R4-ST1;
        -- docs/ARCHITECTURE.md, Documented deviations). No migration: a stored value is kept.
        ignorePanel = false,
        ignoreFonts = false, -- the Scope: leave every font the client's (the skin still colors)
        font    = "",        -- the font override, a LibSharedMedia key; "" is the skin's own
        texture = "",        -- the bar texture override, a LibSharedMedia key; "" is the skin's own
        outline = "hud",     -- the Font outline: "hud" text only, "all" text, or "off" (LibKa0s v1.83.0)
        pickerSeen = false,  -- the first-run skin picker was closed on this profile
    },
    -- The Sample controls page: one row of each widget type and one picker of each media kind, so
    -- the skin can be seen on a settings page too. Nothing reads these but the page.
    sample = {
        checked = true,
        size    = 5,         -- 1 .. 10
        mode    = "medium",
        color   = { r = 0.2, g = 0.6, b = 1, a = 1 },
        colorFromSkin = true,   -- the swatch's skin companion
        useClassColor = false,
        -- LibSharedMedia keys: Ka0s Default's face and bar, and the library's own stock entries of
        -- the other kinds. A row with a skin token carries its `<key>FromSkin` companion, on by
        -- default as a composer's is (LibKa0s v1.85.0); a background and a sound have no such token.
        font       = "Ka0s Prototype",
        fontFromSkin = true,
        statusbar  = "Ka0s Default",
        statusbarFromSkin = true,
        border     = "Blizzard Tooltip",
        borderFromSkin = true,
        background = "Blizzard Tooltip",
        sound      = "None",
    },
}
