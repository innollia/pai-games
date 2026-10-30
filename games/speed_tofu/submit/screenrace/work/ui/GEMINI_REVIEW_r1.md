# Visual Design Review: "Off the Screen!" (Game Jam Entry)

**Judge:** External Visual-Design Judge  
**Target Platform:** Mobile Web Portrait (720 × 1280), Touch Controls, Godot 4.7 Compatibility  
**Review Target:** `submit/screenrace/work/ui/after/*.png` (compared against `before/*.png`, `after_sheet.png`, `before_sheet.png`, and `UI_SPEC.md`)  
**Output File:** `submit/screenrace/work/ui/GEMINI_REVIEW_r1.md`  

---

## 1. Executive Summary & Score

| Overall Score | Core Verdict | Primary Directive Compliance |
| :---: | :---: | :---: |
| **5.8 / 10** | **"Promising paper-craft bones smothered by UI maximalism and text clutter."** | **Needs Immediate Pruning & Minimal Encoding** |

### Visual Design Critique
The transition from the raw tofu debug UI (`before/`) to the "Pocket Parcel Town" paper diorama (`after/`) introduced authentic tactile elements: torn paper edges, rubber stamps, wooden joystick bases, and watercolor backdrops. 

However, the UI currently suffers from **severe maximalism ("UI가 멕시멀해")**. Rather than letting the rich diorama scene and the 3D courier models communicate gameplay state, the interface plasters text labels, redundant badges, micro-indicators, and oversized stamps over the action. A player is told the same information in three or four different places simultaneously. Furthermore, camera framing leaves over 50% of the screen as an empty cardboard wasteland, while high shortcut platforms and beautiful sky watercolor are squashed into a cramped upper strip.

**To reach an 8.5+ jam standard, the design must shift from *informational clutter* to *minimal visual encoding*:** remove world text signs, eliminate duplicate parcel counters, shrink obstructive event stamps, and adjust camera framing so the physical race tells the story.

---

## 2. The Maximalist Trap: Redundancy & Clutter Analysis

The user's direction is unequivocal: **"UI가 멕시멀해. The UI must be MINIMAL: fewer elements, merge several UI pieces into one visual encoding, no duplicated info. FLAG CLUTTER. Propose removing, merging, shrinking, or encoding visually."**

Here are the four primary maximalist culprits in the current build:

```
[CURRENT MAXIMALIST OVERLOAD: 4-WAY PARCEL REDUNDANCY]
1. 3D World: Courier model carries stacked physical boxes on back (3D mesh)
2. Top HUD: Distance rail pin draws tiny 9x8px orange squares (_draw_me)
3. Bottom Deck: Drop button has a floating navy/red numeric circle badge ("3")
4. Dash FX: Floating "-1" text stamp pops up over courier's head
5. Track Signs: World Label3D billboards announce "2 boxes: you fit", "Box 3"

---> MINIMAL MERGE:
Keep ONLY (1) the 3D courier physical backpack stack as the primary visual life/weight meter,
and (2) the remaining count on the Drop button as a tactile ammo indicator.
DELETE the micro-box dots on the rail pin, DELETE the "-1" popup, DELETE the world text labels.
```

```
[CURRENT TEXT OVERLOAD: DOUBLE BILLBOARDING]
1. Screen-space Top HUD: Centered text chip (_line_txt): "← Red edge: lose a box, out if empty"
2. World-space 3D Signs: Label3D floating over track: "Off the left: lose a box · out if empty"
   AND "More boxes: slower but safer" floating permanently across village buildings!
3. Edge Hazard: Left-edge red chevron strip already pulses when nearing screen boundary!

---> MINIMAL MERGE:
DELETE all world Label3D billboards. The 3D world is a diorama, not a billboard alley.
The pulsating red chevron hazard strip on the left edge already visually encodes danger!
```

---

## 3. Checklist Evaluation (8 Jam Criteria + Visual Pillars)

### (1) One screenshot alone shows the core elements: **6.0 / 10**
* **Finding:** Looking at `06_race.png` or `07_dash.png`, one can tell it is a side-scrolling courier race with touch controls.
* **Flaw:** The essential mechanic—that falling off the *left* screen edge loses parcels—is communicated via an awkward text subtitle (`← Red edge: lose a box...`) rather than being immediately obvious from the visual composition. The runner is pushed too far right, and the left hazard edge is idle until danger strikes.
* **Fix:** Keep the left paper tear with a subtle permanent red tint gradient (X: 0..24), proving edge danger passively without needing tutorial text.

