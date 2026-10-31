# 어린 배달부 글 고침 (v11)

**장르: 일상개그물.** 심드렁한 잡담, 작은 엉뚱함, 주민끼리 이어지는 개그(별들은 제자리에서 릴스를 봄 · 꽃들도 릴스 보다 늦게 잠 · 꽃 친구는 바로 릴스 올림 · 형님의 "밥 살게. 아마도."를 우체부·장미가 놀림). 다정하게, 비꼬지 않게. 조작 안내는 정확하게.

말투: 풍차지기 = 옛말 할아버지(~하게나·~구먼·자네·고마우이) · 우체부 = 바쁜 배송 프로(해요체, "배송 완료"·"오늘 물량") · 정원사 = 속삭이는 해요체(쉿…, 말줄임) · 형님 = 느긋한 큰형(반말, "동생", "형이 ~") · 장미 = 새침(…, "딱히", 더듬는 고마움) · 굴뚝 집 = 뜨끈한 거 좋아하는 집("캬, 뜨끈하다") · 꽃 친구 = 들뜬 10대(헐·대박) · 너? = 짧고 어리둥절한 혼잣말.

UI 글(버튼·칩·목록·알림·배너)은 문장 대신 짧은 낱말·화살표(→)·가운뎃점(·). 말풍선 글 안의 `|` = 말풍선 나눔(앞 조각 → 바로 다음 말풍선). 아이템 이름: 돛 → **구식 날다리**(버튼 "날다리") / English **Old Glidewing**(button "Glide"). "스틱" → "조이스틱".

코드: `g/tinyplanet.gd` 세 곳만 — hint.first 말풍선 뺌, 손이 찬 채 만날 때 주민별 `pN.busy`(없으면 talk.busy), `_say`가 `|`로 말풍선을 나눔.

## 사용자 수정 10개

| # | key | 전 한국어 | 새 한국어 | English |
|---|---|---|---|---|
| 1 | hint.first | 스틱으로 달리기 · 막대가 차면 점프! | (지움) | (removed) |
| 2 | who.me | 나 | 너? | You? |
| 3 | who.sunset | 노을 아이 | 형님 | Big Bro |
| 4 | talk.busy | 들고 있는 {item}부터 배달하고 다시 와 줘! | 어라, 이미 {item} 들고 있네. 그것부터 갖다주고 와! | Oh, you're already carrying the {item}. Deliver that first! |
| 4 | p2.busy | (없음 · 새 키) | 아, 손에 {item} 있으시네요! 한 건씩만요. 그거 먼저 배송하고 오세요. | Oh, you've got the {item}! One job at a time. Deliver that first. |
| 4 | p3.busy | (없음 · 새 키) | 어머… 이미 {item} 들고 있네요. 그것부터 전해 주고… 천천히 오세요. | Oh... you're already carrying the {item}. Deliver that first... then come back, slowly. |
| 4 | p4.busy | (없음 · 새 키) | 야, 동생. 손에 {item} 있잖아. 그거부터 갖다주고 와, 난 안 급해. | Hey kiddo, you've got the {item}. Drop that off first. I'm in no rush. |
| 5 | todo.close | 탭하면 닫혀요 | 닫기 | Close |
| 6 | p1.ask | 바람이 멎어 풍차가 잠들었네. 별 둘레를 힘껏 달려 바람을 깨워 주겠나? | 오, 마침 잘 됐군. 자네 다리가 튼실해 보이는데 나 좀 도와주게나. \| 바람이 멎어 풍차가 잠들었네. 이 별을 뛰어다녀 바람을 만들어주게나. | Oh, just in time. Those legs of yours look sturdy. Lend an old man a hand. \| The wind has stopped and the windmill fell asleep. Run around this planet and make me some wind. |
| 7 | p1.thanks | 고마우이, 돛을 받게나. 보라 별이 우편의 별이니 노란 줄을 힘껏 달리게. | 고마우이, 구식 날다리를 받게나. \| 배달 일이라면 우편의 별, 보라색 별로 가면 되겠군 그래. | Much obliged. Take this Old Glidewing. \| If it's delivery work you're after, the Post Planet is the purple one. |
| 8 | p1.thanks2 | 초록 점선이 보이면 점프하게. 날다 스틱 밀며 뛰면 돛으로 방향을 한 번 튼다네. | 날다가 한번 더 뛰면 조이스틱 방향으로 방향을 튼다네. | Jump once more in flight, and you'll turn toward your joystick. |
| 9 | banner.sail | 풍차지기의 고마움: 돛! 날 때 '돛' 버튼을 한 번 누르면 스틱 쪽으로 방향을 튼다 (스틱 안 밀면 갈 곳 쪽). | 구식 날다리! 날 때 '날다리' 버튼을 한 번 누르면 조이스틱 쪽으로 방향을 튼다. | Old Glidewing! In flight, tap 'Glide' once to turn toward your joystick. |
| 9 | ui.sail | 돛 | 날다리 | Glide |
| 10 | p1.idle2 | 서두르지 말게. 별은 언제나 제자리에서 자네를 기다리니. | 서두르지 않아도 되네. 별은 언제나 제자리에서 릴스를 보고 있으니. | No need to hurry. The planets are always right where they are, scrolling reels. |

