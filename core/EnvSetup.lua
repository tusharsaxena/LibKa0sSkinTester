local addonName, NS = ...
-- core/EnvSetup.lua — NS.Meta and NS.Version from LibKa0s-Env-1.0: TOC metadata and the version.

local Env = LibStub and LibStub("LibKa0s-Env-1.0", true)

--- One TOC metadata field of this addon, or nil.
function NS.Meta(field)
    if Env then return Env.GetAddOnMetadata(addonName, field) end
    if C_AddOns and C_AddOns.GetAddOnMetadata then
        return C_AddOns.GetAddOnMetadata(addonName, field)
    end
    return nil
end

--- The addon version: the TOC's, else the code constant, else "?". The fallback stays visible at
--- the call site, as an argument.
function NS.Version()
    local fallback = NS.addon and NS.addon.VERSION
    if Env then return Env.Version(addonName, fallback) or "?" end
    return NS.Meta("Version") or fallback or "?"
end
