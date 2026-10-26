# Common tasks

## Re-vendor LibKa0s after a skin fix

Run `/dev-copilot:wow-revendor-libka0s` in this repo. It copies both payloads from the library's tag,
prunes `media/icons/` to the `LibKa0s icons:` line in `CLAUDE.md`, and records the bundle under
`docs/revendor/`. Then run the gate.

## Add a setting

Add one row to `settings/Schema.lua` with its default in `defaults/Profile.lua`, give its label and
tooltip `enUS` keys, and run the gate: the panel, the CLI and the defaults all follow the row.

## Add a slash verb

Add one positional triple to `COMMANDS` in `settings/Slash.lua`, give its description an `enUS` key,
and add it to [`slash-dispatch.md`](./slash-dispatch.md). Regenerate `docs/test-cases.md` if the
suite changed.

## Show a new primitive

When LibKa0s adds a name to `lib.VOCAB`, `tests/test_showroom_coverage.lua` goes red naming it. Add a
sample to the section it belongs in (`modules/Showroom*.lua`): a `g:Add(w, h, caption)` cell from
`NS.Showroom.Grid`, painted through the build's `paint`, never the facade directly. A getter goes in
`modules/ShowroomValues.lua` and into `NS.Values.shown`.

## Check a skin defect

Open the showroom on the skin in question, find the sample by its caption, and note the primitive it
names: the fix belongs in LibKa0s (`SkinDefs.lua` for a token, `SkinPaint*.lua` for a primitive),
never here.
