Score: 6.2/10

# External Visual-Design Review: "Off the Screen!" (Round 2)

**Game:** "Off the Screen!" (Korean: "화면 밖 경주")  
**Platform:** Mobile Web Portrait (720 × 1280), Touch Controls, Godot 4.7 Compatibility  
**Review Target:** `submit/screenrace/work/ui/after2/*.png` (evaluated against `before/*.png`, `after/*.png`, and `UI_SPEC.md`)  
**Design Palette:** NAVY `#2A2C44`, KRAFT `#E3BA88`, KRAFT_SH `#BA8E5C`, CREAM `#FFFDF5`, WHITE `#FFFFFF`, RED `#E85244`, GOLD `#F7B336`, GREEN `#2B9348`, BLUE `#3D78B5`, NIGHT `#1B1F38`, AMBER `#FFD166`

---

## 1. Executive Summary & Core Verdict

| Metric | Evaluation | Impact / Direction |
| :--- | :---: | :--- |
| **Overall Score** | **6.2 / 10** | **Tangible progress on clutter, but crippled by a game-breaking marker bug, massive bottom voids, and redundant text.** |
| **Maximalism Penalty** | **-2.3 pts** | Didactic sky labels persist into live play, cargo is encoded in 3 separate places, and rating is duplicated across two systems. |
| **Visual Unity Penalty** | **-1.5 pts** | An enormous blue collision diamond (`marker`) smothers the courier on 9 screens, hiding the backpack life mechanic. |

### Visual Design Critique
Round 2 (`after2/`) addresses several critical defects from Round 1:
- The giant, blinding green `FIRST CLASS EXPRESS` dash stamp from r1 has been replaced by clean radial action streaks.
- The competing red CTA button for "화면 밖 경주" on the Korean title screen has been stripped of its red plate.
- World-space 3D text billboards (`Label3D`) have been cleared from the diorama streets.

However, the build still violates the primary directive: **"The UI is too maximal. It must be MINIMAL: fewer elements, merge several UI pieces into one visual encoding... no duplicated information. Do NOT propose adding new UI elements."**

The three most glaring design failures in `after2` are:
1. **The Giant Blue Diamond Bug:** A 100×100px tilted 3D cube (`marker`) is rendered directly over the player courier across 9 of the 13 screens. It completely covers the runner's torso and backpack, concealing the running animation and hiding the physical parcel stack—the very core visual life encoding!
2. **500px Empty Deserts & Missing CTAs:** Mode Select (`04_mode.png`), Perk (`09_perk.png`), and Route (`10_route.png`) leave the lower 500–550 pixels (nearly 40–45% of the screen height!) completely blank. Worst of all, Mode Select lacks a primary CTA button, stranding players with no obvious way to start the race.
3. **Informational Redundancy:** Cargo/life is duplicated 3 ways (backpack mesh, Drop button badge, and a static tutorial subtitle in the sky). Rating is duplicated across the Results receipt and a separate modal card. Loose, unanchored parcel icons float aimlessly on the Route screen.

---

## 2. Checklist Evaluation (8 Jam Criteria + Visual Pillars)

### (1) One screenshot alone shows the core elements: 6.5 / 10
* **Finding:** In `06_race.png`, a viewer sees a side-scrolling courier race with a distance rail, touch controls, and left-edge hazard.
* **Flaw:** The essential mechanic—parcels as lives and weight—is obscured because the oversized blue diamond covers the courier's backpack. Falling off the left edge is explained via a static text subtitle rather than letting physical camera framing and the red chevron edge do the teaching.
* **Fix:** Remove the blue diamond mesh so the physical backpack stack is 100% visible. Delete the static text subtitle.

### (2) Characters / backdrop / UI styles unified: 6.0 / 10
* **Finding:** The "Pocket Parcel Town" papercraft theme, torn edges, and watercolor village backdrop are charming and distinct.
* **Flaw:** Visual unity is broken by:
  1. The untextured, flat blue diamond (`#3D78B5`) hovering like a developer debug hitbox.
  2. A stray brown platform ledge floating inside the solid underground dirt at `Y≈775` in `06_race.png` and `07_dash.png`.
  3. The 3D diorama leaking through gaps between modal cards in Results, Perk, and Route screens.
* **Fix:** Remove the blue diamond mesh; cull subterranean platforms; apply an 85% CREAM `#FFFDF5` paper wash over CanvasLayer 0 during modal dialogs.