### (2) Characters / backdrop / UI styles unified: **5.5 / 10**
* **Finding:** The watercolor backdrops and paper receipt cards share a cohesive craft palette.
* **Flaw:** Visual unity breaks severely in three places:
  1. Platforms in the sky (`06_race.png`) are stark, black-bordered rectangular boxes (`StyleBoxFlat` with black outline) that look like dev collision shapes rather than papercraft props.
  2. Floating unstyled `Label3D` white text hovering in the 3D world clashes with 2D paper stamps.
  3. Leaking debug/tofu star elements and comment button on `11_results.png`.
* **Fix:** Style aerial shortcut ledges as papercraft bridge boards (KRAFT `#E3BA88` with 2px WHITE borders and drop shadows). Purge raw `Label3D` nodes.

### (3) Text and buttons readable on a real phone (720 × 1280): **6.2 / 10**
* **Finding:** Primary buttons (PLAY, JUMP, DROP) have generous touch targets (>88px) and bold Pretendard typography.
* **Flaw:** 
  1. The cargo micro-boxes under the top rail pin (`_draw_me`) are 9×8px. On a 6-inch phone held at arm's length, these are blurry brown smudges.
  2. "Best 3" floating at Y=930 on `01_title.png` is 18px dark ink lost against the empty deck background.
  3. `Label3D` text in `06_race.png` jitters during high-speed camera motion and is unreadable against detailed market awnings.
* **Fix:** Eliminate sub-16px micro-drawings. Rely on macroscopic visual encodings.

### (4) Every important control has visual feedback: **7.5 / 10**
* **Finding:** Virtual stick tilts and scales (0.94); Jump and Drop buttons sink 6px on touch with shadow contraction (8px → 2px).
* **Flaw:** Mode cards (`04_mode.png`) and Route/Perk cards (`09_perk.png`, `10_route.png`) lack clear interactive affordance. In `04_mode.png`, Classic card is tilted, but there is no primary confirm button. Does tapping start the game? Does tapping select? Players will double-tap out of uncertainty.
* **Fix:** Add a clear, single primary red button `CONFIRM` on card selection or show a crisp rubber stamp slam (`APPROVED`) upon single-tap selection before stage transition.

### (5) Start / play / game-over screens equally finished: **4.5 / 10**
* **Finding:** High disparity across screens.
* **Flaw:** 
  - Play screen (`06_race.png`) has custom HUD, custom deck, and active runners.
  - Title screen (`01_title.png`) has 500px of dead space and 3D world signs slicing through the logo.
  - Results screen (`11_results.png`) is an unfinished wreck: the tofu rating system (5 giant stars + Comment button) bleeds through directly under the receipt!
* **Fix:** Equalize finish: clean up Title screen background diorama, and properly encapsulate the rating system inside the paper manifest receipt.

### (6) At least one striking visual moment: **7.0 / 10**
* **Finding:** The rubber stamp slam (`READY`, `DELIVER!`, `#1 · DELIVERED`) with paper confetti particles is tactile and punchy.
* **Flaw:** The mid-race `FIRST CLASS EXPRESS` stamp (`07_dash.png`) is so enormous (400×160px) and stays so long that it blinds the player to oncoming obstacles during a 16 m/s speed burst, turning a visual highlight into an irritating gameplay hazard.
* **Fix:** Shrink event stamp to a compact top-floating banner (240×44px, Y: 140) or brief 0.25s flash with fast alpha fade.

### (7) No clipping / misalignment / size mismatch: **4.0 / 10**
* **Finding:** Severe clipping across multiple screens:
  1. `01_title.png` & `13_title_ko.png`: World sign text "...e left: lose a box · out if empty" clips through courier models and start gate poles.
  2. `13_title_ko.png`: Subtitle "화면 밖 경주" is styled as a red CTA button, clashing with the "배달 시작!" red button below.
  3. `11_results.png`: Rating stars clip out of the receipt bounds onto the bottom background.
  4. `04_mode.png`, `09_perk.png`, `10_route.png`: 3D track and fences awkwardly peek through card margins.
* **Fix:** Ensure 3D world signs are destroyed, camera background is cleanly washed during modal states, and tofu `_rate_box` is hidden.

