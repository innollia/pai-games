extends RefCounted
## 어린 배달부 / The Little Courier — 화면에 나오는 모든 글 (한 곳).
## TEXT = { 키: ["한국어", "English"] }. 노는 순서대로 적었다. 줄 끝 주석 = "언제 나오나 | 누가 말하나" (TEXT_KO.tsv 로 나간다).
## 번역: tinyplanet.gd 의 _lang() 이 이 표 하나로 en 번역(키 -> English)과 ko 번역(키 -> 한국어)을 만든다. 게임은 tr("키") 로 읽는다.
## "tofu." 키만 다르다: tofu.gd 가 한국어 글을 직접 박아 두는 글이라, 번역 열쇠가 키가 아니라 한국어 글 그대로다 (한국어를 바꾸면 안 맞는다).
## 한국어 고치기: submit/tinyplanet/tools/text_export.py -> TEXT_KO.tsv -> 사용자가 "한국어(수정)" 칸 채움 -> text_import.py.
## {planet} {who} {item} {target} {src} 는 게임이 채우는 자리다. 지우거나 이름을 바꾸지 않는다.
## 말풍선 글 안의 "|" = 말풍선 나눔: 앞 조각이 먼저, 뒤 조각이 바로 이어서 다음 말풍선으로 나온다 (tinyplanet.gd _say). 말풍선 하나는 한국어 40자 안쪽.
## 장르: 일상개그물 (심드렁한 잡담·작은 엉뚱함·주민끼리 이어지는 개그: 별들은 릴스를 봄, 형님의 "밥 살게. 아마도."). 안내는 정확하게.
## 말투: 풍차지기 = 옛말 할아버지(~하게나·~구먼·자네), 우체부 = 바쁜 배송 프로(해요체·배송 말), 정원사 = 속삭이는 해요체(…), 형님 = 느긋한 큰형(반말·"동생"),
##       장미 = 새침(…·딱히), 굴뚝 집 = 뜨끈한 거 좋아하는 집, 꽃 친구 = 들뜬 10대(헐·대박), 너? = 짧은 혼잣말. UI 글(버튼·칩·목록·알림) = 짧은 낱말, 문장 아님.

