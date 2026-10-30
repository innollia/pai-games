# 작은 행성 (tinyplanet) v5 — Dialogue brief

You are the writer. Write ALL player-facing text for this game into ONE file:
`submit/tinyplanet/dialogue.json` (path relative to the workspace `C:\projects\pai-games\games\speed_tofu`).
Do NOT edit, create, or delete any other file. `g/tinyplanet.gd` may be read for context only.

## Output format

```json
{
  "<key>": {"ko": "...", "en": "..."},
  ...
  "howto": {"ko": "...", "en": "..."}
}
```

- Every key listed below must be present, spelled exactly. No extra nesting. UTF-8, valid JSON (no comments, no trailing commas).
- Placeholders `{planet}`, `{target}`, `{src}` must appear in both ko and en exactly where listed (the game fills them with names).
- Use `\n` only inside `howto` (and optionally to split a speech bubble into 2 lines).

## The world

A tiny traveler (a white tofu-like figure) lives in one sky with five tiny planets, two moons and one red fire star, all visible at once. It feels like a picture book about a lonely traveler hopping between small worlds and helping each lonely resident — warm, a little melancholic, gentle wonder. Think "a boy visiting tiny planets", but write ORIGINAL lines: no quotes or paraphrases from *The Little Prince* (no "taming", no "what is essential is invisible", no fox, no baobabs, no lamplighter/king/businessman, no "you are responsible for your rose" style lines). The rose here is our own character.

Movement is real gravity flight: run fast around a tiny planet (left stick), jump near take-off speed and you escape that planet's gravity, fly through space, get pulled by another planet, curve around it and land. Miss and you drift into deep space and die. A dotted line in front of your feet shows "the path if you jump now": green = reaches another planet, red = danger, white = falls back home. A bar at the top turns green when a jump would escape. A yellow light pillar marks where to go. Once per flight, with the sail, jumping again turns the flight toward the stick direction. Button "놓기"(drop) drops the carried item onto the small yellow dot under your feet. Glass items crack if you land hard and break if you slam down. 3 lives, refilled when you land on a new planet for the first time.

### The five jobs (in order)
1. **Windmill planet** (풍차의 별, green, big). Keeper: 풍차지기. The wind stopped. Run around the planet staying ON THE GROUND at near take-off speed (≥80% of liftoff) to wake the wind; if your feet leave the ground the wind breaks; hop small rocks. Reward: a sail. Then the first flight lesson: a yellow lane on the equator; run it hard and JUMP AT THE GREEN CELL at its end to reach the Post planet (purple). While flying, jump again while pushing the stick = the sail turns you once.
2. **Post planet** (우편의 별, purple). Mail carrier: 우체부. Take a parcel to the house on the **white chimney moon** (굴뚝 달) — the walls are too high to walk in. The moon is tiny, so even a little speed lifts you; while floating over the chimney press **'놓기'(drop)**; the yellow dot under you is where it lands. Then go to the glass-flower planet (green).
3. **Glass-flower planet** (유리꽃의 별, mint). Gardener: 정원사. Carry the glass flower to the friend on the **mint friend moon** (친구 달). Landing hard cracks it (bad) and slamming breaks it. Do NOT dive straight in: circle around the moon (skim its atmosphere) and land gently. Red shadows on the ground = where meteors will fall; step away early. Then go to the sky-blue sunset planet.
4. **Sunset planet** (노을의 별, sky blue, icy). Sunset child: 노을 아이. The planet is so small the sunset runs away; an orange band moves around it — run inside the band. Ice = slippery. Faster than the band and you float off; slower and you lose it; MATCH THE BAND'S SPEED. Reward: a glass dome to bring to the pink rose planet. The straight path is blocked by a **red rock belt**; **skim past the red fire star** and its gravity bends you around toward the rose planet (gravity slingshot). Touching the fire star = death.
5. **Rose planet** (장미의 별, pink, smallest). The Rose: 장미. It's cold; put the glass dome over her. A wall circles slowly around her with ONE gap. Either walk in together with the gap, or fly from the tower and drop it from above. Landing hard breaks the glass. Ending: all five planets smile.