### (8) A first-time player gets controls and goal in 10 seconds: **6.0 / 10**
* **Finding:** 3-button layout (Stick, Jump, Drop) is intuitive.
* **Flaw:** The player is subjected to information overload: 4 tutorial slides, HUD rail pins, top hint text, floating 3D signs, and button tags. A player spends 10 seconds reading text rather than grokking the race through intuitive visual cues.
* **Fix:** Let physical gameplay demonstrate rules: falling off left drops a box; jumping clears red crates; dropping cargo triggers a rocket trail.

### Visual Pillars: Art Direction, Color, Depth, Animation, Camera
* **Art Direction:** Strong paper diorama concept. Must ruthlessly strip out leftover digital UI tropes (plain wireframe platforms, unstyled 3D labels, standard dialog buttons).
* **Palette:** Strict adherence to the 11-color palette is mostly maintained, but `13_title_ko.png` violates the primary rule: *"Don't use more than one red call to action per screen."*
* **Depth / Atmosphere:** Beautiful backdrops, but currently squashed because runner contact line is too high (Y=620 instead of Y=760), stealing sky headroom.
* **Camera / Transitions:** Ground height must be lowered so runners feel grounded and vertical routes have breathing room.

---

## 4. Concrete Fixable Problems Per Screen (Ordered by Severity)

---

### HIGH SEVERITY (Game-Breaking, Misleading, or Ugly Leaks)

#### Problem H-1: Tofu Rating Card Bleeding onto Results Screen
* **File:** `submit/screenrace/work/ui/after/11_results.png`
* **Defect:** Below the delivery receipt card (`RC_POS: (50, 140)`, ending around Y=880), 5 giant unparented stars (`_stars` from `tofu.gd`) and a blue-bordered "Comment" button (`_WORD_RECT`) float awkwardly on the bare background. This occurs because `tofu._over()` forces `_rate_box.visible = true`, bypassing the custom menu layer.
* **Minimal Fix:**
  1. In `g/sr_menus.gd` inside `show_results()`, immediately set `game._rate_box.visible = false` and ensure tofu's raw rating nodes are hidden.
  2. Consolidate rating into the receipt itself: embed a single compact stamp line inside the receipt paper (`Rect2(120, 720, 480, 44)`): 5 small Gold stars (`#F7B336`, r=14px) with a small Navy text tag `"Rate Delivery"`.
  3. Ground the bottom with the existing `PLAY AGAIN` button (`420 × 80` in POST GREEN `#2B9348` or POSTAL RED `#E85244`) and Home icon.

#### Problem H-2: Mid-Race "FIRST CLASS EXPRESS" Stamp Blinds the Player
* **Files:** `submit/screenrace/work/ui/after/07_dash.png`, `08_edge_moment.png`
* **Defect:** When activating a dash or triggering an event, an enormous green paper stamp (`FIRST CLASS EXPRESS`, ~400 × 160px) slams dead center into the screen (`Vector2(160, 460)` to `(560, 620)`). Because the player is dashing at 16 m/s, this opaque graphic completely occludes incoming red walls, pits, and rival couriers.
* **Minimal Fix:**
  1. REMOVE the central full-screen event stamp from the race playfield.
  2. SHRINK event notifications to a slim top ribbon tag: `Rect2(240, 100, 240, 36)`, CREAM paper background, 2px GREEN border `#2B9348`, 20px Bold Navy text.
  3. Visual Dash Encoding: Encode the dash directly onto the courier sprite: spawn 3 paper speed-lines / dust puffs behind the runner's feet (`#FFFDF5`), leaving the gameplay track 100% visible.

#### Problem H-3: World-Space `Label3D` Signs Colliding and Duplicating HUD Text
* **Files:** `01_title.png`, `02_tutorial_step1.png`, `05_countdown.png`, `06_race.png`, `08_edge_moment.png`, `09_perk.png`, `10_route.png`, `13_title_ko.png`
* **Defect:** In `g/screenrace.gd`, `_sign()` places 3D floating text billboards at `fy + 3.6` ("Off the left: lose a box · out if empty", "More boxes: slower but safer"). These hover across the 3D world, clipping through fence posts, courier heads, and menu cards. Simultaneously, `_draw_line()` in `sr_hud.gd` displays the exact same message in the top HUD ribbon!
* **Minimal Fix:**
  1. REMOVE all `_sign()` calls and delete `Label3D` generation from `screenrace.gd`.
  2. The left red edge danger is already visually represented by the red chevron boundary strip.
  3. For course rules (e.g. low gate, ice), rely solely on the transient top HUD line chip (`sr_hud._draw_line`, Y=104) which fades after 2.6 seconds. Never pollute the 3D diorama with floating text.

