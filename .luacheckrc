std = "lua51"
max_line_length = false
codes = true

-- Only vendored and frozen trees are out of scope; the test tree is linted (lint).
exclude_files = { "libs/", "docs/audits/", "docs/reviews/", "docs/revendor/", "_dev/", "tests/_kit/" }

globals = {
  "LibKa0sSkinTesterDB",               -- the SavedVariables write target
  "LibKa0sSkinTesterPerfDB",           -- the perf capture ring (core/PerfSetup.lua, performance-§5)
  "StaticPopupDialogs",                -- the reset confirmation (settings/Schema.lua)
  "BINDING_HEADER_LIBKA0SSKINTESTER",  -- the key bindings' category title (modules/Showroom.lua)
}

read_globals = {
  "_G",
  "LibStub", "hooksecurefunc",
  "CreateFrame", "UIParent", "UISpecialFrames",
  "InCombatLockdown",
  "C_Timer", "C_AddOns",
  "GetTime",
  "debugprofilestop",                  -- the perf bracket's clock (performance-§2)
  "Settings", "StaticPopup_Show",
  "GameTooltip", "YES", "NO",
  "SlashCmdList",
  "wipe", "tinsert",
}

files["tests/"] = {
  globals = {
    "_G.SKINTESTER_TEST",
    "_G.LibKa0sSkinTesterDB",
  },
}

-- Tester:SlashEnabled and Tester:OnSlashCommand are METHODS because AceConsole and the launcher call
-- them as methods (RegisterChatCommand("st", "OnSlashCommand") resolves a method name); neither body
-- reads `self`. Scoped to this file rather than ignored everywhere (lint).
files["settings/Slash.lua"] = {
  ignore = { "212/self" },
}
