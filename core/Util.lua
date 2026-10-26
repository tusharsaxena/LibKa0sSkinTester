local _, NS = ...
-- core/Util.lua — NS.Windows: the showroom window's position, saved and restored.
--
-- The position is state no control sets and no schema row addresses (only a drag decides it), so it
-- is stored at db.global.windows.<name> and written by NS.Windows.Save alone, called from the
-- window's drag stop (docs/ARCHITECTURE.md, Settings Schema). Global rather than per profile: a
-- window's place on the screen belongs to the installation.

NS.Windows = NS.Windows or {}

--- The frame's first anchor as a plain table, or nil.
function NS.Windows.PointOf(frame)
    if not (frame and frame.GetPoint) then return nil end
    local point, _, relPoint, x, y = frame:GetPoint(1)
    if type(point) ~= "string" then return nil end
    return { point = point, relPoint = relPoint or point, x = x or 0, y = y or 0 }
end

--- Saves `frame`'s anchor under `name`.
function NS.Windows.Save(name, frame)
    local db = NS.addon and NS.addon.db
    if not (db and db.global) then return end
    local pt = NS.Windows.PointOf(frame)
    if not pt then return end
    db.global.windows = db.global.windows or {}
    db.global.windows[name] = pt
end

--- Puts `frame` back where `name` was saved; false when nothing was.
function NS.Windows.Restore(name, frame)
    if not (frame and frame.SetPoint and frame.ClearAllPoints) then return false end
    local db = NS.addon and NS.addon.db
    local saved = db and db.global and db.global.windows and db.global.windows[name]
    if not saved then return false end
    frame:ClearAllPoints()
    frame:SetPoint(saved.point, UIParent, saved.relPoint, saved.x, saved.y)
    return true
end

--- Forgets `name`'s saved anchor (Reset position).
function NS.Windows.Forget(name)
    local db = NS.addon and NS.addon.db
    if db and db.global and db.global.windows then db.global.windows[name] = nil end
end