### (3) Text and buttons readable on a real phone (720 × 1280): 7.0 / 10
* **Finding:** Primary action buttons (`PLAY`, `JUMP`, `DROP`) have large touch footprints (>88px) and strong contrast.
* **Flaw:**
  1. Sub-labels on tutorial cards (e.g., "1/4") and button pill texts are small (<18px).
  2. "Best 3" on the Classic mode card is ambiguous—is it 3rd place, 3 boxes, or 3 seconds?
* **Fix:** Increase tutorial badge typography to 22px Bold NAVY `#2A2C44`; clarify badge as `"BEST: 3 BOXES"`.

### (4) Every important control has visual feedback: 7.5 / 10
* **Finding:** Joystick knob tilts and scales to 0.94; Jump and Drop buttons sink 6px on touch with realistic shadow drop.
* **Flaw:** Mode cards (`04_mode.png`), Perk cards (`09_perk.png`), and Route cards (`10_route.png`) lack interactive clarity. In `04_mode.png`, tapping a card tilts it slightly, but there is no confirm/start button, leaving mobile users unsure whether the game is loading or waiting.
* **Fix:** Anchor the primary CTA `START DELIVERY` (`420 × 96` in RED `#E85244`) at the bottom of Mode Select. On Perk/Route cards, show an immediate rubber-stamp slam (`APPROVED` in GREEN `#2B9348`) before transitioning.

### (5) Start / play / game-over screens equally finished: 5.0 / 10
* **Finding:** Huge disparity in screen finish across the flow.
* **Flaw:**
  - Active Race (`06_race.png`) has a complete HUD, virtual controls, and lively backdrop.
  - Title (`01_title.png`) has 450px of empty cardboard desert at the bottom.
  - Mode Select (`04_mode.png`) is half-empty and lacks a start button.
  - Results (`11_results.png`) features a detached rating slip that leaves a bizarre gap showing the 3D runners' legs.
* **Fix:** Equalize polish: ground Title and Mode screens with balanced touch targets; integrate rating directly into the Results receipt paper.

### (6) At least one striking visual moment: 7.5 / 10
* **Finding:** The dash radial action burst (`07_dash.png`), the red rubber stamp slam (`READY` in `05_countdown.png`), and the red chevron edge hazard pulse (`08_edge_moment.png`) provide strong tactile feedback.
* **Flaw:** The courier at the center of the dash is completely concealed behind the blue diamond, turning a hero visual moment into an obscured silhouette.
* **Fix:** Delete the blue diamond so the courier's dynamic rocket pose and dropped box fly cleanly into view.

### (7) No clipping / misalignment / size mismatch: 4.5 / 10
* **Finding:** Widespread clipping and misalignment:
  1. Blue diamond clips through courier models and start gate poles on Title, Tutorial, and Race screens.
  2. In `08_edge_moment.png`, the blue diamond is sliced in half by the left screen edge.
  3. In `11_results.png`, the 3D runners peek through the gap between the receipt and the detached rating slip.
  4. In `06_race.png` and `07_dash.png`, a stray platform line floats in the underground dirt.
* **Fix:** Delete `marker`; unify Results receipt into a single contiguous slip; fix dirt platform culling.

### (8) A first-time player gets controls and goal in 10 seconds: 6.5 / 10
* **Finding:** 4-step tutorial with animated finger prompts clearly explains running, jumping, and dropping.
* **Flaw:** Mid-race text subtitles ("Boxes = lives + weight: more is slower" and "In the lead, speed shortens your view") force the player to read while racing. The missing start button on Mode Select causes hesitation before the race even starts.
* **Fix:** Strip mid-race explanatory text. Provide clear CTA progression on menus.

### Visual Pillars: Art Direction, Color, Depth, Animation, Camera
* **Art Direction:** Outstanding paper diorama identity. Needs ruthless purging of debug geometric artifacts.
* **Color / Composition:** Palette adherence is good, but vertical composition is heavily bottom-heavy, with empty voids on 6 screens.
* **Depth / Atmosphere:** Beautiful watercolor backdrops, but sky headroom is squashed because runner contact line is too high (Y=640 instead of Y=760).
* **Animation:** Tactile and punchy; stamps and dust bursts fit the craft aesthetic.
* **Camera / Transitions:** Needs camera ground adjustment to Y=760 to give vertical platforming breathing room and allow a dedicated 360px Kraft Control Deck at Y: 920..1280.

