# Testing — Ka0s Skin Tester

How to verify the addon out of the game. What to install first is the root
[`DEPENDENCIES.md`](../DEPENDENCIES.md).

## The green gate

Before every commit, from the repo root:

```sh
lua tests/run.lua                                   # every suite green
~/.claude/dev-copilot/bin/ka0s-bounded luacheck .   # 0 warnings / 0 errors
```

The vendored kit bounds the suite itself on load (testing-§15); `luacheck` loads no kit, so it runs
through the bounded runner. No authored `.lua` file may pass 1500 lines (layout-§1;
`tests/_kit/test_layout_cap.lua` enforces it).

### The harness is the shared kit

`tests/_kit/` is LibKa0s's `testkit/`, vendored whole and never edited. `tests/run.lua` holds the
suite list and the kit's wiring; `tests/loader.lua` builds one isolated addon per case from the TOC
plus every file of `libs/LibKa0s/LibKa0s.xml` in XML order; `tests/wow_mock.lua` extends the kit's
base mock. The kit's own suites (`test_eol`, `test_prose`, `test_layout_cap`,
`test_diagnostics_contract`, `test_lizard_sighted`) are declared by their directory.

What the suites test is this addon's wiring: each descriptor, each degradation stub (by loading the
addon with the library absent, never by hand-stubbing), the stand-down, the bindings and the layers.
The library's internals are tested in the LibKa0s repo and not here.

## The case inventory (testing-§5)

`docs/test-cases.md` is generated, never written by hand:

```sh
lua tests/run.lua --list > docs/test-cases.md
```

Its Total is the authoritative pass count. Regenerate it, and the README's `[tests]` badge, in the
same change as any case added, removed or renamed.

## The vendor gate

`tests/test_vendor_sync.lua` delegates to the kit's `vendor_sync.lua`: `libs/LibKa0s/` and
`tests/_kit/` must match the LibKa0s tag that root `CLAUDE.md`'s provenance line names, and
`libs/LibKa0s/media/icons/` must hold exactly the icons its `LibKa0s icons:` line declares.

## Lint scope

Everything authored is linted, `tests/` included; only `libs/`, `tests/_kit/` and the frozen record
folders are excluded. A suppression is scoped to one file, with its reason beside it, never a
top-level `ignore` (`tests/test_lintconfig.lua`).

## Automated test records

The consolidated four-suite run: [`automated-tests/README.md`](./automated-tests/README.md).

## In-game smoke tests

The checks only the client can make: [`smoke-tests.md`](./smoke-tests.md).