Moons (no dialogue before; may receive one short reaction line each): 굴뚝 달 resident = "굴뚝 집" (the chimney house), 친구 달 resident = "꽃 친구" (flower friend). Fire star 불 별 has no speaker.

### Character voices (make each distinct)
- 풍차지기 (windmill keeper): old, patient, slow-talking, talks about wind like an old friend.
- 우체부 (mail carrier): brisk, cheerful, a bit fussy about deliveries, short sentences.
- 정원사 (gardener): soft, careful, worried about fragile things, whispery.
- 노을 아이 (sunset child): small child, playful but lonely, chases the sunset every day.
- 장미 (the rose): proud but shy, a little cold on the surface, quietly grateful.
- 굴뚝 집 / 꽃 친구: one tiny line each.
- Traveler inner voice (for reactions/ending): quiet, curious, few words.

## Hard constraints

- Korean is the default language. Korean speech-bubble lines: **max 42 characters** (count every char incl. spaces/punctuation), designed to sit in 2 short lines on a phone. Toasts (`msg.*`, `die.*`, `react.*`): **max 20 Korean chars**. `name.*`, `who.*`, `ui.*`: max 8 chars. Ending lines: max 42 each. `howto` ko: max 4 lines, each ≤ 70 chars.
- English: natural, short, same meaning; bubble lines ≤ 70 chars, toasts ≤ 32 chars.
- Hints must stay mechanically exact. Every instruction listed in the "must keep" column must survive in meaning (you may rephrase warmly). Do not invent mechanics that don't exist.
- No onomatopoeia popup words like "쾅!", "쿵!", "쨍그랑!", "슝!", "새총!" as effect text. Toasts are plain guidance or a quiet feeling (sound/shake already handle impact). Korean: plain, easy words (반말 for NPCs is fine), no hard Sino-Korean jargon.
- No @mentions, no emoji.

## Keys

### Names (`name.*`) and speakers (`who.*`)
| key | current ko | meaning |
|---|---|---|
| name.windmill | 풍차의 별 | planet 1 |
| name.post | 우편의 별 | planet 2 |
| name.glass | 유리꽃의 별 | planet 3 |
| name.sunset | 노을의 별 | planet 4 |
| name.rose | 장미의 별 | planet 5 |
| name.chimney_moon | 굴뚝 달 | moon |
| name.friend_moon | 친구 달 | moon |
| name.fire | 불 별 | fire star (deadly) |
| who.windmill | 풍차지기 | speaker |
| who.post | 우체부 | speaker |
| who.glass | 정원사 | speaker |
| who.sunset | 노을 아이 | speaker |
| who.rose | 장미 | speaker |
| who.chimney | 굴뚝 집 | speaker |
| who.friend | 꽃 친구 | speaker |
| who.me | (new) | traveler inner voice label, e.g. 나 |

Keep the planet names close to the current ones (players already know them); you may polish English names.

