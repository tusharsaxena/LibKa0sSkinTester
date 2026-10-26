# Dependencies — Ka0s Skin Tester

What you need installed to build, run, test or release this addon. Commands are for
**WSL2 / Ubuntu** (the collection's development environment). How to *verify* the addon once you are
set up is [`docs/testing.md`](docs/testing.md); this file only covers *what to install*.

Every entry says what needs it and how that is known.

## Runtime (in-game) — what a player needs

- **World of Warcraft (Retail).** Single `## Interface:` line in `LibKa0sSkinTester.toc`, Retail only.
- **Nothing else.** Every library is vendored under `libs/` and committed (library-stack), so no
  separate library addon is installed. `## OptionalDeps:` names the vendored libraries for load
  ordering, not as downloads.
- **EllesmereUI, optional.** Named in `## OptionalDeps:` so it loads first when present; with it, the
  General -> Appearance tab offers EllesmereUI as a skin source (the library's `SkinEUI.lua` checks
  for it). Without it the source is Ka0s skins only.

## Development — the contributor toolchain

| Tool | Version | Needed for | Evidence |
|---|---|---|---|
| `lua5.1` (+ `luac`) | **5.1 exactly** | the headless suite, `lua tests/run.lua` | `tests/_kit/loader.lua` uses `setfenv` |
| `luacheck` | any recent | `luacheck .`, the other half of the green gate | `.luacheckrc` at the repo root |
| `lizard` | any recent | the `complexity` suite of `tests/_kit/run-automated-tests.sh`, which runs it over a sanitized shadow and checks function-count parity, because `lizard` alone is blind in Lua (automated-tests-§3) | `lizard --version` |
| `git` | any recent | vendoring, the vendor gate, the git-based suites | library-stack-§7, `tests/test_vendor_sync.lua` |
| POSIX shell | any | the commands in this file and in `docs/testing.md` | — |

**Lua 5.1 is a requirement, not a preference.** The harness sandboxes each source file with
`setfenv`, which was removed in 5.2.

```sh
# Lua 5.1 and luacheck
sudo apt-get update
sudo apt-get install -y lua5.1 luarocks
sudo luarocks install luacheck

# lizard — via pipx, NOT pip. Ubuntu 24.04 marks its Python EXTERNALLY-MANAGED (PEP 668),
# so `pip install lizard` fails; pipx installs it into its own venv and puts it on PATH.
sudo apt-get install -y pipx
pipx ensurepath          # then open a new shell, or: source ~/.bashrc
pipx install lizard

# verify — each of these must print a version
lua5.1 -v
luacheck --version
lizard --version
git --version
```

## Release / assets

**One entry: Pillow**, and only for **regenerating** the logo (`media/logos/libka0sskintester.logo.png`
is the source; the two `.tga` files are committed renders, made with the layout-§4 recipe by hand).
**None of this group is required to build, run or test the addon.** It is never published, so there
is no packaging step.

## Am I set up correctly?

```sh
lua tests/run.lua                                     # the suite — must be green
~/.claude/dev-copilot/bin/ka0s-bounded luacheck .     # must be 0 warnings / 0 errors
~/.claude/dev-copilot/bin/ka0s-bounded bash tests/_kit/run-automated-tests.sh --suite complexity --no-bundle
```
