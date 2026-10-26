local _, NS = ...
-- modules/Diagnostics.lua — the addon's sections of `/st diagnostics` (debug-logging-§14).
--
-- The library writes everything around these: both markers, its half of the identity header, one
-- pcall per section, the cap and the `truncated` line. This file writes sections only (a buffer,
-- pcall wrapper or marker of its own would be anti-pattern #90).
--
-- READ, NEVER ACT: no hold taken, no window built, no skin changed. The report runs while the addon
-- is stood down and in combat, and leaves both exactly as it found them. `out:add` formats `%s`
-- only, so every argument is a raw value.
--
-- Conventional TOC slot: the DebugLog descriptor reads NS.Diagnostics.Sections at RUN time.

NS.Diagnostics = NS.Diagnostics or {}

local TAG = "Diag"

-- Printed whatever their value: the switches a "the showroom shows nothing" report turns on first.
local ALWAYS = { "enabled", "skin.source", "skin.skin" }

local function stoodDown() return NS.IsStoodDown and NS.IsStoodDown() or false end

local function identity(out)
    local db = NS.addon.db
    local LC = NS.Lifecycle
    out:add(TAG, "schema stored=%s code=%s", db and db.global and db.global.schemaVersion, NS.SCHEMA_VERSION)
    out:add(TAG, "profile=%s", db and db.GetCurrentProfile and db:GetCurrentProfile())
    out:add(TAG, "enabled=%s stoodDown=%s", db and db.profile and db.profile.enabled, stoodDown())
    out:joined(TAG, "holds", LC and LC.Holds and LC:Holds() or {})
end

local function settings(out)
    local S = NS.SchemaRuntime
    out:nonDefaults(NS.addon.Settings and NS.addon.Settings.Schema,
        function(row) return S.Get(row.path) end, nil, nil, { always = ALWAYS })
end

-- The skin this addon wears, stored against applied: they differ while a reload is pending, or
-- when the stored key named a skin the library no longer registers.
local function skin(out)
    local lib = LibStub and LibStub("LibKa0s-Skin-1.0", true)
    out:add(TAG, "skin engine=%s", lib and lib.MINOR or "absent")
    if not lib then return end
    local storedSource, storedSkin = NS.SkinChoice()
    local appliedSource, appliedSkin = lib:GetChoice("LibKa0sSkinTester")
    out:add(TAG, "stored=%s:%s applied=%s:%s", storedSource, storedSkin, appliedSource, appliedSkin)
    out:add(TAG, "owner=%s pendingReload=%s", lib:IsOwner("LibKa0sSkinTester"),
        lib:PendingReload("LibKa0sSkinTester"))
    local keys = {}
    for _, def in ipairs(lib:Skins()) do keys[#keys + 1] = def.key end
    out:joined(TAG, "skins", keys)
end

-- What the showroom has built: a read of its own counters, never a build.
local function showroom(out)
    local snap = NS.Showroom and NS.Showroom.Snapshot and NS.Showroom.Snapshot()
    if not snap then
        out:add(TAG, "showroom: not loaded")
        return
    end
    out:add(TAG, "showroom: built=%s shown=%s sections=%s primitives=%s",
        snap.built, snap.shown, snap.sections, snap.primitives)
end

local function rejected(out)
    out:list(TAG, "rejected events", NS.RejectedEvents or {})
end

--- The sections, in report order.
function NS.Diagnostics.Sections()
    return {
        { "identity", identity },
        { "settings", settings },
        { "skin",     skin },
        { "showroom", showroom },
        { "rejected", rejected },
    }
end