#### Problem H-4: Two Competing Red CTA Buttons on Korean Title Screen
* **File:** `submit/screenrace/work/ui/after/13_title_ko.png`
* **Defect:** Directly beneath the logo, the subtitle "화면 밖 경주" is rendered in a red rounded rectangle (`#E85244`) with a white paper border, matching the visual weight and style of the primary "배달 시작!" CTA button. This directly violates DESIGN_SYSTEM.md: *"Don't use more than one red call to action per screen."*
* **Minimal Fix:**
  1. REMOVE the red button background from "화면 밖 경주".
  2. Encode subtitle as a muted Manila stamp tag: `Rect2(260, 330, 200, 40)`, background CREAM `#FFFDF5`, 2px border KRAFT_SH `#BA8E5C`, text 22px Bold NAVY `#2A2C44`.
  3. Keep POSTAL RED `#E85244` exclusively for the single primary CTA button: `배달 시작!` (`420 × 96` at `Y: 700..796`).

---

### MEDIUM SEVERITY (Maximal Clutter, Redundancies, Unbalanced Layout)

#### Problem M-1: 4-Way Duplication of Cargo/Parcel Count
* **Files:** `06_race.png`, `07_dash.png`, `08_edge_moment.png`
* **Defect:** The player's parcels (lives and weight) are displayed in four redundant locations:
  1. 3D courier backpack stack.
  2. Rail pin micro-squares (9×8px dots under the pin in `_draw_me`).
  3. Drop button badge (`r=19px` circle with number "3").
  4. Floating "-1" text popup over the courier's head during dash.
* **Minimal Fix:**
  1. REMOVE the mini-parcel squares from the distance rail pin (`sr_hud.gd` lines 312–326). They are unreadable clutter on mobile screens.
  2. REMOVE the floating "-1" text popup during drop.
  3. MERGE into physical visual encoding: The 3D courier backpack stack is the hero visual element!
  4. Retain ONLY the small numeric badge on the Drop button (`Center: (478, 1112)`, r=16px, NAVY `#2A2C44` when >1, RED `#E85244` when 1) as a tactile touch indicator.

#### Problem M-2: Massive Empty Deck Void (Y: 650..1280) & Squished Sky Playfield
* **Files:** `01_title.png`, `04_mode.png`, `06_race.png`, `09_perk.png`
* **Defect:** The race track is placed too high (ground contact at Y≈620). The bottom 660px (>51% of screen height) is an empty expanse of beige cardboard with only 3 buttons spread far apart. Meanwhile, the upper playfield has barely 300px of headroom, causing high shortcut awnings and background scenery to be cramped.
* **Minimal Fix (Align with UI_SPEC §2):**
  1. Lower camera vertical offset so runner ground contact is at **Y = 760px**.
  2. Reduce underground dirt to 160px (Y: 760..920).
  3. Ground the Kraft Control Deck to **Y: 920..1280 (Height: 360px)** with a clean 4px white torn paper top border (`T.draw_torn_edge`).
  4. Expand sky playfield headroom to 440px (Y: 180..620) so shortcuts and watercolor backdrops breathe.

#### Problem M-3: Unstyled Black Wireframe Shortcut Platforms in Sky
* **Files:** `02_tutorial_step1.png`, `03_tutorial_step3.png`, `05_countdown.png`, `06_race.png`, `07_dash.png`, `08_edge_moment.png`
* **Defect:** In the sky (Y: 260..380), aerial shortcut platforms appear as stark black-bordered rectangles with plain white fills. They look like unfinished developer debug colliders and completely shatter the paper diorama immersion.
* **Minimal Fix:**
  1. Style aerial platforms as papercraft wooden slats: Fill KRAFT `#E3BA88`, top highlight WHITE `#FFFFFF` (3px), bottom shadow KRAFT_SH `#BA8E5C` (4px).
  2. Replace hard black outline with 2px INK NAVY `#2A2C44` or torn paper edge.

#### Problem M-4: Ghost/Useless Corner Icons on Title, Tutorial, and Race
* **Files:** `01_title.png`, `02_tutorial_step1.png`, `04_mode.png`, `06_race.png`, `09_perk.png`
* **Defect:** 
  - Faint grey circle icons sit at top corners (Home at `(44, 42)`, Star/Rate at `(676, 42)`).
  - Having a Home button on the *Title Screen* or *Tutorial* is nonsensical.
  - Having an active Rate button directly adjacent to the race distance rail risks accidental touches during frantic thumb play, triggering a modal mid-race!