---

## 3. Concrete Fixable Problems Per Screen

---

### Screen 01: Title Screen (`01_title.png`)

1. **Problem 1-1 (HIGH): Giant Blue Diamond Obscuring Couriers (`marker` leak)**
   * **Severity:** HIGH
   * **Defect:** A 100×100px tilted blue diamond cube (`marker`) sits at `(260, 520)`, directly covering the couriers running along the diorama street. It looks like an untextured debug hitbox.
   * **Exact Fix:** REMOVE/HIDE the marker node on the title screen (`marker.visible = false`). The courier diorama must run cleanly with no geometric markers.

2. **Problem 1-2 (MEDIUM): 450px Empty Desert Void at Bottom (Y: 830..1280)**
   * **Severity:** MEDIUM
   * **Defect:** The `PLAY` button sits at `Rect2(130, 690, 460, 96)`. Below it, `?` `(214, 840, 80, 80)` and `EN | 한국어` `(334, 840, 172, 64)` float in mid-air. The entire bottom 450px is blank beige paper.
   * **Exact Fix:**
     - Shift `PLAY` button to `Rect2(150, 760, 420, 96)` in POSTAL RED `#E85244` with a 6px Kraft shadow `#BA8E5C`.
     - Align secondary controls directly beneath: `?` circular button at `(230, 880, 68, 68)` (CREAM `#FFFDF5`, 2px border `#BA8E5C`), and `EN | 한국어` pill at `(320, 884, 170, 60)`.
     - Lower ground contact to Y=760 so town diorama fills Y: 180..760, eliminating empty void.

3. **Problem 1-3 (LOW): Inactive Sky Platforms & Lack of Button Depth**
   * **Severity:** LOW
   * **Defect:** A white platform box with dark brown outline floats aimlessly in the sky at `(92, 270, 98, 28)`. The PLAY button has no bottom bevel shadow.
   * **Exact Fix:** Hide shortcut platforms during Title phase; add 6px bottom shadow offset `(0, 6)` in `#BA8E5C` to PLAY button for tactile depth.

---

### Screen 02: Tutorial Step 1 (`02_tutorial_step1.png`)

1. **Problem 2-1 (HIGH): Blue Diamond Obscuring Player Courier**
   * **Severity:** HIGH
   * **Defect:** The blue diamond marker is centered at `(250, 520)`, completely blocking the player character while trying to teach running mechanics.
   * **Exact Fix:** Set `marker.visible = false`. The courier's blue uniform (`#3D78B5`) already clearly identifies the player.

2. **Problem 2-2 (MEDIUM): Inactive Jump & Drop Buttons Competing for Focus**
   * **Severity:** MEDIUM
   * **Defect:** In Step 1 ("Push right to run!"), the Jump button `(516, 776)` and Drop button `(388, 856)` are fully rendered in bright red and kraft, distracting from the joystick prompt.
   * **Exact Fix:** Dim Jump and Drop buttons (`modulate:a = 0.2`) during Step 1. Highlight only the virtual stick with the golden hand guide.

3. **Problem 2-3 (LOW): Premature Edge Hazard Red Strip**
   * **Severity:** LOW
   * **Defect:** Left edge red torn hazard line is visible during basic run practice.
   * **Exact Fix:** Keep left edge neutral CREAM `#FFFDF5` during steps 1–3; activate red hazard chevrons only in Step 4 when edge danger is explicitly taught.

---

### Screen 03: Tutorial Step 3 (`03_tutorial_step3.png`)

1. **Problem 3-1 (HIGH): Blue Diamond Hides Parcel Throw & Backpack Decrement**
   * **Severity:** HIGH
   * **Defect:** Banner says "Throw a box to DASH! 3/4", but the runner is covered by the blue diamond, so the player cannot see the courier toss the parcel or watch the backpack shrink.
   * **Exact Fix:** Delete/hide the blue diamond. Show the physical courier animation clearly.

2. **Problem 3-2 (MEDIUM): Big Red Jump Button Stealing Hierarchy from Drop Button**
   * **Severity:** MEDIUM
   * **Defect:** The Jump button is huge (radius 76px, POSTAL RED `#E85244`), while the Drop button is small (radius 54px, KRAFT `#D99B5B`). New players tap the big red button by reflex.
   * **Exact Fix:** Dim Jump button (`modulate:a = 0.25`) during Step 3. Pulse a 4px GOLD `#F7B336` ring around the Drop button.

