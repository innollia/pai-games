# 어린 배달부 대사 최종본 (Claude판 + Gemini판 섞음)

장르: 일상개그물. 사용자 수정 10개는 글자 그대로 둔다. 조작 안내는 정확하게, UI 글은 짧은 낱말. `|` = 말풍선 나눔(한 말풍선 한국어 40자 안팎). 아이템 영어 이름은 **Old Glidewing**(버튼 "Glide")으로 통일.

이어지는 개그: 별·꽃·꽃 친구는 릴스를 본다(풍차지기·정원사·꽃 친구) · 형님의 "밥 살게. 아마도."를 형님이 두 번 하고 우체부("3년째 배송 중")·장미("밥 약속보단 확실")가 놀린다 · 우체부는 칼퇴에 진심.

## 말투 (주민마다)

**풍차지기** (C 바탕)
- 옛말 할아버지: ~하게나 · ~구먼 · 자네 · 고마우이 · ~라네.
- 요즘 문물(앱, 릴스)을 아무렇지 않게 말하는 무표정 개그.
- 안내는 짧은 두 마디로 나눠서 또박또박(힌트는 Gemini의 말풍선 나눔).

**우체부** (섞음)
- 바쁜 배송 프로 해요체: "배송 완료", "급한 건", "한 건씩만요", "오늘 물량".
- Gemini에서 "특급 배송 건", "칼퇴각"을 가져옴: 일 잘하는 직장인의 작은 기쁨.
- 남 얘기도 택배 말로 함(형님 밥 약속 = 3년째 배송 중).

**정원사** (C 바탕)
- 속삭이는 해요체, 말줄임표(…) 많이, "쉿…"으로 시작.
- 걱정 많고 조심스러움("제 손이 다 떨렸어요").
- 엉뚱함은 작게: 유리꽃이 가끔 랩을 함, 꽃들이 릴스 보다 늦게 자서 시들함.

**형님** (C 바탕)
- 느긋한 큰형 반말: "어이 동생", "형이 ~", 느낌표 적게, 마침표로 툭툭.
- 입버릇 "형이 밥 살게. 아마도." (부탁 때 한 번, 곁에서 한 번 더 "밥은 다음에 살게. 아마도.").
- 감성 있는 척("마음이 몽글몽글"), 위험 안내만은 "진짜로" 하고 단호하게. 얼음 안내는 Gemini처럼 "조이스틱은 살살"을 넣음.

**장미** (섞음)
- 새침: 말 첫머리 "…", 더듬는 고마움 "고, 고마워".
- Gemini의 정석 츤데레 "딱히 네가 가져오길 기다리는 건 아니니까. 착각하지 마."
- 안내는 정확히('놓기'를 누르라고 말함) 하고 끝에 작게 "…살살 해."

**굴뚝 집** (섞음)
- 뜨끈한 거 좋아하는 아저씨 같은 집: "캬", "뜨끈하다".
- Gemini의 "방바닥" + Claude의 "이 맛에 집 하지."

**꽃 친구** (C)
- 들뜬 10대: "헐", 받자마자 릴스 올림, "반짝반짝".

**너? (포스티 속마음)** (섞음)
- 어리둥절하고 순진한 짧은 혼잣말, 반말.
- Gemini의 소리 말을 가끔 씀: 슝, 빙글빙글, 으앗, 와장창.
- 죽은 뒤 말은 늘 "다음엔 ~하자"로 다음 할 일을 정확히 알려 줌.

**UI·알림·도움말** (C)
- 짧은 낱말·화살표(→)·가운뎃점(·), 문장 금지. Gemini의 한자말(수령·투하·소진·전송)은 안 씀.

## 줄마다 고른 쪽

개수: 전체 166줄 · C 152 · G 3 · 섞음 11 (G·Claude가 같은 줄은 C로 셈. tofu.* 한국어는 tofu.gd가 박아 둔 글이라 C 고정)

