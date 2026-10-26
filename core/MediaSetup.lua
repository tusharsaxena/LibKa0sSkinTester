local addonName, NS = ...
-- core/MediaSetup.lua — NS.Icon / NS.MediaFont from LibKa0s-Media-1.0 and the one RegisterLSM call.
--
-- LOAD-BEARING: before core/Constants.lua, which resolves FONT_MONO from NS.MediaFont at file load.
-- Every call passes the addon's own FOLDER name: a texture path is absolute from Interface\AddOns\
-- and the library is vendored, so it cannot know which folder it was copied into, and a wrong path
-- draws nothing and raises nothing (library-stack-§8).

local Media = LibStub and LibStub("LibKa0s-Media-1.0", true)

--- The texture path for one shipped icon, or nil. Nil is a real answer: the library is absent, or
--- the name is not one this addon declares (root CLAUDE.md's `LibKa0s icons:` line).
function NS.Icon(name)
    if not Media then return nil end
    return Media.Icon(addonName, name)
end

--- The path of one shipped face, or nil when the library is absent.
function NS.MediaFont(name)
    if not Media then return nil end
    return Media.Font(addonName, name)
end

-- At FILE LOAD, not PLAYER_LOGIN: LibSharedMedia is vendored under libs/ and has already run, and
-- the skins' faces (Barlow, Cinzel, Atkinson) resolve through it.
if Media then Media.RegisterLSM(addonName) end
