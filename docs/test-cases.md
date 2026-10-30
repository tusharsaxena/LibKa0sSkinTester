# Test Cases

The full inventory of every headless test case in this repo, grouped by the suite file it
lives in. The `## Totals` table below counts the cases that run: its **Total** is the
authoritative pass count, and the README test badge and any count quoted in the docs must equal
it. A declared skip is listed by name in its group and counted on the `Skipped` row, never in
Total.

**Generated — do not hand-edit.** Regenerate with `lua tests/run.lua --list > docs/test-cases.md`.

### test_harness.lua (11)

- harness: the runner is on the shared kit and reports its revision
- harness: the addon's load list is DERIVED from the TOC, in TOC order (testing-§9)
- harness: every derived addon path exists on disk
- harness: no libs/ path leaked into the derived addon list
- harness: the explicit LibKa0s list matches LibKa0s.xml, in XML order (anti-patterns #48)
- harness: every LibKa0s file the runner loads exists on disk
- harness: the libraries load BEFORE the addon's own files
- harness: the addon is a named AceAddon the kit can look up
- harness: a registration naming a method the addon lacks is refused
- harness: the addon's AceTimer handles are the kit's, on the kit's queue
- events: the [Init] summary carries no rejected clause when every name registered

### test_libka0s.lua (55)

- libka0s: every vendored major registers under LibStub
- libka0s: MODULES names every file of every major, at a positive integer minor
- core: the published seams ARE the library's, not a lookalike
- core: the close button is the library's, told which addon folder is asking
- core: ApplySkin stays a bare bind, so its optional override survives
- core: the printer emits <prefix><space><body> as one line
- core: the prefix is read at CALL time, not captured at load
- core: the sink is the Lua global print, so the harness can see chat output
- debuglog: the console is the library's instance, and the sink is bound bare
- debuglog: the library is told the FOLDER name, not just the frame name
- debuglog: the descriptor keeps the frame globals the old console used
- debuglog: the composed window title is unchanged
- debuglog: the flag stays the addon's — the library never keeps a copy
- debuglog: the [Init] summary is the addon's, reached through the descriptor
- debuglog: the console's user-visible strings resolve to prose, not to their own keys
- debuglog: the gated sink survives a format its arguments cannot satisfy (WhatGroup WG-22)
- options: Settings.Helpers IS the library instance, decorated in place
- options: the library is told the FOLDER name, and the help-mark art is declared if drawn
- options: the host's data seams survived the move onto the instance
- options: the host's RestoreAllDefaults deliberately overrides the library's
- options: a panel write takes the addon's single write seam
- options: no layout constant is restated in this addon's own source
- options: the panel body still builds on the NEXT frame, not inside OnShow
- slash: the help header is the library's, with this addon's alias sentence
- slash: a help row is the one command-row formatter, indented two spaces
- slash: the landing page renders the SAME rows, un-indented (convergence #2)
- slash: the landing page draws those rows and nothing of its own
- slash: `list` renders through the shared key/value formatter
- slash: a number row still renders through its schema `fmt`
- slash: `toggle` survived the adoption, through the descriptor's parse adapter
- slash: the descriptor's L overrides exactly one string and nothing else
- slash: every user-visible CLI string resolves to prose, not to its own key
- degraded: the addon loads with LibKa0s absent
- degraded: the cause clause is published on BOTH paths
- degraded: the printer announces the absence exactly ONCE, then prints normally
- degraded: the fallback printer still degrades a secret in place
- degraded: every DebugLog member the addon calls still answers
- degraded: the console stub copies NO library formatter
- degraded: every HAND-WRITTEN schema row survives the options library's absence (options-ui-§1)
- degraded: the STORED profile is the same shape with the library absent
- degraded: `/st disable` and `/st enable` print the library-absent line and write nothing (options-ui-§1, WhatGroup#22)
- degraded: `/st profile`, CliProfile and ProfileSwitch print the library-absent line and switch nothing (Slash 17)
- degraded: Reset all settings still resets the profile (options-ui-§1)
- degraded: the settings stub carries no widget maker and no layout constant
- degraded: the settings panel explains itself once at load and once per config
- degraded: a bare /st runs `config`, as the library's dispatcher does
- degraded: `/st debug on` still moves the flag and explains the missing window ONCE
- libka0s: no seam re-spells the refusal line (slash-commands-§7)
- degraded: the Slash stub's DisabledLine uses the library's DISABLED_LINE_FORMAT bytes
- libka0s: the Master controls hook is keyed off the library's constant, not a copy of it
- libka0s: the L-trap matcher flags the table and the `or` spelling, not the `and` one
- libka0s: no seam file hands a descriptor this addon's locale table (the L trap)
- libka0s: Core has no STRINGS and reads no descriptor L (tripwire)
- libka0s: Options reads no descriptor L (tripwire)
- locale: every key enUS.lua defines has a reader

### test_surface_parity.lua (8)

- parity: the Core seam's whole namespace surface survives the library's absence
- parity: the DebugLog stub carries the whole live surface
- parity: the Slash stub carries the whole live surface
- parity: the Options helpers stub carries the whole live surface
- parity: the Schema host stub's instance carries the whole live instance surface
- parity: the Schema host stub carries the library's own members
- parity: the Launcher stub carries the whole live surface
- parity: the Lifecycle stub carries the whole live surface

### test_mediasetup.lua (13)

- mediasetup: NS.Icon answers the vendored path, EXTENSIONLESS
- mediasetup: an icon the library does not ship answers nil
- mediasetup: NS.MediaFont answers the vendored face, and only for a face it ships
- mediasetup: the face this addon names is the face the library registers
- mediasetup: the LSM registration is the library's, made at file load
- mediasetup: every icon this addon draws is one the library ships
- mediasetup: every icon this addon draws has a file in the vendored copy
- mediasetup: every declared icon has a file in the vendored copy, and nothing undeclared ships
- mediasetup: the declaration names every icon the library draws for this addon
- mediasetup: this addon ships no private copy of the shared art (anti-patterns #63)
- mediasetup: with no library there is no art and no face, and that is not an error
- mediasetup: a degraded install still gets a REAL font, never nil and never a dead path
- mediasetup: Ka0s Default's faces are Ka0s Prototype, and the vendored copy ships them

### test_envsetup.lua (9)

- envsetup: NS.Meta reads this addon's TOC
- envsetup: NS.Meta asks about this addon's FOLDER, not its title or its frame prefix
- envsetup: NS.Meta degrades to nil when the client exposes no manifest reader
- envsetup: NS.Version prefers the TOC over this addon's own constant
- envsetup: NS.Version falls back to this addon's own constant
- envsetup degraded: an install with no LibKa0s still reads its own TOC
- envsetup degraded: Meta never reads the bare GetAddOnMetadata global
- envsetup: no file inlines its own C_AddOns ladder any more
- envsetup: the library-absent ladder has two rungs, Env then C_AddOns

### test_util.lua (26)

- util: SafeToString handles nil / booleans / strings / numbers
- util: SafeToString yields <secret> for a value that raises in concat
- util: IsConcatSafe true for scalars, false for a raising value
- util: NS.Print prepends the [ST] prefix and stringifies each arg
- util: NS.Print degrades a secret-like arg in place, never raising
- util: Windows.Save/Restore round-trips a frame point through db.global (WhatGroup WG-26)
- util: Windows.Restore is a no-op when nothing is saved (WhatGroup WG-26)
- util: SafeToString renders a negative and a fractional number
- util: SafeToString degrades a function and a coroutine
- util: IsConcatSafe reports a boolean as unsafe
- util: IsConcatSafe reports nil as safe (concat of an empty table)
- util: NS.Print with no arguments still prints the prefix
- util: NS.Print joins several arguments with single spaces
- util: NS.Print stringifies nil and boolean arguments in place
- util: PointOf reads a frame's primary anchor
- util: PointOf defaults relPoint to the point and offsets to zero
- util: PointOf returns nil for a frame with no anchor yet
- util: PointOf returns nil for nil or a non-frame
- util: Save is a no-op before the db is ready
- util: Save skips a frame that has no anchor
- util: Save overwrites a previously stored point
- util: windows are stored under independent names
- util: Restore returns false for a frame that cannot be anchored
- util: Restore is a no-op before the db is ready
- util: Restore clears existing anchors before applying the saved one
- util: a Save/Restore round trip survives through the real frame stub

### test_database.lua (11)

- database: fresh DB lands at schemaVersion 1
- database: RunMigrations is idempotent
- database: RunMigrations re-seeds a missing schemaVersion
- database: defaults declare global.schemaVersion 0 (savedvariables-§1)
- database: the stamp survives AceDB's logout strip, so the first real migration runs
- database: a raising step leaves the stamp at the last completed version
- database: RunMigrations before the db exists is a no-op
- database: an older saved DB is stepped up to the current version
- database: a version move is logged, a no-op migration is silent (debug-logging-§8)
- database: migrations run before any profile read (OnInitialize order)
- database: the profile is untouched by a migration pass

### test_settings.lua (53)

- settings: BuildDefaults threads profile + global defaults
- settings: defaults source from NS.C (defaults/Profile.lua, WhatGroup WG-24)
- settings: BuildDefaults seeds an empty global.windows table (WhatGroup WG-26)
- settings: debug is not a persisted schema row (WhatGroup WG-12)
- settings: ValidateSchema reports zero errors
- settings: Get/Set round-trips through db.profile
- settings: RestoreAllDefaults resets a changed value
- settings: RestoreAllDefaults prunes orphaned profile keys (F1)
- settings: RestoreAllDefaults deep-copies table defaults (F2)
- settings: RestoreAllDefaults skips per-row onChange (F3)
- settings: every schema row declares the fields the panel and CLI need
- settings: schema paths are unique
- settings: every schema row carries a tooltip
- settings: every number row declares min, max and step
- settings: ValidateSchema counts each defect on a broken row
- settings: ValidateSchema reports a non-table row
- settings: a broken row does not stop the panel registering
- settings: BuildDefaults nests dotted paths into real subtables
- settings: BuildDefaults covers every schema row
- settings: BuildDefaults deep-copies table defaults
- settings: BuildDefaults is a fresh table each call
- settings: Get returns nil before the db exists
- settings: Set before the db exists is a harmless no-op
- settings: a write creates the intermediate tables it walks through
- settings: Get on an unknown deep path returns nil and creates no table
- settings: Resolve replaces a non-table intermediate
- settings: there is no RawSet; a write to `enabled` always runs its onChange
- settings: Set takes no skipOnChange option
- settings: a throwing onChange propagates, after the value landed
- settings: Set on a path with no schema row is refused and stores nothing
- settings: FindSchema matches on the exact path
- settings: RestoreAllDefaults restores every schema row
- settings: RestoreAllDefaults leaves db.global untouched
- settings: RefreshAll runs every refresher on the open page, in registration order
- settings: a throwing refresher does not abort the sweep
- settings: a hidden page is not refreshed — it is flagged dirty (options-ui-§11)
- settings: every Set re-syncs the widgets once; there is no skipRefresh
- settings: RestoreAllDefaults refreshes once, plus once per session-only row
- settings: EnsureResetPopup is idempotent
- settings: the reset dialog is a blocking, escapable confirmation
- settings: accepting the reset dialog acknowledges in chat
- settings: the page's tabs are the designed ones, in order, at the designed size
- settings: no tab holds fewer than two controls
- settings: every row's group is one of the designed tabs
- settings: the Master controls block is the FIRST group, in canonical order
- settings: the Master controls rows are the COMPOSER's, not hand-written
- settings: Enable names the addon, and the rows it has no state for are omitted
- settings: the master rows keep this addon's own shipped defaults
- settings: the debug console is a SESSION-ONLY row that never reaches db.profile (WhatGroup WG-12)
- settings: a global reset closes the console a profile reset cannot reach (options-ui-§12)
- settings: every row on every page carries a `group`
- settings: every color row is followed by its class-color companion, and none is disabled
- settings: the stored settings are exactly the pinned ones

### test_slash.lua (19)

- slash: COMMANDS order is the help order, seventeen positional triples
- slash: every description has an enUS entry
- slash: the chat command and its alias are registered through AceConsole
- slash: the help header is the library's, with this addon's alias sentence
- slash: version prints the tagged version
- slash: a bare /st opens the settings panel, and so does config
- slash: list groups the rows under their sections, with current values
- slash: get and set reach the write seam for a number row, clamped to its range
- slash: a bool row takes the library's words and `toggle`
- slash: the skin row accepts a registered skin and refuses an unknown key
- slash: reset takes a path; a bare reset explains itself and writes nothing
- slash: enable and disable write the Enable row and move the latch
- slash: debug toggles the WINDOW, `on`/`off` the flag, and an unknown word the window
- slash: perf is registered by the addon and answers through the library
- slash: show toggles the showroom while enabled
- slash: degraded, the CLI verbs name the missing library and nothing raises
- slash: /skintester opens the window
- slash: a foreign /st is reported once and left alone
- slash: with no foreign /st, nothing is said and both commands stay

### test_selector.lua (8)

- selector: one card per Ka0s skin, in Skins() order
- selector: clicking a card applies and saves the skin
- selector: a pick made elsewhere moves the selection
- selector: the saved skin is applied at load
- selector: the saved Scope is applied at load, and /st set moves one half
- selector: an unknown saved skin falls back to ka0s
- selector: clicking the current card does nothing
- selector: no EllesmereUI card and no copy button

### test_showroom.lua (11)

- showroom: the window is painted through the wrapper
- showroom: Paint answers the primitive's answer and records the name once
- showroom: sections lay out in registration order, each under its title
- showroom: a caption is muted text
- showroom: opened after a skin change, it wears the new skin
- showroom: a skin change repaints the open window
- showroom: a skin card's label keeps to one line under any skin's type size
- showroom scrollbar: hidden while the sections fit, shown once they overflow
- showroom scrollbar: the wheel moves the sections and the knob together
- showroom scrollbar: dragging the knob scrolls the sections, and a sync does not scroll back
- showroom scrollbar: the corridor and the knob are the skin's

### test_showroom_coverage.lua (5)

- showroom: every lib.VOCAB name is shown
- showroom: every section is built and none is empty
- showroom: the tabs sample moves its selection on a click
- showroom: the sections build without the library's widgets
- showroom: the slider sample is visible under Ka0s Default

### test_showroom_values.lua (13)

- values: every getter is displayed
- values: every sem token has a line
- values: a skin change redraws them
- values: the two token categories each have a heading, in the heading role
- values: every quality tier in the schema has a line, poor to legendary
- values: each tier line wears its own color, and follows a skin change
- values: a tier the skin leaves unset reads none, with no swatch
- values: the tooltip colors category lists every gtip.* token, gtip.footer included
- values: gtip.footer is Ka0s Default's 0.6 gray and follows gtip.muted under Obsidian
- values: the art tokens read the client's art under Ka0s Default and a color under Obsidian
- values: FontFlags shows From skin on a HUD and in a window, and a picked flag winning
- values: HudFontSize shows a stored 12 and 24 scaled by the worn skin's HUD size
- values: without the skin engine FontFlags and HudFontSize still answer what SetFont takes

### test_showroom_textures.lua (8)

- textures: the section is built with three bars, five rows and five segments
- textures: the status bars wear the accent, good and bad colors, in the bar texture
- textures: the chart rows and stacked segments wear the series colors
- textures: every label names the texture key in effect
- textures: a skin switch recolors the bars and relabels them
- textures: a texture override repaints every fill and relabels it, live
- textures: the section builds without the skin engine
- textures: Ka0s Default draws its own Ka0s Default bar, shipped in the vendored copy

### test_showroom_owner.lua (9)

- addon surfaces: the section is built, and every sample went through the wrapper
- addon surfaces: the owner tokens resolve: default, a skin's own entry, else the follow
- addon surfaces: the owner token line wears st.note, and follows a skin switch
- addon surfaces: the danger button paints its fill, edge and label from the named tokens
- addon surfaces: the caution callout paints its fill, edge and title from the named tokens
- addon surfaces: the TreeGroup follows the Scope's settings-panel half, live
- addon surfaces: the icon border draws icon.borderSize edges in icon.border, per skin
- addon surfaces: the settings-style window wears Ka0s Default under Ka0s Default
- addon surfaces: the settings-style window follows a skin switch and stays skinned back on Ka0s Default

### test_showroom_fonts.lua (9)

- fonts: the section is built, one face line per skin, in the library's order
- fonts: each line names its skin's body and title faces, the new faces among them
- fonts: the lines draw in each face at its size, under this addon's Font outline
- fonts: the outline line follows the Font outline and says Ignore fonts wins
- fonts: Measure gives every skin a width per role and Ka0s Default a ratio of 1
- fonts: /st widths prints a header and one line per skin against Ka0s Default
- fonts: a face the client cannot resolve reads unmeasured, and nothing raises
- fonts: /st widths is refused while the addon is disabled
- fonts: without the skin engine the section builds and the probe says why

### test_showroom_hud.lua (5)

- hud: the section is built, one line per skin, in the library's order
- hud: each skin's line names that skin's own HUD face, all nine of them
- hud: each skin's line is drawn in its face, at its hud.fontSize, under its hud.outline
- hud: the worn line follows the skin worn, through BarStyle
- hud: under Ignore fonts the worn line takes the host's own face, and the skin lines keep theirs

### test_showroom_widgets.lua (12)

- widgets: the section is built with every sample
- widgets: the drag handle's tooltip draws gtip.title, gtip.value and gtip.footer, per skin
- widgets: the drag handle, chart and autocomplete are owned by this addon, off the panel
- widgets: the resize grip is the client's art under Ka0s Default and icon.grip under Obsidian
- widgets: the drawer and nav hover art is the client's under Ka0s Default and list.hoverArt under Glass
- widgets: the chart's tick labels and the autocomplete rows are in this addon's body face
- widgets: Ignore fonts gives the chart's tick labels and the autocomplete rows their template face
- widgets: Ignore settings panel leaves the section skinned (a window, decision D-01)
- widgets: the copy window opens owned by this addon
- widgets: the console button opens the debug console
- widgets: the picker button shows the skin picker on a profile that has closed it
- widgets: the picker button does nothing in combat

### test_skin_media.lua (9)

- media: a fresh profile stores the skin's own font and texture, and the picker unseen
- media: the write seam's fourth argument writes both keys, false as the empty string
- media: another addon's copy reaches the store through WriteChoice
- media: a row's write applies its own half live
- media: the stored overrides are applied at load
- media: a profile switch applies the incoming profile's overrides, and back
- media: a profile reset clears the overrides
- media: Ignore fonts wins over a font override
- media: without the skin engine the apply is a quiet no-op

### test_skin_outline.lua (9)

- outline: a fresh profile stores All text, the library's default
- outline: the schema row offers the library's three modes, in its order
- outline: the write seam stores media.outline, and leaves it alone when it is nil
- outline: another addon's copy reaches the store through WriteChoice
- outline: the row's write applies the mode live
- outline: /st set refuses a mode the library does not know
- outline: the stored mode is applied at load
- outline: a profile switch applies the incoming profile's mode, and back
- outline: without the skin engine the apply is a quiet no-op

### test_skin_verb.lua (7)

- skin verb: the row sits right after config, with the library's help words
- skin verb: /st skin shows the picker on a profile that has closed it
- skin verb: NS.RunSkinVerb hands O.SkinVerb this addon's first-run spec
- skin verb: in combat every call prints the library's gray line and shows nothing
- skin verb: refused while the addon is disabled, and no picker shows
- skin verb: without LibKa0s the verb prints the library-absent line
- skin verb: the showroom's Show the picker goes through O.SkinVerb

### test_skin_picker.lua (30)

- picker: a fresh profile shows it once the addon is enabled
- picker: not before login
- picker: the spec names this owner's seams, the General page's Skin tab and the eye
- picker: closing it marks the profile, and the next login does not show it
- picker: the eye opens the showroom and leaves the picker up
- picker: the gear saves the pick, opens the General page itself, and marks the profile
- picker: a pick previews: the skin moves live, the profile keeps its own and is not marked
- picker: Apply saves the pick through the schema runtime and marks the profile
- picker: the close control puts the old skin back, writes nothing, and marks the profile
- picker: the title is "Choose a skin" and the owner line names this addon
- picker: not while the addon is disabled
- picker: a login in combat skips it, and the next trigger shows it
- picker: a profile reset shows it again
- picker: a new profile shows it; one that closed it does not
- picker: /st disable hides it, and the profile stays unseen
- picker: a switch to a disabled profile hides it, and neither profile is marked
- picker: a switch to a profile that closed it hides it, and writes nothing
- picker: a switch to a seen profile under a pending preview wears that profile's skin
- picker: a switch to an unseen profile under a pending preview opens afresh on it
- picker: Apply after a switch under a pending preview writes nothing the dropdown did not show
- picker: a profile copy under a pending preview wears the copied skin
- picker: behind another Ka0s addon's picker it queues, and shows when that one closes
- picker: a stand-down while queued takes it out unseen, and nothing shows after
- picker: another addon's Apply to all marks this profile seen and gives it the skin
- picker: this addon's Apply to all saves here and gives the other addon the skin
- picker: Apply to all is hidden while this addon is the only skin owner
- picker: a skin General -> Skin stores under a pending preview stays on the close
- picker: a skin /st set stores under a pending preview stays on the close
- picker: another addon's picker closed in combat does not bring this one up until combat ends
- picker: a stand-down while it waits out combat leaves nothing to show after

### test_settings_sample.lua (5)

- settings: the sample page carries one row of each widget type
- settings: the sample page wears the owner's skin once the panel is skinned
- settings: on a new profile the sample page is the client's
- settings: the sample rows stay on their page
- settings: no copy button on the sample page

### test_panel.lua (37)

- panel: OnEnable registers the parent category and the General subcategory
- panel: the parent category is added to the AddOns list
- panel: Register is idempotent — a second call registers nothing more
- panel: a registration taken in combat is parked and lands at PLAYER_REGEN_ENABLED, with no second host call
- panel: a login taken in combat is parked and lands at combat end, with no second registration
- panel: registration validates the schema
- panel: both panels start hidden
- panel: registration creates no AceGUI widgets
- panel: OnShow itself builds nothing; the deferred hop does
- panel: the build is one-shot across repeated shows
- panel: two OnShows before the hop runs still build only once
- panel: the Defaults button is built lazily, on the General page only
- panel: the reset dialog is not registered before it is needed (taint)
- panel: the Debug console renders as an ordinary Master controls checkbox
- panel: ticking Debug console shows the window without touching db.profile
- panel: unticking Debug console hides the window
- panel: opening the console while General is OPEN moves the checkbox
- panel: re-opening General re-syncs the Debug console checkbox
- panel: a re-render REPLACES the refresher list rather than growing it
- panel: the scroll container is patched to always show its scrollbar
- panel: the patch is one-shot per widget
- panel: releasing the widget restores AceGUI's stock behavior
- panel: the landing page lists one row per slash command
- panel: the landing page shows the TOC Notes line
- panel: the landing page renders the Slash Commands heading and the logo
- panel: the landing logo path is built from the folder this copy loaded from
- panel: the landing page adds logo, notes, heading and command rows in that order
- panel: a dirty landing page re-renders in place instead of stacking a second copy
- panel: the landing page is drawn by the library's BuildLandingPage, logo and commands
- panel: the header Defaults tooltip is the library's Reset all settings wording (WHA-L12)
- panel: General's strip is Master controls, Skin, then Keybindings
- panel: Master controls holds only the rows this addon has state for
- panel: the scale slider commits on release, through the write seam
- panel: unticking Enable stands the addon down through the row's onChange
- panel: Defaults raises the confirmation, and confirming restores the profile
- panel: Reset position forgets the saved point and centers the showroom
- panel: the Skin tab is the library's, for this owner, and a pick lands in the profile

### test_profiles.lua (17)

- profiles: the page registers this db's AceDBOptions table, as the LAST subcategory
- profiles: the page has no Defaults button
- profiles: without any one of the three libraries the page opts out
- profiles: nothing is built until the page is first shown, then the dialog fills a SHOWN container
- profiles: a switch made elsewhere re-draws an OPEN Profiles page into the same container
- profiles: a switch while the page is HIDDEN re-draws it on its next show
- profiles: a page first shown in combat draws nothing, then draws once at combat end
- profiles: a switch logs ONE [Profile] line naming the incoming profile (debug-logging-§10)
- profiles: switching to a disabled profile stands the addon down, and back brings it up
- profiles: the Reset all settings tooltip says it is Profiles -> Reset Profile
- profiles: ONE named veto keeps the Profiles page and every profile row out of the reset walk
- profiles: /st resetall resets the active profile and leaves the list and the other profile alone
- profile verb: bare `/st profile` lists the profiles, the current one marked
- profile verb: `/st profile <name>` switches to an existing profile and runs the handler
- profile verb: an unknown name is refused, and no profile is created
- profile verb: surrounding quotes are stripped, case and inner spaces kept
- profile verb: a switch in combat is refused and nothing moves

### test_diagnostics.lua (10)

- diagnostics: identity names schema, profile, enabled, stood-down and the holds
- diagnostics: the always rows print at default, and a changed row prints with its default
- diagnostics: the skin section names the engine, the stored and applied skin, and the skins
- diagnostics: the showroom section reads the window and never builds it
- diagnostics: the report reads and never acts: no registration, hold, timer or save
- diagnostics: a raising section costs exactly one line, and the report still ends
- diagnostics: an over-cap report ends `truncated`, then the end marker
- diagnostics: with logging off, the enable ack then one localized chat line
- diagnostics: with logging already on, exactly one chat line
- diagnostics: without LibKa0s-DebugLog both forms print the library-absent line, writing nothing

### test_launcher.lua (36)

- launcher: it registers at login, and the broker object IS the minimap button's
- launcher: the object is a launcher, named for the FOLDER, wearing this addon's logo
- launcher: the label is the BRAND NAME in plain text (launcher-§1)
- launcher: the label is NOT wired to the TOC Title
- launcher: the name is the FOLDER this copy loaded from, not a hand-typed literal
- launcher: Register is idempotent -- a second call builds no second button
- launcher: the icon file exists and is an uncompressed 32-bit TGA
- launcher: the TOC's IconTexture is the same file the object wears
- launcher: LEFT-click opens the settings panel, and never the showroom
- launcher: LEFT-click opens the panel while disabled too, with no refusal line
- launcher: RIGHT-click opens a menu titled with the label, with its two entries in order
- launcher: the Enabled entry runs the /st disable|enable body, ack and all
- launcher: the Show window entry toggles the showroom through NS.Showroom.Toggle
- launcher: Bindings.xml carries one CLICK binding on the toggle button, no default, no Lua
- launcher: the binding button is plain, named, hidden and registered for the down edge
- launcher: the binding labels are the brand and the localized action
- launcher: a key press runs the Show window handler, once per press
- launcher: while disabled only Enabled is live; the rest are grayed and call nothing
- launcher: with no MenuUtil the right click falls back to the settings panel
- launcher: the descriptor passes the two pairs to the verbs' seams, and no retired field
- launcher: the tooltip reads title and status, then the two click hints
- launcher: while disabled the tooltip still draws, with the same two click hints
- launcher: the tooltip's version is the TOC's, not the in-code constant
- launcher: there is no host tooltip hook, and the retired label's locale row is gone
- launcher: the Minimap button row is stored, global, and LibDBIcon's OWN hide key
- launcher: the row's get/set invert, and the button follows immediately
- launcher: the row's CLI path reads in its own sense
- launcher: a legacy store with hide = true reads not-shown, and nothing moves
- launcher: a button the player hid survives Reset all settings (options-ui-§12)
- launcher: a button the player hid survives the General page's Defaults button
- launcher: a button the player hid survives the Master controls reset button
- launcher: LibDBIcon's own writes into the table are not disturbed
- launcher: an install with neither broker library loads, and says so once
- launcher: with no LibDBIcon the broker plugin still registers
- launcher: the row still stores with no broker library at all
- launcher: with LibKa0s absent the seam answers honestly and the store still moves

### test_keybinds.lua (8)

- keybinds: Bindings.xml files every binding in the addon's own category, labeled, brand-titled
- keybinds: NS.BINDINGS is the one table, Show window first, each with a localized tooltip
- keybinds: the General strip ENDS in Keybindings, after Appearance
- keybinds: the tab's rows are NS.BINDINGS in order, labeled with the BINDING_NAME_ text
- keybinds: a key bound through the tab is the client's key (GetBindingKey), saved to the set in force
- keybinds: a key set on the client's page shows in the tab after UPDATE_BINDINGS
- keybinds: a second key, set on the client's page, reads '<key> +1' on the one key button
- keybinds: in combat the tab refuses, and no binding is written or saved

### test_lifecycle.lua (18)

- lifecycle: the addon exposes no public global (WhatGroup WG-01)
- lifecycle: NS IS the addon object (AceAddon mixes into the namespace)
- lifecycle: earlier files' fields survive NewAddon
- lifecycle: the shared chat prefix is the cyan [ST] tag
- lifecycle: NS.Print, LibKa0sSkinTester._print and NS.Util.print are one seam
- lifecycle: debug state is session-only and starts off
- lifecycle: OnInitialize builds the db from the schema defaults
- lifecycle: OnInitialize registers both slash verbs
- lifecycle: no events are registered before OnEnable
- lifecycle: InitSummary reflects live runtime state
- lifecycle: InitSummary is safe before the db exists
- lifecycle: /st config opens the parent settings category
- lifecycle: /st config is refused during combat (options-ui-§2)
- lifecycle: a login taken in combat registers the panel at combat end
- lifecycle: /st reset <path> resets one setting, with no confirmation
- lifecycle: a bare /st reset explains the change rather than resetting or erroring
- lifecycle: /st resetall asks for confirmation rather than resetting outright
- lifecycle: /st resetall and the Defaults button share one OnAccept body

### test_debuglog.lua (36)

- debuglog: FONT_MONO points at the library payload's JetBrains Mono TTF
- debuglog: the console renders in the vendored TTF when the client can fetch it
- debuglog: FormatPlain wraps the tag in brackets, single-space separators
- debuglog: FormatPlain tolerates a nil tag
- debuglog: FormatColored colors timestamp + tag; pipe and content default
- debuglog: /st debug on enables session state
- debuglog: /st debug off disables session state
- debuglog: /st debug (no arg) toggles the window, not the state
- debuglog: header toggle click flips debug state
- debuglog: enabling writes a '[Debug] logging enabled' console line
- debuglog: enabling debug appends the [Init] session summary after the bracket (debug-logging-§5)
- debuglog: [Init] fires only on enable, not on disable (debug-logging-§5)
- debuglog: disabling still appends a '[Debug] logging disabled' line
- debuglog: NS.Debug survives an unsafe format arg without raising (WhatGroup WG-22)
- debuglog: NS.Debug is a no-op (no console write) when debug is off
- debuglog: debug-logging-§11 scrollbar + line-counter sync is a safe no-op under the mock
- debuglog: settings change logs one [Set] line at the write seam (debug-logging-§10)
- debuglog: RestoreAllDefaults logs one [Set] reset profile line counting the rows it changed (debug-logging-§10)
- debuglog: RestoreAllDefaults on a pristine profile counts 0 rows (debug-logging-§10)
- debuglog: a profile reset from outside the helper is logged once, without a count (debug-logging-§10)
- debuglog: the library's page reset is one [Set] line counting the rows it changed (debug-logging-§10)
- debuglog: an all-default page reset logs 0 rows, not a line per row (debug-logging-§10)
- debuglog: the bulk bracket adds no line when the act reset the profile (debug-logging-§10)
- debuglog: a nested bracket logs once, at the outermost close, with the summed tally (debug-logging-§10)
- debuglog: a nested bracket that reset the profile silences the outer line (debug-logging-§10)
- debuglog: a bracket that closes on an error still logs its tally and unmutes (debug-logging-§10)
- debuglog: a write that raises inside a bracket is not counted (debug-logging-§10)
- debuglog: a profile reset that raises logs one marked line and re-raises (debug-logging-§10)
- debuglog: a profile reset that raises leaves no count for a later reset (debug-logging-§10)
- debuglog: a profile reset inside an open bracket silences the bracket (debug-logging-§10)
- debuglog: a profile copy logs one [Set] copied line naming the source (debug-logging-§10)
- debuglog: InitSummary leads with the debug-logging-§5 identity fields, then runtime state
- debuglog: enable ack is color-coded green/red matching the header (debug-logging-§5)
- debuglog: pin — standing down logs one [Lifecycle] line naming the holds, the library's
- debuglog: pin — standing back up logs the library's [Lifecycle] stood-up line, once
- debuglog: a caught error logged while debug was off is still logged once it is on

### test_library_lines.lua (8)

- library lines: an unknown verb writes the library's [Cmd] refusal, once
- library lines: a feature verb refused by the disabled gate is one [Cmd] line
- library lines: a set the parser refuses writes one [Cmd] line naming the path
- library lines: a profile switch refused in combat writes one [Cmd] line
- library lines: a registration parked in combat logs the park and the flush, once each
- library lines: the launcher's registration lands the first time logging is turned on
- library lines: the login migration's [Migrate] line lands the first time logging is turned on
- library lines: a caught error logged once is logged again after a Clear

### test_docmap.lua (1)

- docmap: every Tier 2 row agrees with what docs/ holds

### test_lintconfig.lua (6)

- lintconfig: .luacheckrc sets no top-level ignore
- lintconfig: .luacheckrc switches no warning class off wholesale
- lintconfig: every files[...] ignore is narrowed to a file or a name
- lint: exclude_files carries the template's frozen stores
- lint: read_globals grants no removed or unread global
- lintconfig: no source file carries a bare inline luacheck ignore

### test_doc_structure.lua (9)

- docs/ARCHITECTURE.md carries the ten sections documentation-§3 names
- every mandated hub section that has a topic doc has spilled into it
- every anchor pointing into docs/ARCHITECTURE.md resolves to a heading
- the player-facing history has the ONE home documentation-§1 allows, and no second
- README.md's top-level sections are the ones documentation-§1 names, in its order
- README.md's Reporting a bug section is the standard's text with /st, and links nowhere
- the README's settings table is page-granular, not per-tab
- every settings tab the README sends a player to exists in the schema
- docs/smoke-tests.md carries a non-English-client section

### test_register.lua (1)

- every evidence id the register cites is assigned by its bundle in docs/audits/ or docs/reviews/

### test_disabled.lua (18)

- disabled 1: enabled, the addon holds NO registration, and that is pinned
- disabled 3: the registration set stays empty, by count and by name
- disabled 3: the write seam is the route — the checkbox and the verb reach the same latch
- disabled 4: no timer, ticker or OnUpdate survives, and none is armed afterwards
- disabled 5: the showroom is hidden, and every route back to the screen refuses
- disabled 6: combat edges and a skin change write nothing, say nothing, show nothing
- disabled 7: every reserved verb answers normally, and the bare /st opens the panel
- disabled 7: the feature verb answers exactly one refusal line by hold, and writes nothing
- disabled 8: left-click opens the panel; right-click's menu grays Show window
- disabled 8: the Show window key press refuses by hold: the disabled line, then the perf line
- disabled 8: with LibKa0s absent the button still exists and a press refuses on the stub's line
- disabled 9: re-enabling restores the (empty) registration set and reopens nothing
- disabled 9: a setting changed WHILE DISABLED is what the rebuild reflects
- disabled 10: releasing the perf hold does NOT resurrect an addon `disabled` still holds down
- disabled 10: the other order — disabled first, perf released last
- disabled 10: the latch persists nothing
- disabled: the chat command, the db, the launcher and the skin owner all survive
- disabled: a profile switch that flips `enabled` is re-evaluated, both ways

### test_vendor_sync.lua (3)

- libs/LibKa0s is the LibKa0s release CLAUDE.md says this addon bundles
- tests/_kit is the test kit that shipped with that release
- the automated-test runner is recorded executable (100755)

### test_eol.lua (2)

- eol: every tracked file carries the terminator .gitattributes declares for it
- eol: .gitattributes is line-endings-§5's canonical body for this repo kind

### test_prose.lua (15)

- prose: no authored file carries a British spelling from localization-§5's published list
- prose: the gate carries localization-§5's two lists whole, and nothing of its own
- prose self-test: the carve-out suppresses the named generated folder, and only it
- prose self-test: a path the carve-out does not name is not covered by one that looks like it
- prose self-test: a carve-out that is not a set of path strings is a failure, not a silence
- prose self-test: a TOC's file lines are read as paths, and its directives and comments are not
- prose self-test: a .pkgmeta's ignore block is read, and the keys around it are not
- prose self-test: an ignore entry covers a path exactly, by folder, and by wildcard
- prose self-test: the carve-out admits a generated dump and refuses a file the TOC loads
- prose self-test: a waiver-file exclusion meets the same two refusals as the carve-out
- prose self-test: each list is refused on the matching rule its own scan uses
- prose self-test: the scan and the refusals read the added exclusions through one reader
- prose self-test: a narrowing is refused by what it suppresses, not by how it is written
- prose self-test: the disclosure names what each entry suppressed, and says when it is bounded
- prose self-test: a malformed waived is a failure, not a silence

### test_layout_cap.lua (13)

- layoutcap: every authored file over the 1500-line cap is named in the census
- layoutcap: no census row outlives the breach it records
- layoutcap: every over-cap census row carries one of layout-§1's three terminal states
- layoutcap: the census and the exempt set agree about which paths were exempted
- layoutcap: an empty census is written as a result rather than left standing empty
- layoutcap self-test: the parser reads the census nested under the register, and stops there
- layoutcap self-test: a census outside its register, or at the wrong level, is not read
- layoutcap self-test: an over-cap file missing from the census is reported, and an exempt one is not
- layoutcap self-test: a census row that outlives its breach is reported
- layoutcap self-test: an over-cap row that names no terminal state is reported
- layoutcap self-test: the census and the exempt set are held to naming the same paths
- layoutcap self-test: a census that states nothing is told apart from one that states none
- layoutcap self-test: the exempt set takes folders as well as paths

### test_diagnostics_contract.lua (9)

- diagnostics contract: both forms run the report
- diagnostics contract: the debug word is matched in any case
- diagnostics contract: both markers carry the brand and the end counts the report
- diagnostics contract: the report appends after what the console already holds
- diagnostics contract: the report lands with logging off and turns it on for the session
- diagnostics contract: an addon that opts out lands the report and leaves logging off (skipped: this addon keeps the default (Kit.diagnostics.enablesLogging is not false), so its report turns logging on; the case above holds it)
- diagnostics contract: with logging already on, the report writes no second enable line
- diagnostics contract: both forms run while the addon is disabled
- diagnostics contract: no other name runs the report

### test_lizard_sighted.lua (8)

- lizard sighted: every hazard lizard loses a function over is neutralized
- lizard sighted: fields, strings, comments and look-alike names come through unchanged
- lizard sighted: a method definition is rewritten to its dot form with self
- lizard sighted: no line is added or removed, CRLF included
- lizard sighted: countFunctions counts the keyword, not strings, comments or longer names
- lizard sighted: listedCounts reads the per-file table, once per file
- lizard sighted: parity names every file whose counts differ, and only those
- lizard sighted: lizard lists every function of a hazard fixture once it is sanitized

## Totals

| Suite | Cases |
|-------|------:|
| test_harness.lua | 11 |
| test_libka0s.lua | 55 |
| test_surface_parity.lua | 8 |
| test_mediasetup.lua | 13 |
| test_envsetup.lua | 9 |
| test_util.lua | 26 |
| test_database.lua | 11 |
| test_settings.lua | 53 |
| test_slash.lua | 19 |
| test_selector.lua | 8 |
| test_showroom.lua | 11 |
| test_showroom_coverage.lua | 5 |
| test_showroom_values.lua | 13 |
| test_showroom_textures.lua | 8 |
| test_showroom_owner.lua | 9 |
| test_showroom_fonts.lua | 9 |
| test_showroom_hud.lua | 5 |
| test_showroom_widgets.lua | 12 |
| test_skin_media.lua | 9 |
| test_skin_outline.lua | 9 |
| test_skin_verb.lua | 7 |
| test_skin_picker.lua | 30 |
| test_settings_sample.lua | 5 |
| test_panel.lua | 37 |
| test_profiles.lua | 17 |
| test_diagnostics.lua | 10 |
| test_launcher.lua | 36 |
| test_keybinds.lua | 8 |
| test_lifecycle.lua | 18 |
| test_debuglog.lua | 36 |
| test_library_lines.lua | 8 |
| test_docmap.lua | 1 |
| test_lintconfig.lua | 6 |
| test_doc_structure.lua | 9 |
| test_register.lua | 1 |
| test_disabled.lua | 18 |
| test_vendor_sync.lua | 3 |
| test_eol.lua | 2 |
| test_prose.lua | 15 |
| test_layout_cap.lua | 13 |
| test_diagnostics_contract.lua | 8 |
| test_lizard_sighted.lua | 8 |
| Skipped | 1 |
| **Total** | **599** |
