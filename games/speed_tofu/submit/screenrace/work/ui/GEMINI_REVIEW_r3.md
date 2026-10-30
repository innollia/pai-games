Score: 6.4/10

# External Visual-Design Review: "Off the Screen!" (Round 3)

**Game:** "Off the Screen!" (Korean: "화면 밖 경주")  
**Platform:** Mobile Web Portrait (720 × 1280), Touch Controls, Godot 4.7 Compatibility  
**Review Target:** `submit/screenrace/work/ui/after3/*.png` (13 PNGs compared against `after2/*.png`, `before/*.png`, and `UI_SPEC.md`)  
**Design Palette:** NAVY `#2A2C44` | KRAFT `#E3BA88` | CREAM `#FFFDF5` | RED `#E85244` | GOLD `#F7B336` | GREEN `#2B9348` | BLUE `#3D78B5`  
**Review File:** `submit/screenrace/work/ui/GEMINI_REVIEW_r3.md`

---

## 1. Executive Summary & Progression

| Iteration | Overall Score | Key Progress / Regression | Primary Defect |
| :--- | :---: | :--- | :--- |
| **Before** | 4.2 / 10 | Baseline prototype (`tofu.gd` debug circles) | Giant debug "0", hijacked circles, text walls |
| **Round 1 (after)** | 5.8 / 10 | Introduced paper-craft diorama identity | Blinding green dash stamp, 3D world text leaks |
| **Round 2 (after2)** | 6.2 / 10 | Replaced dash stamp with speed lines; cleaned Korean CTA | 100px blue diamond covering couriers; split rating modal |
| **Round 3 (after3)** | **6.4 / 10** | **Merged rating stars into receipt; pruned loose icons; shrank diamond** | **`04_mode.png` capture regression; rating modal duplication; underground platform leak** |

### Core Verdict & Maximalism Assessment
Round 3 (`after3/`) makes clear, commendable strides toward the paper-craft vision:
1. **Rating Integration:** In `11_results.png`, the detached rating slip has been seamlessly unified into the base delivery receipt manifest with 5 stamped stars, eliminating the awkward gap that leaked 3D runner legs in Round 2.
2. **Icon De-Cluttering:** The orphaned parcel boxes `[+] [+]` floating on `10_route.png` have been purged.
3. **Marker Reduction:** The 100×100px blue cube that smothered the courier in Round 2 has been scaled down to a ~30px diamond and lifted above the parcel stack.
4. **Header Streamlining:** The top-right star rating button has been stripped from mode, perk, and route screens.

**However, the UI remains overly maximal, and a critical pipeline regression occurred:**
- **CRITICAL REGRESSION — `04_mode.png` is completely broken:** Image diff analysis proves `04_mode.png` is an identical 0-pixel-difference duplicate of `05_countdown.png`. The first-run tutorial skip bypassed Mode Select entirely and jumped straight into race countdown. Mode Select is totally missing from the round 3 review set.
- **Persistent Duplication (Rating):** Despite cleanly embedding rating stars into `11_results.png`, `12_rating.png` STILL pops up a separate modal card with identical star ratings, comment, and close buttons.
- **Persistent Text Clutter:** During active high-speed racing (`06_race.png`, `07_dash.png`), a didactic label `"Touch the torn left edge = lose a box"` hovers in the sky at Y=80, treating players like they are still trapped in the tutorial.
- **Floating Underground Platform:** A stray brown platform ledge floats inside the underground solid dirt at `X: 58..148, Y: 780..792` directly above the virtual stick in `06_race.png`, `07_dash.png`, and `08_edge_moment.png`.
- **500px Empty Deserts:** Perk (`09_perk.png`) and Route (`10_route.png`) cards still sit clustered at Y: 410..710, leaving 570px (45% of the screen!) as barren beige cardboard.

---

## 2. Checklist Evaluation (8 Jam Criteria)