### Main NPC lines: ask (shown on meeting), hint (repeated while doing the job), thanks (on completion, also points to next step)
| key | current ko | must keep |
|---|---|---|
| p1.ask | 바람이 멎어 풍차가 잠들었어. 별 둘레를 힘껏 달려 바람을 깨워 줄래? | wind stopped; run hard around the planet to wake it |
| p1.hint | 뜨기 직전이 제일 센 바람이야. 발이 뜨면 바람이 끊겨. 바위는 살짝 뛰어넘어. | fastest just before liftoff = best; feet leaving ground breaks it; hop rocks |
| p1.thanks | 고마워! 돛을 가져가. 보라 별이 우편의 별이야. 노란 줄을 힘껏 달려 초록 칸에서 점프! 날다가 스틱 밀며 점프하면 돛으로 방향을 한 번 튼다. | gives sail; purple = post planet; run the yellow lane hard, jump at the green cell; in flight jump+stick turns once with the sail. (This one may be up to 2 bubbles: provide p1.thanks and p1.thanks2, each ≤42) |
| p2.ask | 이 소포를 저 하얀 굴뚝 달의 집에! 담이 높아서 걸어선 못 들어가. | parcel to white chimney moon house; walls too high to walk in |
| p2.hint | 달은 작아서 조금만 빨라도 떠. 떠서 굴뚝 위를 지날 때 '놓기'. 발밑 노란 점이 떨어질 자리야. | tiny moon lifts you easily; press 놓기 while floating over the chimney; yellow dot below = landing spot |
| p2.thanks | 잘 도착했대! 다음은 초록 유리꽃의 별로 날아가. | delivered; next fly to the green glass-flower planet |
| p3.ask | 유리꽃을 저 민트 친구 달에 전해 줘. 쿵 내려앉으면 깨져. | bring glass flower to mint friend moon; hard landing breaks it |
| p3.hint | 곧장 꽂지 말고 달 둘레를 빙 돌다 살살 내려앉아. 빨간 그림자는 운석 자리, 미리 비켜! | don't dive straight; circle the moon and land gently; red shadow = meteor spot, move away early |
| p3.thanks | 꽃이 무사하대! 하늘색 노을의 별로 가 봐. | flower safe; go to the sky-blue sunset planet |
| p4.ask | 내 별은 작아서 노을이 금방 달아나. 주황 띠를 따라 같이 달려 줘. | sunset runs away; run with the orange band |
| p4.hint | 얼음이라 미끄러워. 띠보다 빠르면 떠 버리고 느리면 놓쳐. 띠랑 같은 빠르기로. | ice slippery; faster = float off, slower = lose it; match the band speed |
| p4.thanks | 고마워. 이 유리 덮개를 분홍 장미 별에! 곧장 가면 빨간 바위 띠야. 빨간 불 별 옆을 스치면 휘어 돌아가. 불 별에 닿으면 끝. | gives glass dome for the pink rose planet; straight path = red rock belt; skim beside the red fire star to bend around; touching it = death. (2 bubbles: p4.thanks and p4.thanks2, each ≤42) |
| p5.ask | 바람이 차가워. 유리 덮개를 씌워 줘. 담은 천천히 돌고, 틈은 하나야. | cold; put the glass dome on; wall rotates slowly, one gap |
| p5.hint | 틈과 같이 걸어 들어오거나, 탑에서 날아 위에서 놓아 줘. 쿵 내리면 깨져. | walk in with the gap, or fly from the tower and drop from above; hard landing breaks it |
| p5.thanks | 따뜻해. 네 빠른 발 덕분에 다섯 별이 다 웃어. | warm now; thanks to your fast feet all five planets smile |

### NEW idle / flavor lines (shown when you stand near an NPC with nothing to do, or revisit)
Two per planet, in that NPC's voice, ≤42 ko chars, no mechanics needed (may hint lightly):
p1.idle1, p1.idle2, p2.idle1, p2.idle2, p3.idle1, p3.idle2, p4.idle1, p4.idle2, p5.idle1, p5.idle2

### NEW moon receive lines
| key | meaning |
|---|---|
| moon.chimney.got | chimney house receives the parcel (≤42) |
| moon.friend.got | flower friend receives the glass flower (≤42) |

