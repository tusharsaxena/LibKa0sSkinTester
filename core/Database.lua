local _, NS = ...
-- core/Database.lua — the schemaVersion migration runner (savedvariables-§1).
--
-- AceDB itself is built in core/LibKa0sSkinTester.lua's OnInitialize from the defaults
-- settings/Schema.lua derives. The stored stamp's default is 0, never the current version: AceDB
-- strips a value equal to its default at logout, and backfills it onto an account that never ran a
-- migration.

NS.SCHEMA_VERSION = 1   -- the runner's target: the highest step

-- One step per version. Each is idempotent against a fresh default profile.
NS.MIGRATIONS = {
    [1] = function(_db) end,  -- 0 -> 1: the stamp itself; nothing to reshape
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
