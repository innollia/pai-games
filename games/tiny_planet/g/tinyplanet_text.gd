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
	"ui.wind": ["바람", "Wind"],  # 풍차 부탁 진행 막대 이름표 (풍차 그림 옆) | -
	"ui.sunset": ["노을", "Sunset"],  # 노을 띠 부탁 진행 막대 이름표 (해 그림 옆) | -
	"who.me": ["너?", "You?"],  # 혼잣말·엔딩 말풍선의 이름 | 너?

	# ---- 별·주민 이름 ----
	"name.windmill": ["풍차의 별", "Windmill Planet"],  # 별 1 이름 (처음 끌려 들어갈 때·내려앉을 때 알림, 칩) | -
	"name.post": ["우편의 별", "Post Planet"],  # 별 2 이름 | -
	"name.glass": ["유리꽃의 별", "Glass Flower Planet"],  # 별 3 이름 | -
	"name.sunset": ["노을의 별", "Sunset Planet"],  # 별 4 이름 | -
	"name.rose": ["장미의 별", "Rose Planet"],  # 별 5 이름 | -
	"name.chimney_moon": ["굴뚝 달", "Chimney Moon"],  # 소포 받는 달 이름 | -
	"name.friend_moon": ["친구 달", "Friend Moon"],  # 유리꽃 받는 달 이름 | -
	"name.fire": ["불 별", "Fire Star"],  # 닿으면 튕겨 나는 불 별 이름 (v17) | -
	"who.windmill": ["풍차지기", "Windmill Keeper"],  # 별 1 주민 이름 (말풍선 위) | -
	"who.post": ["우체부", "Mail Carrier"],  # 별 2 주민 이름 | -
	"who.glass": ["정원사", "Gardener"],  # 별 3 주민 이름 | -
	"who.sunset": ["형님", "Big Bro"],  # 별 4 주민 이름 | -
	"who.rose": ["장미", "Rose"],  # 별 5 주민 이름 | -
	"who.chimney": ["굴뚝 집", "Chimney House"],  # 굴뚝 달 주민 이름 | -
	"who.friend": ["꽃 친구", "Flower Friend"],  # 친구 달 주민 이름 | -

	# ---- 맨 위 할 일 칩 ----
	"goal.talk": ["{who}에게 말 걸기", "Talk to {who}"],  # 칩: 주민을 아직 안 만났을 때 | -
	"goal.wind": ["풍차 깨우기 · 초록 칸 빠르기로 달리기", "Wake the windmill · run at green-zone speed"],  # 칩: 풍차 부탁 중 | -
	"goal.pick": ["{planet}에서 {item} 받기", "Get the {item} on {planet}"],  # 칩: 물건을 받으러 가야 할 때 | -
	"goal.deliver": ["{target}에 {item} 배달", "Deliver the {item} to {target}"],  # 칩: 물건을 들고(또는 떨어뜨려 두고) 있을 때 | -
	"goal.band": ["노을 띠 속도 맞추기", "Match the sunset band's speed"],  # 칩: 노을 띠 부탁 중 | -
	"item.pkg": ["소포", "parcel"],  # 칩·목록 안 {item} | -
	"item.flower": ["유리꽃", "glass flower"],  # 칩·목록 안 {item} | -
	"item.dome": ["유리 덮개", "glass dome"],  # 칩·목록 안 {item} | -

	# ---- 왼쪽 위 할 일 목록 (누르면 놀이가 멈춤) ----
	"todo.head": ["할 일", "To-do"],  # 할 일 목록 판 제목 (뒤에 "N/5") | -
	"todo.p1": ["풍차 깨우기 · 초록 칸 빠르기로 달리기", "Wake the windmill · run at green-zone speed"],  # 목록 1줄 (풍차지기) | -
	"todo.p2": ["소포 → 굴뚝 달 집 (담이 막힘 · 공중에서 놓기)", "Parcel → Chimney Moon house (wall closed · drop from the air)"],  # 목록 2줄 (우체부) | -
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
	"talk.busy": ["손에 든 {item}부터 먼저 전해 주고 와.", "Go deliver the {item} in your hands first."],  # 물건을 든 채 주민에게 갔는데 그 주민 줄(pN.busy)이 없을 때 (예비) | 그 주민

	# ---- 별 1 풍차의 별 ----
	"p1.ask": ["어서 오게나, 작은 길손이구먼.|바람이 딱 멈춰서 우리 풍차가 깊이 잠들었네.|이 별 둘레를 신나게 달려서 바람을 좀 일으켜 주게.", "Welcome, little traveler.|The wind died down, and my windmill fell fast asleep.|Run around my planet and stir up a breeze, would you?"],  # 풍차지기 5m 안에 처음 갔을 때 (말풍선 셋) | 풍차지기
	"p1.hint": ["언젠가 시원한 바람이 다시 별을 찾아올 걸세.", "A cool breeze will find this planet again someday."],  # 부탁 바로 뒤, 또 바람 막대 15% 미만이면 40초마다 | 풍차지기
	"p1.thanks": ["풍차가 다시 시원하게 돌아가는구먼, 고맙네!|보답으로 내 젊은 시절 쓰던 '구식 날다리'를 주겠네.", "The windmill's spinning nicely again. Much obliged!|As thanks, take the 'Old Glidewing' I used in my youth."],  # 바람 막대 100% (말풍선 셋) | 풍차지기
	"p1.thanks2": ["그 날다리가 낡아 보여도 뼈대는 아주 튼튼하다네.", "That glidewing may look old, but its frame is sturdy."],  # thanks 바로 뒤 | 풍차지기
	"banner.sail": ["구식 날다리 획득! 날 때 '날다리'를 한 번 누르면 조이스틱 쪽으로 방향을 튼다.", "Old Glidewing acquired! In flight, tap 'Glide' once to turn toward your joystick."],  # 바람 막대 100% (위쪽 띠 5초) | -
	"hint.sail": ["'날다리' 버튼이 생겼다.", "The 'Glide' button appeared."],  # 날다리 버튼이 처음 나올 때 한 번 | -
	"msg.sail": ["날다리로 방향 전환", "Glidewing turn"],  # 날다가 날다리를 쓸 때 알림 | -
	"p1.idle1": ["요즘 젊은이들은 앱 하나로 바람을 부른다더군.|그래도 바람은 발로 뛰어서 만들어야 제맛이지.", "I hear young folks summon wind with an app these days.|Still, wind tastes best when you make it with your own feet."],  # 부탁을 끝낸 뒤 곁에 서면 60초에 한 번 (둘 중 하나) | 풍차지기
	"p1.idle2": ["이웃 별 녀석들이 온종일 릴스만 들여다보고 있네.|하도 고개를 숙이고 있어서 궤도가 비뚤어질 지경이야.", "The neighbor planets do nothing but watch Reels all day.|They hang their heads so low their orbits are going crooked."],  # 위와 같음 | 풍차지기

	# ---- 날기·내려앉기 ----
	"react.first_liftoff": ["어… 나 지금 나는 거야?", "Wait... am I flying?"],  # 처음으로 중력을 벗어나는 점프 (한 번) | 너?
	"react.first_landing": ["착지 성공. 여긴 어디지?", "Landed. Where am I?"],  # 다른 별에 처음 내려앉음 (한 번) | 너?
	"react.new_planet": ["새 별이다. 반가워", "A new planet. Hello there"],  # 그 뒤 새 별에 처음 내려앉음 (v17: 목숨 없음) | 너?
	"react.slingshot": ["별 옆을 스치니 슝 빨라졌다!", "Skimmed a planet. Whoosh, faster!"],  # 다른 별 곁을 지나 휘어 내려앉음 | 너?
	"react.orbit_landing": ["빙글빙글 돌다 사뿐히 착지!", "Round and round, then a soft landing!"],  # 대기에서 오래 돌다 살살 앉음 | 너?
	"msg.next": ["다음: {planet}", "Next: {planet}"],  # 부탁 하나 끝난 뒤 알림 | -
	"hud.next_hint": ["다음: {planet} · 노란 화살표 쪽", "Next: {planet} · follow the yellow arrow"],  # 땅에 있고 갈 곳이 다른 별일 때 (50초에 한 번) | -
	"msg.use_sail": ["지금 날다리!", "Glide now!"],  # 이대로면 못 닿는데 날다리 한 번이면 닿을 때 | -
	"msg.use_air": ["한 번 더 점프!", "Jump once more!"],  # 같은 상황, 날다리가 없을 때 | -

	# ---- 별 2 우편의 별 · 굴뚝 달 ----
	"p2.ask": ["우편의 별에 잘 오셨어요, 배달부님!|마침 당일 특송 건이 하나 밀려 있거든요.|이 소포를 굴뚝 달의 굴뚝 집으로 보내 주세요.|거긴 담이 높아서 하늘로만 물건이 들어간대요.", "Welcome to the Post Planet, courier!|I happen to have a same-day express job backed up.|Please take this parcel to the house on Chimney Moon.|Its wall is high, so things only get in from the sky."],  # 우체부 5m 안 (손이 비었을 때, 말풍선 넷) | 우체부
	"p2.busy": ["배송은 한 번에 딱 한 건씩이 원칙이에요.|들고 계신 {item}부터 먼저 완료하고 오세요.", "Our rule is strictly one job at a time.|Please finish delivering the {item} you're holding first."],  # 다른 물건을 든 채 우체부에게 갔을 때 | 우체부
	"got.pkg": ["소포 → {target}", "Parcel → {target}"],  # 소포를 주웠을 때 위쪽 띠 3초 | -
	"p2.hint": ["그 소포는 속도가 생명인 당일 특송이에요.", "That parcel's same-day express. Speed is everything."],  # 소포를 들고 있으면 45초마다 | 우체부
	"msg.wall_high": ["높은 담 · 공중에서 놓기", "High wall · drop from the air"],  # 굴뚝 달 담에 부딪힘 | -
	"msg.missed_drop": ["빗나감 · 다시 줍기", "Missed · pick it up again"],  # 놓은 물건이 과녁 밖에 떨어짐 | -
	"moon.chimney.got": ["굴뚝으로 소포가 쏙 들어왔어!|온돌 바닥이 지글지글 끓는 기분이야.|이 맛에 내가 집 하는 거지.", "The parcel plopped right down my chimney!|My heated floor feels all sizzly.|This is why I'm a house."],  # 소포 배달 순간 | 굴뚝 집
	"p2.thanks": ["굴뚝 달에서 배송 완료 신호가 떴어요!|덕분에 오늘은 저도 기적의 칼퇴를 노려 볼게요.", "The delivery-complete signal just came in from Chimney Moon!|Thanks to you, I might pull off a miracle and clock out on time."],  # 위 말 바로 뒤 | 우체부
	"p2.idle1": ["노을의 별 형님이 밥 산다는 약속 말이에요.|송장만 찍힌 채 3년째 '배송 중'이더라고요.|도착 예정일은 아직도 미정이고요.", "About Big Bro's promise to buy dinner.|The label's printed, but it's been 'in transit' for three years.|Estimated arrival: still unknown."],  # 부탁을 끝낸 뒤 곁에 서면 60초에 한 번 | 우체부
	"p2.idle2": ["오늘 배송 물량이 진짜 어마어마하네요.|그래도 가방이 묵직하게 차 있으면 왠지 뿌듯해요.", "Today's delivery load is seriously insane.|Still, a heavy, packed bag feels kind of satisfying."],  # 위와 같음 | 우체부

	# ---- 별 3 유리꽃의 별 · 친구 달 ----
	"p3.ask": ["…안녕하세요, 작게 인사할게요.|지금 아기 꽃들이 곤히 낮잠을 자고 있거든요…|이 유리꽃을 친구 달에 좀 데려다주실래요?|세게 부딪히면 깨져 버릴까 봐 걱정돼요…", "...Hello. I'll say it quietly.|The baby flowers are taking a nap right now...|Could you take this glass flower to Friend Moon?|I'm so worried it'll shatter if it hits hard..."],  # 정원사 5m 안 (손이 비었을 때, 말풍선 넷) | 정원사
	"p3.busy": ["…이미 손에 {item} 들고 계시네요.|그 배달부터 조심히 끝내고 와 주세요…", "...You're already holding the {item}.|Please finish that delivery first, carefully..."],  # 다른 물건을 든 채 정원사에게 갔을 때 | 정원사
	"got.flower": ["유리꽃 → {target} (살살)", "Glass flower → {target} (gently)"],  # 유리꽃을 주웠을 때 위쪽 띠 | -
	"p3.hint": ["…유리꽃이 다치지 않게 살살 다뤄 주세요.", "...Please be gentle so the glass flower doesn't get hurt."],  # 유리꽃을 들고 있으면 45초마다 | 정원사
	"react.flower_cracked": ["으앗, 금이 갔다… 더 살살", "Yikes, it cracked... softer"],  # 유리 물건을 들고 세게 착지 | 너?
	"react.flower_broken": ["와장창… 다시 받으러 가자", "Crash... go get another"],  # 유리 물건이 깨짐 | 너?
	"msg.glass_broken": ["깨짐 · {src}에서 다시 받기", "Broken · get another on {src}"],  # 금 100% 또는 높이 놓기로 깨짐 | -
	"moon.friend.got": ["헐, 대박! 금 하나 없이 멀쩡하게 왔잖아!|이 자태, 당장 릴스에 박제해야지.", "No way! It got here without a single crack!|Posting this beauty to Reels right now."],  # 유리꽃 배달 순간 | 꽃 친구
	"p3.thanks": ["…유리꽃이 무사히 도착했다는 소식 들었어요.|깨질까 봐 내내 손이 파르르 떨렸답니다…", "...I heard the glass flower arrived safely.|My hands were trembling the whole time, afraid it would break..."],  # 위 말 바로 뒤 (말풍선 둘) | 정원사
	"p3.idle1": ["유리꽃에 귀를 기울이면 맑은 종소리가 나요…|그런데 가끔은 아주 빠른 랩을 하기도 해요.", "If you listen to a glass flower, it chimes like a bell...|Though sometimes it raps really fast."],  # 부탁을 끝낸 뒤 곁에 서면 60초에 한 번 | 정원사
	"p3.idle2": ["꽃들이 어젯밤 릴스 보느라 새벽까지 안 잤나 봐요…|꽃잎이 졸려서 다 축 처져 있지 뭐예요.", "The flowers must've stayed up watching Reels till dawn...|Their petals are all drooping from sleepiness."],  # 위와 같음 | 정원사

	# ---- 별 4 노을의 별 ----
	"p4.ask": ["어이 동생, 마침 심심했는데 잘 왔다.|별이 너무 좁아서 노을이 자꾸 도망치거든.|저기 주황색 노을 띠를 따라서 같이 좀 뛰어 줘라.|형이 밥 살게. 아마도.", "Hey kiddo, good timing. I was getting bored.|My planet's so tiny the sunset keeps running off.|Run along with that orange sunset band for me.|I'll buy you dinner. Probably."],  # 형님 5m 안 (말풍선 넷) | 형님
	"p4.hint": ["동생, 그러다 저 노을 다 놓치겠다.", "Kiddo, at this rate that sunset's getting away."],  # 부탁 바로 뒤, 띠 막대 15% 미만이면 40초마다 | 형님
	"p4.thanks": ["오, 발이 제법 빠른데, 동생?|이 유리 덮개를 장미의 별에 좀 가져다줘라.", "Oh, you're pretty quick, kiddo.|Take this glass dome to the Rose Planet for me."],  # 띠 막대 100%, 손이 비었을 때 (맡겨 둔 덮개를 받을 때도, 말풍선 셋) | 형님
	"p4.keep": ["동생, 아주 시원하게 잘 달렸어!|근데 손이 꽉 찼으니 덮개는 형이 들고 있을게.|손 비면 언제든 슬슬 다시 와라.", "Kiddo, that was a great run!|Your hands are full, so I'll hang on to the dome.|Swing by whenever your hands are free."],  # 띠 막대 100%인데 손에 다른 물건 | 형님
	"p4.busy": ["손에 든 {item}부터 배달하고 와.|어차피 형은 낮잠이나 잘 거라 하나도 안 급해.", "Deliver the {item} in your hands first.|I'm just gonna nap anyway, so I'm in no rush."],  # 맡긴 덮개가 있는데 다른 물건을 든 채 형님에게 갔을 때 | 형님
	"p4.thanks2": ["동생, 불 별 쪽은 진짜 뜨거우니까 얼씬도 마라.", "Kiddo, the Fire Star is seriously hot. Stay away."],  # thanks 바로 뒤, 또 덮개를 들고 장미 별 밖이면 45초마다 | 형님
	"got.dome": ["유리 덮개 → {target}", "Glass dome → {target}"],  # 덮개를 다시 주웠을 때 위쪽 띠 | -
	"p4.idle1": ["노을 받으며 달리면 마음이 몽글몽글해진단 말이지.|어때, 형한테도 낭만이 좀 있지 않냐?", "Running in the sunset glow makes me all mushy inside.|What do you think, your big bro's got some soul, huh?"],  # 부탁을 끝낸 뒤 곁에 서면 60초에 한 번 | 형님
	"p4.idle2": ["혼자 뛸 땐 쓸쓸했는데 둘이 뛰니 노을도 안 무섭네.|다음엔 진짜 밥 살게. 아마도.", "Running alone was lonely, but with two, the sunset's not scary.|Next time I'm buying dinner for real. Probably."],  # 위와 같음 | 형님

	# ---- 별 5 장미의 별 ----
	"rose.early": ["…안녕, 여기까지 웬일이야?|우주 바람이 불어서 좀 춥네.|형님이 유리 덮개를 갖고 있다던데.", "...Hi. What brings you all the way here?|The space wind is blowing, and it's a bit cold.|I heard Big Bro has a glass dome."],  # 노을 부탁 전에 장미에게 갔을 때 (말풍선 셋) | 장미
	"p5.ask": ["…진짜 그걸 들고 찾아왔어?|바람이 차가우니까 얼른 그 덮개 씌워 줘.", "...You actually came with it?|The wind is freezing, so hurry and put that dome over me."],  # 덮개가 생긴 뒤 장미 5m 안에 처음 갔을 때 (말풍선 셋) | 장미
	"p5.hint": ["…딱히 네가 올 때까지 기다리는 건 아니야.", "...It's not like I'm waiting for you or anything."],  # 덮개를 들고 장미 별에 있으면 45초마다 | 장미
	"msg.wall_gap": ["담 · 틈으로", "Wall · use the gap"],  # 장미 별 담에 부딪힘 | -
	"msg.tower_jump": ["탑에서 점프", "Tower leap"],  # 탑 꼭대기에서 뛰어내릴 때 | -
	"msg.rose_smiles": ["장미가 환하게 웃는다", "Rose smiles brightly"],  # 덮개 배달 (마지막 부탁이었을 때) | -
	"p5.thanks": ["…덮개를 쓰니까 정말 따뜻하네.|그… 여기까지 와 줘서, 고마워.", "...It's really warm under this dome.|Th-thanks for coming all this way."],  # 덮개 배달, 마지막 부탁이었을 때 | 장미
	"p5.thanks_more": ["…바람이 하나도 안 느껴져, 따뜻해.|그… 덮개 가져다줘서, 고마워.", "...I can't feel the wind at all. It's warm.|Th-thanks for bringing the dome."],  # 덮개 배달, 남은 부탁이 있을 때 | 장미
	"p5.idle1": ["…뭘 그렇게 빤히 쳐다봐?|덮개가 마음에 들어서 가만히 있는 것뿐이거든.|사진 같은 건 절대 찍지 마.", "...What are you staring at?|I'm only sitting still because I happen to like the dome.|Don't even think about taking photos."],  # 부탁을 끝낸 뒤 곁에 서면 60초에 한 번 | 장미
	"p5.idle2": ["덮개에 비치는 별빛이 조금 예쁘긴 하네.|형님 밥 약속보다는 백 배 믿을 만하고.", "The starlight on the dome is a little pretty.|A hundred times more reliable than Big Bro's dinner promise."],  # 위와 같음 | 장미

	# ---- 우주 미아·튕김 (v17: 죽음 없음) ----
	"msg.drift_warn": ["떠내려가는 중…", "Drifting away..."],  # 어느 별에도 안 끌리고 멀어질 때 (날다리 있음) | -
	"msg.drift_warn_ns": ["떠내려가는 중!", "Drifting away!"],  # 위와 같음, 날다리 받기 전 | -
	"react.drift_warning": ["어어, 멀어진다… 날다리로 돌리자!", "Uh-oh, drifting... turn with the Glidewing!"],  # 위 상황 첫 번 (날다리 있음) | 너?
	"react.drift_warning_ns": ["어어, 멀어진다… 초록 점선에서 뛰자", "Uh-oh, drifting... jump on green dots"],  # 위 상황 첫 번 (날다리 받기 전) | 너?
	"banner.lost": ["우주 미아 · 마지막 별로 돌아가는 중", "Lost in space · returning to the last planet"],  # 못 닿는 길로 2.6초 넘게 날면 끌려 돌아감 | -
	"die.fire": ["앗 뜨거! 통!", "Hot! Boing!"],  # v17 불 별에 닿아 튕겨 나감 | -
	"react.die_fire": ["앗 뜨거. 스치기만 하자", "Hot! Just skim it"],  # 위 바로 뒤 | 너?
	"die.rocks": ["울타리에 통!", "Boing off the fence!"],  # v17 빨간 울타리에 닿아 밀려남 | -
	"react.die_rocks": ["못 지나가네. 불 별로 돌아가자", "Can't pass. Curve around the Fire Star"],  # 위 바로 뒤 | 너?
	"die.drift": ["너무 멀리 왔다", "Too far out"],  # 너무 멀리 떠내려감 (v17: 끌려 돌아옴) | -
	"react.die_drift": ["우주 너무 넓다…|초록 점선 보고 뛰자", "Space is huge...|Jump on green dots"],  # 위 바로 뒤 | 너?
	"die.meteor": ["운석에 콩!", "Bonk! A meteor"],  # v17 운석에 맞아 밀려남 | -
	"react.die_meteor": ["빨간 그림자는 피하자", "Dodge red shadows"],  # 위 바로 뒤 | 너?

	# ---- 도움 힌트 (v10, 아래 말풍선. 못 할 때만 나온다. 1 = 처음, 2 = 계속 못 할 때 더 자세히 + 그림·도와주기) ----
	"help.idle1": ["조이스틱을 밀어 달려 봐", "Push the joystick to run"],  # 거의 안 달려 본 채 8초 가만히 | -
	"help.idle2": ["조이스틱은 왼쪽 아래에 있어.|손가락으로 밀어 봐.", "The joystick is at the bottom left.|Drag it with your finger."],  # 또 그럴 때 (조이스틱 자리에 손가락 그림 깜빡) | -
	"help.lift1": ["조이스틱을 끝까지 밀어 봐.|그럼 더 빨리 달려.", "Push the joystick all the way.|You'll run faster."],  # 달리는데 이륙선 60%를 못 넘은 채 20초 | -
	"help.lift2": ["끝까지 밀고 계속 달려.|점프 버튼 둘레 고리를 채워.", "Keep it pushed and keep running.|Fill the ring around Jump."],  # 또 그럴 때 (점프 버튼 고리 둘레 깜빡) | -
	"help.jump1": ["점프 버튼 둘레 고리를 봐.|초록일 때 뛰면 별을 떠나.", "Watch the ring around Jump.|Jump when it's green to leave the planet."],  # 갈 곳이 다른 별인데 뛰어도 4번(또는 30초) 못 떠남 | -
	"help.jump2": ["지금은 고리가 금방 초록이 돼.|힘껏 달리다 점프!", "The ring turns green sooner for now.|Sprint, then jump!"],  # 또 그럴 때 (25초 동안 떠나기 도와주기 더 너그럽게) | -
	"help.lost1": ["점선이 초록일 때 뛰어 봐.|그럼 다른 별에 닿아.", "Jump when the dots are green.|You'll reach another planet."],  # 우주 미아(끌려 돌아옴·떠내려감) 2번 | -
	"help.lost2": ["잠깐 별들이 더 세게 끌어 줘.|초록 점선을 보고 뛰어!", "Planets pull harder for a while.|Jump on green dots!"],  # 또 그럴 때 (25초 동안 끌어주기 세게) | -
	"help.goal1": ["어디로 갈지 모르겠어?|왼쪽 위 할 일 목록을 눌러 봐.|노란 화살표를 따라가.", "Lost?|Tap the to-do list at the top left.|Follow the yellow arrow."],  # 갈 곳 별에 90초 못 감 (할 일 버튼 숨쉼·화살표 크게) | -
	"help.goal2": ["노란 화살표가 떠 있는 별로 가 봐", "Head for the planet with the yellow arrow over it"],  # 또 그럴 때 (노란 화살표 더 크고 밝게) | -
	"help.glass1": ["곧장 꽂지 마.|빙 돌다 살살 내려앉아.", "Don't dive in.|Circle around and land softly."],  # 유리 금·깨짐 2번 | -
	"help.glass2": ["잠깐 내려앉기가 더 부드러워져.|빙 돌며 천천히.", "Landings are gentler for a while.|Circle and go slow."],  # 또 그럴 때 (25초 동안 내려가는 빠르기 한도 낮춤) | -
	"help.band1": ["띠와 같은 빠르기로!|얼음이라 조이스틱은 살살.", "Match the band's speed!|It's icy, so ease the joystick."],  # 노을 띠를 3번 놓침 | -
	"help.band2": ["잠깐 띠가 느려졌어.|띠 위에 머물러 봐.", "The band is slower for a while.|Stay on it."],  # 또 그럴 때 (25초 동안 띠 느리게) | -
	"help.fire1": ["불 별 옆을 스쳐 가.|휘어서 장미의 별로 돌아가.", "Skim past the Fire Star.|You'll curve around to Rose Planet."],  # 불 별·지뢰 울타리에 2번 튕김 (v17) | -
	"help.fire2": ["노을의 별에 초록 점선 길을 보여 줄게.|그 길 쪽으로 힘껏 달려.|그리고 점프!", "Green dots on Sunset Planet show a curving path.|Sprint that way.|Then jump!"],  # 또 그럴 때 (40초 동안 새총 길 점선) | -
	"help.fire2b": ["잠깐 땅에서도 점선이 보여.|초록이 될 때 점프.", "For a while, you can see the dots on the ground.|Jump when they turn green."],  # 위와 같은데 길을 못 찾았을 때 (땅 점선을 늘 보임) | -
	"help.sail1": ["빗나갈 것 같아?|날 때 '날다리' 버튼!", "About to miss?|Tap 'Glide' in flight!"],  # 날다리를 받고도 안 쓰고 빗나간 비행 3번 | -
	"help.sail2": ["연한 점선이 초록이면 지금 '날다리'를 눌러", "When the faint dots turn green, tap 'Glide' now"],  # 또 그럴 때 (날다리 버튼 크게 깜빡) | -
	"help.drop1": ["굴뚝 위를 지날 때 '놓기'", "Tap 'Drop' as you pass over the chimney"],  # 소포를 들고 굴뚝 달 근처 40초 | -
	"help.drop2": ["발밑 노란 점이 굴뚝에 겹칠 때 '놓기'", "Tap 'Drop' when the yellow dot below you is on the chimney"],  # 또 그럴 때 (떨어질 자리 노란 점 크게) | -

	# ---- 엔딩·끝 화면 ----
	"msg.all_done": ["모든 부탁 완료!", "All requests done!"],  # 마지막 부탁이 장미가 아닐 때 알림 | -
	"ending.1": ["발끝으로 총총 건넌 별마다 다정한 빛이 켜졌다.", "A gentle light came on at every planet I tiptoed across."],  # 모든 부탁 뒤 혼잣말 1 | 나레이션 (이름 없음)
	"ending.2": ["작고 외롭던 별들이 하늘 한가운데서 서로 웃는다.", "The small, lonely planets smile at each other across the sky."],  # 혼잣말 2 | 나레이션 (이름 없음)
	"ending.3": ["차가운 유리 너머로 전해진 온기가 마음을 데운다.", "Warmth passed through cold glass warms my heart."],  # 혼잣말 3 | 나레이션 (이름 없음)
	"ending.4": ["언젠가 또 바람이 불면, 다시 달려 날아가야지.", "Someday, when the wind blows again, I'll run and fly once more."],  # 혼잣말 4 | 나레이션 (이름 없음)
	"end.win_head": ["모든 부탁 완료!", "All requests done!"],  # 끝 화면 제목 (이김) | -
	"end.win_msg": ["다섯 별이 모두 웃고 있어", "All five planets are smiling"],  # 끝 화면 글 (이김) | -
	"end.lose_head": ["오늘은 여기까지", "That's all for today"],  # 끝 화면 제목 (v17: 안 쓰임, 목숨 없음) | -
	"end.lose_msg": ["다시 하면 첫 별부터", "Again starts from the first planet"],  # 끝 화면 글 (v17: 안 쓰임) | -
	"end.delivered": ["배달", "Delivered"],  # 기록 줄 1 | -
	"end.time": ["걸린 시간", "Time"],  # 기록 줄 2 (이김) | -
	"end.survived": ["걸린 시간", "Time"],  # 기록 줄 2 (v17: 안 쓰임) | -
	"end.slings": ["새총", "Slingshots"],  # 기록 줄 3 (불 별·다른 별 곁을 휘어 돈 수) | -
	"end.best_time": ["최고 기록", "Best time"],  # 기록 줄 4 (이김) | -
	"end.best_count": ["최고 배달", "Most delivered"],  # 기록 줄 4 (v17: 안 쓰임) | -
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
