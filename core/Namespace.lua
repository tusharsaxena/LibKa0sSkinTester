local _, NS = ...
-- core/Namespace.lua — the constants every later file reads at load: the chat tag, the brand and
-- the one sentence that explains a missing library.

-- The mandatory cyan chat tag (slash-commands-§4). The printer (core/CoreSetup.lua) reads it at
-- call time, so a later change to it is never frozen in.
NS.PREFIX = "|cff00FFFF[ST]|r"

-- The brand (launcher-§1): the launcher's label, the key bindings' category title and the debug
-- console's title. Plain text, never the TOC title, and never translated.
NS.BRAND_NAME = "Ka0s Skin Tester"

-- The one cause clause every degraded seam appends its own "so <what> is unavailable" to, so a
-- broken install explains WHY the same way everywhere.
NS.LIBKA0S_MISSING = "The LibKa0s library is missing from this installation of " .. NS.BRAND_NAME ..
    " (expected in libs/LibKa0s)"