| key | 고른 쪽 | 한국어 | English |
|---|---|---|---|
| ui.title | C | 어린 배달부 | The Little Courier |
| ui.start | C | 시작 | START |
| ui.jump | C | 점프 | Jump |
| ui.drop | C | 놓기 | Drop |
| ui.sail | C | 날다리 | Glide |
| who.me | C | 너? | You? |
| name.windmill | C | 풍차의 별 | Windmill Planet |
| name.post | C | 우편의 별 | Post Planet |
| name.glass | C | 유리꽃의 별 | Glass Flower Planet |
| name.sunset | C | 노을의 별 | Sunset Planet |
| name.rose | C | 장미의 별 | Rose Planet |
| name.chimney_moon | C | 굴뚝 달 | Chimney Moon |
| name.friend_moon | C | 친구 달 | Friend Moon |
| name.fire | C | 불 별 | Fire Star |
| who.windmill | C | 풍차지기 | Windmill Keeper |
| who.post | C | 우체부 | Mail Carrier |
| who.glass | C | 정원사 | Gardener |
| who.sunset | C | 형님 | Big Bro |
| who.rose | C | 장미 | Rose |
| who.chimney | C | 굴뚝 집 | Chimney House |
| who.friend | C | 꽃 친구 | Flower Friend |
| goal.talk | C | {who}에게 말 걸기 | Talk to {who} |
| goal.wind | C | 풍차 깨우기 · 땅에서 전력 질주 | Wake the windmill · sprint on the ground |
| goal.pick | C | {planet}에서 {item} 받기 | Get the {item} on {planet} |
| goal.deliver | C | {target}에 {item} 배달 | Deliver the {item} to {target} |
| goal.band | C | 노을 띠 속도 맞추기 | Match the sunset band's speed |
| item.pkg | C | 소포 | parcel |
| item.flower | C | 유리꽃 | glass flower |
| item.dome | C | 유리 덮개 | glass dome |
| todo.head | C | 할 일 | To-do |
| todo.p1 | C | 풍차 깨우기 · 땅에서 전력 질주 | Wake the windmill · sprint on the ground |
| todo.p2 | C | 소포 → 굴뚝 달 집 (공중에서 놓기) | Parcel → Chimney Moon house (drop from the air) |
| todo.p3 | C | 유리꽃 → 친구 달 (살살 착지) | Glass flower → Friend Moon (land softly) |
| todo.p4 | C | 노을 띠 속도 맞추기 | Match the sunset band's speed |
| todo.p5 | C | 유리 덮개 → 장미 | Glass dome → Rose |
| todo.p5_wait | C | 유리 덮개 필요 (형님에게) | Needs a glass dome (from Big Bro) |
| todo.st_none | C | 안 만남 | Not met |
| todo.st_doing | C | 하는 중 | In progress |
| todo.st_done | C | 끝 | Done |
| todo.held | C | 들고 있는 것 | Carrying |
| todo.empty | C | 빈손 | Nothing |
| todo.close | C | 닫기 | Close |
| talk.busy | C | 어라, 이미 {item} 들고 있네. 그것부터 갖다주고 와! | Oh, you're already carrying the {item}. Deliver that first! |
| p1.ask | C | 오, 마침 잘 됐군. 자네 다리가 튼실해 보이는데 나 좀 도와주게나. \| 바람이 멎어 풍차가 잠들었네. 이 별을 뛰어다녀 바람을 만들어주게나. | Oh, just in time. Those legs of yours look sturdy. Lend an old man a hand. \| The wind has stopped and the windmill fell asleep. Run around this planet and make me some wind. |
| p1.hint | G | 뜨기 직전이 제일 센 바람이지. \| 발이 뜨면 바람이 끊기니 땅에 붙어 달리게나. | The wind is strongest just before liftoff. \| It stops when your feet leave the ground, so stay low. |
| p1.thanks | C | 고마우이, 구식 날다리를 받게나. \| 배달 일이라면 우편의 별, 보라색 별로 가면 되겠군 그래. | Much obliged. Take this Old Glidewing. \| If it's delivery work you're after, the Post Planet is the purple one. |
| p1.thanks2 | C | 날다가 한번 더 뛰면 조이스틱 방향으로 방향을 튼다네. | Jump once more in flight, and you'll turn toward your joystick. |
| banner.sail | C | 구식 날다리! 날 때 '날다리' 버튼을 한 번 누르면 조이스틱 쪽으로 방향을 튼다. | Old Glidewing! In flight, tap 'Glide' once to turn toward your joystick. |
| hint.sail | C | '날다리' 버튼 등장 · 연한 점선 = 날다리로 갈 길 | 'Glide' ready · faint dots = where it takes you |
| msg.sail | C | 날다리로 방향 전환 | Glidewing turn |
| p1.idle1 | C | 요즘 젊은이들은 바람도 앱으로 부른다지? 나는 아직 발로 부른다네. | Young folks summon wind with an app these days, I hear. I still do it with my feet. |
| p1.idle2 | 섞음 | 서두르지 않아도 되네. 별은 언제나 제자리에서 릴스를 보고 있으니. | No need to hurry. The planets are always right where they are, watching Reels. |
| react.first_liftoff | C | 어… 나 지금 나는 거야? | Wait... am I flying? |
| react.first_landing | C | 착지 성공. 여긴 어디지? | Landed. Where am I? |
| react.new_planet | C | 새 별이다. 기운이 솟는다 | A new planet. I feel recharged |
| react.slingshot | G | 별 옆을 스치니 슝 빨라졌다! | Skimmed a planet. Whoosh, faster! |
| react.orbit_landing | G | 빙글빙글 돌다 사뿐히 착지! | Round and round, then a soft landing! |
| msg.next | C | 다음: {planet} | Next: {planet} |
| hud.next_hint | C | 다음: {planet} (노란 빛기둥). 달려 점프! 초록 점선이면 닿아. | Next: {planet} (yellow pillar). Run and jump! Green dots mean you'll reach it. |
| msg.use_sail | C | 지금 날다리! | Glide now! |
| msg.use_air | C | 한 번 더 점프! | Jump once more! |
| p2.ask | 섞음 | 어서 오세요, 우편의 별입니다! 마침 특급 배송 건이 하나 있어요. \| 이 소포, 하얀 굴뚝 달 집으로요. 담이 높아서 공중에서 쏙 넣어야 해요! | Welcome to the Post Planet! Perfect timing, I've got an express job. \| This parcel goes to the house on the white Chimney Moon. The wall's high, so drop it in from the air! |
| p2.busy | C | 아, 손에 {item} 있으시네요! 한 건씩만요. 그거 먼저 배송하고 오세요. | Oh, you've got the {item}! One job at a time. Deliver that first. |
| got.pkg | C | 소포 → {target} | Parcel → {target} |
| p2.hint | C | 달은 작아서 금방 떠요! 굴뚝 위를 지날 때 '놓기'. \| 발밑 노란 점에 떨어져요. | The moon's tiny, so you float off fast! Tap 'Drop' over the chimney. \| It lands on the yellow dot below you. |
| msg.wall_high | C | 높은 담 · 공중에서 놓기 | High wall · drop from the air |
| msg.missed_drop | C | 빗나감 · 다시 줍기 | Missed · pick it up again |
| moon.chimney.got | 섞음 | 캬, 굴뚝으로 소포가 쏙! 방바닥 뜨끈하다, 이 맛에 집 하지. | Ahh, right down the chimney! Floor's toasty. This is why I'm a house. |
| p2.thanks | 섞음 | 배송 완료! 덕분에 오늘 칼퇴각이에요. \| 남은 부탁은 왼쪽 위 할 일 목록에 있어요. | Delivered! Thanks to you, I might clock out on time. \| The other requests are in the to-do list, top left. |
| p2.idle1 | C | 형님이 밥 산다는 말, 3년째 배송 중이래요. 도착 예정일 미정. | Big Bro's 'I'll buy you dinner' has been in transit for three years. ETA unknown. |
| p2.idle2 | C | 오늘 물량 실화예요? 그래도 가방이 빵빵하면 기분은 좋아요. | Is today's load for real? Still, a full bag feels good. |
| p3.ask | C | 쉿… 꽃들이 자고 있어서요. 이 유리꽃, 민트색 친구 달에 전해 줄래요? \| 세게 내려앉으면… 깨져 버려요. | Shh... the flowers are sleeping. Could you take this glass flower to the mint Friend Moon? \| If you land hard... it'll break. |
| p3.busy | C | 어머… 이미 {item} 들고 있네요. 그것부터 전해 주고… 천천히 오세요. | Oh... you're already carrying the {item}. Deliver that first... then come back, slowly. |
| got.flower | C | 유리꽃 → {target} (살살) | Glass flower → {target} (gently) |
| p3.hint | C | 곧장 꽂지 말고 빙 돌다 살살 앉아요. \| 빨간 그림자는 운석 자리예요… 미리 피해요. | Don't dive straight in. Circle and land softly. \| Red shadows mean meteors... move early. |
| react.flower_cracked | 섞음 | 으앗, 금이 갔다… 더 살살 | Yikes, it cracked... softer |
| react.flower_broken | 섞음 | 와장창… 다시 받으러 가자 | Crash... go get another |
| msg.glass_broken | C | 깨짐 · {src}에서 다시 받기 | Broken · get another on {src} |
| moon.friend.got | C | 헐, 하나도 안 깨졌어! 바로 릴스 올려야지. 달이 반짝반짝해! | No way, not a single crack! Posting this to Reels right now. The moon's sparkling! |
| p3.thanks | C | 꽃이 무사하대요… 휴, 제 손이 다 떨렸어요. \| 다른 별에도 기다리는 이가 있을 거예요. | The flower made it... phew, my hands were shaking. \| Someone on another planet must be waiting too. |
| p3.idle1 | C | 유리꽃은 아주 여려요… 귀 기울이면 맑게 울려요. 가끔 랩도 해요. | Glass flowers are delicate... listen closely and they chime. Sometimes they rap. |
| p3.idle2 | C | 꽃들이 어젯밤 릴스 보다 늦게 잤대요… 그래서 오늘 다들 시들해요. | The flowers stayed up late watching Reels... so they're all droopy today. |
| p4.ask | C | 어이 동생, 왔냐. 내 별이 쪼끄매서 노을이 자꾸 도망가거든. \| 저 주황 띠랑 같이 좀 달려 줘. 형이 밥 살게. 아마도. | Hey kiddo, you made it. My planet's so tiny the sunset keeps running off. \| Run alongside that orange band for me. I'll buy you dinner. Probably. |
| p4.hint | 섞음 | 얼음이라 미끄럽다. 조이스틱은 살살. \| 빠르면 뜨고 느리면 놓쳐. 띠랑 같은 빠르기로. | It's icy. Easy on the joystick. \| Too fast and you float, too slow and you lose it. Match the band. |
| p4.thanks | C | 오, 잘했다. 이 유리 덮개, 분홍 장미 별에 좀 갖다줘. \| 곧장 가면 빨간 지뢰 울타리야. 거긴 형도 못 지나가. | Nice work. Take this glass dome to the pink Rose Planet. \| The straight route has a red mine fence. Even I can't get through that. |
| p4.keep | C | 오, 잘했다. 근데 손이 꽉 찼네? 덮개는 형이 맡아 둘게. 손 비면 와. | Nice work. Hands full, huh? I'll hang on to the dome. Come back when you're free. |
| p4.busy | C | 야, 동생. 손에 {item} 있잖아. 그거부터 갖다주고 와, 난 안 급해. | Hey kiddo, you've got the {item}. Drop that off first. I'm in no rush. |
| p4.thanks2 | C | 빨간 불 별 옆을 스치면 휘어서 돌아가. 닿으면 끝이다, 진짜로. | Skim past the red Fire Star and you'll curve around. Touch it and it's over. For real. |
| got.dome | C | 유리 덮개 → {target} | Glass dome → {target} |
| p4.idle1 | C | 노을 보면서 달리면 마음이 몽글몽글해진다. 형 감성 좀 있지? | Running under the sunset makes me all mushy inside. Got some soul, huh? |
| p4.idle2 | C | 혼자 뛸 땐 좀 외로웠는데, 둘이 뛰니 노을도 안 무섭네. \| 밥은 다음에 살게. 아마도. | Running alone got lonely. With two of us, the sunset's not so scary. \| Dinner's on me next time. Probably. |
| rose.early | 섞음 | …추워. 형님이 유리 덮개를 갖고 있대. 노을의 별에 가 봐. \| 딱히 네가 가져오길 기다리는 건 아니니까. 착각하지 마. | ...It's cold. I hear Big Bro has a glass dome. Try the Sunset Planet. \| It's not like I'm waiting for you to bring it. Don't get the wrong idea. |
| p5.ask | C | …왔어? 바람이 차가워. 유리 덮개 좀 씌워 줘. \| 담이 천천히 돌고, 틈은 딱 하나야. | ...You're here? The wind is cold. Put the dome over me. \| The wall turns slowly, and there's just one gap. |
| p5.hint | 섞음 | 담 틈으로 걸어 들어오거나, 탑에서 뛰어 위에서 '놓기'를 눌러. \| 세게 떨어뜨리면 깨져. …살살 해. | Walk in through the gap, or jump from the tower and tap 'Drop' above me. \| Drop it hard and it breaks. ...Be gentle. |
| msg.wall_gap | C | 담 · 틈으로 | Wall · use the gap |
| msg.tower_jump | C | 탑에서 점프 | Tower leap |
| msg.rose_smiles | C | 장미가 환하게 웃는다 | Rose smiles brightly |
| p5.thanks | C | …따뜻해. 고, 고마워. 네 빠른 발 덕분에 다섯 별이 다 웃고 있어. | ...It's warm. Th-thanks. Thanks to your fast feet, all five planets are smiling. |
| p5.thanks_more | C | …따뜻해. 고, 고마워. 다른 별들도 네 발을 기다려. 가 봐, 얼른. | ...It's warm. Th-thanks. The others are waiting for your feet too. Go on, hurry. |
| p5.idle1 | C | …뭘 봐? 덮개가 마음에 들어서 가만있는 거야. 사진은 찍지 마. | ...What are you looking at? I'm only sitting still because I like the dome. No photos. |
| p5.idle2 | C | 별빛이 덮개에 반짝이는 건… 조금 예쁘네. 형님 밥 약속보단 확실하고. | Starlight on the dome is... a little pretty. More reliable than Big Bro's dinner promises. |
| msg.drift_warn | C | 떠내려가는 중 · 날다리로 방향 틀기 | Drifting away · turn with Glide |
| msg.drift_warn_ns | C | 떠내려가는 중! | Drifting away! |
| react.drift_warning | C | 어어, 멀어진다… 날다리로 돌리자! | Uh-oh, drifting... turn with the Glidewing! |
| react.drift_warning_ns | C | 어어, 멀어진다… 초록 점선에서 뛰자 | Uh-oh, drifting... jump on green dots |
| banner.lost | C | 우주 미아 · 마지막 별로 돌아가는 중 | Lost in space · returning to the last planet |
| die.fire | C | 불 별에 닿음 | Touched the Fire Star |
| react.die_fire | C | 앗 뜨거. 다음엔 스치기만 하자 | Ouch, hot. Just skim it next time |
| die.rocks | C | 빨간 지뢰 울타리에 부딪힘 | Hit the red mine fence |
| react.die_rocks | C | 울타리는 무리. 불 별 쪽으로 돌아가자 | Can't go through. Curve around the Fire Star |
| die.drift | C | 깊은 우주로 떠내려감 | Drifted into deep space |
| react.die_drift | 섞음 | 우주 너무 넓다… 다음엔 초록 점선 보고 뛰자 | Space is huge... next time, jump on green dots |
| die.meteor | C | 떨어지는 운석에 맞음 | Hit by a falling meteor |
| react.die_meteor | C | 빨간 그림자는 미리 피하자 | Get off red shadows early |
| help.idle1 | C | 조이스틱을 밀어 달려 봐 | Push the joystick to run |
| help.idle2 | C | 왼쪽 아래 조이스틱을 손가락으로 밀어 봐 | Drag the joystick at the bottom left with your finger |
| help.lift1 | C | 조이스틱을 끝까지 밀어 더 빨리 달려 | Push the joystick all the way to run faster |
| help.lift2 | C | 끝까지 밀고 계속 달려. 위 막대가 끝까지 차오르게 | Keep it pushed and keep running. Fill the bar at the top |
| help.jump1 | C | 위 막대가 초록일 때 점프하면 별을 떠나 | Jump when the top bar is green to leave the planet |
| help.jump2 | C | 지금은 막대가 금방 초록이 돼. 힘껏 달리다 점프! | The bar turns green sooner for now. Sprint, then jump! |
| help.lost1 | C | 점선이 초록일 때 뛰면 다른 별에 닿아 | Jump when the dots are green to reach another planet |
| help.lost2 | C | 잠깐 별들이 더 세게 끌어 줘. 초록 점선을 보고 뛰어! | Planets pull harder for a while. Jump on green dots! |
| help.goal1 | C | 어디로 갈지 모르겠으면 왼쪽 위 할 일 목록을 눌러 봐 · 노란 화살표를 따라가 | Lost? Tap the to-do list at the top left · follow the yellow arrow |
| help.goal2 | C | 노란 빛기둥이 서 있는 별로 가면 돼 | Head for the planet with the yellow light pillar |
| help.glass1 | C | 곧장 꽂지 말고 빙 돌다 살살 내려앉아 | Don't dive in. Circle around and land softly |
| help.glass2 | C | 잠깐 내려앉기가 더 부드러워져. 빙 돌며 천천히 | Landings are gentler for a while. Circle and go slow |
| help.band1 | C | 띠와 같은 빠르기로! 얼음이라 조이스틱은 살살 | Match the band's speed! It's icy, so ease the joystick |
| help.band2 | C | 잠깐 띠가 느려졌어. 띠 위에 머물러 봐 | The band is slower for a while. Stay on it |
| help.fire1 | C | 불 별 옆을 스치면 휘어서 장미의 별로 돌아가 | Skim past the Fire Star to curve around to Rose Planet |
| help.fire2 | C | 노을의 별에 초록 점선 길을 보여 줄게. 그 길 쪽으로 힘껏 달려 점프 | Green dots on Sunset Planet show a curving path. Sprint that way and jump |
| help.fire2b | C | 잠깐 땅에서도 점선이 보여. 초록이 될 때 점프 | For a while you can see the dots on the ground. Jump when they turn green |
| help.sail1 | C | 빗나갈 것 같으면 날 때 '날다리' 버튼! | About to miss? Tap 'Glide' in flight! |
| help.sail2 | C | 연한 점선이 초록이면 지금 '날다리'를 눌러 | When the faint dots turn green, tap 'Glide' now |
| help.drop1 | C | 굴뚝 위를 지날 때 '놓기' | Tap 'Drop' as you pass over the chimney |
| help.drop2 | C | 발밑 노란 점이 굴뚝에 겹칠 때 '놓기' | Tap 'Drop' when the yellow dot below you is on the chimney |
| msg.all_done | C | 모든 부탁 완료! | All requests done! |
| ending.1 | 섞음 | 발끝으로 총총 건넌 별마다 다정한 빛이 켜졌다. | A gentle light came on at every planet I tiptoed across. |
| ending.2 | C | 작고 외롭던 별들이 하늘 한가운데서 서로 웃는다. | The small, lonely planets smile at each other across the sky. |
| ending.3 | C | 차가운 유리 너머로 전해진 온기가 마음을 데운다. | Warmth passed through cold glass warms my heart. |
| ending.4 | C | 언젠가 또 바람이 불면, 다시 달려 날아가야지. | Someday, when the wind blows again, I'll run and fly once more. |
| end.win_head | C | 모든 부탁 완료! | All requests done! |
| end.win_msg | C | 다섯 별이 모두 웃고 있어 | All five planets are smiling |
| end.lose_head | C | 목숨 0 | Out of lives |
| end.lose_msg | C | 다시 하면 첫 별부터 | Again starts from the first planet |
| end.delivered | C | 배달 | Delivered |
| end.time | C | 걸린 시간 | Time |
| end.survived | C | 버틴 시간 | Time survived |
| end.slings | C | 새총 | Slingshots |
| end.best_time | C | 최고 기록 | Best time |
| end.best_count | C | 최고 배달 | Most delivered |
| end.new_best | C | 새 기록 | New best |
| end.again | C | 다시 | AGAIN |
| tofu.list | C | < 목록 | < List |
| tofu.menu | C | < 메뉴 | < Menu |
| tofu.restart | C | < 처음부터 | < Restart |
| tofu.over_best | C | 최고 | Best |
| tofu.over_again | C | 탭해서 다시 | Tap to play again |
| tofu.rate | C | 평가 | Rate |
| tofu.rate_title | C | 이 게임 어때요? | How was it? |
| tofu.close | C | 닫기 | Close |
| tofu.comment | C | 한마디 | Comment |
| tofu.thanks | C | 고마워요! | Thanks! |
| tofu.sending | C | 보내는 중 | Sending |
| tofu.sent | C | 한마디 보냈어요 | Comment sent |
| tofu.not_saved | C | 저장 안 됨 · 별을 다시 탭 | Not saved · tap a star again |
| tofu.comment_ph | C | 이 게임에 한마디 (선택) | A word about this game (optional) |