### Toasts / system messages (`msg.*`)
| key | current ko | meaning |
|---|---|---|
| msg.start | 1. {planet} | first screen title of job 1 |
| msg.tower_jump | 탑에서 뛰어내린다 | leapt from the tower |
| msg.liftoff | 떠난다! | jump exceeded escape speed, leaving the planet |
| msg.float | 떴다 | feet left the ground (not escaping) |
| msg.sail | 돛! | the sail turned the flight (replace with plain words) |
| msg.drift_warn | 우주로 떠내려간다… 돛으로 돌려! | drifting away; turn back with the sail |
| msg.flower_crack | 쿵! 유리에 금이 갔다 | hard landing cracked the glass (no onomatopoeia) |
| msg.slingshot | 새총! | slingshot success: curved past another body without landing (no onomatopoeia; plain) |
| msg.rock_snag | 바위에 걸렸다 | snagged on a rock |
| msg.wall_gap | 담 — 틈으로 | wall: go through the gap |
| msg.wall_high | 담이 높다 — 공중에서 놓기 | wall too high: drop from the air |
| msg.picked | 들었다 → {target} | picked up item, destination {target} |
| msg.missed_drop | 빗나갔다 — 다시 줍기 | dropped item missed; pick it up again |
| msg.glass_broken | 쨍그랑! {src}에서 다시 받아 와 | glass broke; get a new one from {src} (no onomatopoeia) |
| msg.rose_smiles | 장미가 웃는다 | final job done |
| msg.next | 다음: {planet} | next destination |
| hud.next_hint | 다음: {planet} (노란 빛기둥). 힘껏 달려 점프! 점선이 초록이면 닿는다. | ≤42; next = {planet} at the yellow light pillar; run hard and jump; green dotted line = you will reach it |

### Death reasons (`die.*`, toasts)
| key | current ko |
|---|---|
| die.fire | 불 별에 닿았다 |
| die.rocks | 빨간 바위 띠에 부딪혔다 |
| die.drift | 우주로 떠내려갔다 |
| die.meteor | 운석에 맞았다 |

### NEW reaction lines (traveler inner voice or the job's NPC; toasts ≤20 ko)
| key | when |
|---|---|
| react.first_liftoff | first time ever escaping a planet |
| react.first_landing | first time landing on another planet |
| react.slingshot | slingshot success (alt/second line to msg.slingshot) |
| react.orbit_landing | gentle landing after circling (orbit landing) |
| react.flower_cracked | glass item got a crack (add caution: land gentler) |
| react.flower_broken | glass item broke |
| react.drift_warning | drifting (must keep: turn back with sail) |
| react.die_fire | after dying to the fire star (hint: skim beside, don't touch) |
| react.die_rocks | after dying to the rock belt (hint: go around via the fire star) |
| react.die_drift | after drifting away (hint: green dotted line before jumping) |
| react.die_meteor | after meteor (hint: step off red shadows) |
| react.new_planet | landing on a planet for the first time (lives refilled) |

### Ending monologue (after the rose, 3-4 lines, traveler voice, ≤42 ko each)
ending.1, ending.2, ending.3, ending.4

### UI
| key | current ko |
|---|---|
| ui.title | 작은 행성 |
| ui.jump | 점프 |
| ui.drop | 놓기 |
| howto | (see below) |

Current `howto` ko (keep EVERY mechanic, ≤4 lines, plain words):
별 여러 개가 한 하늘에 떠 있다. 왼쪽 스틱으로 달린다(많이 밀수록 빠름). 빨리 달리면 발이 뜬다.
아주 빨리 달려 점프하면 그 별 중력을 벗어나 날아간다. 가까운 별에 끌려 빙 돌다 내려앉는다. 빗나가면 우주로 떠내려가 죽는다.
빨리 달리면 발 앞에 점선 = 지금 뛰면 갈 길. 초록이면 다른 별에 닿고, 빨강은 위험. 위 막대가 초록이면 점프로 떠날 수 있다.
날다가 점프 한 번: 돛이 있으면 스틱 쪽으로 방향을 튼다. '놓기'는 든 것을 발밑 노란 점에. 유리는 쿵 내리면 깨진다. 노란 빛기둥이 갈 곳. 목숨 3(처음 가는 별에서 회복).

(howto may use up to 4 lines with ≤ 90 chars each if needed to keep every mechanic.)

## Checklist before you finish
- All keys present: name.* (8), who.* (8), p1–p5 ask/hint/thanks (+ p1.thanks2, p4.thanks2), p1–p5 idle1/idle2, moon.chimney.got, moon.friend.got, msg.* (17), hud.next_hint, die.* (4), react.* (12), ending.1–4, ui.title, ui.jump, ui.drop, howto.
- Korean length limits respected; placeholders kept; mechanics kept; no Little Prince quotes; no onomatopoeia toasts.
- Only `submit/tinyplanet/dialogue.json` written.