---

### Screen 04: Mode Select (`04_mode.png`)

1. **Problem 4-1 (HIGH): 500px Empty Desert & Missing Primary Start CTA**
   * **Severity:** HIGH
   * **Defect:** The 3 mode cards (`170 × 400px` each) sit at Y: 380..780. The lower 500px (Y: 780..1280, 39% of screen!) is completely empty. There is NO "START RACE" or "CONFIRM" button!
   * **Exact Fix:**
     - Anchor the primary CTA button from UI spec §3: `START DELIVERY` / `배달 출발!` at `Rect2(150, 1040, 420, 96)` in POSTAL RED `#E85244` (32px Bold WHITE, 6px shadow `#BA8E5C`).
     - Tapping a card selects it (Gold border `#F7B336`, 1.05x scale, -2° tilt); tapping `START DELIVERY` starts countdown.

2. **Problem 4-2 (MEDIUM): Clutter Corner Icons (Home & Star)**
   * **Severity:** MEDIUM
   * **Defect:** Home button `(44, 42)` and Star button `(676, 42)` are present. Having a Star rating icon on mode select is nonsensical clutter.
   * **Exact Fix:** REMOVE the Star button (`_rate_on = false`). Keep only a simple Kraft back chevron `(36, 46, 56, 56)` to return to Title.

3. **Problem 4-3 (LOW): Cryptic "Best 3" Badge on Classic Card**
   * **Severity:** LOW
   * **Defect:** Classic card has an orange pill at the bottom: parcel icon + "Best 3". Does "3" mean 3rd place, 3 boxes, or 3 seconds?
   * **Exact Fix:** Change text to `"BEST: 3 BOXES"` / `"최고: 3상자"` (18px Bold NAVY on CREAM pill).

---

### Screen 05: Countdown Screen (`05_countdown.png`)

1. **Problem 5-1 (HIGH): Giant Blue Diamond Sits Behind READY Stamp**
   * **Severity:** HIGH
   * **Defect:** The "READY" stamp (`Rect2(220, 390, 280, 100)`) slams down, but right behind it, the giant blue diamond covers the runners on the starting line.
   * **Exact Fix:** Set `marker.visible = false`. Show the 4 couriers on the track line in clean diorama view.

2. **Problem 5-2 (MEDIUM): Active Home Button During Countdown**
   * **Severity:** MEDIUM
   * **Defect:** Top-left Home button `(44, 42)` is active. Players readying their thumbs to sprint can accidentally trigger Home.
   * **Exact Fix:** HIDE Home button during countdown and active race (`_back_on = false`).

3. **Problem 5-3 (MEDIUM): 50% Screen Height Wasted on Bare Dirt**
   * **Severity:** MEDIUM
   * **Defect:** Ground line is at Y=640. Lower 640px is bare dirt with controls spread out.
   * **Exact Fix:** Lower ground line to Y=760; establish the Kraft Control Deck at Y: 920..1280 (360px height) with torn paper edge.

---

### Screen 06: Active Race Playfield (`06_race.png`)

1. **Problem 6-1 (HIGH): Giant Blue Diamond Obscures Player Model & Backpack**
   * **Severity:** HIGH
   * **Defect:** The blue diamond (`marker`) is rendered right on top of the player courier at `(260, 500)`, ~100×100px. It hides the runner's legs, torso, and parcel backpack, destroying the user's core vision: *"lives shown as parcels on the character instead of a counter"*.
   * **Exact Fix:** DELETE the 3D diamond `marker`. The player is already visually distinguished by their BLUE uniform (`#3D78B5`) and cap. The physical parcel backpack stack on the character is the hero life meter.

2. **Problem 6-2 (HIGH): Stray Platform Floating Inside Underground Dirt Void**
   * **Severity:** HIGH
   * **Defect:** At `X: 70..134, Y: 775` (directly left of the joystick), a brown platform outline (`64 × 12px`) floats inside the underground solid dirt.
   * **Exact Fix:** Cull all shortcut ledge instances whose `Y` coordinate is below `fy` (ground level) in course generation.