* **Minimal Fix:**
  1. On Title, Mode, and Tutorial screens: HIDE both corner buttons (`_back_on = false`, `_rate_on = false`).
  2. During active race (`phase == "race"`): HIDE the Rate button (`_rate_on = false`). The user should only rate between rounds or on the results receipt.
  3. Keep only the small Kraft back tag (`12, 20, 60, 40`) if explicitly paused.

#### Problem M-5: Mode Select Screen Void & Missing Action Button
* **File:** `submit/screenrace/work/ui/after/04_mode.png`
* **Defect:** The 3 vertical cards (Classic, Lantern, Rush; `190 × 480px`) float in the top half (Y: 240..720). The entire lower half (Y: 720..1280) is an empty blank desert. Selecting Classic tilts the card, but there is no call-to-action button, leaving mobile users confused whether they have selected a mode or launched it.
* **Minimal Fix:**
  1. Position the 3 cards vertically at `Y: 200..740` (X: 30, 265, 500; width: 190px).
  2. Add the primary CTA button from spec: `START DELIVERY` / `배달 출발!` (`420 × 96` in POSTAL RED `#E85244` at `Vector2(150, 1020)`, 32px Bold White).
  3. Single-tapping a card selects it (Gold border `#F7B336`, 1.05x scale, -2° tilt). Tapping `START DELIVERY` initiates the race countdown.

---

### LOW SEVERITY (Polish, Spacing, and Visual Hierarchy)

#### Problem L-1: Disconnected "Best 3" Label on Title Screen
* **Files:** `01_title.png`, `13_title_ko.png`
* **Defect:** Floating in the lower half at Y=930, the label "Best 3" / "최고 배달 3" sits in tiny 18px text with no visual container, looking like an orphaned debug print.
* **Minimal Fix:**
  1. Merge it into the Title card structure: place a small Kraft stamp badge directly above or below the `PLAY` button: `Rect2(280, 810, 160, 36)`, CREAM fill, 2px KRAFT_SH border, 18px Bold Navy: `"BEST: 3 BOXES"`.

#### Problem L-2: Card Peeking and Transparent Washes on Inter-Round Choices
* **Files:** `09_perk.png`, `10_route.png`
* **Defect:** On Perk and Route pick screens, the 3D track, fence posts, and lingering world signs are visible through the gaps between cards. The bottom 40% of the screen is an empty beige expanse.
* **Minimal Fix:**
  1. Apply a solid paper wash overlay: Color `#FFFDF5` at 88% opacity over the 3D scene (CanvasLayer 0).
  2. Center the two horizontal cards vertically: Card 1 at `Y: 360`, Card 2 at `Y: 620` (`620 × 200px`, X: 50).
  3. Ground the bottom with a brief instruction pill: `Rect2(200, 920, 320, 50)`, CREAM paper, 20px NAVY text: `"Tap card to select"`.

#### Problem L-3: Route Offer Redundant Parcel Icons
* **File:** `submit/screenrace/work/ui/after/10_route.png`
* **Defect:** Two tiny parcel box icons float disconnected in the center space above the cards (`Y: 300`), with no explanatory text or frame.
* **Minimal Fix:**
  1. REMOVE these floating loose icons.
  2. If showing the player's current cargo to help them decide on the "Low Gate" (which requires ≤2 boxes), integrate it into the title ribbon: `"Next road? (Carrying 2 Boxes)"` in 28px Bold Navy at Y: 220.

---

## 5. The Minimalist Consolidation Matrix

Following the user's explicit rule: **"Do NOT propose adding new UI elements; propose removing, merging, shrinking, or encoding visually."**

