-- tests/test_vendor_sync.lua — the vendored-payload gate. The whole implementation lives in
-- `tests/_kit/vendor_sync.lua`, inside the payload it checks; this file is the call.
--
-- WHAT IT CHECKS: that `libs/LibKa0s/` and `tests/_kit/` in this repo are exactly what the LibKa0s
-- repo published at the tag THIS REPO'S `CLAUDE.md` says it bundles.
--
-- THE PROVENANCE LINE IS AN INPUT, NOT A CONSTANT. It is read out of the root CLAUDE.md rather
-- than hardcoded: a provenance line and a vendored payload that disagree is precisely the drift this
-- gate exists to catch, so the claim has to be the thing under test. Bump the line and the bytes
-- in the same commit.
--
-- ONE NORMALIZATION, AND ONLY ONE: `git show` hands back the stored blob, which is LF, while the
-- working tree is CRLF because `.gitattributes` pins `* text=auto eol=crlf`. CR is stripped from
-- the working-tree side so the file is compared to the blob it round-trips to. Nothing else is
-- normalized — a real fork in content still fails. (Carried in verbatim from
-- AbsorbTracker/tests/test_vendor_sync.lua, which is where the paragraph was written; the strip
-- itself now lives in the kit module.)
--
-- A MISSING SIBLING CHECKOUT IS A SKIP, NOT A PASS: when `../LibKa0s` is not there the cases
-- report SKIP with the reason naming the absent checkout, and the run's exit code stays 0.

-- AN UNRELEASED RE-VENDOR NAMES ITS BRANCH. Between a library change and the tag that ships it, the
-- provenance line reads `vX.Y.Z (unreleased, branch <name>) (MIT).`; no tag of that name exists yet,
-- so the gate compares the payload to the tip of the named branch in the sibling checkout instead,
-- byte for byte, with the same declaration rules. The comparison is not loosened: the branch moving
-- turns this red exactly as a moved tag would. Re-vendoring the tag rolls the line back to the
-- plain form and the default pattern.

local VendorSync = dofile("tests/_kit/vendor_sync.lua")

local BRANCH_PATTERN = "[Bb]undles %[LibKa0s%]%b() v[%d%.]+ %(unreleased, branch ([%w%-%./_]+)%)"

local function provenanceOpts()
    local f = io.open("CLAUDE.md", "rb")
    local doc = f and f:read("*a") or ""
    if f then f:close() end
    if doc:match(BRANCH_PATTERN) then return { provenancePattern = BRANCH_PATTERN } end
    return {}
end

VendorSync.register(_G.SKINTESTER_TEST, provenanceOpts())