3. **Problem 6-3 (MEDIUM): Permanent Redundant Tutorial Subtitle in Sky**
   * **Severity:** MEDIUM
   * **Defect:** Text label "Boxes = lives + weight: more is slower" sits permanently at `(146, 74)` in Navy text, cluttering the sky and repeating tutorial text.
   * **Exact Fix:** REMOVE permanent sky subtitle. Use this area only for brief transient alerts (e.g. "LOW GATE - ≤2 BOXES", 2.0s fadeout).

4. **Problem 6-4 (MEDIUM): Triple Duplication of Cargo Count**
   * **Severity:** MEDIUM
   * **Defect:** Cargo count is shown (1) on backpack, (2) on Drop button badge ("3"), and (3) in top subtitle.
   * **Exact Fix:** Keep ONLY (1) the 3D backpack stack as the primary life meter, and (2) the compact numeric badge (`r=16px`) on the Drop button as a tactile ammo count. Remove all text labels.

5. **Problem 6-5 (LOW): Distance Rail Lacks Course Tag & Rival Pins**
   * **Severity:** LOW
   * **Defect:** Rail at `(120, 32, 480, 16)` has only a blue dot and finish flag. No course name or rival positions.
   * **Exact Fix:** Add a small Manila card at `(24, 20, 90, 32)`: `"MARKET · R1"`, and add 3 rival colored pips (`r=5px`) on the rail trough.

---

### Screen 07: Dash Action Moment (`07_dash.png`)

1. **Problem 7-1 (HIGH): Blue Diamond Ruins Dash Action Silhouette**
   * **Severity:** HIGH
   * **Defect:** Radial speed lines fire outward, but at the center is the static blue diamond, concealing the courier's forward rocket lean and ejected parcel.
   * **Exact Fix:** Remove blue diamond. Let the courier model's forward lean, smoke dust particles, and discarded parcel fly cleanly into view.

2. **Problem 7-2 (MEDIUM): Stray Underground Platform Still Visible**
   * **Severity:** MEDIUM
   * **Defect:** Stray brown bar at `(70, 775)` persists in the dirt.
   * **Exact Fix:** Cull subterranean platform rendering.

3. **Problem 7-3 (LOW): Static HUD Subtitle Persists During Sprint**
   * **Severity:** LOW
   * **Defect:** "Boxes = lives + weight: more is slower" remains static at top.
   * **Exact Fix:** Suppress HUD subtitle during race actions.

---

### Screen 08: Left Edge Hazard Moment (`08_edge_moment.png`)

1. **Problem 8-1 (HIGH): Blue Diamond Clips at Left Screen Edge**
   * **Severity:** HIGH
   * **Defect:** As the runner falls off the left edge, the blue diamond is sliced in half by the screen boundary at `X: 0..60, Y: 520`, creating an ugly geometric artifact.
   * **Exact Fix:** Remove the blue diamond. The red chevron hazard strip on the left edge (`X: 0..48`) pulsing in RED `#E85244` is already dramatic and effective on its own.

2. **Problem 8-2 (MEDIUM): Tutorial Text Subtitle Replacing Dynamic Camera Urgency**
   * **Severity:** MEDIUM
   * **Defect:** "In the lead, speed shortens your view" is displayed as a plain navy text label at `(150, 74)`.
   * **Exact Fix:** DELETE this text label. Game jam players do not read didactic text while frantically trying not to fall off-screen. Camera zoom and red chevron pulses communicate urgency visually.

---

### Screen 09: Perk Selection (`09_perk.png`)

1. **Problem 9-1 (HIGH): 550px Desert at Bottom (Y: 720..1280) & No Affordance**
   * **Severity:** HIGH
   * **Defect:** "Tough" and "Draft" cards (`580 × 160px`) sit at Y: 360 and Y: 560. The lower 550px is totally empty. No CTA, no explanation that tapping a card selects it.
   * **Exact Fix:**
     - Center the two cards vertically: Card 1 at `Rect2(50, 420, 620, 180)`, Card 2 at `Rect2(50, 640, 620, 180)`.
     - Add a bottom guidance pill: `Rect2(200, 940, 320, 52)` in CREAM `#FFFDF5`, 20px Bold NAVY: `"Tap a perk to equip"`.
     - Single-tap applies an ink rubber stamp `"EQUIPPED"` / `"장착!"` in POST GREEN `#2B9348` and smoothly advances to the next stage.

