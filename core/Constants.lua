local _, NS = ...
-- core/Constants.lua — the monospace face and the layers table.

NS.Constants = NS.Constants or {}

-- The debug console's monospace face (debug-logging-§2), shipped inside the LibKa0s payload. The
-- fallback is a REAL client font: SetFont takes a path to a missing file, fails to load it, and the
-- text simply does not draw.
NS.Constants.FONT_MONO_NAME = "JetBrains Mono"
NS.Constants.FONT_MONO = NS.MediaFont and NS.MediaFont(NS.Constants.FONT_MONO_NAME)
    or _G.STANDARD_TEXT_FONT

-- The layers table (frame-layering-§5). The one strata and level table: every SetFrameStrata and
-- SetFrameLevel in this addon reads it, and docs/ARCHITECTURE.md points here rather than copying it.
-- This addon's stack, bottom to top (frame-layering-§1 tiers):
--   T3 window   the skin showroom   MEDIUM, toplevel (frame-layering-§4)
--   T4 modal    the showroom's sample confirm popup   DIALOG, over the window it belongs to
-- Within a window, a sample's own regions sit on its frame; a sample's overlay (a cover, a strip)
-- is one level above the sample it covers (LEVEL.OVERLAY).
-- Library- and Blizzard-owned tiers this addon relies on (frame-layering-§6): debug console DIALOG,
-- toplevel; copy window FULLSCREEN; menus FULLSCREEN_DIALOG; the window grip at +10.
NS.Constants.LAYERS = {
    STRATA = { WINDOW = "MEDIUM", MODAL = "DIALOG" },
    LEVEL  = { OVERLAY = 4 },
}