const TEXT := {
	# ---- 시작 화면 ----
	"ui.title": ["어린 배달부", "The Little Courier"],  # 시작 화면 제목 (마지막 낱말은 큰 글자, 앞은 리본) | -
	"ui.start": ["시작", "START"],  # 시작 화면 버튼 | -

	# ---- 조작 버튼 ----
	"ui.jump": ["점프", "Jump"],  # 늘 있는 점프 버튼 | -
	"ui.drop": ["놓기", "Drop"],  # 물건을 들고 있을 때 버튼 | -
	"ui.sail": ["날다리", "Glide"],  # 구식 날다리가 있고 날고 있고 공중 한 번이 남았을 때 버튼 | -
	"who.me": ["너?", "You?"],  # 혼잣말·엔딩 말풍선의 이름 | 너?

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
	"who.sunset": ["형님", "Big Bro"],  # 별 4 주민 이름 | -
	"who.rose": ["장미", "Rose"],  # 별 5 주민 이름 | -
	"who.chimney": ["굴뚝 집", "Chimney House"],  # 굴뚝 달 주민 이름 | -
	"who.friend": ["꽃 친구", "Flower Friend"],  # 친구 달 주민 이름 | -

	# ---- 맨 위 할 일 칩 ----
	"goal.talk": ["{who}에게 말 걸기", "Talk to {who}"],  # 칩: 주민을 아직 안 만났을 때 | -
	"goal.wind": ["풍차 깨우기 · 땅에서 전력 질주", "Wake the windmill · sprint on the ground"],  # 칩: 풍차 부탁 중 | -
	"goal.pick": ["{planet}에서 {item} 받기", "Get the {item} on {planet}"],  # 칩: 물건을 받으러 가야 할 때 | -
	"goal.deliver": ["{target}에 {item} 배달", "Deliver the {item} to {target}"],  # 칩: 물건을 들고(또는 떨어뜨려 두고) 있을 때 | -
	"goal.band": ["노을 띠 속도 맞추기", "Match the sunset band's speed"],  # 칩: 노을 띠 부탁 중 | -
	"item.pkg": ["소포", "parcel"],  # 칩·목록 안 {item} | -
	"item.flower": ["유리꽃", "glass flower"],  # 칩·목록 안 {item} | -
	"item.dome": ["유리 덮개", "glass dome"],  # 칩·목록 안 {item} | -

	# ---- 왼쪽 위 할 일 목록 (누르면 놀이가 멈춤) ----
	"todo.head": ["할 일", "To-do"],  # 할 일 목록 판 제목 (뒤에 "N/5") | -
	"todo.p1": ["풍차 깨우기 · 땅에서 전력 질주", "Wake the windmill · sprint on the ground"],  # 목록 1줄 (풍차지기) | -
	"todo.p2": ["소포 → 굴뚝 달 집 (공중에서 놓기)", "Parcel → Chimney Moon house (drop from the air)"],  # 목록 2줄 (우체부) | -
	"todo.p3": ["유리꽃 → 친구 달 (살살 착지)", "Glass flower → Friend Moon (land softly)"],  # 목록 3줄 (정원사) | -
	"todo.p4": ["노을 띠 속도 맞추기", "Match the sunset band's speed"],  # 목록 4줄 (형님) | -
	"todo.p5": ["유리 덮개 → 장미", "Glass dome → Rose"],  # 목록 5줄 (장미), 덮개가 생긴 뒤 | -
	"todo.p5_wait": ["유리 덮개 필요 (형님에게)", "Needs a glass dome (from Big Bro)"],  # 목록 5줄, 노을 부탁 끝나기 전 | -
	"todo.st_none": ["안 만남", "Not met"],  # 목록 줄 오른쪽 상태 | -
	"todo.st_doing": ["하는 중", "In progress"],  # 목록 줄 오른쪽 상태 | -
	"todo.st_done": ["끝", "Done"],  # 목록 줄 오른쪽 상태 | -
	"todo.held": ["들고 있는 것", "Carrying"],  # 목록 아래 "들고 있는 것: ○○" | -
	"todo.empty": ["빈손", "Nothing"],  # 위 줄에서 아무것도 안 들었을 때 | -
	"todo.close": ["닫기", "Close"],  # 목록 판 맨 아래 (판 아무 데나 누르면 닫힘) | -
	"talk.busy": ["어라, 이미 {item} 들고 있네. 그것부터 갖다주고 와!", "Oh, you're already carrying the {item}. Deliver that first!"],  # 물건을 든 채 주민에게 갔는데 그 주민 줄(pN.busy)이 없을 때 (예비) | 그 주민

	# ---- 별 1 풍차의 별 ----
	"p1.ask": ["오, 마침 잘 됐군. 자네 다리가 튼실해 보이는데 나 좀 도와주게나.|바람이 멎어 풍차가 잠들었네. 이 별을 뛰어다녀 바람을 만들어주게나.", "Oh, just in time. Those legs of yours look sturdy. Lend an old man a hand.|The wind has stopped and the windmill fell asleep. Run around this planet and make me some wind."],  # 풍차지기 5m 안에 처음 갔을 때 (말풍선 둘) | 풍차지기
	"p1.hint": ["뜨기 직전이 제일 센 바람이지. 발이 뜨면 바람이 끊기니 땅에 붙어 달리게나.", "The wind is strongest just before liftoff. It stops when your feet leave the ground, so stay low."],  # 부탁 바로 뒤, 또 바람 막대 15% 미만이면 40초마다 | 풍차지기
	"p1.thanks": ["고마우이, 구식 날다리를 받게나.|배달 일이라면 우편의 별, 보라색 별로 가면 되겠군 그래.", "Much obliged. Take this Old Glidewing.|If it's delivery work you're after, the Post Planet is the purple one."],  # 바람 막대 100% (말풍선 둘) | 풍차지기
	"p1.thanks2": ["날다가 한번 더 뛰면 조이스틱 방향으로 방향을 튼다네.", "Jump once more in flight, and you'll turn toward your joystick."],  # thanks 바로 뒤 | 풍차지기
	"banner.sail": ["구식 날다리! 날 때 '날다리' 버튼을 한 번 누르면 조이스틱 쪽으로 방향을 튼다.", "Old Glidewing! In flight, tap 'Glide' once to turn toward your joystick."],  # 바람 막대 100% (위쪽 띠 5초) | -
	"hint.sail": ["'날다리' 버튼 등장 · 연한 점선 = 날다리로 갈 길", "'Glide' ready · faint dots = where it takes you"],  # 날다리 버튼이 처음 나올 때 한 번 | -
	"msg.sail": ["날다리로 방향 전환", "Glidewing turn"],  # 날다가 날다리를 쓸 때 알림 | -
	"p1.idle1": ["요즘 젊은이들은 바람도 앱으로 부른다지? 나는 아직 발로 부른다네.", "Young folks summon wind with an app these days, I hear. I still do it with my feet."],  # 부탁을 끝낸 뒤 곁에 서면 60초에 한 번 (둘 중 하나) | 풍차지기
	"p1.idle2": ["서두르지 않아도 되네. 별은 언제나 제자리에서 릴스를 보고 있으니.", "No need to hurry. The planets are always right where they are, scrolling reels."],  # 위와 같음 | 풍차지기

	# ---- 날기·내려앉기 ----
	"react.first_liftoff": ["어… 나 지금 나는 거야?", "Wait... am I flying?"],  # 처음으로 중력을 벗어나는 점프 (한 번) | 너?
	"react.first_landing": ["착지 성공. 여긴 어디지?", "Landed. Where am I?"],  # 다른 별에 처음 내려앉음 (한 번) | 너?
	"react.new_planet": ["새 별이다. 기운이 솟는다", "A new planet. I feel recharged"],  # 그 뒤 새 별에 처음 내려앉음 (목숨이 3으로 참) | 너?
	"react.slingshot": ["별 옆을 스치니 빨라졌다", "Skimmed a planet. Faster!"],  # 다른 별 곁을 지나 휘어 내려앉음 | 너?
	"react.orbit_landing": ["한 바퀴 돌고 사뿐히 착지", "One lap, then a soft landing"],  # 대기에서 오래 돌다 살살 앉음 | 너?
	"msg.next": ["다음: {planet}", "Next: {planet}"],  # 부탁 하나 끝난 뒤 알림 | -
	"hud.next_hint": ["다음: {planet} (노란 빛기둥). 달려 점프! 초록 점선이면 닿아.", "Next: {planet} (yellow pillar). Run and jump! Green dots mean you'll reach it."],  # 땅에 있고 갈 곳이 다른 별일 때 (50초에 한 번) | -
	"msg.use_sail": ["지금 날다리!", "Glide now!"],  # 이대로면 못 닿는데 날다리 한 번이면 닿을 때 | -
	"msg.use_air": ["한 번 더 점프!", "Jump once more!"],  # 같은 상황, 날다리가 없을 때 | -

	# ---- 별 2 우편의 별 · 굴뚝 달 ----
	"p2.ask": ["어서 오세요, 우편의 별입니다! 마침 급한 건이 하나 있는데요.|이 소포, 하얀 굴뚝 달 집으로요. 담이 높아서 걸어선 못 들어가요!", "Welcome to the Post Planet! Perfect timing, I've got a rush job.|This parcel goes to the house on the white Chimney Moon. The wall's too high to walk in!"],  # 우체부 5m 안 (손이 비었을 때, 말풍선 둘) | 우체부
	"p2.busy": ["아, 손에 {item} 있으시네요! 한 건씩만요. 그거 먼저 배송하고 오세요.", "Oh, you've got the {item}! One job at a time. Deliver that first."],  # 다른 물건을 든 채 우체부에게 갔을 때 | 우체부
	"got.pkg": ["소포 → {target}", "Parcel → {target}"],  # 소포를 주웠을 때 위쪽 띠 3초 | -
	"p2.hint": ["달은 작아서 금방 떠요! 굴뚝 위를 지날 때 '놓기'.|발밑 노란 점에 떨어져요.", "The moon's tiny, so you float off fast! Tap 'Drop' over the chimney.|It lands on the yellow dot below you."],  # 소포를 들고 있으면 45초마다 | 우체부
	"msg.wall_high": ["높은 담 · 공중에서 놓기", "High wall · drop from the air"],  # 굴뚝 달 담에 부딪힘 | -
	"msg.missed_drop": ["빗나감 · 다시 줍기", "Missed · pick it up again"],  # 놓은 물건이 과녁 밖에 떨어짐 | -
	"moon.chimney.got": ["캬, 굴뚝으로 소포가 쏙! 뜨끈하다, 이 맛에 집 하지.", "Ahh, right down the chimney! Toasty. This is why I'm a house."],  # 소포 배달 순간 | 굴뚝 집
	"p2.thanks": ["배송 완료! 오늘 물량 하나 줄었네요.|남은 부탁은 왼쪽 위 할 일 목록에 있어요.", "Delivered! One less in today's pile.|The other requests are in the to-do list, top left."],  # 위 말 바로 뒤 | 우체부
	"p2.idle1": ["형님이 밥 산다는 말, 3년째 배송 중이래요. 도착 예정일 미정.", "Big Bro's 'I'll buy you dinner' has been in transit for three years. ETA unknown."],  # 부탁을 끝낸 뒤 곁에 서면 60초에 한 번 | 우체부
	"p2.idle2": ["오늘 물량 실화예요? 그래도 가방이 빵빵하면 기분은 좋아요.", "Is today's load for real? Still, a full bag feels good."],  # 위와 같음 | 우체부

	# ---- 별 3 유리꽃의 별 · 친구 달 ----
	"p3.ask": ["쉿… 꽃들이 자고 있어서요. 이 유리꽃, 민트색 친구 달에 전해 줄래요?|세게 내려앉으면… 깨져 버려요.", "Shh... the flowers are sleeping. Could you take this glass flower to the mint Friend Moon?|If you land hard... it'll break."],  # 정원사 5m 안 (손이 비었을 때, 말풍선 둘) | 정원사
	"p3.busy": ["어머… 이미 {item} 들고 있네요. 그것부터 전해 주고… 천천히 오세요.", "Oh... you're already carrying the {item}. Deliver that first... then come back, slowly."],  # 다른 물건을 든 채 정원사에게 갔을 때 | 정원사
	"got.flower": ["유리꽃 → {target} (살살)", "Glass flower → {target} (gently)"],  # 유리꽃을 주웠을 때 위쪽 띠 | -
	"p3.hint": ["곧장 꽂지 말고 빙 돌다 살살 앉아요.|빨간 그림자는 운석 자리예요… 미리 피해요.", "Don't dive straight in. Circle and land softly.|Red shadows mean meteors... move early."],  # 유리꽃을 들고 있으면 45초마다 | 정원사
	"react.flower_cracked": ["금이 갔다… 더 살살", "It cracked... softer"],  # 유리 물건을 들고 세게 착지 | 너?
	"react.flower_broken": ["깨졌다… 다시 받으러 가자", "It broke... go get another"],  # 유리 물건이 깨짐 | 너?
	"msg.glass_broken": ["깨짐 · {src}에서 다시 받기", "Broken · get another on {src}"],  # 금 100% 또는 높이 놓기로 깨짐 | -
	"moon.friend.got": ["헐, 하나도 안 깨졌어! 바로 릴스 올려야지. 달이 반짝반짝해!", "No way, not a single crack! Posting this to Reels right now. The moon's sparkling!"],  # 유리꽃 배달 순간 | 꽃 친구
	"p3.thanks": ["꽃이 무사하대요… 휴, 제 손이 다 떨렸어요.|다른 별에도 기다리는 이가 있을 거예요.", "The flower made it... phew, my hands were shaking.|Someone on another planet must be waiting too."],  # 위 말 바로 뒤 (말풍선 둘) | 정원사
	"p3.idle1": ["유리꽃은 아주 여려요… 귀 기울이면 맑게 울려요. 가끔 랩도 해요.", "Glass flowers are delicate... listen closely and they chime. Sometimes they rap."],  # 부탁을 끝낸 뒤 곁에 서면 60초에 한 번 | 정원사
	"p3.idle2": ["꽃들이 어젯밤 릴스 보다 늦게 잤대요… 그래서 오늘 다들 시들해요.", "The flowers stayed up late watching Reels... so they're all droopy today."],  # 위와 같음 | 정원사

	# ---- 별 4 노을의 별 ----
	"p4.ask": ["어이 동생, 왔냐. 내 별이 쪼끄매서 노을이 자꾸 도망가거든.|저 주황 띠랑 같이 좀 달려 줘. 형이 밥 살게. 아마도.", "Hey kiddo, you made it. My planet's so tiny the sunset keeps running off.|Run alongside that orange band for me. I'll buy you dinner. Probably."],  # 형님 5m 안 (말풍선 둘) | 형님
	"p4.hint": ["얼음이라 미끄럽다. 빠르면 뜨고 느리면 놓쳐. 띠랑 같은 빠르기로, 살살.", "It's icy. Too fast and you float, too slow and you lose it. Match the band. Easy does it."],  # 부탁 바로 뒤, 띠 막대 15% 미만이면 40초마다 | 형님
	"p4.thanks": ["오, 잘했다. 이 유리 덮개, 분홍 장미 별에 좀 갖다줘.|곧장 가면 빨간 지뢰 울타리야. 거긴 형도 못 지나가.", "Nice work. Take this glass dome to the pink Rose Planet.|The straight route has a red mine fence. Even I can't get through that."],  # 띠 막대 100%, 손이 비었을 때 (맡겨 둔 덮개를 받을 때도, 말풍선 둘) | 형님
	"p4.keep": ["오, 잘했다. 근데 손이 꽉 찼네? 덮개는 형이 맡아 둘게. 손 비면 와.", "Nice work. Hands full, huh? I'll hang on to the dome. Come back when you're free."],  # 띠 막대 100%인데 손에 다른 물건 | 형님
	"p4.busy": ["야, 동생. 손에 {item} 있잖아. 그거부터 갖다주고 와, 난 안 급해.", "Hey kiddo, you've got the {item}. Drop that off first. I'm in no rush."],  # 맡긴 덮개가 있는데 다른 물건을 든 채 형님에게 갔을 때 | 형님
	"p4.thanks2": ["빨간 불 별 옆을 스치면 휘어서 돌아가. 닿으면 끝이다, 진짜로.", "Skim past the red Fire Star and you'll curve around. Touch it and it's over. For real."],  # thanks 바로 뒤, 또 덮개를 들고 장미 별 밖이면 45초마다 | 형님
	"got.dome": ["유리 덮개 → {target}", "Glass dome → {target}"],  # 덮개를 다시 주웠을 때 위쪽 띠 | -
	"p4.idle1": ["노을 보면서 달리면 마음이 몽글몽글해진다. 형 감성 좀 있지?", "Running under the sunset makes me all mushy inside. Got some soul, huh?"],  # 부탁을 끝낸 뒤 곁에 서면 60초에 한 번 | 형님
	"p4.idle2": ["혼자 뛸 땐 좀 외로웠는데, 둘이 뛰니 노을도 안 무섭네.", "Running alone got lonely. With two of us, the sunset's not so scary."],  # 위와 같음 | 형님

	# ---- 별 5 장미의 별 ----
	"rose.early": ["…추워. 형님이 유리 덮개를 갖고 있대. 노을의 별에 가 봐.|딱히 기다리는 건 아니야.", "...It's cold. I hear Big Bro has a glass dome. Try the Sunset Planet.|Not that I'm waiting or anything."],  # 노을 부탁 전에 장미에게 갔을 때 (말풍선 둘) | 장미
	"p5.ask": ["…왔어? 바람이 차가워. 유리 덮개 좀 씌워 줘.|담이 천천히 돌고, 틈은 딱 하나야.", "...You're here? The wind is cold. Put the dome over me.|The wall turns slowly, and there's just one gap."],  # 덮개가 생긴 뒤 장미 5m 안에 처음 갔을 때 (말풍선 둘) | 장미
	"p5.hint": ["담 틈으로 들어오거나 탑에서 뛰어 위에서 놓아 줘. 세게 내리면 깨져.", "Come in through the gap, or jump from the tower and drop it from above. Drop it hard and it breaks."],  # 덮개를 들고 장미 별에 있으면 45초마다 | 장미
	"msg.wall_gap": ["담 · 틈으로", "Wall · use the gap"],  # 장미 별 담에 부딪힘 | -
	"msg.tower_jump": ["탑에서 점프", "Tower leap"],  # 탑 꼭대기에서 뛰어내릴 때 | -
	"msg.rose_smiles": ["장미가 환하게 웃는다", "Rose smiles brightly"],  # 덮개 배달 (마지막 부탁이었을 때) | -
	"p5.thanks": ["…따뜻해. 고, 고마워. 네 빠른 발 덕분에 다섯 별이 다 웃고 있어.", "...It's warm. Th-thanks. Thanks to your fast feet, all five planets are smiling."],  # 덮개 배달, 마지막 부탁이었을 때 | 장미
	"p5.thanks_more": ["…따뜻해. 고, 고마워. 다른 별들도 네 발을 기다려. 가 봐, 얼른.", "...It's warm. Th-thanks. The others are waiting for your feet too. Go on, hurry."],  # 덮개 배달, 남은 부탁이 있을 때 | 장미
	"p5.idle1": ["…뭘 봐? 덮개가 마음에 들어서 가만있는 거야. 사진은 찍지 마.", "...What are you looking at? I'm only sitting still because I like the dome. No photos."],  # 부탁을 끝낸 뒤 곁에 서면 60초에 한 번 | 장미
	"p5.idle2": ["별빛이 덮개에 반짝이는 건… 조금 예쁘네. 형님 밥 약속보단 확실하고.", "Starlight on the dome is... a little pretty. More reliable than Big Bro's dinner promises."],  # 위와 같음 | 장미

	# ---- 우주 미아·죽음 ----
	"msg.drift_warn": ["떠내려가는 중 · 날다리로 방향 틀기", "Drifting away · turn with Glide"],  # 어느 별에도 안 끌리고 멀어질 때 (날다리 있음) | -
	"msg.drift_warn_ns": ["떠내려가는 중!", "Drifting away!"],  # 위와 같음, 날다리 받기 전 | -
	"react.drift_warning": ["어어, 멀어진다… 날다리로 돌리자!", "Uh-oh, drifting... turn with the Glidewing!"],  # 위 상황 첫 번 (날다리 있음) | 너?
	"react.drift_warning_ns": ["어어, 멀어진다… 초록 점선에서 뛰자", "Uh-oh, drifting... jump on green dots"],  # 위 상황 첫 번 (날다리 받기 전) | 너?
	"banner.lost": ["우주 미아 · 마지막 별로 돌아가는 중", "Lost in space · returning to the last planet"],  # 못 닿는 길로 2.6초 넘게 날면 끌려 돌아감 | -
	"die.fire": ["불 별에 닿음", "Touched the Fire Star"],  # 불 별에 닿음 | -
	"react.die_fire": ["앗 뜨거. 다음엔 스치기만 하자", "Ouch, hot. Just skim it next time"],  # 위 바로 뒤 | 너?
	"die.rocks": ["빨간 지뢰 울타리에 부딪힘", "Hit the red mine fence"],  # 빨간 지뢰 울타리에 닿음 | -
	"react.die_rocks": ["울타리는 무리. 불 별 쪽으로 돌아가자", "Can't go through. Curve around the Fire Star"],  # 위 바로 뒤 | 너?
	"die.drift": ["깊은 우주로 떠내려감", "Drifted into deep space"],  # 너무 멀리 떠내려감 | -
	"react.die_drift": ["다음엔 초록 점선 보고 뛰자", "Next time, jump on green dots"],  # 위 바로 뒤 | 너?
	"die.meteor": ["떨어지는 운석에 맞음", "Hit by a falling meteor"],  # 운석에 맞음 | -
	"react.die_meteor": ["빨간 그림자는 미리 피하자", "Get off red shadows early"],  # 위 바로 뒤 | 너?

	# ---- 도움 힌트 (v10, 아래 말풍선. 못 할 때만 나온다. 1 = 처음, 2 = 계속 못 할 때 더 자세히 + 그림·도와주기) ----
	"help.idle1": ["조이스틱을 밀어 달려 봐", "Push the joystick to run"],  # 거의 안 달려 본 채 8초 가만히 | -
	"help.idle2": ["왼쪽 아래 조이스틱을 손가락으로 밀어 봐", "Drag the joystick at the bottom left with your finger"],  # 또 그럴 때 (조이스틱 자리에 손가락 그림 깜빡) | -
	"help.lift1": ["조이스틱을 끝까지 밀어 더 빨리 달려", "Push the joystick all the way to run faster"],  # 달리는데 이륙선 60%를 못 넘은 채 20초 | -
	"help.lift2": ["끝까지 밀고 계속 달려. 위 막대가 끝까지 차오르게", "Keep it pushed and keep running. Fill the bar at the top"],  # 또 그럴 때 (위 막대 둘레 깜빡) | -
	"help.jump1": ["위 막대가 초록일 때 점프하면 별을 떠나", "Jump when the top bar is green to leave the planet"],  # 갈 곳이 다른 별인데 뛰어도 4번(또는 30초) 못 떠남 | -
	"help.jump2": ["지금은 막대가 금방 초록이 돼. 힘껏 달리다 점프!", "The bar turns green sooner for now. Sprint, then jump!"],  # 또 그럴 때 (25초 동안 떠나기 도와주기 더 너그럽게) | -
	"help.lost1": ["점선이 초록일 때 뛰면 다른 별에 닿아", "Jump when the dots are green to reach another planet"],  # 우주 미아(끌려 돌아옴·떠내려감) 2번 | -
	"help.lost2": ["잠깐 별들이 더 세게 끌어 줘. 초록 점선을 보고 뛰어!", "Planets pull harder for a while. Jump on green dots!"],  # 또 그럴 때 (25초 동안 끌어주기 세게) | -
	"help.goal1": ["어디로 갈지 모르겠으면 왼쪽 위 할 일 목록을 눌러 봐 · 노란 화살표를 따라가", "Lost? Tap the to-do list at the top left · follow the yellow arrow"],  # 갈 곳 별에 90초 못 감 (할 일 버튼 숨쉼·화살표 크게) | -
	"help.goal2": ["노란 빛기둥이 서 있는 별로 가면 돼", "Head for the planet with the yellow light pillar"],  # 또 그럴 때 (빛기둥 더 크고 밝게) | -
	"help.glass1": ["곧장 꽂지 말고 빙 돌다 살살 내려앉아", "Don't dive in. Circle around and land softly"],  # 유리 금·깨짐 2번 | -
	"help.glass2": ["잠깐 내려앉기가 더 부드러워져. 빙 돌며 천천히", "Landings are gentler for a while. Circle and go slow"],  # 또 그럴 때 (25초 동안 내려가는 빠르기 한도 낮춤) | -
	"help.band1": ["띠와 같은 빠르기로! 얼음이라 조이스틱은 살살", "Match the band's speed! It's icy, so ease the joystick"],  # 노을 띠를 3번 놓침 | -
	"help.band2": ["잠깐 띠가 느려졌어. 띠 위에 머물러 봐", "The band is slower for a while. Stay on it"],  # 또 그럴 때 (25초 동안 띠 느리게) | -
	"help.fire1": ["불 별 옆을 스치면 휘어서 장미의 별로 돌아가", "Skim past the Fire Star to curve around to Rose Planet"],  # 불 별·지뢰 울타리에 2번 죽음 | -
	"help.fire2": ["노을의 별에 초록 점선 길을 보여 줄게. 그 길 쪽으로 힘껏 달려 점프", "Green dots on Sunset Planet show a curving path. Sprint that way and jump"],  # 또 그럴 때 (40초 동안 새총 길 점선) | -
	"help.fire2b": ["잠깐 땅에서도 점선이 보여. 초록이 될 때 점프", "For a while you can see the dots on the ground. Jump when they turn green"],  # 위와 같은데 길을 못 찾았을 때 (땅 점선을 늘 보임) | -
	"help.sail1": ["빗나갈 것 같으면 날 때 '날다리' 버튼!", "About to miss? Tap 'Glide' in flight!"],  # 날다리를 받고도 안 쓰고 빗나간 비행 3번 | -
	"help.sail2": ["연한 점선이 초록이면 지금 '날다리'를 눌러", "When the faint dots turn green, tap 'Glide' now"],  # 또 그럴 때 (날다리 버튼 크게 깜빡) | -
	"help.drop1": ["굴뚝 위를 지날 때 '놓기'", "Tap 'Drop' as you pass over the chimney"],  # 소포를 들고 굴뚝 달 근처 40초 | -
	"help.drop2": ["발밑 노란 점이 굴뚝에 겹칠 때 '놓기'", "Tap 'Drop' when the yellow dot below you is on the chimney"],  # 또 그럴 때 (떨어질 자리 노란 점 크게) | -

	# ---- 엔딩·끝 화면 ----
	"msg.all_done": ["모든 부탁 완료!", "All requests done!"],  # 마지막 부탁이 장미가 아닐 때 알림 | -
	"ending.1": ["발끝으로 건넌 별마다 다정한 빛이 켜졌다.", "A gentle light came on at every planet I crossed."],  # 모든 부탁 뒤 혼잣말 1 | 너?
	"ending.2": ["작고 외롭던 별들이 하늘 한가운데서 서로 웃는다.", "The small, lonely planets smile at each other across the sky."],  # 혼잣말 2 | 너?
	"ending.3": ["차가운 유리 너머로 전해진 온기가 마음을 데운다.", "Warmth passed through cold glass warms my heart."],  # 혼잣말 3 | 너?
	"ending.4": ["언젠가 또 바람이 불면, 다시 달려 날아가야지.", "Someday, when the wind blows again, I'll run and fly once more."],  # 혼잣말 4 | 너?
	"end.win_head": ["모든 부탁 완료!", "All requests done!"],  # 끝 화면 제목 (이김) | -
	"end.win_msg": ["다섯 별이 모두 웃고 있어", "All five planets are smiling"],  # 끝 화면 글 (이김) | -
	"end.lose_head": ["목숨 0", "Out of lives"],  # 끝 화면 제목 (목숨 0) | -
	"end.lose_msg": ["다시 하면 첫 별부터", "Again starts from the first planet"],  # 끝 화면 글 (목숨 0) | -
	"end.delivered": ["배달", "Delivered"],  # 기록 줄 1 | -
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