2. **Problem 9-2 (MEDIUM): Background 3D Scene Leaking Through Between Cards**
   * **Severity:** MEDIUM
   * **Defect:** Between the two cards (Y: 520..560), the 3D track, fence posts, and that blue diamond leak through without an overlay wash.
   * **Exact Fix:** Apply an 85% opacity CREAM `#FFFDF5` paper wash over CanvasLayer 0 during modal choice screens.

3. **Problem 9-3 (LOW): Home & Star Buttons Active on Inter-Round Choice**
   * **Severity:** LOW
   * **Defect:** Top-left Home and top-right Star buttons are present.
   * **Exact Fix:** Hide both corner buttons (`_back_on = false`, `_rate_on = false`).

---

### Screen 10: Route Selection (`10_route.png`)

1. **Problem 10-1 (HIGH): Floating Orphaned Parcel Icons at Y=310 (Maximalist Clutter)**
   * **Severity:** HIGH
   * **Defect:** Directly below "Next road?", two tiny parcel icons `[+] [+]` float without background, border, or label at `(316, 304)` and `(368, 304)`. They look like accidental graphics garbage.
   * **Exact Fix:** DELETE these floating loose icons. To show player cargo for the Low Gate requirement (≤2 boxes), merge it cleanly into the header subtitle: `"Next road? (Carrying 2 Boxes)"` in 24px NAVY `#2A2C44`.

2. **Problem 10-2 (HIGH): 550px Empty Desert at Bottom**
   * **Severity:** HIGH
   * **Defect:** Bottom half from Y=720 to 1280 is completely blank.
   * **Exact Fix:** Center cards vertically (Card 1 at Y: 400, Card 2 at Y: 620), and add bottom guidance pill at `(200, 940)`: `"Tap route to confirm"`.

3. **Problem 10-3 (MEDIUM): 3D Scene Leaks in Background**
   * **Severity:** MEDIUM
   * **Defect:** 3D world shows behind cards.
   * **Exact Fix:** Apply uniform 85% CREAM paper wash.

---

### Screen 11: Results Manifest Screen (`11_results.png`)

1. **Problem 11-1 (HIGH): Detached Rating Slip & 3D Scene Peeking Through Gaps**
   * **Severity:** HIGH
   * **Defect:** The receipt card sits at Y: 160..600. Below it, a detached rating slip sits at Y: 620..780. In between (Y: 590..630), the 3D courier models and track peek right through! Below Y=780, the bottom 500px is blank.
   * **Exact Fix:**
     - Unify into a single continuous delivery receipt manifest: `Rect2(50, 120, 620, 980)`.
     - Put all content inside the paper receipt:
       - Header: Postmark cancel stamp + `#1 · DELIVERED` (Green `#2B9348`).
       - Sub: `2 delivered · 4.0s` (+ stats).
       - Medals row: 6 circular wax seals.
       - Rating row: Embed the 5 wooden stars directly inside the receipt at Y=700 as an authentic "Delivery Feedback" stamp.
       - Footer buttons inside receipt at Y: 820..910: `PLAY AGAIN` (`420 × 80` in POSTAL RED `#E85244`) and Home icon.
     - Eliminate the detached floating bottom slip and cover the 3D scene with solid CREAM paper background.

2. **Problem 11-2 (HIGH): Split Rating System Redundancy**
   * **Severity:** HIGH
   * **Defect:** Rating is shown here on the results screen AND in a separate modal popup (`12_rating.png`).
   * **Exact Fix:** MERGE into one! Keep rating solely as a fun postmark star stamp on this receipt. Delete the separate modal card and remove the Star button from header navigation.

---

### Screen 12: Rating Modal Card (`12_rating.png`)

1. **Problem 12-1 (HIGH): Completely Redundant Modal Screen**
   * **Severity:** HIGH
   * **Defect:** This entire modal card ("How was the delivery?" + 5 stars + Comment + Close) duplicates the rating already present on `11_results.png`. It is triggered by the Star button in the top header, which encourages players to break out of the race flow.
   * **Exact Fix:** REMOVE THIS ENTIRE SCREEN AND MODAL. Game jam players should never be interrupted with standalone rating modals during race setup. Consolidate rating 100% into the end-of-race receipt manifest on `11_results.png`. Delete the top-right Star button from the HUD ribbon.

---

### Screen 13: Title Screen - Korean (`13_title_ko.png`)

