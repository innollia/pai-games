# "Off the Screen!" — UI/UX Design Specification
**Lead Game UI/UX Designer Spec | Game Jam Final Submission**  
**Platform:** Mobile Web Portrait (720 × 1280), Godot 4.7 Compatibility (Single-Threaded)  
**File:** `submit/screenrace/UI_SPEC.md`

---

## 1. Concrete Screen-by-Screen Critique

The current UI relies on debug text labels and flat circles from `tofu.gd`. It clashes with the "Pocket Parcel Town" paper-craft diorama aesthetic and causes severe mobile touch friction.

* **01 How-To Card (`01_howto.png`):** 3D player model spawns at origin before dismissal, poking through behind the card. Inherited `_score_l` draws a meaningless 88px "0" at `(0, 20)`. 4 dense text lines in a white `ColorRect` (`660×780`) lack visual diagrams. "Tap to start" lacks button framing.
* **02 Mode Select (`02_mode.png`):** Action circles (`kit_button()`) are hijacked: Classic = Jump `(600, 1120)`, Lantern = Drop `(600, 890)`, Rush = circle at `(420, 690)`. Rules dumped in `route_l` at Y=250 in 25px font are 800px away from thumb targets. Lang toggle is a tiny unanchored circle (`r=54`) at `(630, 520)`. No mode visuals.
* **03 Countdown (`03_countdown.png`):** Invisible countdown (`pt = 1.4` with zero visual cues). Beep at 0.7s, then abrupt start at 0.0s. Web judges miss launch timing, causing instant left-edge elimination.
* **04 & 05 Race & Race Later (`04_race.png`, `05_race_later.png`):** Track at Y≈640 wastes lower 580px on solid underground dirt; shortcuts lack headroom. Static "0" score at top; round info smushed at Y=130; player cargo shown only as button text (`Box 3`); no 380m distance rail. Left 3D edge strip clips off-screen. Jump at `(600, 1120)` sits below Drop at `(600, 890)`, causing thumb strain.
* **06 Event Stamps (`06_stamp.png`):** Basic `StyleBoxFlat` rectangles without serrated edges, postmarks, or paper grain. Clamped head tracking vibrates rapidly during jump arcs.
* **07 & 08 Perk & Route Pick (`07_perk.png`, `08_route.png`):** Branch choices hijack Jump and Box circles. Text sits at Y=250 while circles sit at screen bottom; route requirements cannot be cross-referenced with player cargo.
* **09 Results Screen (`09_result.png`):** 12-line text wall in a single `Label` (`660×570`) with medals listed as raw strings ("Market Gold Riverside Silver"). Replay prompt hidden on line 12.
* **10 Rating Card (`10_rate.png`):** Unstyled white box (`600×550`) over dark dim; hardcoded Korean ignores language toggle.

---

## 2. Race Layout & Camera Framing (720 × 1280)

```
0px   +-------------------------------------------------------------+
      | TOP HUD (Y: 0..180): Course Tag | Rail (380m) | Cargo | Rank|
180px +-------------------------------------------------------------+
      | RACE PLAYFIELD (Y: 180..920, Height: 740px)                 |
      | - Open Sky, Awnings, Shortcuts, Balloon Signs (Y: 180..620) |
      | - Courier Running Line (Y: 620..760)                        |
      | - Ground Surface (Y: 760..920)                              |
      | * Left Edge Hazard Strip (X: 0..84, screen-space)           |
920px +-------------------------------------------------------------+
      | KRAFT CONTROL DECK (Y: 920..1280, Height: 360px)            |
      | Left Stick: (180, 1100)      | Drop: (440, 1150)            |
      |                              | Jump: (590, 1070)            |
1280px+-------------------------------------------------------------+
```

