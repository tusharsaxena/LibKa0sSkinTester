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
    },
    -- The Sample controls page: one row of each widget type, so the skin can be seen on a settings
    -- page too. Nothing reads these but the page.
    sample = {
        checked = true,
        size    = 5,         -- 1 .. 10
        mode    = "medium",
        color   = { r = 0.2, g = 0.6, b = 1, a = 1 },
        useClassColor = false,
    },
}
