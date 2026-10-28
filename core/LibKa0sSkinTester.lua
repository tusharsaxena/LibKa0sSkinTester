local addonName, NS = ...
-- core/LibKa0sSkinTester.lua — AceAddon registration and the addon's lifecycle: initialize, enable,
-- the profile events and the stand-down's two callbacks.
--
-- NS IS the addon object: AceAddon:NewAddon mixes its methods into the namespace table every file
-- already shares, and NS.addon aliases it. The addon exposes no public global (architecture-§1).

local Tester = LibStub("AceAddon-3.0"):NewAddon(NS, addonName,
    "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")
NS.addon = Tester
Tester.VERSION = "0.1.0"

-- AceConsole's embed stamped its own :Print over NS.Print; reclaim the name for the one tagged
-- printer (core/CoreSetup.lua), the same function object NS.Util.print holds (architecture-§2).
NS.Print = NS.Util.print
Tester._print = NS.Print

--- One line per distinct caught error (debug-logging-§8): the console's change gate keyed by the
--- site and the message, so a pcall that raises on every call is one line, re-armed by a Clear.
function NS.DebugErrorOnce(tag, site, err)
    if not NS.State.debug then return end
    NS.DebugOnce(tostring(site) .. "\0" .. NS.SafeToString(err), tag, "%s: %s", site, err)
end

-- ── the profile events ───────────────────────────────────────────────────────────────────────

-- Switching, copying or resetting a profile replaces every stored value at once, and nothing else
-- in the addon would notice: no row was written. So the incoming profile is applied here.
local function reloadProfile(self)
    -- A pending preview belongs to the profile it was picked on. Stood down first, it is put back
    -- with no write and no seen mark, so the incoming skin applied below stays on, and the picker
    -- the last line asks for opens afresh on this profile (settings/Panel.lua).
    if NS.StandDownSkinPicker then NS.StandDownSkinPicker() end
    self:RunMigrations()
    local S = self.Settings
    local H = S and S.Helpers
    if H and H.RefreshAll then H.RefreshAll() end
    if S and S.RefreshProfilesPage then S.RefreshProfilesPage() end
    -- The incoming profile carries its own answers to `enabled` and to the skin. `Set` and
    -- `Reevaluate` fire an edge only when the answer actually changed (slash-commands-§7).
    if NS.Lifecycle then
        NS.Lifecycle:Set(NS.HOLD_DISABLED, not (self.db and self.db.profile and self.db.profile.enabled))
        NS.Lifecycle:Reevaluate()
    end
    if NS.ApplySkinChoice then NS.ApplySkinChoice() end
    if NS.Showroom and NS.Showroom.ApplyWindowSettings then NS.Showroom.ApplyWindowSettings() end
    -- A new or reset profile has not seen the skin picker (settings/Panel.lua).
    if NS.MaybeShowSkinPicker then NS.MaybeShowSkinPicker() end
end

-- A profile switch rewrites no row, so its one line is written here (debug-logging-§10). A method,
-- so a test can call it with AceDB's real arguments (event, db, newProfileKey).
function Tester:OnProfileChanged(_, _, key)
    NS.Debug("Profile", "switched to '%s'", tostring(key or self.db:GetCurrentProfile()))
    reloadProfile(self)
end

-- A copy lands in the ACTIVE profile; AceDB fires OnProfileCopied(event, db, sourceProfileKey).
function Tester:OnProfileCopied(_, _, source)
    NS.Debug("Set", "copied profile '%s' \226\134\146 '%s'", source, self.db:GetCurrentProfile())
    reloadProfile(self)
end

-- ── initialize and enable ────────────────────────────────────────────────────────────────────