### Exact Pixel Regions
1. **Top HUD (`X: 0..720, Y: 0..180`):** Safe top margin `Y: 0..40`. Active components at `Y: 44..114` (Course Tag, Distance Rail, Cargo Stack, Lang Toggle). Badges at `Y: 118..170` (Rank Shield, Route Rule).
2. **Race Playfield (`X: 0..720, Y: 180..920`, Height: 740px):** Camera vertical offset: `camy = lerpf(camy, lead.p.y + 6.2, 1.0 - exp(-4.0 * dt))`. Lowers runner ground contact to **Y = 760px**. Sky headroom expands to 440px (`Y: 180..620`) for high shortcuts. Underground dirt reduced to 160px (`Y: 760..920`).
3. **Left Edge Danger (`X: 0..84, Y: 180..920`):** Screen-space red chevron strip; pulses when player is within 4.0m of left screen boundary.
4. **Kraft Control Deck (`X: 0..720, Y: 920..1280`, Height: 360px):** Grounded cardboard deck (`#E3BA88`, 4px white torn paper top border). Isolates controls, preventing thumb occlusion.

---

## 3. Components with Exact Styling

### Palette: Pocket Parcel Town
`#2A2C44` (Ink Navy) | `#E3BA88` (Cardboard Kraft) | `#BA8E5C` (Kraft Shadow) | `#FFFDF5` (Manila Cream) | `#FFFFFF` (White Edge) | `#E85244` (Postal Red) | `#F7B336` (Delivery Gold) | `#D99B5B` (Parcel Brown) | `#2B9348` (Post Green) | `#3D78B5` (Courier Blue) | `#1B1F38` (Lantern Night) | `#FFD166` (Lantern Amber)

---

### Component Specifications

* **Top HUD Ribbon:**
  * *Course Tag (`X: 24, Y: 46`, `210 × 60`):* Manila card `#FFFDF5`, 4px border `#BA8E5C`, radius 10px. 24px Bold `#2A2C44`: `MARKET · R1` / `시장 · 1판`.
  * *Distance Rail (`X: 250, Y: 56`, `230 × 20`):* Trough `#EAD7BC`, 2px border `#BA8E5C`. Red tape fill tracks 0-100% of 380m. 4 runner pins track positions. Goal flag at 100%.
  * *Cargo Stack (`X: 496, Y: 46`, `200 × 60`):* Serrated stamp card, 5 slots (`28 × 34`): Filled = parcel `#D99B5B` with red tape `#E85244`; Empty = dotted border `#D0C2AE`. Weight badge: `x1.0` to `x0.7` in 16px Ink Navy.
  * *Rank Pin (`X: 250, Y: 84`, `100 × 44`):* Shield tag: 1st Gold `#F7B336`, 2nd Silver `#BAC4C8`, 3rd Bronze `#CD7F32`, 4th Red `#E85244`. Text: `26px` Bold White with 3px outline.
  * *Edge Danger (`X: 0..84, Y: 180..920`):* Gradient Red `#E85244` (alpha 0.6) to transparent with white chevrons. Pulses at 4Hz when distance < 2.0m.
  * *Language Toggle (`X: 620, Y: 114`, `76 × 36`):* Kraft stamp badge, 2px ink border. Text `16px` Bold: `EN | KO`.

* **Tactile Controls (Control Deck):**
  * *Virtual Stick (`Center: 180, 1100`, Radius: `100px`):* Outer ring `#BA8E5C` (r=100px); base plate `#FFFDF5` (r=90px) stamped with 4 arrows. Knob: Blue disc `#3D78B5` (r=44px), 3px white rim, shadow `(0, 8)` `#2A2C44` (alpha 0.35). Tilts/scales to 0.94 on touch.
  * *Jump Button (`Center: 590, 1070`, Radius: `76px`):* Resting thumb position. Base shadow `#9E6F3A` offset `(0, 8)`; face Orange `#F47E38` (r=72px), 4px white border. Jump arrow + `JUMP` (26px Bold White). Press: shifts `Y + 6px`, shadow drops to 2px, surface darkens 8%.
  * *Box Drop Button (`Center: 440, 1150`, Radius: `54px`):* Lower-left of Jump. Base shadow `#BA8E5C` offset `(0, 6)`; face Parcel Kraft `#D99B5B` (r=50px), 3px white border. Drop arrow + `DROP` (20px Bold Ink `#2A2C44`). Pill tag: `-1 BOX = DASH`.