## 나머지 (같은 방식으로)

| key | 전 한국어 | 새 한국어 | English |
|---|---|---|---|
| goal.wind | 풍차 깨우기: 땅에 붙어 힘껏 달리기 | 풍차 깨우기 · 땅에서 전력 질주 | Wake the windmill · sprint on the ground |
| goal.band | 노을 띠와 같은 빠르기로 달리기 | 노을 띠 속도 맞추기 | Match the sunset band's speed |
| todo.p1 | 풍차 깨우기: 땅에 붙어 힘껏 달리기 | 풍차 깨우기 · 땅에서 전력 질주 | Wake the windmill · sprint on the ground |
| todo.p2 | 소포를 굴뚝 달 집에 공중에서 놓기 | 소포 → 굴뚝 달 집 (공중에서 놓기) | Parcel → Chimney Moon house (drop from the air) |
| todo.p3 | 유리꽃을 친구 달에 살살 전하기 | 유리꽃 → 친구 달 (살살 착지) | Glass flower → Friend Moon (land softly) |
| todo.p4 | 주황 노을 띠와 같은 빠르기로 달리기 | 노을 띠 속도 맞추기 | Match the sunset band's speed |
| todo.p5 | 유리 덮개를 장미에게 씌우기 | 유리 덮개 → 장미 | Glass dome → Rose |
| todo.p5_wait | 유리 덮개가 필요해 (노을 아이가 줌) | 유리 덮개 필요 (형님에게) | Needs a glass dome (from Big Bro) |
| todo.st_none | 아직 안 만남 | 안 만남 | Not met |
| hint.sail | 지금 '돛'을 누를 수 있다 · 연한 점선이 돛을 쓰면 갈 길 | '날다리' 버튼 등장 · 연한 점선 = 날다리로 갈 길 | 'Glide' ready · faint dots = where it takes you |
| msg.sail | 돛으로 방향을 튼다 | 날다리로 방향 전환 | Glidewing turn |
| p1.idle1 | 바람결을 느끼며 달리면 하늘도 그 발소리를 듣는다네. | 요즘 젊은이들은 바람도 앱으로 부른다지? 나는 아직 발로 부른다네. | Young folks summon wind with an app these days, I hear. I still do it with my feet. |
| react.first_liftoff | 별을 떠나 날아오른다 | 어… 나 지금 나는 거야? | Wait... am I flying? |
| react.first_landing | 새로운 별에 내려앉았다 | 착지 성공. 여긴 어디지? | Landed. Where am I? |
| react.new_planet | 새 별에 닿아 힘이 난다 | 새 별이다. 기운이 솟는다 | A new planet. I feel recharged |
| react.slingshot | 별의 곁을 스쳐 가속한다 | 별 옆을 스치니 빨라졌다 | Skimmed a planet. Faster! |
| react.orbit_landing | 궤도를 돌아 살포시 앉았다 | 한 바퀴 돌고 사뿐히 착지 | One lap, then a soft landing |
| msg.use_sail | 지금 돛! | 지금 날다리! | Glide now! |
| p2.ask | 이 소포, 저 하얀 굴뚝 달 집에 전해 줘! 담이 높아 걸어선 못 들어가. | 어서 오세요, 우편의 별입니다! 마침 급한 건이 하나 있는데요. \| 이 소포, 하얀 굴뚝 달 집으로요. 담이 높아서 걸어선 못 들어가요! | Welcome to the Post Planet! Perfect timing, I've got a rush job. \| This parcel goes to the house on the white Chimney Moon. The wall's too high to walk in! |
| got.pkg | 소포! {target}에 전해 주자 | 소포 → {target} | Parcel → {target} |
| p2.hint | 달은 작아 금방 떠! 굴뚝 위 지날 때 '놓기'. 발밑 노란 점에 떨어져! | 달은 작아서 금방 떠요! 굴뚝 위를 지날 때 '놓기'. \| 발밑 노란 점에 떨어져요. | The moon's tiny, so you float off fast! Tap 'Drop' over the chimney. \| It lands on the yellow dot below you. |
| msg.wall_high | 담이 높다 — 공중에서 놓기 | 높은 담 · 공중에서 놓기 | High wall · drop from the air |
| msg.missed_drop | 빗나갔다 — 다시 줍기 | 빗나감 · 다시 줍기 | Missed · pick it up again |
| moon.chimney.got | 굴뚝 속으로 소포가 쏙 들어왔어! 따뜻한 온기가 번지네. | 캬, 굴뚝으로 소포가 쏙! 뜨끈하다, 이 맛에 집 하지. | Ahh, right down the chimney! Toasty. This is why I'm a house. |
| p2.thanks | 잘 도착했대, 고마워! 남은 부탁은 왼쪽 위 할 일 목록에 있어. | 배송 완료! 오늘 물량 하나 줄었네요. \| 남은 부탁은 왼쪽 위 할 일 목록에 있어요. | Delivered! One less in today's pile. \| The other requests are in the to-do list, top left. |
| p2.idle1 | 하늘에 띄운 편지는 길을 잃지 않아. 언제나 닿을 곳으로 가지! | 형님이 밥 산다는 말, 3년째 배송 중이래요. 도착 예정일 미정. | Big Bro's 'I'll buy you dinner' has been in transit for three years. ETA unknown. |
| p2.idle2 | 오늘도 우편 가방이 든든하네! 다음 행선지는 어디야? | 오늘 물량 실화예요? 그래도 가방이 빵빵하면 기분은 좋아요. | Is today's load for real? Still, a full bag feels good. |
| p3.ask | 유리꽃을 저 민트 친구 달에 전해 줘요… 세게 내려앉으면 깨져 버려요. | 쉿… 꽃들이 자고 있어서요. 이 유리꽃, 민트색 친구 달에 전해 줄래요? \| 세게 내려앉으면… 깨져 버려요. | Shh... the flowers are sleeping. Could you take this glass flower to the mint Friend Moon? \| If you land hard... it'll break. |
| got.flower | 유리꽃! 살살 {target}에 전해 주자 | 유리꽃 → {target} (살살) | Glass flower → {target} (gently) |
| p3.hint | 곧장 말고 빙 돌아 살살 앉아요. 빨간 그림자는 운석 자리니 미리 피해요! | 곧장 꽂지 말고 빙 돌다 살살 앉아요. \| 빨간 그림자는 운석 자리예요… 미리 피해요. | Don't dive straight in. Circle and land softly. \| Red shadows mean meteors... move early. |
| react.flower_cracked | 금이 갔다… 더 살살 앉자 | 금이 갔다… 더 살살 | It cracked... softer |
| react.flower_broken | 깨져 버렸다… 다시 가자 | 깨졌다… 다시 받으러 가자 | It broke... go get another |
| msg.glass_broken | 깨졌다… {src}에서 다시 받기 | 깨짐 · {src}에서 다시 받기 | Broken · get another on {src} |
| moon.friend.got | 정원사의 맑은 꽃이 깨지지 않고 닿았어… 달이 환해졌네! | 헐, 하나도 안 깨졌어! 바로 릴스 올려야지. 달이 반짝반짝해! | No way, not a single crack! Posting this to Reels right now. The moon's sparkling! |
| p3.thanks | 꽃이 무사하대요… 정말 다행이에요. 다른 별에도 기다리는 이가 있을 거예요. | 꽃이 무사하대요… 휴, 제 손이 다 떨렸어요. \| 다른 별에도 기다리는 이가 있을 거예요. | The flower made it... phew, my hands were shaking. \| Someone on another planet must be waiting too. |
| p3.idle1 | 유리꽃은 아주 여려요… 가만히 숨소리를 들으면 맑게 울리지요. | 유리꽃은 아주 여려요… 귀 기울이면 맑게 울려요. 가끔 랩도 해요. | Glass flowers are delicate... listen closely and they chime. Sometimes they rap. |
| p3.idle2 | 별들 사이를 날아갈 땐 마음도 깃털처럼 가볍게 가져 보세요. | 꽃들이 어젯밤 릴스 보다 늦게 잤대요… 그래서 오늘 다들 시들해요. | The flowers stayed up late watching Reels... so they're all droopy today. |
| p4.ask | 내 별은 너무 작아서 노을이 자꾸 달아나. 저 주황 띠랑 같이 달려 줘! | 어이 동생, 왔냐. 내 별이 쪼끄매서 노을이 자꾸 도망가거든. \| 저 주황 띠랑 같이 좀 달려 줘. 형이 밥 살게. 아마도. | Hey kiddo, you made it. My planet's so tiny the sunset keeps running off. \| Run alongside that orange band for me. I'll buy you dinner. Probably. |
| p4.hint | 얼음이라 미끄러워! 빠르면 뜨고 느리면 놓쳐. 띠랑 같은 빠르기로 뛰어! | 얼음이라 미끄럽다. 빠르면 뜨고 느리면 놓쳐. 띠랑 같은 빠르기로, 살살. | It's icy. Too fast and you float, too slow and you lose it. Match the band. Easy does it. |
| p4.thanks | 고마워! 분홍 장미 별에 유리 덮개를 줘. 곧장 가면 빨간 지뢰 울타리야. | 오, 잘했다. 이 유리 덮개, 분홍 장미 별에 좀 갖다줘. \| 곧장 가면 빨간 지뢰 울타리야. 거긴 형도 못 지나가. | Nice work. Take this glass dome to the pink Rose Planet. \| The straight route has a red mine fence. Even I can't get through that. |
| p4.keep | 고마워! 유리 덮개는 내가 맡아 둘게. 손이 비면 받으러 와! | 오, 잘했다. 근데 손이 꽉 찼네? 덮개는 형이 맡아 둘게. 손 비면 와. | Nice work. Hands full, huh? I'll hang on to the dome. Come back when you're free. |
| p4.thanks2 | 빨간 불 별 옆을 스치면 휘어 돌아가. 불 별에 닿으면 끝이니까 닿지 마! | 빨간 불 별 옆을 스치면 휘어서 돌아가. 닿으면 끝이다, 진짜로. | Skim past the red Fire Star and you'll curve around. Touch it and it's over. For real. |
| got.dome | 유리 덮개! {target}에 씌워 주자 | 유리 덮개 → {target} | Glass dome → {target} |
| p4.idle1 | 노을빛이 주황색으로 번질 때 별을 달리면 마음이 몽글몽글해. | 노을 보면서 달리면 마음이 몽글몽글해진다. 형 감성 좀 있지? | Running under the sunset makes me all mushy inside. Got some soul, huh? |
| p4.idle2 | 혼자 달릴 땐 외로웠는데, 같이 뛰니까 노을이 안 무서워! | 혼자 뛸 땐 좀 외로웠는데, 둘이 뛰니 노을도 안 무섭네. | Running alone got lonely. With two of us, the sunset's not so scary. |
| rose.early | 바람이 차가워… 노을 아이가 유리 덮개를 갖고 있대. 노을의 별에 가 봐. | …추워. 형님이 유리 덮개를 갖고 있대. 노을의 별에 가 봐. \| 딱히 기다리는 건 아니야. | ...It's cold. I hear Big Bro has a glass dome. Try the Sunset Planet. \| Not that I'm waiting or anything. |
| p5.ask | 바람이 차가워… 유리 덮개를 씌워 줘. 담이 천천히 돌고 틈은 하나야. | …왔어? 바람이 차가워. 유리 덮개 좀 씌워 줘. \| 담이 천천히 돌고, 틈은 딱 하나야. | ...You're here? The wind is cold. Put the dome over me. \| The wall turns slowly, and there's just one gap. |
| p5.hint | 담 틈 맞춰 들어오거나 탑에서 날아 위에서 놓아 줘. 세게 내리면 깨져. | 담 틈으로 들어오거나 탑에서 뛰어 위에서 놓아 줘. 세게 내리면 깨져. | Come in through the gap, or jump from the tower and drop it from above. Drop it hard and it breaks. |
| msg.wall_gap | 담 — 틈으로 | 담 · 틈으로 | Wall · use the gap |
| msg.tower_jump | 탑에서 뛰어내린다 | 탑에서 점프 | Tower leap |
| p5.thanks | …따뜻해. 고마워. 네 빠른 발 덕분에 우리 다섯 별이 다 웃고 있어. | …따뜻해. 고, 고마워. 네 빠른 발 덕분에 다섯 별이 다 웃고 있어. | ...It's warm. Th-thanks. Thanks to your fast feet, all five planets are smiling. |
| p5.thanks_more | …따뜻해. 고마워. 다른 별들도 네 빠른 발을 기다리고 있어. | …따뜻해. 고, 고마워. 다른 별들도 네 발을 기다려. 가 봐, 얼른. | ...It's warm. Th-thanks. The others are waiting for your feet too. Go on, hurry. |
| p5.idle1 | …뭘 그렇게 봐? 유리 덮개가 마음에 들어서 가만있는 것뿐이야. | …뭘 봐? 덮개가 마음에 들어서 가만있는 거야. 사진은 찍지 마. | ...What are you looking at? I'm only sitting still because I like the dome. No photos. |
| p5.idle2 | 별빛이 덮개에 닿아 반짝이는 건… 조금 예쁜 것 같네. | 별빛이 덮개에 반짝이는 건… 조금 예쁘네. 형님 밥 약속보단 확실하고. | Starlight on the dome is... a little pretty. More reliable than Big Bro's dinner promises. |
| msg.drift_warn | 우주로 떠내려간다… 돛으로 돌려! | 떠내려가는 중 · 날다리로 방향 틀기 | Drifting away · turn with Glide |
| msg.drift_warn_ns | 우주로 떠내려간다! | 떠내려가는 중! | Drifting away! |
| react.drift_warning | 멀어진다… 돛으로 돌리자! | 어어, 멀어진다… 날다리로 돌리자! | Uh-oh, drifting... turn with the Glidewing! |
| react.drift_warning_ns | 멀어진다… 초록 점선에서 뛰자 | 어어, 멀어진다… 초록 점선에서 뛰자 | Uh-oh, drifting... jump on green dots |
| banner.lost | 우주 미아! 마지막 별로 돌아가는 중… | 우주 미아 · 마지막 별로 돌아가는 중 | Lost in space · returning to the last planet |
| die.fire | 뜨거운 불 별에 닿았다 | 불 별에 닿음 | Touched the Fire Star |
| react.die_fire | 스치기만 하고 닿지 말자 | 앗 뜨거. 다음엔 스치기만 하자 | Ouch, hot. Just skim it next time |
| die.rocks | 빨간 지뢰 울타리에 부딪혔다 | 빨간 지뢰 울타리에 부딪힘 | Hit the red mine fence |
| react.die_rocks | 불 별 쪽으로 돌아가자 | 울타리는 무리. 불 별 쪽으로 돌아가자 | Can't go through. Curve around the Fire Star |
| die.drift | 깊은 우주로 떠내려갔다 | 깊은 우주로 떠내려감 | Drifted into deep space |
| react.die_drift | 초록 점선을 보고 뛰자 | 다음엔 초록 점선 보고 뛰자 | Next time, jump on green dots |
| die.meteor | 떨어지는 운석에 맞았다 | 떨어지는 운석에 맞음 | Hit by a falling meteor |
| react.die_meteor | 빨간 그림자를 미리 피하자 | 빨간 그림자는 미리 피하자 | Get off red shadows early |
| help.idle1 | 스틱을 밀어 달려 봐 | 조이스틱을 밀어 달려 봐 | Push the joystick to run |
| help.idle2 | 왼쪽 아래 스틱을 손가락으로 밀어 봐 | 왼쪽 아래 조이스틱을 손가락으로 밀어 봐 | Drag the joystick at the bottom left with your finger |
| help.lift1 | 스틱을 끝까지 밀어 더 빨리 달려 | 조이스틱을 끝까지 밀어 더 빨리 달려 | Push the joystick all the way to run faster |
| help.band1 | 띠와 같은 빠르기로! 얼음이라 스틱은 살살 | 띠와 같은 빠르기로! 얼음이라 조이스틱은 살살 | Match the band's speed! It's icy, so ease the joystick |
| help.sail1 | 빗나갈 것 같으면 날 때 '돛' 버튼! | 빗나갈 것 같으면 날 때 '날다리' 버튼! | About to miss? Tap 'Glide' in flight! |
| help.sail2 | 연한 점선이 초록이면 지금 '돛'을 눌러 | 연한 점선이 초록이면 지금 '날다리'를 눌러 | When the faint dots turn green, tap 'Glide' now |
| msg.all_done | 모든 부탁을 마쳤다! | 모든 부탁 완료! | All requests done! |
| end.lose_head | 목숨을 다 썼어 | 목숨 0 | Out of lives |
| end.lose_msg | 다시 하면 첫 별부터 새로 시작해 | 다시 하면 첫 별부터 | Again starts from the first planet |
| end.delivered | 배달한 수 | 배달 | Delivered |

개수: 사용자 수정 10개(키 14), 나머지 바뀜 77줄, 지움 1(hint.first), 새 키 3(p2/p3/p4.busy), 그대로 76줄. 표 전체 166줄.