1. **Problem 13-1 (HIGH): Giant Blue Diamond Obscuring Couriers**
   * **Severity:** HIGH
   * **Defect:** Same as Screen 01: giant blue diamond covers couriers in the diorama street.
   * **Exact Fix:** Hide `marker` on title screen.

2. **Problem 13-2 (MEDIUM): Subtitle "화면 밖 경주" is an Unstyled Plain Text String**
   * **Severity:** MEDIUM
   * **Defect:** While r1 removed the competing red button, the text "화면 밖 경주" is now raw unstyled 24px navy text floating in the white sky at Y=340. It lacks diorama framing and looks disconnected from the logo.
   * **Exact Fix:** Style subtitle as a neat Manila postal tag: `Rect2(250, 330, 220, 44)` in CREAM `#FFFDF5`, 2px KRAFT_SH border `#BA8E5C`, 22px Bold NAVY `#2A2C44` text.

3. **Problem 13-3 (MEDIUM): Massive 450px Empty Void at Bottom**
   * **Severity:** MEDIUM
   * **Defect:** Same as Screen 01: vast empty beige space from Y=790 to 1280.
   * **Exact Fix:** Re-anchor `배달 시작!` button and secondary controls as detailed in Screen 01.

---

## 4. Top 5 Removals / Merges

In strict adherence to the user directive: **"Flag clutter, redundant labels, duplicated info, and things to REMOVE or MERGE. Do NOT propose adding new UI elements."**

| Rank | UI Element / Clutter | Current Maximalist State | Minimalist Action | New Visual Encoding / Size / Color |
| :---: | :--- | :--- | :--- | :--- |
| **1** | **3D Blue Diamond Marker (`marker`)** | 100×100px tilted cube covering courier across 9 screens (`01`, `02`, `03`, `05`, `06`, `07`, `08`, `09`, `13`) | **REMOVE completely** | Delete `marker` mesh. The player is already visually encoded by their blue courier uniform (`#3D78B5`). Uncovers running animation and backpack stack. |
| **2** | **3-Way Parcel Indicators** | 3D backpack + Drop button badge ("3") + permanent sky tutorial subtitle ("Boxes = lives + weight") | **MERGE into backpack + single tactile ammo badge** | 3D backpack mesh is the sole hero visual meter for lives and weight. Drop button badge (`r=16px`) is the sole tactile ammo count. DELETE all sky subtitle text. |
| **3** | **Separate Rating Modal (`12_rating.png`) & Top-Right Star Button** | Standalone rating popup + Star icon active in HUD header across Mode, Perk, and Route screens | **REMOVE modal & icon; MERGE rating into Results receipt** | Delete `12_rating.png` and remove top-right Star icon. Embed 5 wooden stars directly inside the Results receipt manifest (`11_results.png`) at Y=700. |
| **4** | **Orphaned Loose Parcel Icons on Route Screen** | Two tiny parcel boxes floating unanchored at Y=310 (`10_route.png`) | **REMOVE loose icons; MERGE into header text** | Delete the floating icons. If communicating cargo for Low Gate requirement, merge into header subtitle: `"Next road? (Carrying 2 Boxes)"`. |
| **5** | **Empty Bottom Deserts on Menus & Missing Mode Start CTA** | 500–550px blank wastelands on Mode (`04_mode`), Perk (`09_perk`), and Route (`10_route`) | **MERGE with bottom touch deck & add spec CTA** | On Mode Select, anchor `START DELIVERY` (`420 × 96` in RED `#E85244`) at `Vector2(150, 1040)`. On Perk/Route, center cards vertically and use single-tap selection with stamp feedback. |

---

## 5. Judge Conclusion

"Off the Screen!" features exceptional papercraft diorama aesthetics and tactile design DNA. The step from Round 1 to Round 2 cleaned up several heavy visual obstructions (notably removing the blinding dash stamp and Korean red button conflict). 

However, the current **6.2 / 10** score reflects a game that is still fighting against UI maximalism:
- The giant blue diamond bug hides the central mechanic of carrying parcels on the character.
- Redundant sky text treats mobile judges like they are constantly in a tutorial.
- Empty bottom deserts on menu screens waste prime mobile thumb real estate and leave Mode Select without a clear start action.

By executing the **Top 5 Removals/Merges**—killing the blue diamond, stripping redundant parcel labels, consolidating rating into the receipt, removing distracting corner icons, and grounding menus with clear CTAs—this entry will instantly jump to an **8.5+ jam winner caliber**.