* **Mode Select (3 Postal Cards, `Y: 340..900`, `X: 40`, `X: 265`, `X: 490`, `190 × 480`):**
  * *Classic:* Airmail border, 3-box courier art. Balance weight with survival.
  * *Lantern:* Night navy `#1B1F38`, amber foil `#FFD166`. Stay in leader's glow!
  * *Rush:* Speed chevrons `#E85244`. Rocket courier art. ≤2 boxes: ceiling boost & wall rebound!
  * *Action:* Tap scales card 1.06x with stamp. `CONFIRM DELIVERY` (`Y: 1020..1110`, w=460px) starts race.

* **Perk & Route Selection (2 Stacked Cards, `X: 50`, `Y: 460` and `Y: 720`, `620 × 210`):**
  * Watercolor card `#FFFDF5`, serrated border, 4px shadow. Left: 96px stamp icon in ink ring (Shoes, Spring, Wind, Gate). Right: Title `32px` Bold Navy, Effect `24px` `#3D78B5`, Advisory `18px` Muted `#6C757D`. Direct tap stamps `"APPROVED"` and advances stage.

* **Countdown Display (`Center: 360, 600`):**
  * `1.4s -> 0.7s`: Stamp 1: **`READY...`** (`36px` Red `#E85244`, tilt -4°).
  * `0.7s -> 0.0s`: Stamp 2: **`SET...`** (`40px` Gold `#F7B336`, tilt +3°).
  * `0.0s`: Stamp 3: **`DELIVER!` / `출발!`** (`56px` Post Green `#2B9348`, 0°) with paper dust burst.

* **Results Screen: Delivery Receipt (`X: 50, Y: 140`, `620 × 960`):**
  * Aged cream paper `#FFFDF8`, zigzag tear edges. Header: Postmark cancel stamp + `OFFICIAL DELIVERY MANIFEST`.
  * Stamp (`Center: 360, 300`): `#1 CHAMPION - DELIVERED` (Green `#2B9348`) or `DELIVERY FAILED - RETURNED` (Red `#E85244`) at -12° tilt.
  * Table: `Delivered`: `18 Parcels` (+360 pts); `Time`: `142.3s` (Gold `NEW RECORD!`); `Best Sector`: `Market (시장)`.
  * Medals: 6 circular wax seals in Gold/Silver/Bronze.
  * Button (`Y: 830..910`): Kraft button `DELIVER NEXT PARCEL` (`480 × 80`, Color: `#2B9348`, 30px White).

* **How-To Screen (3 Comic Panels, `Y: 280..850`, `620 × 170` each):**
  * *Panel 1:* Run & Jump — Courier leaping red wall with stick and jump arc indicators.
  * *Panel 2:* Weight is Life — Cargo stack showing speed gauge lowering as boxes increase.
  * *Panel 3:* Drop for Nitro — Courier ejecting a box to rocket past rivals.
  * *Dismiss (`Y: 880..960`):* Manila tag: `LET'S RACE!` (`420 × 76`).

* **Rating Card (`580 × 520` at `Y: 680`):** Inquiry card. 5 wooden star stamps filling with gold wax `#F7B336` on tap. Ruled memo line. Bilingual (EN/KO).

---

## 4. UI Motion & Tween Timings

All tweens execute on Godot 4.7 Compatibility renderer without per-frame allocations:

| Event | Recipe | Timing & Values |
| :--- | :--- | :--- |
| **Card Open** | `TRANS_BACK, EASE_OUT` | `0.32s`: Scale `0.85->1.0`, Rot `-5°->0°`, Alpha `0->1` |
| **Modal Dismiss** | `TRANS_QUAD, EASE_IN` | `0.20s`: Scale `1.0->0.92`, Offset Y `0->+80px`, Alpha `1->0` |
| **Button Down** | `TRANS_QUAD, EASE_OUT` | `0.06s`: Offset Y `0->+6px`, Shadow `8px->2px`, Scale `0.96` |
| **Button Up** | `TRANS_ELASTIC, EASE_OUT` | `0.22s`: Offset Y `+6px->0px`, Shadow `2px->8px`, Scale `1.0` |
| **Stamp Slam** | `TRANS_CUBIC, EASE_IN` | `0.14s`: Scale `1.7->1.0`, Alpha `0.2->1.0`. Shake `0.1s, 2px` |
| **Box Lost** | `TRANS_BACK, EASE_IN` | `0.24s`: Scale `1.0->1.4->0.0`, Rot `0°->25°`, Fade Red |
| **Box Added** | `TRANS_BOUNCE, EASE_OUT` | `0.30s`: Start Y `-40px`, Land Y `0px`, Squash `(1.2,0.8)->(1,1)` |
| **Hazard Edge** | `TRANS_SINE, EASE_IN_OUT` | Loop `0.28s`: Alpha `0.25<->0.75`, Chevrons `+24px/s` |
| **Receipt Unfold** | `TRANS_EXPO, EASE_OUT` | `0.45s`: Clip Height `0px->960px`, fold lines fade out |

