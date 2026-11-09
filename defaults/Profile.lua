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
        skin   = NS.DEFAULT_SKIN or "ka0s", -- the Ka0s skin worn: WoW Forever on Forever, else Ka0s Default
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
}
