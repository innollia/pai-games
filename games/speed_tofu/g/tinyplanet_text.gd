extends RefCounted
## 어린 배달부 / The Little Courier — 화면에 나오는 모든 글 (한 곳).
## TEXT = { 키: ["한국어", "English"] }. 노는 순서대로 적었다. 줄 끝 주석 = "언제 나오나 | 누가 말하나" (TEXT_KO.tsv 로 나간다).
## 번역: tinyplanet.gd 의 _lang() 이 이 표 하나로 en 번역(키 -> English)과 ko 번역(키 -> 한국어)을 만든다. 게임은 tr("키") 로 읽는다.
## "tofu." 키만 다르다: tofu.gd 가 한국어 글을 직접 박아 두는 글이라, 번역 열쇠가 키가 아니라 한국어 글 그대로다 (한국어를 바꾸면 안 맞는다).
## 한국어 고치기: submit/tinyplanet/tools/text_export.py -> TEXT_KO.tsv -> 사용자가 "한국어(수정)" 칸 채움 -> text_import.py.
## {planet} {who} {item} {target} {src} 는 게임이 채우는 자리다. 지우거나 이름을 바꾸지 않는다.

const TEXT := {
	# ---- 시작 화면 ----
	"ui.title": ["어린 배달부", "The Little Courier"],  # 시작 화면 제목 (마지막 낱말은 큰 글자, 앞은 리본) | -
	"ui.start": ["시작", "START"],  # 시작 화면 버튼 | -

	# ---- 조작 버튼·첫 안내 ----
	"ui.jump": ["점프", "Jump"],  # 늘 있는 점프 버튼 | -
	"ui.drop": ["놓기", "Drop"],  # 물건을 들고 있을 때 버튼 | -
	"ui.sail": ["돛", "Sail"],  # 돛이 있고 날고 있고 공중 한 번이 남았을 때 버튼 | -
	"hint.first": ["스틱으로 달리기 · 막대가 차면 점프!", "Stick to run · Jump when the bar fills!"],  # 첫 판, 풍차지기 부탁 바로 뒤 말풍선 | -
	"who.me": ["나", "Me"],  # 혼잣말·엔딩 말풍선의 이름 | 나

	# ---- 별·주민 이름 ----
	"name.windmill": ["풍차의 별", "Windmill Planet"],  # 별 1 이름 (처음 끌려 들어갈 때·내려앉을 때 알림, 칩) | -
	"name.post": ["우편의 별", "Post Planet"],  # 별 2 이름 | -
	"name.glass": ["유리꽃의 별", "Glass Flower Planet"],  # 별 3 이름 | -
	"name.sunset": ["노을의 별", "Sunset Planet"],  # 별 4 이름 | -
	"name.rose": ["장미의 별", "Rose Planet"],  # 별 5 이름 | -
	"name.chimney_moon": ["굴뚝 달", "Chimney Moon"],  # 소포 받는 달 이름 | -
	"name.friend_moon": ["친구 달", "Friend Moon"],  # 유리꽃 받는 달 이름 | -
	"name.fire": ["불 별", "Fire Star"],  # 닿으면 죽는 불 별 이름 | -
	"who.windmill": ["풍차지기", "Windmill Keeper"],  # 별 1 주민 이름 (말풍선 위) | -
	"who.post": ["우체부", "Mail Carrier"],  # 별 2 주민 이름 | -
	"who.glass": ["정원사", "Gardener"],  # 별 3 주민 이름 | -
	"who.sunset": ["노을 아이", "Sunset Child"],  # 별 4 주민 이름 | -
	"who.rose": ["장미", "Rose"],  # 별 5 주민 이름 | -
	"who.chimney": ["굴뚝 집", "Chimney House"],  # 굴뚝 달 주민 이름 | -
	"who.friend": ["꽃 친구", "Flower Friend"],  # 친구 달 주민 이름 | -

	# ---- 맨 위 할 일 칩 ----
	"goal.talk": ["{who}에게 말 걸기", "Talk to {who}"],  # 칩: 주민을 아직 안 만났을 때 | -
	"goal.wind": ["풍차 깨우기: 땅에 붙어 힘껏 달리기", "Wake the windmill: sprint on the ground"],  # 칩: 풍차 부탁 중 | -
	"goal.pick": ["{planet}에서 {item} 받기", "Get the {item} on {planet}"],  # 칩: 물건을 받으러 가야 할 때 | -
	"goal.deliver": ["{target}에 {item} 배달", "Deliver the {item} to {target}"],  # 칩: 물건을 들고(또는 떨어뜨려 두고) 있을 때 | -
	"goal.band": ["노을 띠와 같은 빠르기로 달리기", "Run at the sunset band's speed"],  # 칩: 노을 띠 부탁 중 | -
	"item.pkg": ["소포", "parcel"],  # 칩·목록 안 {item} | -
	"item.flower": ["유리꽃", "glass flower"],  # 칩·목록 안 {item} | -
	"item.dome": ["유리 덮개", "glass dome"],  # 칩·목록 안 {item} | -

	# ---- 왼쪽 위 할 일 목록 (누르면 놀이가 멈춤) ----
	"todo.head": ["할 일", "To-do"],  # 할 일 목록 판 제목 (뒤에 "N/5") | -
	"todo.p1": ["풍차 깨우기: 땅에 붙어 힘껏 달리기", "Wake the windmill: sprint on the ground"],  # 목록 1줄 (풍차지기) | -
	"todo.p2": ["소포를 굴뚝 달 집에 공중에서 놓기", "Drop the parcel on the Chimney Moon house from the air"],  # 목록 2줄 (우체부) | -
	"todo.p3": ["유리꽃을 친구 달에 살살 전하기", "Gently bring the glass flower to Friend Moon"],  # 목록 3줄 (정원사) | -
	"todo.p4": ["주황 노을 띠와 같은 빠르기로 달리기", "Run at the orange sunset band's speed"],  # 목록 4줄 (노을 아이) | -
	"todo.p5": ["유리 덮개를 장미에게 씌우기", "Put the glass dome over Rose"],  # 목록 5줄 (장미), 덮개가 생긴 뒤 | -
	"todo.p5_wait": ["유리 덮개가 필요해 (노을 아이가 줌)", "Needs a glass dome (from the Sunset Child)"],  # 목록 5줄, 노을 부탁 끝나기 전 | -
	"todo.st_none": ["아직 안 만남", "Not met yet"],  # 목록 줄 오른쪽 상태 | -
	"todo.st_doing": ["하는 중", "In progress"],  # 목록 줄 오른쪽 상태 | -
	"todo.st_done": ["끝", "Done"],  # 목록 줄 오른쪽 상태 | -
	"todo.held": ["들고 있는 것", "Carrying"],  # 목록 아래 "들고 있는 것: ○○" | -
	"todo.empty": ["빈손", "Nothing"],  # 위 줄에서 아무것도 안 들었을 때 | -
	"todo.close": ["탭하면 닫혀요", "Tap to close"],  # 목록 판 맨 아래 | -
	"talk.busy": ["들고 있는 {item}부터 배달하고 다시 와 줘!", "Deliver the {item} you're carrying first, then come back!"],  # 물건을 든 채 다른 주민에게 갔을 때 | 그 주민

	# ---- 별 1 풍차의 별 ----
	"p1.ask": ["바람이 멎어 풍차가 잠들었네. 별 둘레를 힘껏 달려 바람을 깨워 주겠나?", "The wind stopped and the windmill fell asleep. Run hard around the planet to wake the wind?"],  # 풍차지기 5m 안에 처음 갔을 때 | 풍차지기
	"p1.hint": ["뜨기 직전이 제일 센 바람이지. 발이 뜨면 바람이 끊기니 땅에 붙어 달리게나.", "The wind is strongest just before liftoff. It stops when your feet leave the ground, so stay low."],  # 부탁 바로 뒤, 또 바람 막대 15% 미만이면 40초마다 | 풍차지기
	"p1.thanks": ["고마우이, 돛을 받게나. 보라 별이 우편의 별이니 노란 줄을 힘껏 달리게.", "Thank you! Take this sail. The purple one is Post Planet; sprint along the yellow line."],  # 바람 막대 100% | 풍차지기
	"p1.thanks2": ["초록 점선이 보이면 점프하게. 날다 스틱 밀며 뛰면 돛으로 방향을 한 번 튼다네.", "Jump when the dots turn green. In flight, push the stick and jump to turn once with the sail."],  # thanks 바로 뒤 | 풍차지기
	"banner.sail": ["풍차지기의 고마움: 돛! 날 때 '돛' 버튼을 한 번 누르면 스틱 쪽으로 방향을 튼다 (스틱 안 밀면 갈 곳 쪽).", "The Windmill Keeper's gift: a sail! In flight, tap 'Sail' once to turn toward your stick (no stick: toward your goal)."],  # 바람 막대 100% (위쪽 띠 5초) | -
	"hint.sail": ["지금 '돛'을 누를 수 있다 · 연한 점선이 돛을 쓰면 갈 길", "You can tap 'Sail' now · the faint dots show where it takes you"],  # 돛 버튼이 처음 나올 때 한 번 | -
	"msg.sail": ["돛으로 방향을 튼다", "Turning with the sail"],  # 날다가 돛을 쓸 때 알림 | -
	"p1.idle1": ["바람결을 느끼며 달리면 하늘도 그 발소리를 듣는다네.", "Run with the wind, and the sky hears your footsteps."],  # 부탁을 끝낸 뒤 곁에 서면 60초에 한 번 (둘 중 하나) | 풍차지기
	"p1.idle2": ["서두르지 말게. 별은 언제나 제자리에서 자네를 기다리니.", "No need to rush. The planets always wait for you right where they are."],  # 위와 같음 | 풍차지기

	# ---- 날기·내려앉기 ----
	"react.first_liftoff": ["별을 떠나 날아오른다", "Off the planet, into the sky"],  # 처음으로 중력을 벗어나는 점프 (한 번) | 나
	"react.first_landing": ["새로운 별에 내려앉았다", "Landed on a new planet"],  # 다른 별에 처음 내려앉음 (한 번) | 나
	"react.new_planet": ["새 별에 닿아 힘이 난다", "A new planet! I feel stronger"],  # 그 뒤 새 별에 처음 내려앉음 (목숨이 3으로 참) | 나
	"react.slingshot": ["별의 곁을 스쳐 가속한다", "Skimming a planet for speed"],  # 다른 별 곁을 지나 휘어 내려앉음 | 나
	"react.orbit_landing": ["궤도를 돌아 살포시 앉았다", "Orbited and landed softly"],  # 대기에서 오래 돌다 살살 앉음 | 나
	"msg.next": ["다음: {planet}", "Next: {planet}"],  # 부탁 하나 끝난 뒤 알림 | -
	"hud.next_hint": ["다음: {planet} (노란 빛기둥). 달려 점프! 초록 점선이면 닿아.", "Next: {planet} (yellow pillar). Run and jump! Green dots mean you'll reach it."],  # 땅에 있고 갈 곳이 다른 별일 때 (50초에 한 번) | -
	"msg.use_sail": ["지금 돛!", "Sail now!"],  # 이대로면 못 닿는데 돛 한 번이면 닿을 때 | -
	"msg.use_air": ["한 번 더 점프!", "Jump once more!"],  # 같은 상황, 돛이 없을 때 | -

	# ---- 별 2 우편의 별 · 굴뚝 달 ----
	"p2.ask": ["이 소포, 저 하얀 굴뚝 달 집에 전해 줘! 담이 높아 걸어선 못 들어가.", "Take this parcel to the house on the white Chimney Moon! The wall's too high to walk in."],  # 우체부 5m 안 (손이 비었을 때) | 우체부
	"got.pkg": ["소포! {target}에 전해 주자", "A parcel! Let's take it to {target}"],  # 소포를 주웠을 때 위쪽 띠 3초 | -
	"p2.hint": ["달은 작아 금방 떠! 굴뚝 위 지날 때 '놓기'. 발밑 노란 점에 떨어져!", "The moon is tiny, so you float off fast! Tap 'Drop' over the chimney. It falls on the yellow dot below you!"],  # 소포를 들고 있으면 45초마다 | 우체부
	"msg.wall_high": ["담이 높다 — 공중에서 놓기", "The wall is high — drop it from the air"],  # 굴뚝 달 담에 부딪힘 | -
	"msg.missed_drop": ["빗나갔다 — 다시 줍기", "Missed — pick it up again"],  # 놓은 물건이 과녁 밖에 떨어짐 | -
	"moon.chimney.got": ["굴뚝 속으로 소포가 쏙 들어왔어! 따뜻한 온기가 번지네.", "The parcel popped right down the chimney! Cozy warmth is spreading."],  # 소포 배달 순간 | 굴뚝 집
	"p2.thanks": ["잘 도착했대, 고마워! 남은 부탁은 왼쪽 위 할 일 목록에 있어.", "It arrived safely, thank you! The other requests are in the to-do list, top left."],  # 위 말 바로 뒤 | 우체부
	"p2.idle1": ["하늘에 띄운 편지는 길을 잃지 않아. 언제나 닿을 곳으로 가지!", "Letters sent into the sky never get lost. They always find their way!"],  # 부탁을 끝낸 뒤 곁에 서면 60초에 한 번 | 우체부
	"p2.idle2": ["오늘도 우편 가방이 든든하네! 다음 행선지는 어디야?", "My mailbag is nice and full again today! Where are you headed next?"],  # 위와 같음 | 우체부

	# ---- 별 3 유리꽃의 별 · 친구 달 ----
	"p3.ask": ["유리꽃을 저 민트 친구 달에 전해 줘요… 세게 내려앉으면 깨져 버려요.", "Please take this glass flower to the mint Friend Moon... A hard landing will break it."],  # 정원사 5m 안 (손이 비었을 때) | 정원사
	"got.flower": ["유리꽃! 살살 {target}에 전해 주자", "A glass flower! Let's take it gently to {target}"],  # 유리꽃을 주웠을 때 위쪽 띠 | -
	"p3.hint": ["곧장 말고 빙 돌아 살살 앉아요. 빨간 그림자는 운석 자리니 미리 피해요!", "Don't dive straight in; circle and land softly. Red shadows mean meteors, so move early!"],  # 유리꽃을 들고 있으면 45초마다 | 정원사
	"react.flower_cracked": ["금이 갔다… 더 살살 앉자", "It cracked... land softer!"],  # 유리 물건을 들고 세게 착지 | 나
	"react.flower_broken": ["깨져 버렸다… 다시 가자", "It broke... let's try again"],  # 유리 물건이 깨짐 | 나
	"msg.glass_broken": ["깨졌다… {src}에서 다시 받기", "Broken... get a new one on {src}"],  # 금 100% 또는 높이 놓기로 깨짐 | -
	"moon.friend.got": ["정원사의 맑은 꽃이 깨지지 않고 닿았어… 달이 환해졌네!", "The gardener's clear flower arrived unbroken... the moon is glowing!"],  # 유리꽃 배달 순간 | 꽃 친구
	"p3.thanks": ["꽃이 무사하대요… 정말 다행이에요. 다른 별에도 기다리는 이가 있을 거예요.", "The flower is safe... what a relief. Someone on another planet must be waiting too."],  # 위 말 바로 뒤 | 정원사
	"p3.idle1": ["유리꽃은 아주 여려요… 가만히 숨소리를 들으면 맑게 울리지요.", "Glass flowers are very delicate... listen quietly and you'll hear them ring."],  # 부탁을 끝낸 뒤 곁에 서면 60초에 한 번 | 정원사
	"p3.idle2": ["별들 사이를 날아갈 땐 마음도 깃털처럼 가볍게 가져 보세요.", "When you fly between planets, keep your heart light as a feather."],  # 위와 같음 | 정원사

	# ---- 별 4 노을의 별 ----
	"p4.ask": ["내 별은 너무 작아서 노을이 자꾸 달아나. 저 주황 띠랑 같이 달려 줘!", "My planet is so small the sunset keeps running away. Run with that orange band!"],  # 노을 아이 5m 안 | 노을 아이
	"p4.hint": ["얼음이라 미끄러워! 빠르면 뜨고 느리면 놓쳐. 띠랑 같은 빠르기로 뛰어!", "It's icy and slippery! Too fast, you float; too slow, you lose it. Match its speed!"],  # 부탁 바로 뒤, 띠 막대 15% 미만이면 40초마다 | 노을 아이
	"p4.thanks": ["고마워! 분홍 장미 별에 유리 덮개를 줘. 곧장 가면 빨간 지뢰 울타리야.", "Thank you! Take the glass dome to the pink Rose Planet. The straight way has a red mine fence."],  # 띠 막대 100%, 손이 비었을 때 (맡겨 둔 덮개를 받을 때도) | 노을 아이
	"p4.keep": ["고마워! 유리 덮개는 내가 맡아 둘게. 손이 비면 받으러 와!", "Thank you! I'll keep the glass dome for you. Come get it when your hands are free!"],  # 띠 막대 100%인데 손에 다른 물건 | 노을 아이
	"p4.thanks2": ["빨간 불 별 옆을 스치면 휘어 돌아가. 불 별에 닿으면 끝이니까 닿지 마!", "Skim past the red Fire Star to curve around. Touching it is the end, so don't!"],  # thanks 바로 뒤, 또 덮개를 들고 장미 별 밖이면 45초마다 | 노을 아이
	"got.dome": ["유리 덮개! {target}에 씌워 주자", "The glass dome! Let's bring it to {target}"],  # 덮개를 다시 주웠을 때 위쪽 띠 | -
	"p4.idle1": ["노을빛이 주황색으로 번질 때 별을 달리면 마음이 몽글몽글해.", "When the sunset glows orange and I run, my heart feels soft and warm."],  # 부탁을 끝낸 뒤 곁에 서면 60초에 한 번 | 노을 아이
	"p4.idle2": ["혼자 달릴 땐 외로웠는데, 같이 뛰니까 노을이 안 무서워!", "Running alone was lonely, but with you the sunset isn't scary!"],  # 위와 같음 | 노을 아이

	# ---- 별 5 장미의 별 ----
	"rose.early": ["바람이 차가워… 노을 아이가 유리 덮개를 갖고 있대. 노을의 별에 가 봐.", "The wind is cold... I hear the Sunset Child has a glass dome. Try Sunset Planet."],  # 노을 부탁 전에 장미에게 갔을 때 | 장미
	"p5.ask": ["바람이 차가워… 유리 덮개를 씌워 줘. 담이 천천히 돌고 틈은 하나야.", "The wind is cold... Please put the dome over me. The wall turns slowly and has one gap."],  # 덮개가 생긴 뒤 장미 5m 안에 처음 갔을 때 | 장미
	"p5.hint": ["담 틈 맞춰 들어오거나 탑에서 날아 위에서 놓아 줘. 세게 내리면 깨져.", "Come in through the gap, or leap from the tower and drop it from above. Drop it hard and it breaks."],  # 덮개를 들고 장미 별에 있으면 45초마다 | 장미
	"msg.wall_gap": ["담 — 틈으로", "Wall — use the gap"],  # 장미 별 담에 부딪힘 | -
	"msg.tower_jump": ["탑에서 뛰어내린다", "Leaping from the tower"],  # 탑 꼭대기에서 뛰어내릴 때 | -
	"msg.rose_smiles": ["장미가 환하게 웃는다", "Rose smiles brightly"],  # 덮개 배달 (마지막 부탁이었을 때) | -
	"p5.thanks": ["…따뜻해. 고마워. 네 빠른 발 덕분에 우리 다섯 별이 다 웃고 있어.", "...So warm. Thank you. Thanks to your fast feet, all five planets are smiling."],  # 덮개 배달, 마지막 부탁이었을 때 | 장미
	"p5.thanks_more": ["…따뜻해. 고마워. 다른 별들도 네 빠른 발을 기다리고 있어.", "...So warm. Thank you. The other planets are waiting for your fast feet too."],  # 덮개 배달, 남은 부탁이 있을 때 | 장미
	"p5.idle1": ["…뭘 그렇게 봐? 유리 덮개가 마음에 들어서 가만있는 것뿐이야.", "...What are you staring at? I'm only sitting still because I like this dome."],  # 부탁을 끝낸 뒤 곁에 서면 60초에 한 번 | 장미
	"p5.idle2": ["별빛이 덮개에 닿아 반짝이는 건… 조금 예쁜 것 같네.", "Starlight sparkling on the dome... is a little pretty, I suppose."],  # 위와 같음 | 장미

	# ---- 우주 미아·죽음 ----
	"msg.drift_warn": ["우주로 떠내려간다… 돛으로 돌려!", "Drifting into space... turn with the sail!"],  # 어느 별에도 안 끌리고 멀어질 때 (돛 있음) | -
	"msg.drift_warn_ns": ["우주로 떠내려간다!", "Drifting into space!"],  # 위와 같음, 돛 받기 전 | -
	"react.drift_warning": ["멀어진다… 돛으로 돌리자!", "Drifting away... turn with the sail!"],  # 위 상황 첫 번 (돛 있음) | 나
	"react.drift_warning_ns": ["멀어진다… 초록 점선에서 뛰자", "Drifting away... jump on green dots"],  # 위 상황 첫 번 (돛 받기 전) | 나
	"banner.lost": ["우주 미아! 마지막 별로 돌아가는 중…", "Lost in space! Heading back to the last planet…"],  # 못 닿는 길로 2.6초 넘게 날면 끌려 돌아감 | -
	"die.fire": ["뜨거운 불 별에 닿았다", "Touched the hot Fire Star"],  # 불 별에 닿음 | -
	"react.die_fire": ["스치기만 하고 닿지 말자", "Just skim past, don't touch it"],  # 위 바로 뒤 | 나
	"die.rocks": ["빨간 지뢰 울타리에 부딪혔다", "Hit the red mine fence"],  # 빨간 지뢰 울타리에 닿음 | -
	"react.die_rocks": ["불 별 쪽으로 돌아가자", "Go around by the Fire Star"],  # 위 바로 뒤 | 나
	"die.drift": ["깊은 우주로 떠내려갔다", "Drifted into deep space"],  # 너무 멀리 떠내려감 | -
	"react.die_drift": ["초록 점선을 보고 뛰자", "Look for green dots before jumping"],  # 위 바로 뒤 | 나
	"die.meteor": ["떨어지는 운석에 맞았다", "Hit by a falling meteor"],  # 운석에 맞음 | -
	"react.die_meteor": ["빨간 그림자를 미리 피하자", "Move off red shadows early"],  # 위 바로 뒤 | 나

	# ---- 엔딩·끝 화면 ----
	"msg.all_done": ["모든 부탁을 마쳤다!", "All requests done!"],  # 마지막 부탁이 장미가 아닐 때 알림 | -
	"ending.1": ["발끝으로 건넌 별마다 다정한 빛이 켜졌다.", "A gentle light came on at every planet I crossed."],  # 모든 부탁 뒤 혼잣말 1 | 나
	"ending.2": ["작고 외롭던 별들이 하늘 한가운데서 서로 웃는다.", "The small, lonely planets smile at each other across the sky."],  # 혼잣말 2 | 나
	"ending.3": ["차가운 유리 너머로 전해진 온기가 마음을 데운다.", "Warmth passed through cold glass warms my heart."],  # 혼잣말 3 | 나
	"ending.4": ["언젠가 또 바람이 불면, 다시 달려 날아가야지.", "Someday, when the wind blows again, I'll run and fly once more."],  # 혼잣말 4 | 나
	"end.win_head": ["모든 부탁 완료!", "All requests done!"],  # 끝 화면 제목 (이김) | -
	"end.win_msg": ["다섯 별이 모두 웃고 있어", "All five planets are smiling"],  # 끝 화면 글 (이김) | -
	"end.lose_head": ["목숨을 다 썼어", "Out of lives"],  # 끝 화면 제목 (목숨 0) | -
	"end.lose_msg": ["다시 하면 첫 별부터 새로 시작해", "Playing again starts from the first planet"],  # 끝 화면 글 (목숨 0) | -
	"end.delivered": ["배달한 수", "Delivered"],  # 기록 줄 1 | -
	"end.time": ["걸린 시간", "Time"],  # 기록 줄 2 (이김) | -
	"end.survived": ["버틴 시간", "Time survived"],  # 기록 줄 2 (목숨 0) | -
	"end.slings": ["새총", "Slingshots"],  # 기록 줄 3 (불 별·다른 별 곁을 휘어 돈 수) | -
	"end.best_time": ["최고 기록", "Best time"],  # 기록 줄 4 (이김) | -
	"end.best_count": ["최고 배달", "Most delivered"],  # 기록 줄 4 (목숨 0) | -
	"end.new_best": ["새 기록", "New best"],  # 기록을 깼을 때 딱지 | -
	"end.again": ["다시", "AGAIN"],  # 끝 화면 버튼 (첫 별부터 다시) | -

	# ---- tofu 공통 글 (tofu.gd 가 한국어를 직접 박아 둠: 한국어는 여기서 바꿔도 화면에 안 바뀐다. 영어만 고친다) ----
	"tofu.list": ["< 목록", "< List"],  # 단독판을 목록에서 열었을 때 왼쪽 위 | -
	"tofu.menu": ["< 메뉴", "< Menu"],  # 모음판(SPEED 두부)에서 왼쪽 위 | -
	"tofu.restart": ["< 처음부터", "< Restart"],  # 단독판 왼쪽 위 (지금은 숨김) | -
	"tofu.over_best": ["최고", "Best"],  # 게임 끝에 가운데 점수 글 "점수 / 최고 N" (끝 화면 아래) | -
	"tofu.over_again": ["탭해서 다시", "Tap to play again"],  # 같은 점수 글 셋째 줄 | -
	"tofu.rate": ["평가", "Rate"],  # 모음판 오른쪽 위 평가 버튼 (단독판은 끔) | -
	"tofu.rate_title": ["이 게임 어때요?", "How was it?"],  # 평가 카드 제목 | -
	"tofu.close": ["닫기", "Close"],  # 평가 카드 | -
	"tofu.comment": ["한마디", "Comment"],  # 평가 카드 | -
	"tofu.thanks": ["고마워요!", "Thanks!"],  # 평가 카드, 별을 누른 뒤 | -
	"tofu.sending": ["보내는 중", "Sending"],  # 평가 카드 | -
	"tofu.sent": ["한마디 보냈어요", "Comment sent"],  # 평가 카드 | -
	"tofu.not_saved": ["저장 안 됨 · 별을 다시 탭", "Not saved · tap a star again"],  # 평가 카드 | -
	"tofu.comment_ph": ["이 게임에 한마디 (선택)", "A word about this game (optional)"],  # 평가 카드 입력 칸 | -
}


## 키의 한국어 (없으면 키 그대로)
static func ko(key: String) -> String:
	return str(TEXT[key][0]) if TEXT.has(key) else key


## 키의 영어 (없으면 키 그대로)
static func en(key: String) -> String:
	return str(TEXT[key][1]) if TEXT.has(key) else key


## 번역 열쇠: 보통은 키, tofu 글은 tofu.gd 가 쓰는 한국어 그대로
static func msgid(key: String) -> String:
	return ko(key) if key.begins_with("tofu.") else key


## 이 표 하나로 번역을 만든다. ko 번역에는 한국어 글 -> 그대로도 넣는다
## (Label 이 스스로 번역할 때 다른 게임의 영어 번역으로 빠지지 않게).
static func make(korean: bool) -> Translation:
	var t := Translation.new()
	t.locale = "ko" if korean else "en"
	var i := 0 if korean else 1
	for k: String in TEXT:
		var pr: Array = TEXT[k]
		t.add_message(msgid(k), str(pr[i]))
		if korean and not k.begins_with("tofu."):
			t.add_message(str(pr[0]), str(pr[0]))
	return t