---

## 5. Asset Production Specification (Total: ~1,020 KB < 1.5 MB)

All 2D assets are exported as optimized WebP/PNG textures:

| Asset Filename | Dimensions | Format | Est. Size | AI Generation Prompt / Style |
| :--- | :---: | :---: | :---: | :--- |
| `ui_deck_sheet.png` | 512 × 512 | RGBA PNG | 210 KB | "Paper-craft UI spritesheet: kraft paper, joystick base, buttons, torn borders, shadows, transparent." |
| `ui_icons_sheet.png` | 256 × 256 | RGBA PNG | 95 KB | "Paper cutout icons: parcel, winged shoe, spring, wind arrow, low gate, ice snowflake, lantern, wax seal, transparent." |
| `ui_howto_strip.png` | 512 × 512 | RGBA PNG | 240 KB | "Tutorial panels: leaping wall, heavy courier slow, dropping cargo for speed burst, transparent." |
| `ui_mode_cards.png` | 512 × 512 | RGBA PNG | 280 KB | "3 vertical mode postage cards: Classic daytime, Lantern night lamp, Rush racing chevrons, transparent." |
| `ui_stamps_sheet.png` | 256 × 256 | RGBA PNG | 85 KB | "Post rubber stamps: OUT FOR DELIVERY, DELIVERED, RETURN TO SENDER, 1ST PLACE, APPROVED, ink, transparent." |
| `ui_receipt_bg.png` | 512 × 512 | RGBA PNG | 110 KB | "Vintage folded receipt background, zigzag tear margins, watercolor paper grain, transparent." |

---

## 6. Judge Impact Priority & Implementation Guardrails

### Priority Order for Jam Judging Impact
1. **Camera Framing (Critical):** Elevate ground to Y≈780 to remove 500px underground void and open sky view.
2. **Dedicated Choice Cards (Critical):** Stop button hijacking; use touch cards to prevent onboarding confusion.
3. **Top HUD & Kill "0" (High):** Replace debug "0" with Course Tag, Cargo Life Stack, and Rank Shield.
4. **Stamp Slam Countdown (High):** `READY-SET-DELIVER` gives clear visual launch timing on mobile web.
5. **Ergonomic Control Deck (High):** Jump `(590, 1070)` and Drop `(440, 1150)` with press feedback cure control penalties.
6. **Receipt Results (Medium):** Accordion manifest with wax seals turns round end into a satisfying reward.
7. **3-Step How-To (Medium):** Visual comic strip replaces text wall for rapid onboarding.

### What NOT to Do (Anti-Patterns & Jam Traps)
* ❌ **No custom fragment shaders for UI:** Web Compatibility renderer stutters under heavy 2D canvas shaders. Use `StyleBoxFlat`, texture atlases, and Godot tweens.
* ❌ **No UI asset bloat:** Total UI assets must stay under 1.5 MB to prevent web judge bounce.
* ❌ **No logic mutations:** Retain all state variables (`phase`, `records`, `kit_move`, `ci`, `rnd`, `pl.cargo`). The UI wraps these without breaking logic.
* ❌ **No dark race screens:** Avoid heavy vignettes or dark overlays during races. Maintain bright paper contrast for dimmed mobile screens.
* ❌ **No disabling desktop fallbacks:** Ensure desktop judges can still use WASD/Arrows, Spacebar, and mouse clicks seamlessly.
