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
}
