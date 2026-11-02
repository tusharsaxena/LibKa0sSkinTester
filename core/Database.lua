local _, NS = ...
-- core/Database.lua — the schemaVersion migration runner (savedvariables-§1).
--
-- AceDB itself is built in core/LibKa0sSkinTester.lua's OnInitialize from the defaults
-- settings/Schema.lua derives. The stored stamp's default is 0, never the current version: AceDB
-- strips a value equal to its default at logout, and backfills it onto an account that never ran a
-- migration.

NS.SCHEMA_VERSION = 2   -- the runner's target: the highest step

-- LibKa0s v1.85.0 deleted Ka0s Friz Quadrata TT (R3-L7) and WoW Default draws Ka0s Ubuntu in its place
-- (R3-L6). A stored font pick naming the deleted face moves to its successor (R3-FRIZ).
local RETIRED_FONTS = { ["Ka0s Friz Quadrata TT"] = "Ka0s Ubuntu" }

--- Moves every string naming a retired face, at any depth of `t`, to its successor.
local function retireFonts(t)
    for k, v in pairs(t) do
        if type(v) == "table" then
            retireFonts(v)
        elseif RETIRED_FONTS[v] then
            t[k] = RETIRED_FONTS[v]
        end
    end
end
NS.RetireFonts = retireFonts   -- test seam

-- One step per version. Each is idempotent against a fresh default profile.
NS.MIGRATIONS = {
    [1] = function(_db) end,  -- 0 -> 1: the stamp itself; nothing to reshape
    -- 1 -> 2 (R3-FRIZ): every stored profile, active or not, the sample font picker's pick included.
    [2] = function(db)
        for _, profile in pairs(db.sv and db.sv.profiles or {}) do
            if type(profile) == "table" then retireFonts(profile) end
        end
    end,
}

--- Runs every step past the stored stamp, advancing the stamp only past a step that returned.
function NS:RunMigrations()
    local g = self.db and self.db.global
    if not g then return end
    local from = g.schemaVersion or 0
    local v = from
    while v < NS.SCHEMA_VERSION do
        local step = NS.MIGRATIONS[v + 1]
        if step then step(self.db) end
        v = v + 1
        g.schemaVersion = v
    end
    -- At enable rather than now: the debug flag is off at login, so a plain line would be dropped.
    if from ~= g.schemaVersion and NS.DebugAtEnable then
        NS.DebugAtEnable("Migrate", "v%s -> v%s", from, g.schemaVersion)
    end
end
