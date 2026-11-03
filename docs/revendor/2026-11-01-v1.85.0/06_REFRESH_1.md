# Refresh 1 of v1.85.0

Item `FS-ST-GATE` of the full skinning run. The tag `v1.85.0` moved before it was pushed:
`git -C ../LibKa0s ls-remote --tags origin v1.85.0` prints nothing, so this is a refresh and not a new
re-vendor. No new bundle folder, and line 1 of `01_DELTA.md` stands.

- Old commit: `9776130` (the one `01_DELTA.md` names).
- New commit: `git -C ../LibKa0s rev-parse v1.85.0^{commit}`, tag object `36506d6`.
- Why it moved: the owner's rulings of 2026-11-01 and the gaps the flips found (`FS-FIX`), and the gate
  (`FS-GATE`).

## What arrived

Ten files of `libs/LibKa0s/` and kit revision 49 -> 50, which adds `skin_values.lua`, `skin_switch.lua`,
`test_skin_values.lua` and `test_skin_switch.lua`. Per-file minors: the tag's `CHANGELOG.md` v1.85.0 block.

- Class A, on the copy: every skin's own `bar.bg`, `bar.border`, `icon.border`, `glow.color` and
  `cover.dim`, a real `bar.borderStyle` under four skins, and `W.ContextMenu`.
- Blockers, fixed in this commit: the facade gains `BarBorder`, which answers its stored three, and
  `HoverArt`; both kit suites declared by the pair; the coverage suite's two new primitives shown, as
  a Values line and a Library widgets sample; the pin of one font object per string moves to one per
  look.
- This addon has no Widgets stub, so `ContextMenu` owes nothing. It has no companion, no flip and no
  `Skin.FollowOnce` call, so no profile repair is owed. It calls `S.Mark` only on its own cell
  textures, never on a pooled AceGUI widget.

## The kit's gates

`test_skin_values` found eight values. Fixed: the slider sample's three typed tints now read
`slider.track`, `slider.fill` and `slider.thumb`; the three copies of the degraded bar path are one
`NS.Constants.FALLBACK_BAR_TEXTURE`, which the kit's stock-path category takes. Rows, both with a
cause id: `sel:SetColorTexture(1, 1, 1, 1)`, the white base `S.NavItem` tints (A5), and the client's
hover art `list.hoverArt` tints (D9).

`test_skin_switch` declares the window's chrome and every captioned sample through
`tests/skin_surfaces.lua`. Left out, each with its reason there: the four AceGUI samples on the kit's
stub widget, FadeNineSlice, and the per-skin `hud.font` lines.

## Step 5 host

Strip only, as before. `Widgets.lua` moved in the menu, which the strip does not reach.
