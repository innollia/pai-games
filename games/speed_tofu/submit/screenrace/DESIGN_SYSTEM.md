# Off the Screen! — Design System ("Pocket Parcel Town")

Code: `g/sr_theme.gd` (`const T = preload("res://g/sr_theme.gd")`). Layouts follow `UI_SPEC.md`.
Look: a paper-craft diorama. Cut paper and cardboard, thin white paper edges, soft shadows that fall straight down, post-office stamps.

## Palette (only these + light/dark variants)
| Role | Const | Hex |
|---|---|---|
| Ink: text, outlines, shadows | `NAVY` | #2A2C44 |
| Cardboard: control deck, badges | `KRAFT` | #E3BA88 |
| Cardboard shade: card borders, button plates | `KRAFT_SH` | #BA8E5C |
| Paper: panels, cards | `CREAM` | #FFFDF5 |
| Paper edge | `WHITE` | #FFFFFF |
| **Accent (one): danger + primary call to action** | `RED` | #E85244 |
| Reward, selected, 1st place | `GOLD` | #F7B336 |
| Parcels | `PARCEL` | #D99B5B |
| Success, delivered | `GREEN` | #2B9348 |
| Player, effect text | `BLUE` | #3D78B5 |
| Lantern night / light | `NIGHT` / `AMBER` | #1B1F38 / #FFD166 |
| Secondary text, disabled | `MUTED` | #6C757D |
Derived colors: `SHADOW` (navy at 25%), `TROUGH` #EAD7BC, `EMPTY_SLOT` #D0C2AE, `SILVER`, `BRONZE`.
Text color on any fill: `T.ink_on(face)` (navy on light fills, white on dark fills).

## Type (one font: Pretendard Bold, `T.font()`)
56 hero (GO!, result stamp) · 40 screen title · 32 card title / button · 26 body / badge · 22 card body · 18 tag / tip.
Minimum size on a phone is 18. White text on a colored fill gets a 3 px navy outline.

## Shape
- Corner radius: 14 for cards and panels, 10 for tags and badges, 18 for buttons.
- Border: a 4 px white paper edge on every face (cards and stamps use a perforated white edge).
- Shadow: always offset (0, 8), navy at 25%, never blurred sideways. Pressed: (0, 2).
- `T.panel()` gives a StyleBox; `T.draw_paper_rect()` does the same inside `_draw`.
- Torn edges (`T.draw_torn_edge`) only for the top of the control deck and the receipt.

## Components
- `PaperButton`: primary 420×96 in `RED`, reward / continue in `GREEN` or `GOLD`, secondary in `KRAFT`. Icon on the left is optional.
- `PaperCard`: stamp card with a perforated edge and an accent stripe. Vertical cards for modes (190×480), horizontal cards (`horizontal = true`) for perks and routes (620×210). `selected` lifts the card, adds a gold outline and tilts it -2°.
- Cargo HUD: `T.draw_parcel_icon(ci, c, size, filled)` (kraft box with a red tape cross; an empty slot is a dashed outline).
- Stamps (events and countdown): a rotated paper label with an ink border, slammed in with `T.stamp_slam`. Bad = RED, good = GREEN or GOLD, info = NAVY.

## Motion
| Use | Call | Timing |
|---|---|---|
| Open a card or modal | `T.pop_in(n, delay)` | 0.32 s BACK OUT, scale .85→1, rotation -5°→0, alpha 0→1 |
| Close | `T.pop_out(n)` | 0.20 s QUAD IN, scale →.92, y +80, alpha →0, then hide |
| Button down / up | built in | 0.06 s down 6 px + scale .96 / 0.22 s ELASTIC back |
| Stamp | `T.stamp_slam(n)` | 0.14 s CUBIC IN, scale 1.7→1, plus a 2 px shake |
| Score or icon change | `T.bump(n)` | 0.18 s scale punch 1.15→1 |
| Hit, error | `T.shake(n, 6, 0.2)` | returns exactly to its start position |
Stagger lists by 0.05–0.08 s per item. Nothing loops faster than 4 Hz.

## Do
- Give every tap visual feedback (a button press, a card lift, or a stamp).
- Keep the race screen bright. Night mode uses `NIGHT` with `AMBER` light, never black.
- Load art with `T.tex(name)` and always keep a drawn fallback.
- Send every string through `L(ko, en)`.

## Don't
- Don't use colors outside the palette, add a second font, or use gradients on UI faces.
- Don't use custom canvas shaders, or create nodes and tweens every frame (use a pool and reuse it).
- Don't use more than one red call to action per screen.
- Don't put text under 18 px, or make touch targets smaller than 88 px.
