# 02 Candidates

Not interviewed (the run pre-decides this addon's items). What v1.108.0 brings, against this addon:

- Class A, delivered on the copy: the footer lays out only its shown marks (Widgets 30; the showroom's footer has
  no marks); a secret strip rect's tooltip above the nearest readable ancestor (WidgetsDragHandleTip 3); an owned
  menu's submenu arrows tinted from the menu palette (WidgetsDropdown 3, the Library widgets cascade); the
  composers' new companions (OptionsCompose 20, no composer called here); `W.BarStyle`, `S.BarGloss` and
  `S.ApplyBarFill` defaults (no `W.Bar`; the ApplyBarFill sample keeps its host texture).
- New surfaces not adopted: `W.OwnerWarnings(owner, sink)` (Widgets 30), a debug-gated report of an owner-less
  library widget under an owned frame. Every library widget the showroom builds passes its owner, so it would
  report nothing today; noted for the lead, not filed. `Core.ApplySkin`'s `skinBands`, the Callout's
  `onClose` / `onSettings` / `FollowKeys` / `MoveToSkin`, and the WaypointArrow companions belong to surfaces this
  addon does not use.