function Tester:OnInitialize()
    -- settings/Schema.lua loads after this file but before OnInitialize fires (ADDON_LOADED runs
    -- after every TOC line), so the defaults builder exists here.
    local defaults = self.Settings and self.Settings.BuildDefaults
        and self.Settings.BuildDefaults() or { profile = {} }
    self.db = LibStub("AceDB-3.0"):New("LibKa0sSkinTesterDB", defaults, true)

    -- Before anything reads the profile (savedvariables-§1). Idempotent.
    self:RunMigrations()

    if self.db.RegisterCallback then
        -- A reset is logged here, once (debug-logging-§10): AceDB replacing the whole profile is not
        -- a write through the seam. N is the count Helpers.RestoreAllDefaults hands over.
        local function logReset()
            local S = self.Settings
            local name = self.db:GetCurrentProfile()
            local n = S and S.ConsumeResetCount and S.ConsumeResetCount()
            if n then
                NS.Debug("Set", "reset profile '%s' to defaults (%d rows)", name, n)
            else
                NS.Debug("Set", "reset profile '%s' to defaults", name)
            end
        end
        self.db.RegisterCallback(self, "OnProfileChanged", function(...) self:OnProfileChanged(...) end)
        self.db.RegisterCallback(self, "OnProfileCopied",  function(...) self:OnProfileCopied(...) end)
        self.db.RegisterCallback(self, "OnProfileReset",   function()
            logReset()
            reloadProfile(self)
        end)
    end

    -- The stored skin, now that the profile exists (core/SkinSetup.lua registered the owner at file
    -- load, before AceDB, and it answered Ka0s Default then).
    if NS.ApplySkinChoice then NS.ApplySkinChoice() end

    self:RegisterChatCommand("st",         "OnSlashCommand")
    self:RegisterChatCommand("skintester", "OnSlashCommand")
end

function Tester:OnEnable()
    -- The settings category registers at login so it is in Settings -> AddOns without a `/st config`
    -- first. In combat the library parks it and lands it at combat end (options-ui-§9).
    if self.Settings and self.Settings.Register then self.Settings.Register() end

    -- The launcher, registered here because LibDBIcon keeps the button's position in
    -- db.global.minimap, which OnInitialize created. Idempotent in the library.
    if NS.Launcher then NS.Launcher:Register() end

    -- `/st` is two letters, and another addon may hold it. Checked here, once every addon has
    -- registered: a foreign `/st` keeps it, and this addon answers to `/skintester` alone.
    if NS.CheckSlashCollision then NS.CheckSlashCollision() end

    -- THE LATCH, from the stored path (slash-commands-§7). Last, because everything above has to be
    -- up before the latch can take it back down.
    if NS.Lifecycle then
        NS.Lifecycle:Set(NS.HOLD_DISABLED, not (self.db and self.db.profile and self.db.profile.enabled))
    end

    -- The first-run skin picker, once the stored skin is on (OnInitialize applied it) and the latch
    -- has its answer: it skips a disabled addon and a login in combat (settings/Panel.lua).
    if NS.MaybeShowSkinPicker then NS.MaybeShowSkinPicker() end
end

-- ── the stand-down (slash-commands-§7) ───────────────────────────────────────────────────────
--
-- DISABLED MEANS THE ADDON IS NOT RUNNING. The tester registers no game event and runs no timer, so
-- going down is the showroom closing and refusing to open (modules/Showroom.lua), and the first-run
-- skin picker taken down without marking the profile seen (settings/Panel.lua), and nothing else.
-- What survives is SETUP: the chat command and dispatcher, the settings category, the AceDB handle
-- and its profile callbacks, the launcher and the skin owner. A disabled addon must stay reachable
-- by the player who wants to turn it back on. The edges are logged by the library.

function NS.StandDown()
    if NS.Showroom and NS.Showroom.StandDown then NS.Showroom.StandDown() end
    if NS.StandDownSkinPicker then NS.StandDownSkinPicker() end
end

-- Rebuilds from CURRENT state, never from a snapshot taken on the way down.
function NS.StandUp()
    if NS.Showroom and NS.Showroom.StandUp then NS.Showroom.StandUp() end
end

--- The one-line [Init] summary (debug-logging-§5): name, version, schema, profile, then the state a
--- debug session opens with. Called by the DebugLog seam when logging is turned on.
function Tester:InitSummary()
    local db = self.db
    local schema  = db and db.global and db.global.schemaVersion
    local profile = (db and db.GetCurrentProfile and db:GetCurrentProfile()) or "?"
    local pr = (db and db.profile) or {}
    local source, skin = "ka0s", "ka0s"
    if NS.SkinChoice then source, skin = NS.SkinChoice() end
    local line = string.format("%s v%s, schema v%s, profile '%s' (enabled=%s, skin=%s:%s)",
        addonName, tostring(self.VERSION), tostring(schema), tostring(profile),
        tostring(pr.enabled), tostring(source), tostring(skin))
    local rejected = NS.RejectedEvents
    if rejected and #rejected > 0 then
        line = line .. ", rejected events: " .. table.concat(rejected, ", ")
    end
    return line
end