| UI Element | Current Maximal State (File) | Minimalist Action | New Visual Encoding / Size / Color |
| :--- | :--- | :--- | :--- |
| **World Signs (`_sign`)** | Floating `Label3D` white text on track (`06_race.png`) | **REMOVE completely** | Delete `Label3D`. Edge hazard is already encoded by the left red chevron strip. |
| **Top Line Text Chip** | Permanent duplicate of world signs (`06_race.png`) | **SHRINK & MERGE** | Keep only for dynamic alerts (LINE_T = 2.0s fade), 22px NAVY on CREAM tag. |
| **Parcel HUD Dots** | 9×8px brown boxes under rail pin (`06_race.png`) | **REMOVE completely** | Rely 100% on the 3D courier backpack model for visual cargo count. |
| **Drop Button Badge** | Redundant numeric badge ("3") on button (`06_race.png`) | **MERGE & SHRINK** | Keep as compact remaining ammo badge (`r=16px`, NAVY/RED) on the Drop disc. |
| **Dash "-1" Popup** | Floating text "-1" above courier head (`07_dash.png`) | **REMOVE completely** | Encode visually as 3 paper speed-lines / dust puffs behind feet (`#FFFDF5`). |
| **Event Stamp (`FIRST CLASS`)** | 400×160px central opaque stamp (`07_dash.png`) | **SHRINK & RELOCATE** | Shrink to 240×44px top banner (`Y: 100`), or fast 0.25s burst that clears playfield. |
| **Sky Shortcut Ledges** | Black wireframe boxes (`06_race.png`) | **ENCODE VISUALLY** | Style as papercraft boards: KRAFT `#E3BA88`, 2px WHITE edge, soft NAVY shadow. |
| **Tofu Rating Leaks** | 5 raw stars + Comment button below receipt (`11_results.png`) | **REMOVE from root, MERGE into receipt** | Hide `_rate_box`. Embed single 5-star stamp line inside the receipt paper (`Y: 720`). |
| **Korean Title Subtitle** | Red button rectangle "화면 밖 경주" (`13_title_ko.png`) | **MERGE / STRIP RED** | Remove red button background. Use neutral CREAM tag with NAVY text `#2A2C44`. |
| **Corner Icons (Home/Rate)** | Active on Title, Tutorial, and Race (`01_title`, `06_race`) | **REMOVE during play** | Hide completely on Title, Tutorial, and Race. Show Rate only on Results receipt. |
| **Race Playfield Height** | Ground at Y=620; bottom 51% is empty deck (`06_race.png`) | **RE-FRAME CAMERA** | Lower ground to Y=760. Control deck Y: 920..1280 (360px). Headroom grows to 440px. |
| **Mode Select Void** | 3 cards floating over 500px void (`04_mode.png`) | **MERGE with Spec CTA** | Cards at Y: 200..740. Primary CTA `START DELIVERY` (`420×96` in RED `#E85244`) at Y: 1020. |

---

## 6. Implementation Code Guidance for Next Revision

To execute these fixes without introducing new nodes or shaders:

1. **In `g/screenrace.gd`:**
   - In `_build_course()`: Comment out or delete all calls to `_sign(...)` (lines ~1264–1265).
   - In `_setup()`: Adjust camera vertical tracking offset: `camy = lerpf(camy, lead.p.y + 6.2, ...)` so runner contact stays at Y=760.
   - In `_finish()`: Explicitly ensure `_rate_box.visible = false` before calling `menus.show_results(data)`.

2. **In `g/sr_hud.gd`:**
   - In `_draw_me()` (lines 312–326): Remove the loop drawing parcel rectangles under the runner pin.
   - In `_draw_top()`: Suppress `_corner_icon(..., "rate")` whenever `phase == "race"`.
   - In `_draw_line()`: Keep line width strictly constrained (`max_w = 540`) with fast alpha fadeout.

3. **In `g/sr_front.gd`:**
   - In `_draw_title()`: When `game.lang == "ko"`, render the subtitle as a simple text label or Kraft stamp, never with a `T.RED` background plate.
   - On title screen init: Set `_back_on = false` and `_rate_on = false`.

4. **In `g/sr_menus.gd`:**
   - In `show_results()`: Add `if game._rate_box: game._rate_box.visible = false`.
   - In `countdown_tick(2)` and dash triggers: Limit stamp display life to `0.3s` and position outside the central running track (above Y: 180 or below Y: 800).
   - In `_draw_mode()`: Anchor the `START DELIVERY` button at `(150, 1020, 420, 96)` in `T.RED`.

---

## 7. Conclusion

"Off the Screen!" has an exceptional paper-craft diorama art direction that sets it apart from typical game jam entries. The current 5.8/10 visual score is primarily due to **UI over-engineering and informational redundancy**.

By stripping away the 3D billboard text, cutting the 4-way parcel indicators down to the physical courier stack, shrinking the blinding dash stamp, and fixing the rating leak on the results receipt, the game will instantly gain clarity, elegance, and tactile delight—delivering a minimal, polished, and mobile-friendly experience worthy of top jam honors.
