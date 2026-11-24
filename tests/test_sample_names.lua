-- tests/test_sample_names.lua — every named sample person comes from the library (FB2-ST-01 of
-- Ka0sAddonsCommonTasks docs/2026-11-24-FEEDBACK_BATCH, decision D1; LibKa0s#104; LibKa0s v1.113.0,
-- Sim minor 5, which retired the naming convention's rule 6).
--
-- The owner, 2026-11-24: "adopt the predefined test mode names consistently across all addon's
-- test/sim modes". A test mode, a sim, a preview stand-in or a sample chat line or toast draws its
-- people from LibKa0s-Sim-1.0: Sim.Sample() for the five protagonists and Sim.SampleCrowd() beyond
-- them, seeded where a host needs determinism. No host keeps a list of its own.
--
-- This addon draws no named sample person today: the showroom's "Test mode" and "SIM" strips are
-- specimens of the strip, with no roster behind them, and it has no sim mode. So the rule is held
-- here as a guard: no Sample*/Mock* name literal (the convention's shape, a capitalized word of
-- 2-12 letters starting "Sample" or "Mock", the realms included) in any tracked text file outside
-- tests/, libs/ and the frozen bundles. A name that turns up is one a future change hand-copied
-- instead of asking the library.

local T = _G.SKINTESTER_TEST
local test, assertEqual, assertTrue = T.test, T.assertEqual, T.assertTrue

-- Not scanned: the suites (which may name the library's people to check them), the vendored
-- payload and kit, the media, and the frozen bundles a sync never edits.
local SKIP = { "^tests/", "^libs/", "^media/", "^docs/audits/", "^docs/reviews/", "^docs/automated%-tests/",
               "^docs/perf%-analysis/", "^docs/revendor/", "^docs/superpowers/" }
local TEXT = { lua = true, md = true, toc = true, xml = true, txt = true, pkgmeta = true, luacheckrc = true }
-- English words of the same shape, which name no person.
local ENGLISH = { Samples = true, Sampled = true, Sampler = true, Samplers = true, Sampling = true,
                  Mocks = true, Mocked = true, Mocking = true, Mockup = true, Mockups = true }

local function scanned(path)
    for _, p in ipairs(SKIP) do
        if path:find(p) then return false end
    end
    local ext = path:match("%.([%w]+)$") or path:match("^%.([%w]+)$")
    return ext ~= nil and TEXT[ext] == true
end

--- The sample-name literals in `text`, in order.
local function namesIn(text)
    local out = {}
    for word in text:gmatch("%f[%a]%a+%f[%A]") do
        if (word:match("^Sample%l+$") or word:match("^Mock%l+$")) and #word <= 12 and not ENGLISH[word] then
            out[#out + 1] = word
        end
    end
    return out
end

local function tracked()
    local pipe = assert(io.popen("git ls-files"))
    local out = {}
    for line in pipe:lines() do out[#out + 1] = line end
    pipe:close()
    return out
end

test("sample names: the matcher finds a hand-copied name and realm, and passes English and code names", function()
    -- red under: a matcher that could never fire, so the case below passed on a blind scan.
    assertEqual(table.concat(namesIn('local who = "Samplehunter-Samplerealm" -- Mockflame Stone'), ","),
        "Samplehunter,Samplerealm,Mockflame")
    assertEqual(#namesIn("Samples are mocked; Mocking it; R.SampleButton; aceSamples; Sample; Mock"), 0)
end)

test("sample names: no Sample*/Mock* name literal lives outside tests/, libs/ and the frozen bundles", function()
    -- red under: a hand-kept roster or a copied protagonist in the addon's own code or living docs.
    local files, hits = 0, {}
    for _, path in ipairs(tracked()) do
        if scanned(path) then
            local fh = io.open(path, "rb")
            if fh then
                files = files + 1
                local n = 0
                for line in fh:lines() do
                    n = n + 1
                    for _, name in ipairs(namesIn(line)) do hits[#hits + 1] = ("%s:%d %s"):format(path, n, name) end
                end
                fh:close()
            end
        end
    end
    assertTrue(files >= 40, "the scan read the addon's own files, got " .. files)
    assertEqual(table.concat(hits, "; "), "", "every named sample person comes from LibKa0s-Sim-1.0")
end)
