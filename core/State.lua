local _, NS = ...
-- core/State.lua — session-only runtime state, never in SavedVariables.

NS.State = NS.State or {}

-- The debug flag (debug-logging-§5): off on every login and reset by every /reload. Toggled only by
-- `/st debug on|off` and the console's own toggle, through NS.DebugLog:SetEnabled.
NS.State.debug = false