### (1) Core elements visible in one shot: 7.0 / 10
* **Finding:** In `06_race.png`, the player sees a side-scrolling courier race, distance rail with runner pips, virtual stick, jump button, drop button with ammo badge, and left edge hazard.
* **Flaw:** The player model is partially obscured by scenery posts and background overlap, and the sky is cluttered by the static tutorial subtitle `"Touch the torn left edge = lose a box"`.
* **Fix:** REMOVE the static sky subtitle; allow the camera framing and red chevron pulse to convey the edge hazard.

### (2) Characters / backdrop / UI styles unified: 6.5 / 10
* **Finding:** Paper-craft diorama buildings, torn paper edges, and watercolor backdrops share a charming storybook aesthetic.
* **Flaw:** Visual unity is broken by:
  1. The 3D polygonal blue diamond marker (`marker`) hovering over the runner—it looks like a 3D editor gizmo rather than paper craft.
  2. A stray course platform bar floating inside the underground dirt at `Y ≈ 780` in `06_race.png`, `07_dash.png`, and `08_edge_moment.png`.
  3. The 3D world leaking through behind modal screens (`09_perk.png`, `10_route.png`, `11_results.png`).
* **Fix:** REMOVE `marker` mesh entirely (the player's distinctive coral uniform and backpack stack identify them). CULL subterranean platforms below ground level `fy`. Increase modal paper wash opacity to 90% CREAM `#FFFDF5`.

### (3) Text and buttons readable on a real phone (720 × 1280): 7.0 / 10
* **Finding:** Primary action buttons (`PLAY`, `JUMP`, `DROP`) have large touch footprints (>88px) and strong contrast against the kraft deck.
* **Flaw:**
  1. The Drop button ammo count ("3", "2") is rendered as loose text floating directly above the circular button face rather than being integrated inside a dedicated badge pill.
  2. In `13_title_ko.png`, the Korean subtitle `"화면 밖 경주"` is a raw unstyled text string floating below the English logo without postal tag framing.
* **Fix:** MERGE ammo count into a 32px circular badge on the top-right border of the Drop button; frame `"화면 밖 경주"` inside a neat CREAM `#FFFDF5` postal tag.

### (4) Every important control has visual feedback: 7.5 / 10
* **Finding:** Tactile spring physics on buttons (6px sink, shadow contraction) and dynamic radial speed lines during Dash (`07_dash.png`) provide excellent feedback.
* **Flaw:** Perk cards (`09_perk.png`) and Route cards (`10_route.png`) lack clear tap affordance. There is no visual cue explaining whether tapping a card selects it or immediately advances the game.
* **Fix:** When a perk/route card is tapped, apply an immediate rubber-stamp slam (`APPROVED` in GREEN `#2B9348`, 0.14s) before advancing to the next screen.

### (5) Start / play / game-over screens equally finished: 5.5 / 10
* **Finding:** Results receipt (`11_results.png`) is significantly more finished now with integrated star stamps, and Race (`06_race.png`) has complete controls.
* **Flaw:** Severe imbalance remains:
  - `04_mode.png` is missing/broken due to capture bypass.
  - Perk and Route screens waste 570px at the bottom.
  - Rating modal (`12_rating.png`) is an unstyled, redundant duplicate of the receipt stars.
* **Fix:** Fix Mode Select capture flow; balance Perk/Route card spacing; REMOVE `12_rating.png` completely.

### (6) At least one striking visual moment: 7.5 / 10
* **Finding:** Dash radial burst (`07_dash.png`), red chevron screen-space edge danger pulse (`08_edge_moment.png`), and the stamped `#1 · DELIVERED` receipt seal (`11_results.png`) are visually punchy.
* **Flaw:** In `08_edge_moment.png`, the blue diamond marker is jammed against the left edge, distracting from the dramatic courier ejection.
* **Fix:** REMOVE the blue diamond marker so the red runner's desperate struggle against the torn paper edge is unobstructed.

### (7) No clipping / misalignment / size mismatch: 5.0 / 10
* **Finding:** Several misalignments persist:
  1. `04_mode.png` is an identical duplicate of `05_countdown.png`.
  2. Stray underground platform floats at `X: 58..148, Y: 780..792` in `06_race.png` and `X: 680..720, Y: 780` in `08_edge_moment.png`.
  3. Stray platforms float in the sky at Y=130 and Y=290 in `07_dash.png`.
  4. Blue diamond marker clips against foreground lampposts at `X: 230..300, Y: 535` in `06_race.png`.
* **Fix:** Fix capture sequencing; cull platforms with `Y < fy`; remove `marker`.

### (8) A first-time player gets controls and goal in 10 seconds: 6.5 / 10
* **Finding:** 4-step tutorial with animated finger guides makes basic movement clear.
* **Flaw:** Redundant text subtitles mid-race create cognitive overload. Mode selection affordance is unclear without seeing the mode cards.
* **Fix:** Remove didactic text mid-race; let physical edge mechanics do the teaching.

---

## 3. Concrete Screen-by-Screen Critique & Exact Fixes

---

### Screen 01: Title Screen (`01_title.png`)
* **Finding:** The diorama runners (yellow, green, coral, blue) run cleanly along the track; the giant blue cube from r2 is gone.
* **Problem 1-1 (MEDIUM): 390px Empty Desert Void at Bottom (Y: 890..1280)**
  * **Element:** Button stack and cardboard footer.
  * **Action:** MOVE elements downward to balance the canvas.
  * **Exact Coordinates / Sizes:**
    - Move `PLAY` button from `Y = 700` to `Rect2(150, 780, 420, 96)` in RED `#E85244` with 6px shadow `#BA8E5C`.
    - Move secondary controls directly below: `?` button to `Rect2(230, 900, 72, 72)` (CREAM `#FFFDF5`, 2px border `#BA8E5C`), and `EN | 한국어` toggle pill to `Rect2(324, 904, 172, 64)`.
  * **Severity:** MEDIUM
  * **Likely File:** `g/sr_front.gd` (`_build_title()`, `_Deck`)

* **Problem 1-2 (LOW): Stray Course Platform Floating in Sky**
  * **Element:** Platform ledge at `X: 92..190, Y: 270`.
  * **Action:** REMOVE / HIDE course shortcut platforms while `phase == "title"`.
  * **Severity:** LOW
  * **Likely File:** `g/screenrace.gd` (`_reset()`, platform visibility)

---

### Screen 02: Tutorial Step 1 (`02_tutorial_step1.png`)
* **Finding:** Animated finger clearly demonstrates stick dragging to the right.
* **Problem 2-1 (MEDIUM): Persistent Blue Diamond Marker Above Courier**
  * **Element:** 3D diamond `marker` floating at `(310, 535)`.
  * **Action:** REMOVE `marker` node (`marker.visible = false`). The courier is the only character on screen; a floating geometric diamond is unnecessary debug clutter.
  * **Severity:** MEDIUM
  * **Likely File:** `g/screenrace.gd` (lines 1192–1194, 2993–2999)

* **Problem 2-2 (MEDIUM): Inactive Jump & Drop Buttons Competing with Joystick Prompt**
  * **Element:** Jump button `(590, 1070)` and Drop button `(440, 1150)`.
  * **Action:** MERGE focus by dimming inactive buttons: set `modulate.a = 0.2` on Jump and Drop buttons during Step 1.
  * **Severity:** MEDIUM
  * **Likely File:** `g/sr_front.gd` (`_enter(0)`)

---

### Screen 03: Tutorial Step 3 (`03_tutorial_step3.png`)
* **Finding:** Finger prompt successfully targets the Drop button with pulsing rings.
* **Problem 3-1 (MEDIUM): Blue Diamond Obscures Runner Parcel Ejection**
  * **Element:** 3D diamond `marker` at `(310, 535)`.
  * **Action:** REMOVE `marker`. Players must see the physical parcel fly off the courier's back without visual distraction.
  * **Severity:** MEDIUM
  * **Likely File:** `g/screenrace.gd`

* **Problem 3-2 (LOW): Red Jump Button Distracting from Drop Button Target**
  * **Element:** Jump button at `(590, 1070)`.
  * **Action:** Dim Jump button (`modulate.a = 0.25`) during Step 3 so the Drop button (`#E3BA88`, radius 54px) is the undisputed focal point.
  * **Severity:** LOW
  * **Likely File:** `g/sr_front.gd` (`_enter(2)`)

---

### Screen 04: Mode Select (`04_mode.png`)
* **CRITICAL REGRESSION / BLOCKER:**
* **Problem 4-1 (HIGH - BLOCKER): Exact Duplicate of Countdown Screen (Mode Cards Missing)**
  * **Element:** Whole screen.
  * **Defect:** `04_mode.png` is literally identical to `05_countdown.png` (diff bbox: None). The capture script skipped Mode Select because `front.tutorial_done` with `first = true` in `screenrace.gd:1118` immediately routes to `_pick_mode("jump")` without displaying mode cards! Furthermore, `sr_menus.gd:365` hid `_go_btn`.
  * **Exact Fix:**
    - In `screenrace.gd`: Ensure `_open_mode_select()` always presents `menus.show_modes()` when requested.
    - In `tools/capture.gd`: Fix line 67 so the tutorial skip lands in `phase == "mode"` and properly captures the 3 mode postal cards (`Classic`, `Lantern`, `Rush`) before starting the race.
    - On the Mode Select screen itself: Render the 3 mode cards at `CARD_Y = 490` (`190 × 460px` each at X: 40, 265, 490 in CREAM `#FFFDF5`, 2px border `#E3BA88`). Tapping a card directly launches the mode with a rubber-stamp feedback.
  * **Severity:** HIGH (BLOCKER)
  * **Likely File:** `g/screenrace.gd` (line 1118), `g/sr_menus.gd` (line 365), `tools/capture.gd` (lines 67–70)

---

### Screen 05: Countdown Screen (`05_countdown.png`)
* **Finding:** The "SET" rubber-stamp card in Delivery Gold `#F7B336` at `Rect2(252, 388, 216, 96)` provides good launch anticipation.
* **Problem 5-1 (MEDIUM): Active Home Button During Countdown**
  * **Element:** Top-left Home button at `(44, 42)`.
  * **Action:** REMOVE / HIDE Home button during countdown (`phase == "count"`). Players preparing their thumbs for the start signal risk accidental navigation aborts.
  * **Severity:** MEDIUM
  * **Likely File:** `g/sr_hud.gd` (`const NO_BACK_PHASES`, line 23)

* **Problem 5-2 (LOW): Blue Diamond Marker Leaking on Starting Line**
  * **Element:** Marker at `(255, 535)`.
  * **Action:** REMOVE marker.
  * **Severity:** LOW
  * **Likely File:** `g/screenrace.gd`

---

### Screen 06: Active Race Playfield (`06_race.png`)
* **Finding:** Clean distance rail at Y=40; crisp virtual joystick and buttons; courier backpack visibly carries 3 parcel boxes.
* **Problem 6-1 (HIGH): Stray Platform Ledge Floating Inside Underground Solid Dirt**
  * **Element:** Brown bar with white top border at `X: 58..148, Y: 780..792` (directly above the joystick knob).
  * **Defect:** A track shortcut platform was spawned below ground level, creating an ugly visual glitch in the solid dirt region.
  * **Action:** CULL all platforms where `y < fy` (ground contact line) in course generation.
  * **Severity:** HIGH
  * **Likely File:** `g/screenrace.gd` (course builder / platform loop)

* **Problem 6-2 (HIGH): Didactic Sky Subtitle Cluttering Active Race Headroom**
  * **Element:** Text label `"Touch the torn left edge = lose a box"` at `X: 180..540, Y: 74..90` in Navy `#2A2C44`.
  * **Defect:** Clutters high shortcut jumping headroom and repeats tutorial text while the player is concentrating on running.
  * **Action:** REMOVE permanent sky text label during active race. The red torn edge and pulsing chevrons already communicate danger visually.
  * **Severity:** HIGH
  * **Likely File:** `g/screenrace.gd` (line 841), `g/sr_hud.gd` (`set_line`)

* **Problem 6-3 (MEDIUM): 3D Blue Diamond Marker Clips Foreground Scenery**
  * **Element:** 30px diamond marker at `(270, 535)`.
  * **Defect:** As the courier runs past lampposts and awnings, the diamond clips through the wooden posts.
  * **Action:** REMOVE `marker` completely. The player's coral cap/shirt and backpack parcel stack are sufficient visual identifiers.
  * **Severity:** MEDIUM
  * **Likely File:** `g/screenrace.gd` (lines 1192, 2993)

* **Problem 6-4 (MEDIUM): Unanchored Ammo Digit "3" Above Drop Button**
  * **Element:** Digit "3" at `(440, 1076)`.
  * **Defect:** The number "3" floats in empty space above the Drop button with no backing plate or badge framing.
  * **Action:** MERGE into a compact badge pill: circular badge `radius = 16px` anchored at top-right of the Drop button at `(480, 1110)` in CREAM `#FFFDF5`, 2px border `#2A2C44`, text 18px Bold Navy.
  * **Severity:** MEDIUM
  * **Likely File:** `g/sr_hud.gd` (`_draw_kit`)

---

### Screen 07: Dash Action Moment (`07_dash.png`)
* **Finding:** Gold/white radial burst streaks communicate high speed effectively; parcel decrement to 2 is reflected on the button.
* **Problem 7-1 (MEDIUM): Didactic Sky Subtitle Persists During Sprint**
  * **Element:** `"Touch the torn left edge = lose a box"` at Y=80.
  * **Action:** REMOVE text.
  * **Severity:** MEDIUM
  * **Likely File:** `g/screenrace.gd`

* **Problem 7-2 (LOW): Stray Platform Bars in Sky at Y=130 and Y=290**
  * **Element:** Disconnected brown platform outlines floating in open sky.
  * **Action:** Ensure sky shortcut platforms have supporting wooden stilts or awning brackets rather than floating disembodied.
  * **Severity:** LOW
  * **Likely File:** `g/screenrace.gd`

---

### Screen 08: Left Edge Hazard Moment (`08_edge_moment.png`)
* **Finding:** Dynamic torn paper edge with red gradient and white animated chevrons `< < < < < < <` creates intense peril.
* **Problem 8-1 (HIGH): Blue Diamond Marker Jammed Against Screen Boundary**
  * **Element:** Marker at `(90, 540)`.
  * **Defect:** Sits directly between the falling runner and the chevron border, cluttering the critical elimination threshold.
  * **Action:** REMOVE marker.
  * **Severity:** HIGH
  * **Likely File:** `g/screenrace.gd`

* **Problem 8-2 (MEDIUM): Stray Platform Floating in Right Underground Dirt**
  * **Element:** Brown bar at `X: 680..720, Y: 780`.
  * **Action:** CULL subterranean platforms below ground level.
  * **Severity:** MEDIUM
  * **Likely File:** `g/screenrace.gd`

---

### Screen 09: Perk Selection (`09_perk.png`)
* **Finding:** Star button has been removed from header; two clean watercolor postal stamp cards (`Light Box` and `Tough`).
* **Problem 9-1 (HIGH): 570px Empty Cardboard Void at Bottom (Y: 710..1280)**
  * **Element:** Canvas layout.
  * **Defect:** Cards occupy Y: 410..710; the lower 45% of the mobile screen is completely bare.
  * **Action:** MOVE cards to ergonomic thumb center:
    - Card 1 (`Light Box`): `Rect2(50, 480, 620, 160)` in CREAM `#FFFDF5`, serrated stamp border.
    - Card 2 (`Tough`): `Rect2(50, 680, 620, 160)` in CREAM `#FFFDF5`, serrated stamp border.
    - Guidance chip at `Rect2(200, 890, 320, 48)` in CREAM `#FFFDF5`, 20px Bold Navy: `"Tap perk to equip"`.
  * **Severity:** HIGH
  * **Likely File:** `g/sr_menus.gd` (`CH_Y`, line 39)

* **Problem 9-2 (MEDIUM): 3D Town Diorama Leaking Through Card Gaps**
  * **Element:** Background CanvasLayer wash.
  * **Defect:** Streets and rooftops peek through the white card margins.
  * **Action:** Increase paper wash overlay opacity to 92% CREAM `#FFFDF5` during perk selection.
  * **Severity:** MEDIUM
  * **Likely File:** `g/sr_menus.gd` (`_wash_a`)

---

### Screen 10: Route Selection (`10_route.png`)
* **Finding:** Loose floating parcel icons from Round 2 have been pruned.
* **Problem 10-1 (HIGH): 570px Empty Bottom Void & Missing Player Cargo Context**
  * **Element:** Cards and header.
  * **Defect:** Card 1 says `"Low Gate: You fit"`, but the player cannot see their cargo count to know why they fit. The bottom 45% of screen is blank.
  * **Action:**
    - Reposition cards vertically: Card 1 at `Rect2(50, 480, 620, 160)`, Card 2 at `Rect2(50, 680, 620, 160)`.
    - MERGE cargo count into the header title: `"Next road? (Carrying 2 Boxes)"` in 32px Bold Navy `#2A2C44` at Y=360.
  * **Severity:** HIGH
  * **Likely File:** `g/sr_menus.gd` (`_fill_routes()`)

---

### Screen 11: Results Manifest Screen (`11_results.png`)
* **Finding:** Significant improvement! The detached rating slip from r2 has been fused into a single continuous delivery receipt with a perforated tear line and 5 star stamps.
* **Problem 11-1 (MEDIUM): 3D Diorama Leaking on Left/Right Flanks (X: 0..50, 670..720)**
  * **Element:** Canvas background.
  * **Defect:** The receipt card (`620px` wide) leaves 50px margins where 3D diorama buildings are visible.
  * **Action:** Apply a solid 88% CREAM `#FFFDF5` paper wash behind the receipt to prevent 3D world bleeding.
  * **Severity:** MEDIUM
  * **Likely File:** `g/sr_menus.gd` (`_wash`)

* **Problem 11-2 (LOW): Receipt Card Clipped at Bottom (Y=940) Leaving 340px Void**
  * **Element:** Receipt card height.
  * **Action:** Extend receipt paper downward from `RC_SIZE.y = 560` to `RC_SIZE.y = 740` (`Rect2(50, 140, 620, 880)`), giving breathing room between buttons and the rating stars.
  * **Severity:** LOW
  * **Likely File:** `g/sr_menus.gd` (`RC_SIZE`)

---

### Screen 12: Rating Modal Card (`12_rating.png`)
* **Problem 12-1 (HIGH - MAXIMALIST REDUNDANCY): Completely Redundant Modal Screen**
  * **Element:** Standalone modal card `Rect2(60, 560, 600, 440)`.
  * **Defect:** This screen violates the core directive: **"MINIMAL: fewer elements, merge UI pieces into one visual encoding, no duplicated info."** The 5 rating stars are ALREADY beautifully integrated into the delivery receipt on `11_results.png`! Having a separate popup modal that asks "How was the delivery?" with duplicate stars and buttons is pure maximalist bloat.
  * **Exact Fix:** REMOVE THIS ENTIRE SCREEN AND MODAL. Delete `_rate_open()` trigger. Rating lives 100% on the Results receipt manifest (`11_results.png`).
  * **Severity:** HIGH
  * **Likely File:** `g/screenrace.gd` (line 1118, `_rate_open`), `g/sr_menus.gd`

---

### Screen 13: Title Screen - Korean (`13_title_ko.png`)
* **Finding:** Competing red button from r1 is gone; Korean CTA `"배달 시작!"` is clear and bold.
* **Problem 13-1 (MEDIUM): Unstyled Floating Text for "화면 밖 경주"**
  * **Element:** Label at `(290, 340)`.
  * **Defect:** Raw 24px Navy text floats in the empty sky under the logo with no paper-craft framing.
  * **Action:** MERGE subtitle into a neat postal Manila card: `Rect2(245, 332, 230, 42)` in CREAM `#FFFDF5`, 2px Kraft border `#BA8E5C`, radius 8px, with 20px Bold Navy text.
  * **Severity:** MEDIUM
  * **Likely File:** `g/sr_front.gd` (`_build_title()`)

* **Problem 13-2 (MEDIUM): 390px Empty Bottom Void**
  * **Element:** Cardboard footer.
  * **Action:** Move buttons down identical to Screen 01.
  * **Severity:** MEDIUM
  * **Likely File:** `g/sr_front.gd`

---

## 4. Top 5 Removals / Merges (Anti-Maximalism Audit)

Strictly adhering to the user rule: **"Flag clutter and duplication; never propose adding UI."**

| Rank | Maximalist Clutter Element | Current Problematic State | Minimalist Action | New Consolidated Encoding |
| :---: | :--- | :--- | :--- | :--- |
| **1** | **Standalone Rating Modal (`12_rating.png`)** | Separate popup card with 5 stars, Comment, Close duplicating Results receipt | **REMOVE modal completely** | Rating is 100% handled by the 5 stamped stars on the Results manifest (`11_results.png`). Zero modal popups. |
| **2** | **3D Blue Diamond Marker (`marker`)** | Polygonal diamond hovering over runner across 6 screens (`02`, `03`, `05`, `06`, `07`, `08`) | **REMOVE mesh completely** | Courier's coral uniform (`#E85244`) and stacked backpack parcels are the sole visual hero encoding for player identity and lives. |
| **3** | **Didactic Sky Subtitle in Active Race** | `"Touch the torn left edge = lose a box"` permanent text at Y=80 during live racing | **REMOVE text label** | Red torn paper edge + animated screen-space chevrons (`#E85244`) communicate edge hazard visually without text. |
| **4** | **Subterranean Course Platform Ledges** | Brown platform bars floating in underground dirt at `Y ≈ 780` (`06_race`, `07_dash`, `08_edge`) | **REMOVE / CULL ledges where `y < fy`** | Solid underground cardboard dirt remains clean and uncluttered behind virtual controls. |
| **5** | **Loose Cargo Info on Route Pick (`10_route`)** | Route requirement ("You fit") detached from cargo count | **MERGE into header subtitle** | Change header text to `"Next road? (Carrying 2 Boxes)"`. Avoid floating loose parcel icons or extra widgets. |

---

## 5. Summary & Scorecard

```
Visual Polish:        6.8 / 10  (Clean paper diorama, punchy stamps, integrated receipt)
Information Density:  5.8 / 10  (Duplicate rating modal, redundant mid-race text)
Canvas Balance:       6.2 / 10  (Severe 570px bottom voids on perk/route screens)
Stability / Pipeline: 6.0 / 10  (04_mode.png duplicate capture regression)
-------------------------------------------------------------------------------------
OVERALL SCORE:        6.4 / 10
```

### Path to 8.5+ Jam Winner:
1. **Fix `04_mode.png` capture pipeline:** Ensure `menus.show_modes()` displays the 3 postal mode cards properly without bypassing to countdown.
2. **Delete `12_rating.png`:** Completely disable the standalone rating modal; let the receipt manifest stars be the sole rating mechanism.
3. **Cull subterranean platforms:** Strip course ledges spawned below ground level (`Y < fy`).
4. **Delete the blue diamond marker:** Let the character's coral uniform and parcel stack shine cleanly.
5. **Center perk and route cards:** Move cards from Y: 410..710 down to ergonomic thumb center (Y: 480..840) to eliminate the 570px bottom wasteland.
