extends Tofu
## 일격의 길 (단독판): [막기]·[베기] 버튼을 누른 채 왼·오·위·아래로 밀면 그쪽으로 바로 막고 벤다.
## 버튼을 그냥 탭하면 마지막으로 잡은 방향으로. 화면 빈 곳을 밀어 방향만 미리 잡아 둘 수도 있다. 1인칭 내 칼은 없다.
## 적 칼은 그쪽으로 들어 올려지고 흐린 잔상이 지나갈 길을 보여 준다(색 없이 칼 모양만 봐도 안다). 초록 상자 = 빈틈.
## 끝까지 기다렸다 막으면 '간파'(세상이 느려짐).
## 켜면 튜토리얼부터: 맞는 쪽으로 밀 때까지 멈추고 알려 준다. 그다음 찌르기 → 속임수 → 베기 → 거합 검객이 두 바퀴 나오고
## (뒤로 갈수록 체력·공격력·빠르기가 오른다), 마지막은 쓰러뜨릴 수 없는 끝판왕 검귀. 간파하면 그 자리에서 내가 직접 벤다.
## 빈틈이 아닐 때 휘두르면 헛공격: 체력 -1, 잠깐 굳고, 상대가 바로 친다.
## 매 판 맨몸으로 시작. 검객을 쓰러뜨리면 능력 셋 중 하나를 고른다(이번 판에만, 체력 자동 회복 없음). 쓰러지면 로비(전투 · 캐릭터 · 도감)에서 [전투]로 처음부터.
## 기록·도감·설정은 저장된다. 튜토리얼은 처음 한 번만(로비에서 다시 볼 수 있다).

const SWIPE := 60.0
const BTN_SWIPE := 38.0  # 버튼 위에서 이만큼 밀면 그 방향으로 바로 발동
const BTN_WAIT := 0.14  # 버튼을 밀지 않고 이만큼 누르고 있으면 잡아 둔 방향으로 발동
const OFF := [Vector3(-1.5, 0, 0.7), Vector3(1.5, 0, 0.7), Vector3(0, 1.75, 0.7), Vector3(0, -1.75, 0.7)]
const LEAN := [Vector3(-1, 0, 0), Vector3(1, 0, 0), Vector3(0, 1, 0), Vector3(0, -1, 0)]
const OPP := [1, 0, 3, 2]
## 적 칼 (검객 기준): 들어 올린 자리 → 내게 닿는 자리, z 회전. 좌우는 세운 칼, 위아래는 눕힌 칼.
const WIND := [Vector3(-1.9, 0.5, 0.3), Vector3(1.9, 0.5, 0.3), Vector3(0, 2.4, 0.3), Vector3(0, -1.6, 0.4)]
const HIT := [Vector3(-0.6, 0.0, 0.9), Vector3(0.6, 0.0, 0.9), Vector3(0, 0.4, 0.9), Vector3(0, -0.7, 0.9)]
const ROT := [0.2, -0.2, PI / 2, PI / 2]
const ARROW := ["←", "→", "↑", "↓"]
## 공격 모양(검객 성향): 0 찌르기 = 칼끝을 겨누고 곧게 찌른다, 1 속임수 = 칼끝을 흔들며 휘두른다,
## 2 베기 = 크게 젖혔다 둥글게 내려 벤다, 3 거합 = 칼집에서 뽑아 한 번에 긋는다
## 찌르기: 당긴 자리 → 찌른 자리 (칼끝이 내 쪽을 향하고 조금 바깥으로 비스듬해서 방향이 보인다)
const T_WIND := [Vector3(-0.75, 0.1, -0.4), Vector3(0.75, 0.1, -0.4), Vector3(0, 0.75, -0.4), Vector3(0, -0.55, -0.4)]
const T_HIT := [Vector3(-1.35, 0.0, 1.5), Vector3(1.35, 0.0, 1.5), Vector3(0, 1.25, 1.5), Vector3(0, -1.15, 1.5)]
const SWING := [1.0, -1.0, 1.0, -1.0]  # 베기: 젖힌 칼이 도는 쪽
const CAM_O := Vector3(0, 0.3, 5)
const NAMES := ["찌르기 검객", "속임수 검객", "베기 검객", "거합 검객", "끝판왕 검귀"]
const TIPS := [
	"칼이 오는 쪽으로 밀고 막기",
	"반쯤에 칼이 다른 쪽으로 옮겨 가요\n끝까지 보고 막기",
	"같은 쪽으로 두 번 와요!\n흐린 칼이 두 자루면 한 번 더 막기",
	"가만히 있다가 갑자기 뽑아요!\n눈이 번쩍하면 칼 쪽을 보고 막기. 먼저 베면 헛공격",
	"쓰러뜨릴 수 없어요. 오래 버티며 피해를 쌓아요",
]
const BODY := [A, C, B, ME, INK]
## 파이가 보낸 효과음 (10/30). 막기 소리는 공격 모양(sty: 찌르기·속임수·베기·거합)마다 다르다
const SND := {
	"hit": preload("res://sfx/hit.mp3"),
	"miss": preload("res://sfx/miss.mp3"),
	"whiff": preload("res://sfx/whiff.mp3"),
	"parry": preload("res://sfx/parry.mp3"),
	"death": preload("res://sfx/death.mp3"),
	"iai1": preload("res://sfx/iai_draw1.mp3"),  # 거합: 눈이 번쩍할 때 (10/31)
	"iai2": preload("res://sfx/iai_draw2.mp3"),  # 거합: 칼이 칼집에서 빠져나올 때 (10/31)
}
const BLOCK_SND := [preload("res://sfx/block_thrust.mp3"), preload("res://sfx/block_trick.mp3"), preload("res://sfx/block_slash.mp3"), preload("res://sfx/block_iai.mp3")]
const BOSS_AT := 8  # 이 번째(0부터)부터 끝판왕
const BOSS_HP := 9999
const SLOW := 0.3
const FILE := "user://blade_path.json"
## 검객 종류 > 단 > [쉼, 빈틈, 연속기 목록]. 연속기 = [보이는 쪽, 진짜 쪽, 예비 시간]의 줄. 보이는 쪽≠진짜 쪽이면 반쯤에 바뀌는 속임수.
const PAT := [
	[
		[0.7, 0.7, [[[0, 0, 0.8]], [[1, 1, 0.8]], [[2, 2, 0.8]], [[3, 3, 0.8]]]],
		[0.6, 0.6, [[[0, 0, 0.6], [1, 1, 0.6]], [[2, 2, 0.6], [3, 3, 0.6]]]],
		[0.5, 0.55, [[[0, 0, 0.45], [2, 2, 0.45], [1, 1, 0.45]], [[3, 3, 0.45], [1, 1, 0.45], [0, 0, 0.45]]]],
	],
	[
		[0.8, 0.4, [[[2, 2, 1.2], [0, 0, 0.35]], [[3, 3, 1.2], [1, 1, 0.35]]]],
		[0.7, 0.35, [[[0, 1, 1.0]], [[2, 3, 1.0]], [[1, 1, 0.5]]]],
		[0.6, 0.3, [[[3, 2, 1.0], [0, 0, 0.3]], [[1, 1, 1.2], [2, 3, 0.7]]]],
	],
	# 베기: 넷째 칸 1 = 앞 칼과 같은 쪽으로 바로 이어지는 두 번째 칼 (상자 두 겹으로 미리 보인다)
	[
		[0.8, 0.6, [[[0, 0, 0.8], [0, 0, 0.35, 1]], [[1, 1, 0.8], [1, 1, 0.35, 1]], [[2, 2, 0.8], [2, 2, 0.35, 1]]]],
		[0.7, 0.5, [[[3, 3, 0.7], [3, 3, 0.3, 1]], [[0, 0, 0.6], [0, 0, 0.3, 1], [1, 1, 0.6]], [[2, 2, 0.6], [2, 2, 0.3, 1], [3, 3, 0.5], [3, 3, 0.3, 1]]]],
		[0.6, 0.45, [[[1, 1, 0.55], [1, 1, 0.28, 1], [0, 0, 0.55], [0, 0, 0.28, 1]], [[2, 2, 0.5], [2, 2, 0.26, 1], [2, 2, 0.26, 1]]]],
	],
	# 거합: 넷째 칸 2 = 가만히 서 있다가(길이 무작위) 눈이 번쩍하고 순식간에 뽑는다
	# 10/31: 칼집에 있으면 무슨 수든 발도로 시작하고, 뽑은 뒤엔 베기로 몰아친다. 내가 맞거나 내가 베면 다시 칼집에 넣는다 (drawn)
	[
		[0.5, 0.7, [[[0, 0, 0, 2], [1, 1, 0.75]], [[2, 2, 0.75]], [[3, 3, 0, 2], [0, 0, 0.7]], [[1, 1, 0.7]]]],
		[0.4, 0.6, [[[0, 0, 0, 2], [1, 1, 0.6], [2, 2, 0.6]], [[3, 3, 0.6]], [[1, 1, 0, 2], [0, 0, 0.55]], [[2, 2, 0.55], [3, 3, 0.55]]]],
		[0.3, 0.5, [[[2, 2, 0, 2], [3, 3, 0.5]], [[0, 0, 0.5], [1, 1, 0.45]], [[0, 0, 0, 2], [0, 0, 0.3, 1]], [[3, 3, 0.45], [2, 2, 0.45]]]],
	],
	# 끝판왕: 넷을 섞는다. 단은 체력이 아니라 벤 횟수로 오른다
	[
		[0.6, 0.45, [[[0, 0, 0.6], [1, 1, 0.5]], [[2, 3, 0.9]], [[3, 3, 0.6], [3, 3, 0.3, 1]], [[1, 1, 0, 2]]]],
		[0.5, 0.4, [[[0, 1, 0.8], [2, 2, 0.4], [2, 2, 0.26, 1]], [[3, 3, 0, 2], [1, 1, 0.35]], [[2, 2, 1.1], [0, 0, 0.3]]]],
		[0.4, 0.35, [[[1, 0, 0.8], [3, 3, 0.3], [3, 3, 0.24, 1]], [[0, 0, 0, 2], [0, 0, 0.26, 1], [2, 3, 0.7]], [[2, 2, 0.4], [1, 1, 0.4], [3, 3, 0, 2]]]],
	],
]
## 튜토리얼 공격: 왼쪽(막기 연습), 위(간파 연습)
const TUT_MV := [[0, 0, 1.2], [2, 2, 1.4]]
const TUT_SAY := [
	"칼이 왼쪽에서 와요 (흐린 칼 = 지나갈 길)\n[막기]를 누른 채 왼쪽으로 밀어요!",
	"막았어요!\n초록 상자 = 빈틈. [베기]를 누른 채 오른쪽으로!",
	"끝까지 기다렸다 막으면 '간파'!\n[막기]를 누른 채 위로!",
	"간파: 세상이 느려지고 빈틈이 길어요.\n[베기]를 누른 채 아래로!",
]
const ACT := ["막기", "베기"]
## 검객을 쓰러뜨리면 고르는 능력 (이번 판에만): 키, 이름, 설명, 최대 단계. 상점·돈은 없앴다(10/31).
const PERKS := [
	["hp", "단단한 몸", "최대 체력 +4 (지금 체력도 +4)", 99],
	["pow", "날 선 칼", "베기 힘 +1", 99],
	["per", "맑은 눈", "간파 판정이 0.04초 넓어져요", 4],
	["mend", "상처 동여매기", "체력을 절반만큼 되찾아요", 99],
	["leech", "숨 고르기", "간파할 때마다 체력 +1", 3],
	["steady", "흔들림 없는 손", "헛공격해도 체력이 안 깎여요", 1],
	["gap", "긴 빈틈", "빈틈(초록)이 30% 더 오래 열려요", 3],
]
## 로비 [강화] 탭의 스킬 트리 (10/31, 로그라이트): 판이 끝나면 쓰러뜨린 만큼 냥을 받고, 냥으로 영구 강화를 찍는다.
## 키, 이름, 설명, 최대 단계, 첫 값, 줄(0 몸 · 1 칼 · 2 눈), 칸(위에서 0~2), 먼저 찍어야 하는 칸.
## 값 = 첫 값 × UP_GROW^지금 단계 (찍을수록 크게 비싸진다)
const TREE := [
	["t_hp", "튼튼한 몸", "시작 체력 +1", 5, 8, 0, 0, ""],
	["t_mend", "숨 돌리기", "검객을 쓰러뜨릴 때마다 체력 +1", 3, 20, 0, 1, "t_hp"],
	["t_last", "마지막 버팀", "판마다 한 번, 죽을 피해를 체력 1로 버텨요", 1, 70, 0, 2, "t_mend"],
	["t_pow", "단련된 칼", "베기 힘 +1", 3, 15, 1, 0, ""],
	["t_gap", "빈틈 읽기", "빈틈(초록)이 10% 더 오래 열려요", 3, 20, 1, 1, "t_pow"],
	["t_x3", "간파 일격 강화", "간파 일격 x2 → x3", 1, 80, 1, 2, "t_gap"],
	["t_per", "밝은 눈", "간파 판정이 0.01초 넓어져요", 5, 10, 2, 0, ""],
	["t_stun", "빠른 손", "헛공격 뒤 굳는 시간 -0.1초", 2, 20, 2, 1, "t_per"],
	["t_coin", "현상금 사냥", "판이 끝날 때 받는 냥 +25%", 2, 60, 2, 2, "t_stun"],
]
const UP_GROW := 2.5
const TREE_COL := ["몸", "칼", "눈"]
## 간파 판정 (10/31): 칼이 닿은 뒤에도 이만큼은 막으면 간파 (판정이 너무 빨랐다). 맞는 건 이만큼 늦게.
const PARRY_LATE := 0.08
## 죽기 직전(다음에 맞으면 죽을 때) 몰래 넓혀 주는 간파 판정. 칼 색(빨강)에는 안 보인다
const LAST_HELP := 0.5

## 개발 도구(g/dev.gd)에서 고친 글·UI 자리. [내보내기]한 내용을 여기 붙여 넣으면 출시판에도 그대로 남는다.
const BAKED_TEXT := {}
const BAKED_UI := {}
const BAKED_TEXT_EN := {}  # 영어판에서 고친 글

## 영어판(기본) 번역: 한국어 원문 -> 영어. 새 글을 넣으면 여기에도 넣는다(없으면 영어판에 한국어가 뜬다).
## 언어는 로비 [설정]의 언어 버튼으로 바꾼다(저장 lang). 서식 글은 tr("...%d...") % 값.
const EN := {
	"일격의 길": "Blade Path",
	"< 처음부터": "< Restart",
	"찌르기 검객": "Thrust Swordsman", "속임수 검객": "Feint Swordsman", "베기 검객": "Twin-Cut Swordsman",
	"거합 검객": "Iai Swordsman", "끝판왕 검귀": "Sword Demon (Final Boss)",
	"칼이 오는 쪽으로 밀고 막기": "Swipe toward the incoming blade and Block",
	"반쯤에 칼이 다른 쪽으로 옮겨 가요\n끝까지 보고 막기": "Halfway, the blade switches sides\nWatch it to the end, then Block",
	"같은 쪽으로 두 번 와요!\n흐린 칼이 두 자루면 한 번 더 막기": "Strikes the same side twice!\nTwo ghost blades = Block once more",
	"가만히 있다가 갑자기 뽑아요!\n눈이 번쩍하면 칼 쪽을 보고 막기. 먼저 베면 헛공격": "Stands still, then draws in a flash!\nWhen the eyes flash, Block toward the blade. Striking first is a whiff",
	"쓰러뜨릴 수 없어요. 오래 버티며 피해를 쌓아요": "Cannot be beaten. Survive and pile up damage",
	"칼이 왼쪽에서 와요 (흐린 칼 = 지나갈 길)\n[막기]를 누른 채 왼쪽으로 밀어요!": "A blade comes from the left (ghost blade = its path)\nHold [BLOCK] and swipe left!",
	"막았어요!\n초록 상자 = 빈틈. [베기]를 누른 채 오른쪽으로!": "Blocked!\nGreen box = opening. Hold [STRIKE] and swipe right!",
	"끝까지 기다렸다 막으면 '간파'!\n[막기]를 누른 채 위로!": "Wait until the last moment to Block = PARRY!\nHold [BLOCK] and swipe up!",
	"간파: 세상이 느려지고 빈틈이 길어요.\n[베기]를 누른 채 아래로!": "Parry: time slows and the opening lasts longer.\nHold [STRIKE] and swipe down!",
	"막기": "BLOCK", "베기": "STRIKE",
	"단단한 몸": "Iron Body", "최대 체력 +4 (지금 체력도 +4)": "Max HP +4 (current HP +4 too)",
	"날 선 칼": "Keen Edge", "베기 힘 +1": "Strike power +1",
	"맑은 눈": "Clear Eyes", "간파 판정이 0.04초 넓어져요": "Parry window +0.04s",
	"상처 동여매기": "Bind Wounds", "체력을 절반만큼 되찾아요": "Recover half your HP",
	"숨 고르기": "Steady Breath", "간파할 때마다 체력 +1": "+1 HP on every parry",
	"흔들림 없는 손": "Unshaken Hand", "헛공격해도 체력이 안 깎여요": "Whiffs no longer cost HP",
	"긴 빈틈": "Long Opening", "빈틈(초록)이 30% 더 오래 열려요": "Openings (green) last 30% longer",
	"전투": "FIGHT", "캐릭터": "Character", "강화": "Upgrade", "도감": "Codex",
	"찌르기": "Thrust", "속임수": "Feint", "거합": "Iai", "검귀": "Demon",
	"검객이 공격하려고 해요. 잘 봐요!": "The swordsman is about to attack. Watch closely!",
	"이번엔 칼이 거의 닿을 때까지\n기다려요…": "This time, wait until the blade\nalmost reaches you…",
	"좋아요!": "Nice!",
	"준비 끝!\n검객을 쓰러뜨리면 능력을 하나 골라요.\n체력은 저절로 차지 않아요. 갈수록 적이 세져요.\n\n탭해서 싸우러 가기": "Ready!\nDefeat a swordsman to pick one skill.\nHP does not refill on its own. Foes get stronger.\n\nTap to fight",
	"건너뛰기 >": "Skip >", "튜토리얼 다시 보기": "Replay tutorial",
	"간파!": "PARRY!", "간파!\n지금 초록 쪽으로 베요!": "PARRY!\nStrike the green side now!",
	"좋아요!\n두 번째도 맞춰야 간파!": "Nice!\nParry the second one too!",
	"베기!": "STRIKE!", "간파 일격! x2": "PARRY STRIKE! x2", "연격!": "CHAIN!",
	"헛공격!  체력 -1\n빈틈을 보였어요": "WHIFF!  HP -1\nYou left an opening",
	"헛공격!\n빈틈을 보였어요": "WHIFF!\nYou left an opening",
	"헛막기": "EMPTY BLOCK", "간파 놓침": "PARRY LOST",
	"막았지만 빈틈이 없어요\n두 칼 다 간파해야 해요": "Blocked, but no opening\nParry both blades to open one",
	"승리!": "VICTORY!", "쓰러짐": "DEFEATED",
	"설정": "Settings", "소리 크기": "Sound", "진동 세기": "Vibration", "닫기": "Close", "끔": "Off",
	"진동은 안드로이드 폰에서만 울려요\n0이면 꺼져요": "Vibration works on Android phones only\n0 = off",
	"최고 %d명 쓰러뜨림": "Best: %d defeated",
	"매 판 맨몸으로 시작해요\n검객을 쓰러뜨릴 때마다 능력을 하나 골라요": "Every run starts bare-handed\nPick one skill each time you defeat a swordsman",
	"\n끝판왕 최고 피해 %d": "\nBest damage to the boss: %d",
	"나 · 떠돌이 검객\n\n체력 6 · 베기 힘 1 · 간파 0.15초\n(판마다 맨몸으로 시작,\n검객을 쓰러뜨리면 능력을 골라요)\n\n— 기록 —\n최고 %d명 쓰러뜨림 · 끝판왕 최고 피해 %d\n싸운 판 %d · 막기 %d · 간파 %d": "Me · Wandering Swordsman\n\nHP 6 · Strike power 1 · Parry 0.15s\n(Every run starts bare-handed,\npick a skill after each win)\n\n— Records —\nBest %d defeated · Best boss damage %d\nRuns %d · Blocks %d · Parries %d",
	"???\n아직 못 만났어요\n싸우다 보면 열려요": "???\nNot met yet\nKeep fighting to unlock",
	"만남 %d번 · 쓰러뜨림 %d번": "Met %d · Defeated %d",
	"만남 %d번 · 준 피해 최고 %d": "Met %d · Best damage %d",
	"%d번째 상대\n체력 %s · 공격 %d": "Foe %d\nHP %s · Attack %d",
	"지난 판: %d번째 상대에게 %d 피해\n%s": "Last run: foe %d, %d damage\n%s",
	"지난 판: %d번째 상대에게 쓰러짐\n%s": "Last run: fell to foe %d\n%s",
	"버튼을 누른 채 칼이 오는 쪽으로 밀기": "Hold a button and swipe toward the blade",
	"버튼을 밀어 방향 · 지금 %s": "Swipe a button to aim · now %s",
	"튜토리얼": "Tutorial",
	"나 %d/%d   ·   %d번째 · 준 피해 %d · 공격 %d": "Me %d/%d   ·   Foe %d · Damage %d · Attack %d",
	"나 %d/%d   ·   %d번째 %d/%d · 공격 %d": "Me %d/%d   ·   Foe %d %d/%d · Attack %d",
	"맞음 -%d": "HIT -%d",
	"버튼을 누른 채 %s 쪽으로 밀어요!": "Hold the button and swipe %s!",
	"[%s]를 눌러요!": "Press [%s]!",
	"%d단": "Rank %d",
	"승리!  능력을 하나 골라요\n체력 %d/%d": "VICTORY!  Pick one skill\nHP %d/%d",
	"고른 능력 없음": "No skills picked", "능력: ": "Skills: ",
	"검객별 기록": "Records by swordsman", "%s\n쓰러뜨림 %d번 · 죽음 %d번": "%s\nDefeated %d · Died %d",
	"%s\n최고 피해 %d · 죽음 %d번": "%s\nBest damage %d · Died %d", "???\n아직 못 만났어요": "???\nNot met yet",
	"%d냥": "%d coins", "승리!  +%d냥": "VICTORY!  +%d coins", "받은 냥 +%d": "Coins earned +%d", "간파 일격! x3": "PARRY STRIKE! x3",
	"마지막 버팀!\n체력 1": "LAST STAND!\nHP 1", "강화 · 가진 냥 %d": "Upgrade · %d coins", "최대": "MAX", "윗칸 먼저": "Unlock above first",
	"강화하기 (%d냥)": "Upgrade (%d coins)", "냥이 모자라요 (%d냥)": "Not enough (%d coins)",
	"몸": "Body", "칼": "Blade", "눈": "Eyes",
	"튼튼한 몸": "Sturdy Body", "시작 체력 +1": "Starting HP +1",
	"숨 돌리기": "Catch Breath", "검객을 쓰러뜨릴 때마다 체력 +1": "+1 HP each time you defeat a swordsman",
	"마지막 버팀": "Last Stand", "판마다 한 번, 죽을 피해를 체력 1로 버텨요": "Once per run, survive a killing blow with 1 HP",
	"단련된 칼": "Honed Blade", "빈틈 읽기": "Read the Gap", "빈틈(초록)이 10% 더 오래 열려요": "Openings (green) last 10% longer",
	"간파 일격 강화": "Heavier Parry Strike", "간파 일격 x2 → x3": "Parry strike x2 → x3",
	"밝은 눈": "Sharp Eyes", "간파 판정이 0.01초 넓어져요": "Parry window +0.01s",
	"빠른 손": "Quick Hands", "헛공격 뒤 굳는 시간 -0.1초": "Freeze after a whiff -0.1s",
	"현상금 사냥": "Bounty Hunter", "판이 끝날 때 받는 냥 +25%": "+25% coins at the end of a run",
}

## 아래 탭 줄 (칸 번호 = tab)
const TABS := ["전투", "강화", "도감"]
const DEX := ["찌르기", "속임수", "베기", "거합", "검귀"]
const NAV_Y := 1150.0

# 저장되는 것
var tut_done := false
var seen := [0, 0, 0, 0, 0]  # 도감: 종류별 만난 수
var kills := [0, 0, 0, 0, 0]
var deaths := [0, 0, 0, 0, 0]  # 종류별 이 검객에게 쓰러진 수 (10/31)
var runs := 0
var blocks := 0
var perfects := 0
var best_n := 0
var best_dmg := 0  # 끝판왕에게 준 가장 큰 피해
var vol := 8  # 설정: 소리 0~10
var vib := 8  # 설정: 진동 0~10
var lang := "en"  # 설정: 언어 (en 기본, ko)
var coin := 0  # 강화에 쓰는 냥
var tree := {}  # 찍은 강화 -> 단계
var lang_l: Label  # 설정 창 언어 버튼 글
var lang_btn: ColorRect  # 위 띠 언어 버튼
var lang_top_l: Label
var say_en := {}  # 영어판에서 고친 글 (키 -> 글). 없으면 say 를 번역
static var _tr: Translation  # 영어 번역표 (한 번만 만든다)
# 한 판
var tut := 0  # 0~3 튜토리얼 단계, 4 끝 카드, -1 실전
var hold := false  # 튜토리얼: 맞는 손짓을 할 때까지 멈춤
var n := 0  # 몇 번째 검객 (0부터)
var ftype := 0
var foe_max := 6
var foe_hp := 6
var foe_atk := 2
var spd := 1.0
var life := 6
var max_life := 6
var perk := {}  # 이번 판에 고른 능력 -> 단계
var pick: Array = []  # 고르는 중인 능력 셋 (PERKS 번호)
var boss_dmg := 0
var run_coin := 0  # 이번 판에 모은 냥 (판이 끝나면 받는다)
var last_used := false  # 강화 "마지막 버팀"을 이번 판에 썼나
var cuts := 0  # 끝판왕: 벤 횟수 (단 오르기)
# 장면
var piv: Node3D
var body: MeshInstance3D
var rig: Node3D = null  # 찌르기 검객 모델 (없으면 상자 몸)
var anim: AnimationPlayer = null
var rig_m: Array[MeshInstance3D] = []
var blade_m: MeshInstance3D
var eyes: Array[MeshInstance3D] = []
var hp_fill: MeshInstance3D
var hp_back: MeshInstance3D
var floor_m: MeshInstance3D
var _floor_mats := {}
const BG_PIC := preload("res://art/field_bg.jpg")
var mark: Node3D
var ind: Array[Node3D] = []  # 빈틈 표시: 검은 테두리 + 초록 면
var ghosts: Array[MeshInstance3D] = []  # 적 칼이 지나갈 길 (흐린 잔상 셋 + 두 번째 칼)
var blade_rest := Vector3(0.95, -0.3, 0.6)
var blade_rr := Vector3(0, 0, 0.5)
var hand_p := Vector3(0.95, -0.62, 0.42)  # 칼 쥔 손 자리 (models.gd HAND)
var sheath_p := Vector3.ZERO  # 칼집에 든 칼 자리 (거합·끝판왕의 발도 수)
var sheath_rr := Vector3.ZERO
var stance := -1  # 내가 밀어서 잡은 칼 방향 (-1 = 아직)
var stance_l: Label
var cam_base := Vector3.ZERO
# 결투
var mode := "intro"
var mode_t := 0.0
var ph := 0
var ci := 0
var mi := 0
var fs := 0  # 0 쉼, 1 예비 동작, 2 빈틈, 3 내가 맞음, 4 상대 휘청, 5 연격 사이 텀(흰→노랑)
var beat := 0.3  # 연격 사이 텀 길이
var fs_t := 0.0
var gap := 0.5
var win := 0.5
var rdir := 0
var sdir := 0
var odir := 0
## 연속기마다 방향을 섞는다(10/31): 패턴(박자·몇 번·속임수·같은 쪽 두 번)은 그대로, 쪽만 무작위로 바꿔 끼운다
var dmap := [0, 1, 2, 3]
var feint_at := -1.0
var feinting := false  # 이번 칼이 방향을 바꾸는 속임수인가 (속임수 칼만 흔들린다)
var show_at := 0.0  # 거합: 이때 칼이 칼집에서 빠져나와 잔상 길이 보인다
var tell_at := -1.0  # 거합: 이때 눈이 번쩍 (이보다 먼저 휘두르면 헛공격)
var told := true
var drawn := false  # 거합 검객이 칼을 뽑아 든 채인가 (10/31)
var shown := true
var stun := 0.0  # 헛공격 뒤 굳은 시간
var whiff_t := 0.0
var fl := Vector3.ZERO
var slow := 0.0
var gp := false  # 지금 빈틈이 간파로 연 것인가 (헛공격하면 피해 없이 간파만 끝남)
var tw_p := false  # 베기 검객 첫 칼을 간파 타이밍에 막았나 (두 칼 다 맞춰야 간파)
var flash_t := 0.0
var shake_t := 0.0
var blink := 0.0
var start := Vector2.ZERO
var armed := false
var pend := {}  # 눌렀지만 아직 발동 안 한 버튼 -> 누른 시간
var sty := 0  # 이번 공격 모양 (위 T_WIND 설명)
var hitstop := 0.0  # 막은 순간 화면이 멈추는 시간
var sparks: Array = []  # 불꽃: [상자, 속도, 남은 시간, 처음 시간]
var fx: Node = null  # 전투 이펙트 (g/fx.gd, 없거나 꺼져 있으면 null)
var going := false  # 로비 버튼 누름 애니메이션 끝나고 출발하는 중
var link := false  # 연격: 지금 칼 뒤에 다음 칼이 이미 오고 있다 (노랑)
var link_at := -1.0  # 연격 칼(노랑)이 이때부터 보인다 (처음엔 흰 칼 하나만, 10/31)
var link_b: MeshInstance3D  # 연격 칼 (노랑)
var link_g: Array[MeshInstance3D] = []  # 연격 칼이 지나갈 길 (노랑 잔상)
var sfx_p: Array[AudioStreamPlayer] = []  # 효과음 전용 줄 (삑 소리에 밀려 끊기지 않게)
var sfx_i := 0
# 화면 글자
var info_l: Label
var tut_box: ColorRect
var tut_l: Label
var skip_l: Label
# 로비 (쓰러진 뒤, 다시 켤 때)
var lobby: Control
var tab := 0
var pages: Array[Control] = []
var nav_bg: Array[ColorRect] = []
var nav_l: Array[Label] = []
var top_l: Label
var home_l: Label
var pick_box: ColorRect  # 능력 고르기 창
var pick_head: Label
var pick_bg: Array[ColorRect] = []
var pick_l: Array[Label] = []
var play_bg: ColorRect
var play_edge: ColorRect
var tut_again: Label
var fixed_l := {}  # 대사 키 -> 늘 떠 있는 글들 (설정 창 등). 글을 고치면 _apply_text 가 다시 넣는다
var dex_bg: Array[ColorRect] = []
var dex_l: Array[Label] = []
var dex_card: Label
var dex_pick := 0
var last_run := ""
var up_pick := 0  # 강화 탭에서 고른 칸 (TREE 번호)
var up_bg: Array[ColorRect] = []
var up_l: Array[Label] = []
var up_card: Label
var up_buy: ColorRect
var up_buy_l: Label
var up_head: Label
const UP_BUY := Rect2(160, 1035, 400, 100)
var lobby_k := 0  # 전투 탭 뒤에 서 있는 검객 (마지막에 진 상대)
var set_box: ColorRect  # 설정 창 (로비 위 [설정])
var set_btn: ColorRect
var set_fill: Array[ColorRect] = []
var set_val: Array[Label] = []
# 고칠 수 있는 글·UI (개발 도구가 바꾼다)
var say := {}  # 글 키 -> 글
var ui := {}  # UI 이름 -> Control
var btn_at := {"guard": GUARD_P, "cut": CUT_P}  # 막기·베기 버튼 자리
var btn_r := {"guard": BTN_R, "cut": BTN_R}
var title_l: Label

const GUARD_P := Vector2(185, 1150)
const CUT_P := Vector2(535, 1150)
const BTN_R := 105.0
const PLAY_R := Rect2(110, 880, 500, 150)
const TUT_R := Rect2(200, 1050, 320, 80)
const SET_R := Rect2(586, 118, 124, 68)
const LANG_R := Rect2(446, 118, 134, 68)  # 위 띠 [설정] 왼쪽 언어 버튼 (설정 창 안 버튼과 같은 일)
const DEV := "res://g/dev.gd"  # 개발 도구. 출시 때는 이 파일만 지우면 된다
## 찌르기 검객 3D 모델 (파이가 보낸 duelist_animated.glb, 10/31): 대기·찌르기 4방향·맞음·쓰러짐 동작이 들어 있다.
## 칼은 게임 칼(blade_m, 빨개지는 신호)을 그대로 쓰고 모델의 레이피어는 숨긴다. 상자 몸으로 되돌리려면 DUELIST_ON 을 false 로
const DUELIST_ON := false
const DUELIST := preload("res://models/duelist.glb")
const RAPIER := ["Rapier_diamond_blade", "Curved_quillons", "Knuckle_bow", "Swept_ring_guard", "Round_pommel", "Rapier_leather_grip", "Grip_"]
const THRUST := ["Thrust_Left", "Thrust_Right", "Thrust_Up", "Thrust_Down"]
const FX := "res://g/fx.gd"  # 전투 이펙트 (10/31 시험 적용). 안 어울리면 이 파일의 ON 을 false 로 (예전 불꽃으로 돌아간다)
const SET_CLOSE := Rect2(210, 960, 300, 90)
const SET_LANG := Rect2(160, 850, 400, 90)  # 언어 버튼 (영어 <-> 한국어)


## 설정 창 줄 i(0 소리, 1 진동)의 [-] [+] 칸
func _set_r(i: int, plus: bool) -> Rect2:
	return Rect2(570 if plus else 70, 470 + i * 200, 90, 90)


## 능력 고르기 카드 i (0~2)
func _pick_r(i: int) -> Rect2:
	return Rect2(40, 330 + i * 230, 640, 200)


func _tab_r(i: int) -> Rect2:
	return Rect2(i * 240, NAV_Y, 240, 1280 - NAV_Y)


## 강화 칸: c 줄(0 몸 · 1 칼 · 2 눈), r 칸(위에서 0~2)
func _up_r(c: int, r: int) -> Rect2:
	return Rect2(18 + c * 232, 312 + r * 182, 220, 140)


## 강화 칸 i 를 찍을 수 있나 (윗칸을 먼저 1단계 이상 찍어야 열린다)
func _up_open(i: int) -> bool:
	var need: String = TREE[i][7]
	return need == "" or _tl(need) > 0


func _dex_r(i: int) -> Rect2:
	return Rect2(16 + i * 139, 210, 131, 84)


# ---- 저장 ----
func _load_save() -> void:
	if not FileAccess.file_exists(FILE):
		return
	var f := FileAccess.open(FILE, FileAccess.READ)
	if f == null:
		return
	var d: Variant = JSON.parse_string(f.get_as_text())
	if not d is Dictionary:
		return
	tut_done = bool(d.get("tut", false))
	runs = int(d.get("runs", 0))
	blocks = int(d.get("blocks", 0))
	perfects = int(d.get("perfects", 0))
	for key in ["seen", "kills", "deaths"]:
		var a: Variant = d.get(key, [])
		if a is Array:
			for i in mini(a.size(), 5):
				({"seen": seen, "kills": kills, "deaths": deaths}[key] as Array)[i] = int(a[i])
	best_n = int(d.get("best", 0))
	best_dmg = int(d.get("dmg", 0))
	vol = clampi(int(d.get("vol", 8)), 0, 10)
	vib = clampi(int(d.get("vib", 8)), 0, 10)
	lang = "ko" if str(d.get("lang", "en")) == "ko" else "en"
	coin = maxi(0, int(d.get("coin", 0)))
	var t: Variant = d.get("tree", {})
	if t is Dictionary:
		for row: Array in TREE:
			tree[row[0]] = clampi(int(t.get(row[0], 0)), 0, int(row[3]))


func _save() -> void:
	var f := FileAccess.open(FILE, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify({"best": best_n, "dmg": best_dmg, "tut": tut_done, "runs": runs, "blocks": blocks, "perfects": perfects, "seen": seen, "kills": kills, "deaths": deaths, "vol": vol, "vib": vib, "lang": lang, "coin": coin, "tree": tree}))


# ---- 능력치 ----
func _lv(k: String) -> int:
	return int(perk.get(k, 0))


func _tl(k: String) -> int:
	return int(tree.get(k, 0))


## 강화 칸 i 의 다음 값
func _cost(i: int) -> int:
	return int(round(float(TREE[i][4]) * pow(UP_GROW, _tl(TREE[i][0]))))


func _pow() -> int:
	return 1 + _lv("pow") + _tl("t_pow")


## 간파 판정: 칼이 닿기 전 이 시간 안에 막으면 간파. 기본은 좁게(10/31: 0.20 → 0.15), 능력 "맑은 눈"은 한 번에 크게 (+0.04, 다 골라도 0.31초)
func _per() -> float:
	return 0.15 + 0.04 * _lv("per") + 0.01 * _tl("t_per")


## 막은 순간이 간파인가: 칼이 닿기 _per() 전부터 닿은 뒤 PARRY_LATE 까지. 죽기 직전엔 몰래 LAST_HELP 만큼 더 일찍부터
func _is_parry() -> bool:
	var w := _per()
	if tut < 0 and life <= foe_atk:
		w += LAST_HELP
	return win - fs_t <= w


# ---- 화면 글자 ----
func _setup() -> void:
	_load_save()
	_set_lang()
	_apply_vol()
	for i in 4:
		var ap := AudioStreamPlayer.new()
		add_child(ap)
		sfx_p.append(ap)
	var hud := CanvasLayer.new()
	hud.layer = 2
	add_child(hud)
	info_l = _label(hud, 34, 236, 60)
	stance_l = _label(hud, 32, 1012, 50)
	_buttons()
	# 튜토리얼 안내 (아래쪽 띠, 깜빡임)
	var tl := CanvasLayer.new()
	tl.layer = 3
	add_child(tl)
	tut_box = ColorRect.new()
	tut_box.color = Color(0.1, 0.07, 0.04, 0.82)
	tut_box.position = Vector2(0, 740)
	tut_box.size = Vector2(720, 270)
	tut_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tl.add_child(tut_box)
	tut_l = _label(tut_box, 36, 0, 270)
	tut_l.label_settings.font_color = WHITE
	tut_l.label_settings.outline_color = INK
	tut_l.label_settings.line_spacing = 6
	tut_l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	tut_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tut_l.position.x = 20
	tut_l.size.x = 680
	skip_l = _label(tl, 32, 310, 60)
	skip_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	skip_l.position.x = 456
	skip_l.size.x = 240
	_lobby_ui()
	ui = {"info": info_l, "stance": stance_l, "score": _score_l, "bar": _bar_bg, "msg": _msg_l, "tut": tut_box, "skip": skip_l,
		"top": top_l.get_parent(), "set": set_btn, "title": title_l, "home": home_l.get_parent(), "play": play_edge, "tut_again": tut_again}
	_default_say()
	say.merge(BAKED_TEXT, true)
	say_en.merge(BAKED_TEXT_EN, true)
	_apply_ui(BAKED_UI)
	_apply_text()
	if ResourceLoader.exists(DEV):
		add_child(load(DEV).new())
	if ResourceLoader.exists(FX):
		var fs_scr: GDScript = load(FX)
		if fs_scr.get_script_constant_map().get("ON", false):
			fx = fs_scr.new()
			fx.g = self
			add_child(fx)


## 글 기본값 (개발 도구 [대사 편집]에서 바꿀 수 있다)
func _default_say() -> void:
	say = {"title": "일격의 길", "tut_look": "검객이 공격하려고 해요. 잘 봐요!"}
	for i in TUT_SAY.size():
		say["tut%d" % i] = TUT_SAY[i]
	say["tut_wait"] = "이번엔 칼이 거의 닿을 때까지\n기다려요…"
	say["tut_good"] = "좋아요!"
	say["tut_end"] = "준비 끝!\n검객을 쓰러뜨리면 능력을 하나 골라요.\n체력은 저절로 차지 않아요. 갈수록 적이 세져요.\n\n탭해서 싸우러 가기"
	say["skip"] = "건너뛰기 >"
	say["play"] = "전투"
	say["tut_again"] = "튜토리얼 다시 보기"
	for i in NAMES.size():
		say["name%d" % i] = NAMES[i]
		say["dexd%d" % i] = TIPS[i]  # 도감에만 나오는 검객 설명 (10/31: 전투 글과 따로)
	for pk: Array in PERKS:
		say["pk_%s" % pk[0]] = pk[1]
		say["pkd_%s" % pk[0]] = pk[2]
	say.merge({"parry": "간파!", "parry_go": "간파!\n지금 초록 쪽으로 베요!", "parry_twice": "좋아요!\n두 번째도 맞춰야 간파!", "block": "막기",
		"cut": "베기!", "x2": "간파 일격! x2", "link": "연격!", "whiff": "헛공격!  체력 -1\n빈틈을 보였어요",
		"whiff_steady": "헛공격!\n빈틈을 보였어요", "eguard": "헛막기", "lose": "간파 놓침", "no_gap": "막았지만 빈틈이 없어요
두 칼 다 간파해야 해요", "win": "승리!", "dead": "쓰러짐"})
	# 10/31: 화면에 뜨는 나머지 글도 전부 여기서 고칠 수 있게 (%d·%s = 숫자·글이 들어가는 자리)
	say.merge({"foe_intro": "%d번째 상대\n체력 %s · 공격 %d", "hurt": "맞음 -%d", "rank": "%d단",
		"tut_dir": "버튼을 누른 채 %s 쪽으로 밀어요!", "tut_btn": "[%s]를 눌러요!",
		"pick_head": "승리!  능력을 하나 골라요\n체력 %d/%d",
		"info": "나 %d/%d   ·   %d번째 %d/%d · 공격 %d", "info_boss": "나 %d/%d   ·   %d번째 · 준 피해 %d · 공격 %d",
		"stance_none": "버튼을 누른 채 칼이 오는 쪽으로 밀기", "stance": "버튼을 밀어 방향 · 지금 %s",
		"btn_guard": "막기", "btn_cut": "베기",
		"best": "최고 %d명 쓰러뜨림", "home": "매 판 맨몸으로 시작해요\n검객을 쓰러뜨릴 때마다 능력을 하나 골라요",
		"home_dmg": "\n끝판왕 최고 피해 %d", "last_dmg": "지난 판: %d번째 상대에게 %d 피해\n%s",
		"last_dead": "지난 판: %d번째 상대에게 쓰러짐\n%s", "no_perk": "고른 능력 없음", "perks": "능력: ",
		"char_head": "검객별 기록", "char_row": "%s\n쓰러뜨림 %d번 · 죽음 %d번", "char_boss": "%s\n최고 피해 %d · 죽음 %d번",
		"char_unknown": "???\n아직 못 만났어요",
		"coin_top": "%d냥", "win_coin": "승리!  +%d냥", "got_coin": "받은 냥 +%d", "x3": "간파 일격! x3", "last": "마지막 버팀!\n체력 1",
		"up_head": "강화 · 가진 냥 %d", "up_cost": "%d냥", "up_max": "최대", "up_lock": "윗칸 먼저",
		"up_buy": "강화하기 (%d냥)", "up_short": "냥이 모자라요 (%d냥)",
		"dex_none": "???\n아직 못 만났어요\n싸우다 보면 열려요", "dex_rec": "만남 %d번 · 쓰러뜨림 %d번",
		"dex_rec_boss": "만남 %d번 · 준 피해 최고 %d",
		"set": "설정", "set_vol": "소리 크기", "set_vib": "진동 세기", "close": "닫기", "off": "끔",
		"vib_note": "진동은 안드로이드 폰에서만 울려요\n0이면 꺼져요"})
	for i in TABS.size():
		say["tab%d" % i] = TABS[i]
	for i in DEX.size():
		say["dex%d" % i] = DEX[i]
	for row: Array in TREE:
		say[row[0]] = row[1]
		say["d_" + row[0]] = row[2]
	for i in TREE_COL.size():
		say["tcol%d" % i] = TREE_COL[i]


func _s(k: String) -> String:
	if lang == "en" and say_en.has(k):
		return say_en[k]
	return tr(say.get(k, k))


## 숫자가 들어가는 글: %d·%s 자리에 차례로 넣는다. 대사 편집에서 자리를 지우거나 늘려도 멈추지 않는다
func _f(k: String, a: Array) -> String:
	var s := _s(k)
	var out := ""
	var i := 0
	var j := 0
	while j < s.length():
		if s[j] == "%" and j + 1 < s.length() and (s[j + 1] == "d" or s[j + 1] == "s"):
			out += str(a[i]) if i < a.size() else ""
			i += 1
			j += 2
			continue
		out += s[j]
		j += 1
	return out


## 언어 정하기: 영어 번역표를 한 번 넣고 locale 을 바꾼다. Label 은 저절로 바뀌고, 서식 글은 tr() 로 감싼다
## (한국어판에서는 번역표를 뺀다. 남겨 두면 Godot 가 기본 언어 en 으로 돌아가 영어가 뜬다)
func _set_lang() -> void:
	if _tr == null:
		_tr = Translation.new()
		_tr.locale = "en"
		for k: String in EN:
			_tr.add_message(k, EN[k])
	TranslationServer.remove_translation(_tr)
	if lang == "en":
		TranslationServer.add_translation(_tr)
	TranslationServer.set_locale(lang)


## 글이 바뀌면 화면에 늘 떠 있는 글자에 다시 넣는다
func _apply_text() -> void:
	title_l.text = _s("title")
	skip_l.text = _s("skip")
	(play_bg.get_child(0) as Label).text = _s("play")
	tut_again.text = _s("tut_again")
	lang_top_l.text = "한국어" if lang == "en" else "English"
	for k in fixed_l:
		for l: Label in fixed_l[k]:
			l.text = _s(k)
	if _btns.has("guard"):
		_btns.guard.label = _s("btn_guard")
		_btns.cut.label = _s("btn_cut")
	if lobby.visible:
		_lobby_refresh()


## UI 자리·크기: 이름 -> [x, y, 크기]. 막기·베기 버튼은 [가운데 x, 가운데 y, 크기]
func _apply_ui(d: Dictionary) -> void:
	for k in d:
		var v: Array = d[k]
		if btn_at.has(k):
			btn_at[k] = Vector2(v[0], v[1])
			btn_r[k] = BTN_R * float(v[2])
			if _btns.has(k):
				_btns[k].pos = btn_at[k]
				_btns[k].r = btn_r[k]
		elif ui.has(k):
			var c: Control = ui[k]
			c.pivot_offset = c.size * 0.5
			c.position = Vector2(v[0], v[1])
			c.scale = Vector2.ONE * float(v[2])
			c.set_meta("s0", c.scale)


func _panel(parent: Node, r: Rect2, c: Color) -> ColorRect:
	var bg := ColorRect.new()
	bg.color = c
	bg.position = r.position
	bg.size = r.size
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(bg)
	return bg


func _fixed(k: String, l: Label) -> void:
	if not fixed_l.has(k):
		fixed_l[k] = []
	fixed_l[k].append(l)


func _white(l: Label) -> Label:
	l.label_settings.font_color = WHITE
	l.label_settings.outline_color = INK
	return l


## 로비: 위 기록 띠, 가운데 탭 화면, 아래 탭 줄(전투 · 캐릭터 · 도감)
func _lobby_ui() -> void:
	var sl := CanvasLayer.new()
	sl.layer = 4
	add_child(sl)
	lobby = Control.new()
	lobby.size = Vector2(720, 1280)
	lobby.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lobby.visible = false
	sl.add_child(lobby)
	var top := _panel(lobby, Rect2(0, 110, 720, 84), Color(0.12, 0.08, 0.05, 0.85))
	top_l = _white(_label(top, 38, 0, 84))
	top_l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	top_l.size.x = 440  # 오른쪽은 [언어] [설정] 자리
	for i in TABS.size():
		var pg := Control.new()
		pg.size = Vector2(720, 1280)
		pg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lobby.add_child(pg)
		pages.append(pg)
	# 0 전투 (뒤에 검객이 서 있다)
	title_l = _label(pages[0], 72, 210, 100)
	var card := _panel(pages[0], Rect2(60, 320, 600, 150), Color(0.12, 0.08, 0.05, 0.7))
	home_l = _white(_label(card, 30, 0, 150))
	home_l.size.x = 600
	home_l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	play_edge = _panel(pages[0], Rect2(PLAY_R.position + Vector2(-8, -8), PLAY_R.size + Vector2(16, 24)), INK)
	play_bg = _panel(play_edge, Rect2(8, 8, PLAY_R.size.x, PLAY_R.size.y), D)
	var pl := _label(play_bg, 80, 0, PLAY_R.size.y)
	pl.size.x = PLAY_R.size.x
	pl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	tut_again = _label(pages[0], 30, TUT_R.position.y, TUT_R.size.y)
	tut_again.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	tut_again.position.x = TUT_R.position.x
	tut_again.size.x = TUT_R.size.x
	# 1 강화: 스킬 트리 (세 줄 몸·칼·눈, 위에서 아래로 찍는다), 아래 고른 칸 설명과 [강화] 버튼 (10/31)
	_panel(pages[1], Rect2(0, 194, 720, NAV_Y - 194), Color(0.12, 0.08, 0.05, 0.8))
	up_head = _white(_label(pages[1], 34, 200, 60))
	for c in 3:
		var hl := _white(_label(pages[1], 30, 262, 44))
		hl.position.x = _up_r(c, 0).position.x
		hl.size.x = _up_r(c, 0).size.x
		_fixed("tcol%d" % c, hl)
		for r in 2:
			var a := _up_r(c, r)
			_panel(pages[1], Rect2(a.get_center().x - 5, a.end.y, 10, _up_r(c, r + 1).position.y - a.end.y), SOFT)
	for i in TREE.size():
		var r := _up_r(int(TREE[i][5]), int(TREE[i][6]))
		var edge := _panel(pages[1], r, INK)
		var bg := _panel(edge, Rect2(Vector2(5, 5), r.size - Vector2(10, 10)), SOFT)
		up_bg.append(bg)
		var l := _label(bg, 26, 0, r.size.y - 10)
		l.size.x = r.size.x - 10
		l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.label_settings.outline_size = 0
		up_l.append(l)
	var uc := _panel(pages[1], Rect2(30, 860, 660, 165), Color(0.05, 0.03, 0.02, 0.6))
	up_card = _white(_label(uc, 28, 0, 165))
	up_card.size.x = 660
	up_card.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	up_card.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	up_buy = _panel(pages[1], UP_BUY, D)
	up_buy_l = _label(up_buy, 34, 0, UP_BUY.size.y)
	up_buy_l.size.x = UP_BUY.size.x
	up_buy_l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	up_buy_l.label_settings.outline_size = 0
	# 2 도감: 위 칩 다섯, 가운데 검객(3D), 아래 설명 카드
	for i in 5:
		var bg := _panel(pages[2], _dex_r(i), SOFT)
		dex_bg.append(bg)
		var l := _label(bg, 30, 0, 84)
		l.size.x = 131
		l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		l.label_settings.outline_size = 0
		dex_l.append(l)
	var dc := _panel(pages[2], Rect2(30, 860, 660, 270), Color(0.12, 0.08, 0.05, 0.8))
	dex_card = _white(_label(dc, 30, 0, 270))
	dex_card.size.x = 660
	dex_card.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	dex_card.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	# 아래 탭 줄
	_panel(lobby, Rect2(0, NAV_Y, 720, 1280 - NAV_Y), INK)
	for i in TABS.size():
		var r := _tab_r(i)
		var bg := _panel(lobby, r.grow(-4), Color("5a4632"))
		nav_bg.append(bg)
		var l := _white(_label(bg, 32, 0, r.size.y - 8))
		l.size.x = r.size.x - 8
		l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		nav_l.append(l)
	# 위 띠 오른쪽 [설정] → 소리·진동 창
	set_btn = _panel(lobby, SET_R, Color("5a4632"))
	var sl2 := _white(_label(set_btn, 30, 0, SET_R.size.y))
	sl2.size.x = SET_R.size.x
	sl2.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_fixed("set", sl2)
	lang_btn = _panel(lobby, LANG_R, Color("5a4632"))
	lang_top_l = _white(_label(lang_btn, 28, 0, LANG_R.size.y))
	lang_top_l.size.x = LANG_R.size.x
	lang_top_l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lang_top_l.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	set_box = _panel(lobby, Rect2(0, 194, 720, NAV_Y - 194), Color(0.08, 0.05, 0.03, 0.94))
	set_box.visible = false
	var st := _white(_label(set_box, 48, 120, 90))
	_fixed("set", st)
	for i in 2:
		var y := 470.0 + i * 200.0 - 194.0
		var nm := _white(_label(set_box, 34, y - 70, 60))
		_fixed(["set_vol", "set_vib"][i], nm)
		for plus in [false, true]:
			var r := _set_r(i, plus)
			var b := _panel(set_box, Rect2(r.position - Vector2(0, 194), r.size), D)
			var bl2 := _label(b, 56, 0, r.size.y)
			bl2.size.x = r.size.x
			bl2.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			bl2.label_settings.outline_size = 0
			bl2.text = "+" if plus else "-"
		var back := _panel(set_box, Rect2(180, y + 25, 360, 40), SOFT)
		var fill := _panel(back, Rect2(0, 0, 360, 40), GOOD)
		set_fill.append(fill)
		var v := _white(_label(set_box, 30, y + 92, 50))
		set_val.append(v)
	var close := _panel(set_box, Rect2(SET_CLOSE.position - Vector2(0, 194), SET_CLOSE.size), Color("5a4632"))
	var cl := _white(_label(close, 38, 0, SET_CLOSE.size.y))
	cl.size.x = SET_CLOSE.size.x
	cl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_fixed("close", cl)
	var lb := _panel(set_box, Rect2(SET_LANG.position - Vector2(0, 194), SET_LANG.size), D)
	lang_l = _label(lb, 34, 0, SET_LANG.size.y)
	lang_l.size.x = SET_LANG.size.x
	lang_l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lang_l.label_settings.outline_size = 0
	lang_l.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	var sh := _white(_label(set_box, 28, 1064 - 194, 80))
	_fixed("vib_note", sh)
	# 검객을 쓰러뜨리면 뜨는 능력 고르기 (카드 셋)
	var pl2 := CanvasLayer.new()
	pl2.layer = 5
	add_child(pl2)
	pick_box = _panel(pl2, Rect2(0, 0, 720, 1280), Color(0.08, 0.05, 0.03, 0.82))
	pick_box.visible = false
	pick_head = _white(_label(pick_box, 44, 170, 140))
	pick_head.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	for i in 3:
		var r := _pick_r(i)
		var edge := _panel(pick_box, r.grow(6), INK)
		var bg := _panel(edge, Rect2(Vector2(6, 6), r.size), D)
		pick_bg.append(edge)
		var l := _label(bg, 34, 0, r.size.y)
		l.size.x = r.size.x
		l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.label_settings.outline_size = 0
		pick_l.append(l)


## 설정 창 글자·막대
func _set_refresh() -> void:
	for i in 2:
		var v: int = vol if i == 0 else vib
		set_fill[i].size.x = 360.0 * v / 10.0
		set_val[i].text = _s("off") if v == 0 else "%d%%" % (v * 10)
	lang_l.text = "한국어로 바꾸기" if lang == "en" else "Switch to English"
	lang_top_l.text = "한국어" if lang == "en" else "English"


## 소리 크기: 전체 소리 길(버스)에 건다
func _apply_vol() -> void:
	AudioServer.set_bus_mute(0, vol == 0)
	AudioServer.set_bus_volume_db(0, linear_to_db(maxf(vol, 1) / 10.0))


## 진동: 설정 세기만큼 길이·세기를 줄인다. 0이면 안 울린다
func _buzz(ms: int, amp: float) -> void:
	if vib == 0:
		return
	var k := vib / 10.0
	Input.vibrate_handheld(maxi(10, int(ms * (0.4 + 0.6 * k))), clampf(amp * k, 0.05, 1.0))


## 막기·베기 버튼 (여러 손가락: 한 손가락으로 밀면서 다른 손가락으로 누른다). 상점에서는 뺀다.
func _buttons() -> void:
	kit_button("guard", _s("btn_guard"), btn_at.guard, btn_r.guard, B)
	kit_button("cut", _s("btn_cut"), btn_at.cut, btn_r.cut, A)


func _lobby_refresh() -> void:
	top_l.text = "%s   %s" % [_f("best", [best_n]), _f("coin_top", [coin])]
	for i in TABS.size():
		nav_l[i].text = _s("tab%d" % i)
		pages[i].visible = i == tab
		nav_bg[i].color = D if i == tab else Color("5a4632")
		nav_l[i].label_settings.font_size = 36 if i == tab else 30
	match tab:
		0:
			var h := last_run if last_run != "" else _s("home")
			if best_dmg > 0:
				h += _f("home_dmg", [best_dmg])
			home_l.text = h
		1:
			up_head.text = _f("up_head", [coin])
			for i in TREE.size():
				var row: Array = TREE[i]
				var lv := _tl(row[0])
				var mx := int(row[3])
				var open := _up_open(i)
				var price := _s("up_max") if lv >= mx else _f("up_cost", [_cost(i)])
				up_l[i].text = "%s\n%d/%d · %s" % [_s(row[0]), lv, mx, price] if open else "%s\n%s" % [_s(row[0]), _s("up_lock")]
				var c := SOFT
				if lv >= mx:
					c = GOOD
				elif not open:
					c = Color("8a7a66")
				elif coin >= _cost(i):
					c = D
				up_bg[i].color = c
				(up_bg[i].get_parent() as ColorRect).color = WHITE if i == up_pick else INK
			var sel: Array = TREE[up_pick]
			var slv := _tl(sel[0])
			up_card.text = "%s  (%d/%d)\n%s" % [_s(sel[0]), slv, int(sel[3]), _s("d_" + sel[0])]
			if slv >= int(sel[3]):
				up_buy_l.text = _s("up_max")
				up_buy.color = GOOD
			elif not _up_open(up_pick):
				up_buy_l.text = _s("up_lock")
				up_buy.color = Color("8a7a66")
			elif coin < _cost(up_pick):
				up_buy_l.text = _f("up_short", [_cost(up_pick)])
				up_buy.color = SOFT
			else:
				up_buy_l.text = _f("up_buy", [_cost(up_pick)])
				up_buy.color = D
		2:
			for i in 5:
				dex_l[i].text = _s("dex%d" % i) if seen[i] > 0 else "???"
				dex_bg[i].color = D if i == dex_pick else (SOFT if seen[i] > 0 else Color("8a7a66"))
			var i := dex_pick
			if seen[i] == 0:
				dex_card.text = _s("dex_none")
			else:
				var rec := _f("dex_rec", [seen[i], kills[i]]) if i < 4 else _f("dex_rec_boss", [seen[i], best_dmg])
				dex_card.text = "%s\n%s\n%s" % [_s("name%d" % i), _s("dexd%d" % i).replace("\n", " "), rec]


## 로비로 (t = 탭). 막기·베기 버튼은 뺀다.
func _to_lobby(t: int) -> void:
	mode = "lobby"
	tut = -1
	hold = false
	_btns.clear()
	pend.clear()
	tut_box.visible = false
	skip_l.visible = false
	lobby.visible = true
	set_box.visible = false
	slow = 0.0
	stun = 0.0
	_floor(SOFT)
	_set_tab(t)


func _set_tab(t: int) -> void:
	tab = t
	# 전투 탭 = 마지막 상대, 도감 = 고른 검객(못 만났으면 검은 그림자)
	if t == 2:
		_spawn(BOSS_AT if dex_pick == 4 else dex_pick)
		if seen[dex_pick] == 0:
			for c in piv.find_children("*", "MeshInstance3D", true, false):
				c.material_override = mat(INK)
			for m in rig_m:
				m.material_override = mat(INK)
	else:
		_spawn(lobby_k)
	_clear()
	hp_back.visible = false
	hp_fill.visible = false
	fl = Vector3.ZERO
	piv.rotation = Vector3.ZERO
	_lobby_refresh()


# ---- 판 ----
func _reset() -> void:
	_scenery()
	mark = Node3D.new()
	world.add_child(mark)
	ind.clear()
	for i in 4:
		var g := Node3D.new()
		g.position = OFF[i]
		g.visible = false
		mark.add_child(g)
		box(Vector3.ZERO, Vector3(0.82, 0.82, 0.06), Color.BLACK, g)
		box(Vector3(0, 0, 0.04), Vector3(0.6, 0.6, 0.06), GOOD, g)
		ind.append(g)
	cam_base = CAM_O
	cam.position = cam_base
	cam.look_at(Vector3.ZERO)
	score = n
	slow = 0.0
	flash_t = 0.0
	shake_t = 0.0
	armed = false
	stun = 0.0
	whiff_t = 0.0
	stance = -1
	if tut_done:
		_to_lobby(0)
		return
	_begin_tut()


## 처음 켜면(또는 로비에서 다시 보기) 튜토리얼
func _begin_tut() -> void:
	going = false
	lobby.visible = false
	tut_box.visible = true
	skip_l.visible = true
	_buttons()
	pend.clear()
	stance = -1
	tut = 0
	hold = false
	n = 0
	spd = 1.0
	foe_atk = 0
	_spawn(0)
	foe_max = 99
	foe_hp = 99
	hp_back.visible = false
	hp_fill.visible = false
	_intro()
	msg(_s("title"), 1.4)
	tut_l.text = _s("tut_look")


## 배경 = 파이가 보낸 그림(하늘·갈대밭·모랫길, 10/31). 3D 뒤 캔버스에 화면 가득 깐다.
## 바닥 상자는 평소엔 안 보이고, 헛공격(빨강)·간파(파랑) 때만 반투명으로 깔린다(_floor).
func _scenery() -> void:
	floor_m = box(Vector3(0, -1.9, -1), Vector3(8, 0.3, 8), SOFT)
	_floor(SOFT)
	for c in get_children():
		if c is WorldEnvironment:
			(c as WorldEnvironment).environment.background_mode = Environment.BG_CANVAS
	var back := CanvasLayer.new()
	back.layer = -1
	add_child(back)
	var pic := TextureRect.new()
	pic.texture = BG_PIC
	pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	pic.set_anchors_preset(Control.PRESET_FULL_RECT)
	pic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	back.add_child(pic)


func _floor(c: Color) -> void:
	floor_m.visible = c != SOFT
	if not _floor_mats.has(c):
		var m := StandardMaterial3D.new()
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		m.albedo_color = Color(c, 0.35)
		_floor_mats[c] = m
	floor_m.material_override = _floor_mats[c]


## n번째 검객을 만든다. 종류는 번갈아, 뒤로 갈수록 몸이 어둡고 머리 위 금장식이 늘어난다.
func _spawn(k: int) -> void:
	if piv:
		piv.queue_free()
	ftype = 4 if k >= BOSS_AT else k % 4
	var col: Color = BODY[ftype]
	if ftype < 4:
		col = col.lerp(INK, minf(0.6, floorf(k / 4.0) * 0.3))
	piv = Node3D.new()
	world.add_child(piv)
	eyes.clear()
	rig = null
	anim = null
	rig_m.clear()
	blade_rest = Vector3(0.95, -0.3, 0.6)
	blade_rr = Vector3(0, 0, 0.5)
	drawn = false
	var hp_y := 2.0
	var eye_y := 0.6
	var eye_z := 0.6 if ftype == 4 else 0.5
	_dress_box(col)
	if ftype == 4:
		hp_y = 2.9
		eye_y = 0.95
	body.set_meta("col", (body.material_override as StandardMaterial3D).albedo_color)
	for s in [-1.0, 1.0]:
		if rig == null and rig_m.is_empty():
			eyes.append(box(Vector3(s * 0.33, eye_y, eye_z), Vector3(0.24, 0.24, 0.06), INK, piv))
	_spawn_rest(k, hp_y)


## 검객 종류(찌르기·속임수·베기·거합·끝판왕) -> models.gd 외형 번호. 10/31 파이 요청: 찌르기↔끝판왕, 속임수↔베기 외형 맞바꿈
const LOOK := [4, 2, 1, 3, 0]


## 상자 검객 몸
func _dress_box(_col: Color) -> void:
	body = box(Vector3.ZERO, Vector3.ONE, WHITE, piv)
	body.visible = false
	var model := preload("res://g/models.gd").new()
	piv.add_child(model)
	model.build(LOOK[ftype])
	for m in model.find_children("*", "MeshInstance3D", true, false):
		rig_m.append(m)
		if m.has_meta("signal_eye"):
			m.set_meta("eye_col", m.material_override.albedo_color)
			eyes.append(m)
	# 칼은 검객마다 쥔 손(팔) 자리에서 (10/31). 거합 칼은 허리 칼집에 손잡이가 앞으로
	hand_p = preload("res://g/models.gd").HAND[LOOK[ftype]]
	var tip := Vector3(0.3, -0.35, -0.89).normalized()  # 칼집 칼: 칼끝은 뒤·아래, 손잡이는 앞으로
	sheath_rr = Basis(Quaternion(Vector3.UP, tip)).get_euler()
	sheath_p = _grip_rest(hand_p, sheath_rr)
	blade_rr = Vector3(0, 0, 0.5)
	blade_rest = _grip_rest(hand_p, blade_rr)
	if ftype == 3:
		blade_rest = sheath_p
		blade_rr = sheath_rr


## 칼 손잡이(쥔 손 공)가 hand 에 오는 칼 자리
func _grip_rest(hand: Vector3, rr: Vector3) -> Vector3:
	var l := 2.0 if ftype == 2 else 1.7
	return hand - Basis.from_euler(rr) * Vector3(0, -(0.38 * l + 0.16), -0.06)


## 찌르기 검객 = 파이가 보낸 모델. 상자 몸(body)은 숨겨 두고 번쩍임 색만 받는다
func _dress_duelist() -> void:
	body.visible = false
	rig = DUELIST.instantiate()
	rig.scale = Vector3.ONE * 1.3
	rig.position = Vector3(0, -1.4, 0)
	piv.add_child(rig)
	for m in rig.find_children("*", "MeshInstance3D", true, false):
		var hide := false
		for r in RAPIER:
			if (m.name as String).begins_with(r):
				hide = true
		m.visible = not hide
		if not hide:
			rig_m.append(m)
	anim = rig.find_child("AnimationPlayer", true, false)
	anim.get_animation("Idle").loop_mode = Animation.LOOP_LINEAR
	anim.animation_finished.connect(func(a: StringName) -> void:
		if a != &"Death" and anim:
			anim.play("Idle"))
	anim.play("Idle")


## 모델 동작: 칼이 오는 동안 그쪽 찌르기 동작을 칼에 맞춰 당겼다 뻗고, 그 밖엔 남은 동작을 마저 하고 대기로
func _rig_pose() -> void:
	if anim == null:
		return
	if mode == "fight" and fs == 1 and shown:
		var k := clampf((fs_t - show_at) / maxf(0.01, win - show_at), 0.0, 1.0)
		var a: String = THRUST[sdir]
		if anim.current_animation != a:
			anim.play(a)
		anim.pause()
		# 0~0.25 당김, 0.25~0.5 뻗음: 오래 당기고 있다가 끝에 뻗는다 (게임 칼과 같은 박자)
		var t := 0.25 * minf(1.0, k / 0.7) + 0.22 * maxf(0.0, (k - 0.7) / 0.3)
		anim.seek(anim.get_animation(a).length * t, true)
	elif not anim.is_playing():
		anim.play()


## 몸 번쩍임: 상자 몸은 색을 바꾸고, 모델은 위에 반투명 색을 덮는다. null 이면 원래대로
func _tint(c: Variant) -> void:
	if c == null:
		body.material_override = mat(body.get_meta("col"))
	else:
		body.material_override = mat(c)
	for m in rig_m:
		if c == null:
			m.material_overlay = null
		else:
			var o := StandardMaterial3D.new()
			o.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			o.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			o.albedo_color = Color(c, 0.55)
			m.material_overlay = o


func _spawn_rest(k: int, hp_y: float) -> void:
	# 칼은 세로로 긴 막대: 좌우 공격은 세운 칼, 위아래 공격은 눕힌 칼로 보인다
	blade_m = box(blade_rest, Vector3(0.16, 2.0 if ftype == 2 else 1.7, 0.16), WHITE, piv)
	blade_m.rotation = blade_rr
	preload("res://g/models.gd").sword(blade_m)
	ghosts.clear()
	for i in 4:
		var gm := StandardMaterial3D.new()
		gm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		gm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		gm.albedo_color = Color(1, 1, 1, [0.22, 0.34, 0.5, 0.5][i])
		var gh := box(Vector3.ZERO, blade_m.scale, WHITE, piv)
		gh.material_override = gm
		gh.visible = false
		ghosts.append(gh)
	link_b = box(Vector3.ZERO, blade_m.scale, D, piv)
	link_b.visible = false
	link_g.clear()
	for i in 3:
		var om := StandardMaterial3D.new()
		om.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		om.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		om.albedo_color = Color(D, [0.25, 0.38, 0.55][i])
		var og := box(Vector3.ZERO, blade_m.scale, A, piv)
		og.material_override = om
		og.visible = false
		link_g.append(og)
	link = false
	hp_back = box(Vector3(0, hp_y, 0), Vector3(2.0, 0.22, 0.2), INK, piv)
	hp_fill = box(Vector3(0, hp_y, 0.08), Vector3(1.9, 0.16, 0.16), BAD, piv)
	foe_max = BOSS_HP if ftype == 4 else 6 + 4 * k
	foe_hp = foe_max
	foe_atk = 2 + k
	spd = maxf(0.55, 1.0 - 0.05 * k)
	boss_dmg = 0
	cuts = 0
	ph = 0
	_eyes()
	_hp_bar()


## 검객 전체 투명도 (0 = 안 보임, 1 = 다 보임). 등장할 때 페이드인
func _fade(a: float) -> void:
	for m in piv.find_children("*", "GeometryInstance3D", true, false):
		(m as GeometryInstance3D).transparency = 1.0 - a


func _eyes() -> void:
	var c := BAD if ph == 2 or ftype == 4 else INK
	for e in eyes:
		e.material_override = mat(BAD if c == BAD else e.get_meta("eye_col", INK))


func _hp_bar() -> void:
	var f := clampf(float(foe_hp) / float(foe_max), 0.0, 1.0)
	hp_fill.scale.x = maxf(0.001, 1.9 * f)
	hp_fill.position.x = -0.95 + 0.95 * f


func _intro() -> void:
	ph = 0
	ci = 0
	mi = 0
	fs = 0
	fs_t = 0.0
	fl = Vector3.ZERO
	mode = "intro"
	mode_t = 1.6
	piv.rotation = Vector3.ZERO
	if tut < 0:
		seen[ftype] += 1
		mode_t = 2.6
		var hp_s := "∞" if ftype == 4 else str(foe_max)
		# 상대가 누구인지는 글로 알려 주지 않는다 (로비 도감에서만)
		msg(_f("foe_intro", [n + 1, hp_s, foe_atk]), 2.0)


func _start_run() -> void:
	going = false
	tut = -1
	hold = false
	lobby.visible = false
	tut_box.visible = false
	tut_done = true
	runs += 1
	_save()
	skip_l.visible = false
	n = 0
	max_life = 6 + _tl("t_hp")
	run_coin = 0
	last_used = false
	perk = {}
	life = max_life
	stun = 0.0
	pend.clear()
	slow = 0.0
	_floor(SOFT)
	_spawn(0)
	_clear()
	stance = -1
	_buttons()
	fl = Vector3(0, 0, -10)
	_fade(0.0)
	mode = "enter"
	mode_t = 1.0


func _pat() -> Array:
	return PAT[ftype][ph]


## 빈틈 상자 (내가 벨 쪽). -1 이면 숨김
func _show(d: int) -> void:
	for i in 4:
		ind[i].visible = i == d
	if d >= 0:
		ind[d].scale = Vector3.ONE


## 적 칼이 d 쪽에서 올 길: 흐린 잔상 셋(멀리서 가까이), twice 면 들어 올린 칼 옆에 두 번째 칼. -1 이면 숨김
func _path(d: int, twice := false) -> void:
	for i in 4:
		ghosts[i].visible = d >= 0 and (i < 3 or twice)
	if d < 0:
		return
	for i in 3:
		var t: float = [0.35, 0.68, 1.0][i]
		ghosts[i].position = _bpos(d, t)
		ghosts[i].rotation = _brot(d, t)
	ghosts[3].position = _bpos(d, 0.0) + (Vector3(0.38, 0, -0.1) if d < 2 else Vector3(0, 0.38, -0.1)) * (-1.0 if d == 1 else 1.0)
	ghosts[3].rotation = _brot(d, 0.0)


## 적 칼 자리: d 쪽 공격, t 0 = 들어 올린 자리 ~ 1 = 내게 닿는 자리. 모양(sty)마다 길이 다르다.
func _bpos(d: int, t: float) -> Vector3:
	match sty:
		0:
			return (T_WIND[d] as Vector3).lerp(T_HIT[d], t)
		2:
			# 크게 젖힌 자리에서 바깥으로 둥글게 돌아 내려온다
			var a: Vector3 = WIND[d] * 1.25 + Vector3(0, 0.35, -0.5)
			var h: Vector3 = HIT[d]
			var mid: Vector3 = (a + h) * 0.5 + LEAN[d] * 0.9 + Vector3(0, 0, 0.3)
			return a.lerp(mid, t).lerp(mid.lerp(h, t), t)
	return (WIND[d] as Vector3).lerp(HIT[d], t)


func _brot(d: int, t: float) -> Vector3:
	match sty:
		0:
			# 칼(긴 쪽)이 찌르는 방향을 향한다
			var dir: Vector3 = (T_HIT[d] - T_WIND[d]).normalized()
			return Basis(Quaternion(Vector3.UP, dir)).get_euler()
		2:
			return Vector3(0, 0, ROT[d] + SWING[d] * lerpf(1.1, -0.35, t))
	return Vector3(0, 0, ROT[d])


## 이 수의 공격 모양: 검객 성향대로. 끝판왕은 수에 맞춰 넷을 섞는다.
func _style(mv: Array) -> int:
	if ftype == 3:
		return 2 if drawn else 3  # 거합: 뽑은 뒤엔 크게 베어 들어온다
	if ftype < 4:
		return ftype
	if _flag(mv) == 2:
		return 3
	if _flag(mv) == 1 or _twice_next():
		return 2
	if int(mv[0]) != int(mv[1]):
		return 1
	return 0 if (ci + mi) % 2 == 0 else 2


func _clear() -> void:
	_show(-1)
	_path(-1)
	_link_show(false)


## 연격이 오는가: 2단부터(끝판왕은 늘) 연속기의 다음 칼이 이번 칼과 겹쳐 온다. 베기 검객의 두 번째 칼·거합은 빼고
func _link_next() -> bool:
	if tut >= 0 or (ph < 1 and ftype != 4):
		return false
	var c: Array = _pat()[2][ci]
	if mi + 1 >= c.size() or _flag(c[mi]) == 2 or (ftype == 3 and not drawn):
		return false
	return _flag(c[mi + 1]) == 0


## 연격 칼(노랑)을 다음 칼 쪽에 들어 올려 두고 주황 잔상으로 길을 보여 준다. false 면 숨김
func _link_show(on: bool) -> void:
	link = on
	if link_b == null:
		return
	link_b.visible = on
	for g in link_g:
		g.visible = on
	if not on:
		return
	var nx: Array = _pat()[2][ci][mi + 1]
	var d: int = dmap[nx[0]]
	var keep := sty
	mi += 1
	sty = _style(nx)
	mi -= 1
	for i in 3:
		var t: float = [0.35, 0.68, 1.0][i]
		link_g[i].position = _bpos(d, t)
		link_g[i].rotation = _brot(d, t)
	link_b.position = _bpos(d, 0.0)
	link_b.rotation = _brot(d, 0.0)
	sty = keep


func _rest(g: float) -> void:
	blade_m.material_override = mat(WHITE)
	fs = 0
	fs_t = 0.0
	gap = g * spd
	_clear()


func _relax(dt: float) -> void:
	fl = fl.lerp(Vector3.ZERO, minf(1.0, dt * 10.0))
	piv.rotation.z = lerpf(piv.rotation.z, 0.0, minf(1.0, dt * 10.0))
	blade_m.position = blade_m.position.lerp(blade_rest, minf(1.0, dt * 10.0))
	blade_m.rotation = blade_m.rotation.lerp(blade_rr, minf(1.0, dt * 10.0))


func _step(dt: float) -> void:
	score = n
	# 막은 순간 잠깐 멈춤 (불꽃은 그 자리에 멈춰 보였다가 튄다)
	if hitstop > 0.0:
		hitstop -= dt
		return
	_sparks(dt)
	if fx:
		fx.tick(dt)
	var fdt := dt
	if slow > 0.0:
		slow -= dt
		fdt = dt * SLOW
		if slow <= 0.0:
			_floor(SOFT)
	if stun > 0.0:
		stun -= dt
	if whiff_t > 0.0:
		whiff_t -= dt
		if whiff_t <= 0.0:
			_floor(B if slow > 0.0 else SOFT)
	mode_t -= dt
	# 버튼: 누르고 밀면 _btn_drag 에서 바로, 안 밀고 떼거나 잠깐 누르고 있으면 잡아 둔 방향으로
	for k in ["guard", "cut"]:
		if pend.has(k):
			pend[k] += dt
			if pend[k] >= BTN_WAIT:
				_btn_fire(k)
	match mode:
		"intro", "shift":
			_relax(dt)
			if mode_t <= 0.0:
				mode = "fight"
				_rest(0.5)
		"fight":
			if not hold:
				_fight(fdt)
		"fall":
			if anim:
				if anim.current_animation != "Death":
					anim.play("Death")
			else:
				piv.rotation.x = lerpf(piv.rotation.x, -1.45, minf(1.0, dt * 5.0))
			fl = fl.lerp(Vector3(-1.6, -1.3, -1.5), minf(1.0, dt * 5.0))
			if mode_t <= 0.0:
				_open_pick()
		"lobby":
			_relax(dt)
		"enter":
			fl = fl.lerp(Vector3.ZERO, minf(1.0, dt * 4.0))
			_fade(clampf(1.0 - mode_t, 0.0, 1.0))  # 적이 스르륵 나타난다 (10/31)
			if mode_t <= 0.0:
				_fade(1.0)
				_intro()
		"dead":
			if mode_t <= 0.0:
				if ftype == 4:
					last_run = _f("last_dmg", [n + 1, boss_dmg, _perk_text()])
				else:
					last_run = _f("last_dead", [n + 1, _perk_text()])
				last_run = _f("got_coin", [run_coin]) + "\n" + last_run
				lobby_k = n
				_to_lobby(0)
	piv.position = fl
	_rig_pose()
	mark.position = piv.position
	if fx:
		fx.trail(blade_m, mode == "fight" and fs == 1 and shown)
	mark.rotation.z = piv.rotation.z
	stance_l.visible = mode != "lobby"
	_score_l.visible = mode != "lobby"
	stance_l.text = _s("stance_none") if stance < 0 else _f("stance", [ARROW[stance]])
	if flash_t > 0.0:
		flash_t -= dt
		if flash_t <= 0.0:
			_tint(null)
	cam.position = cam_base
	if shake_t > 0.0:
		shake_t -= dt
		cam.position += Vector3(randf_range(-0.12, 0.12), randf_range(-0.12, 0.12), 0)
	# 화면 글자
	if tut >= 0:
		_bar_bg.visible = false
		info_l.text = "튜토리얼"
		blink += dt
		tut_l.modulate.a = 0.55 + 0.45 * absf(cos(blink * 4.0)) if hold or tut == 4 else 1.0
	elif mode == "lobby":
		_bar_bg.visible = false
		info_l.text = ""
	else:
		gauge(float(life) / float(max_life), GOOD if life > foe_atk else BAD)
		if ftype == 4:
			info_l.text = _f("info_boss", [maxi(life, 0), max_life, n + 1, boss_dmg, foe_atk])
		else:
			info_l.text = _f("info", [maxi(life, 0), max_life, n + 1, maxi(foe_hp, 0), foe_max, foe_atk])


func _fight(dt: float) -> void:
	fs_t += dt
	# 튜토리얼: 맞는 순간에 멈추고 기다린다
	if tut >= 0 and tut < 4:
		var stop := false
		if fs == 1:
			stop = (tut == 0 and fs_t >= 0.55) or (tut == 2 and fs_t >= win - 0.08)
		elif fs == 2:
			stop = (tut == 1 or tut == 3) and fs_t >= 0.05
		if stop:
			hold = true
			tut_l.text = _s("tut%d" % tut)
			return
	var k := 0.0
	match fs:
		0:
			_relax(dt)
			if fs_t >= gap:
				_attack()
		1:
			if not shown:
				# 거합: 가만히 서 있다가, 눈이 번쩍하면 칼이 그쪽으로 간다
				if not told and fs_t >= tell_at:
					told = true
					for e in eyes:
						e.material_override = mat(WHITE)
					sfx(SND["iai1"])
				if told:
					# 발도 (10/31): 먼저 손잡이가 앞으로 쑥 나오고, 이어 칼이 칼집에서 빠져 그쪽으로 간다
					var p := (fs_t - tell_at) / maxf(0.01, show_at - tell_at)
					if p < 0.45:
						var out := sheath_p - Vector3(0.3, -0.35, -0.89).normalized() * 0.6
						blade_m.position = blade_m.position.lerp(out, minf(1.0, dt * 16.0))
						blade_m.rotation = blade_m.rotation.lerp(sheath_rr, minf(1.0, dt * 16.0))
					else:
						blade_m.position = blade_m.position.lerp(_bpos(sdir, 0.0), minf(1.0, dt * 22.0))
						blade_m.rotation = blade_m.rotation.lerp(_brot(sdir, 0.0), minf(1.0, dt * 22.0))
					fl = fl.lerp(Vector3(0, -0.15, 0), minf(1.0, dt * 6.0))
				else:
					_relax(dt)
					if ftype == 4:
						# 끝판왕의 발도 수: 칼을 허리 칼집 자리에 넣고 기다린다
						blade_m.position = blade_m.position.lerp(sheath_p, minf(1.0, dt * 10.0))
						blade_m.rotation = blade_m.rotation.lerp(sheath_rr, minf(1.0, dt * 10.0))
				if fs_t < show_at:
					return
				shown = true
				if ftype == 3:
					_hold(true)
				_eyes()
				_path(sdir)
				sfx(SND["iai2"])
			# 연격: 처음엔 흰 칼 하나만, 반쯤 와서야 노랑 칼이 뒤에 붙는다 (10/31)
			if link and fs_t >= link_at and not link_b.visible:
				_link_show(true)
			# 간파할 수 있는 거리에 들어오면 칼이 빨갛게 (맑은 눈으로 넓어지면 더 일찍 빨개진다)
			var can := win - fs_t <= _per() and not (feint_at >= 0.0 and fs_t < feint_at)
			var bc := mat(BAD if can else WHITE)
			if blade_m.material_override != bc:
				blade_m.material_override = bc
			if feint_at >= 0.0 and fs_t >= feint_at and sdir != rdir:
				sdir = rdir
				_path(rdir, _twice_next())
			k = clampf((fs_t - show_at) / (win - show_at), 0.0, 1.0)
			var l: Vector3 = LEAN[sdir]
			match sty:
				0:
					# 찌르기: 옆으로 기울지 않고 곧게 뛰어든다
					fl = Vector3(l.x * 0.1 * k, l.y * 0.08 * k, 1.3 * k * k)
					piv.rotation.z = 0.0
				2:
					# 베기: 몸을 크게 틀어 실어 벤다
					fl = Vector3(l.x * 0.5 * k, l.y * 0.3 * k, 1.6 * k * k)
					piv.rotation.z = -l.x * 0.45 * k
				_:
					fl = Vector3(l.x * 0.35 * k, l.y * 0.25 * k, 1.8 * k * k)
					piv.rotation.z = -l.x * 0.25 * k
			# 칼은 들어 올린 자리에서 버티다 끝에 몰아쳐 잔상 길을 따라 내게 온다
			var bp := _bpos(sdir, k * k * k)
			var br := _brot(sdir, k * k * k)
			if sty == 0 and k < 0.85:
				bp.z -= 0.15 * k  # 찌르기: 칼을 조금씩 더 당겼다가
			elif sty == 1 and feinting and k < 0.8:
				br.z += sin(fs_t * 16.0) * 0.08 * (1.0 - k)  # 속임수: 진짜 속임수일 때만 칼끝이 살짝 흔들린다 (10/31)
			blade_m.position = blade_m.position.lerp(bp, minf(1.0, dt * 22.0))
			blade_m.rotation = blade_m.rotation.lerp(br, minf(1.0, dt * 18.0))
			if fs_t >= win + (PARRY_LATE if tut < 0 else 0.0):
				_hurt()
		2:
			k = clampf(fs_t / win, 0.0, 1.0)
			fl = fl.lerp(Vector3(0, 0, -0.7), minf(1.0, dt * 14.0))
			# 막힌 칼은 온 쪽 바깥으로 튕겨 나가 반대쪽이 빈다
			blade_m.position = blade_m.position.lerp(WIND[rdir] * 1.15 + Vector3(0, 0.3, -0.3), minf(1.0, dt * 12.0))
			blade_m.rotation.z = lerpf(blade_m.rotation.z, ROT[rdir] + 0.7, minf(1.0, dt * 12.0))
			ind[odir].scale = Vector3.ONE * (1.2 - 0.6 * k)
			if fs_t >= win:
				_rest(_pat()[0])
		3:
			if fs_t >= 0.5:
				_rest(_pat()[0])
		5:
			# 앞 절반은 흰 칼, 뒤 절반은 노랑 칼로 바뀌며 살짝 더 젖힌다 (곧 온다)
			if fs_t >= beat * 0.5 and blade_m.material_override != mat(D):
				blade_m.material_override = mat(D)
			var bp := _bpos(sdir, 0.0)
			if fs_t >= beat * 0.5:
				bp += (bp - Vector3(0, 0.3, 0)).normalized() * 0.12
			blade_m.position = blade_m.position.lerp(bp, minf(1.0, dt * 18.0))
			if fs_t >= beat:
				_attack(true)
		4:
			fl = fl.lerp(Vector3(0, 0, -0.9), minf(1.0, dt * 8.0))
			if fs_t >= 0.45:
				if tut == 4:
					_tut_done()
				else:
					_rest(_pat()[0])


## linked = 앞 칼을 그냥 막아서 이미 오던 연격 칼이 이어 들어온다 (텀 뒤, 예비 시간 조금 짧음)
func _attack(linked := false) -> void:
	var mv: Array
	if tut >= 0:
		mv = TUT_MV[0 if tut < 2 else 1]
		if tut == 2:
			tut_l.text = _s("tut_wait")
	else:
		mv = _pat()[2][ci][mi]
		if mi == 0 and not linked:
			dmap.shuffle()
		if ftype == 3:
			# 거합: 칼집에 있으면 발도, 뽑아 든 채면 발도 칸도 그냥 베기
			if not drawn:
				mv = [mv[0], mv[1], 0, 2]
			elif _flag(mv) == 2:
				mv = [mv[0], mv[1], 0.6]
	sdir = mv[0] if tut >= 0 else dmap[mv[0]]
	rdir = mv[1] if tut >= 0 else dmap[mv[1]]
	sty = 0 if tut >= 0 else _style(mv)
	fs = 1
	fs_t = 0.0
	if _flag(mv) == 2:
		# 거합: 서 있는 시간은 무작위, 뽑는 건 순식간
		win = randf_range(1.0, 2.4)
		show_at = win - maxf(0.14, 0.22 * spd)  # 10/31: 뽑는 칼이 더 빠르게 (0.32 → 0.22)
		tell_at = win - maxf(0.4, 0.6 * spd)
		told = false
		shown = false
		feint_at = -1.0
		blade_m.material_override = mat(WHITE)
		_clear()
		if ftype == 3:
			drawn = true
		return
	win = float(mv[2]) * (1.0 if tut >= 0 else spd)
	blade_m.material_override = mat(WHITE)
	if linked:
		# 이미 오고 있던 칼: 노랑 칼 자리에서 이어서, 막을 틈은 넉넉히 남긴다
		win = maxf(0.45, win * 0.85)
		blade_m.position = _bpos(sdir, 0.0)
		blade_m.rotation = _brot(sdir, 0.0)
	if _flag(mv) == 1:
		# 두 번째 칼: 튕겨 나간 칼을 바로 다시 크게 젖혀 들고, 막을 틈은 남긴다
		win = maxf(0.4, win)
		blade_m.position = _bpos(sdir, 0.0)
		blade_m.rotation = _brot(sdir, 0.0)
		fl = Vector3(0, 0, -0.3)
	show_at = 0.0
	tell_at = -1.0
	told = true
	shown = true
	feint_at = win * 0.5 if sdir != rdir else -1.0
	feinting = feint_at >= 0.0
	_path(sdir, _twice_next())
	_link_show(false)
	link = _link_next()
	link_at = win * 0.5
	# 느린 예비 동작은 낮은 소리, 갑작스러운 건 높은 소리


## 연격 사이 텀 (10/31): 막은 뒤 다음 칼이 그 자리에 들린 채 잠깐 서서 흰색 → 노랑으로 바뀐 뒤 들어온다
func _link_beat() -> void:
	var mv: Array = _pat()[2][ci][mi]
	sdir = dmap[mv[0]]
	sty = _style(mv)
	fs = 5
	fs_t = 0.0
	beat = maxf(0.4, 0.6 * spd)
	_clear()
	blade_m.material_override = mat(WHITE)
	blade_m.position = _bpos(sdir, 0.0)
	blade_m.rotation = _brot(sdir, 0.0)
	msg(_s("link"), 0.5)


func _flag(mv: Array) -> int:
	return int(mv[3]) if mv.size() > 3 else 0


## 다음 칼이 같은 쪽으로 바로 이어지면 상자를 두 겹으로 보인다
func _twice_next() -> bool:
	if tut >= 0:
		return false
	var c: Array = _pat()[2][ci]
	return mi + 1 < c.size() and _flag(c[mi + 1]) == 1


func _hurt() -> void:
	msg(_f("hurt", [foe_atk]), 0.5)
	sfx(SND["hit"], 0.72)  # 내가 맞음: 적중 소리를 낮게 (10/31)
	_hold(false)
	if fx:
		fx.hit(blade_m.global_position, blade_m.global_transform.basis.y.normalized() if sty == 0 else Vector3.ZERO)
	fs = 3
	fs_t = 0.0
	_clear()
	_eyes()
	ci = (ci + 1) % _pat()[2].size()
	mi = 0
	_damage(foe_atk)


func _damage(v: int) -> void:
	life -= v
	shake_t = 0.22
	if life <= 0 and tut < 0 and _tl("t_last") > 0 and not last_used:
		last_used = true
		life = 1
		msg(_s("last"), 1.0)
		return
	if life <= 0:
		sfx(SND["death"])
		mode = "dead"
		mode_t = 1.4
		msg(_s("dead"), 1.4)
		deaths[ftype] += 1
		best_n = maxi(best_n, n)
		if ftype == 4:
			best_dmg = maxi(best_dmg, boss_dmg)
		run_coin = int(round(run_coin * (1.0 + 0.25 * _tl("t_coin"))))
		coin += run_coin
		_save()


## 빈틈이 아닐 때 휘두름: 체력 -1, 잠깐 굳고, 상대가 바로 친다
## wrong = 빈틈은 열렸는데 엉뚱한 쪽으로 벰 (공격 실패 소리)
func _whiff(wrong := false) -> void:
	sfx(SND["miss"] if wrong else SND["whiff"])
	if fx and stance >= 0:
		fx.swing(ind[stance].global_position, stance)  # 빗나감: 충돌 없이 잔상만
	var steady := _lv("steady") > 0  # 능력 "흔들림 없는 손": 체력은 안 깎인다
	msg(_s("whiff_steady") if steady else _s("whiff"), 0.9)
	stun = 0.55 - 0.1 * _tl("t_stun")
	whiff_t = 0.35
	_floor(BAD)
	if fs != 1:
		ci = (ci + 1) % _pat()[2].size()
		mi = 0
		_rest(0.12)
	if not steady:
		_damage(1)


## 헛막기: 칼이 오지 않을 때 막기. 피해는 없지만 잠깐 굳어서 진짜 칼을 놓칠 수 있다
func _empty_guard() -> void:
	msg(_s("eguard"), 0.5)
	stun = 0.35


## 버튼: a 0 = 막기, 1 = 베기. 방향은 밀어서 잡아 둔 stance.
func _act(a: int) -> void:
	if mode == "ready":
		_start_run()
		return
	if mode == "dead" or mode == "lobby" or mode == "pick" or mode == "picked":
		return
	if stun > 0.0:
		# 굳어서 못 휘두름: 베기는 헛공격 소리만 (벌은 없음)
		if a == 1 and tut < 0:
			sfx(SND["whiff"])
		return
	var d := stance
	if tut >= 0:
		if not hold:
			return
		var want: int = rdir if fs == 1 else odir
		var want_a := 0 if fs == 1 else 1
		if d != want:
			msg(_f("tut_dir", [ARROW[want]]), 0.8)
			return
		if a != want_a:
			msg(_f("tut_btn", [_s(["btn_guard", "btn_cut"][want_a])]), 0.8)
			return
		hold = false
		tut += 1
		tut_l.modulate.a = 1.0
		tut_l.text = _s("tut_good")
		if fs == 1:
			_parry(tut == 3)
		else:
			_cut()
		return
	if mode != "fight":
		if a == 1:
			sfx(SND["whiff"])
		return
	if a == 0:
		# 막기: 칼이 보일 때만. 잡은 방향이 다르거나 속임수에 먼저 막으면 맞는다
		if fs == 1 and told:
			var fooled := feint_at >= 0.0 and fs_t < feint_at
			if d == rdir and not fooled:
				_parry(_is_parry())
			else:
				_hurt()
		elif fs == 2 and gp:
			# 간파 빈틈에 헛막기: 간파 기회도 사라진다 (10/31)
			_lose_chance()
			_empty_guard()
			msg("%s\n%s" % [_s("eguard"), _s("lose")], 0.6)
		elif fs == 0 or fs == 1 or fs == 2 or fs == 5:
			_empty_guard()
		return
	# 베기: 빈틈에 맞는 쪽만. 그 밖에는 헛공격
	match fs:
		2:
			if d == odir:
				_cut()
				msg(_s("cut"), 0.35)
			elif gp:
				_lose_chance()
			else:
				_whiff(true)
		0, 1:
			_whiff()
		_:
			# 맞은 직후·벤 직후에 또 휘두름: 벌은 없고 헛공격 소리만
			sfx(SND["whiff"])


## 간파 빈틈에 엉뚱한 쪽으로 휘두름: 피해 없이 간파만 끝난다
func _lose_chance() -> void:
	sfx(SND["miss"])
	if fx and stance >= 0:
		fx.swing(ind[stance].global_position, stance)
	msg(_s("lose"), 0.6)
	gp = false
	slow = 0.0
	_floor(SOFT)
	_rest(0.12)


func _parry(perfect: bool) -> void:
	# 베기 검객의 두 칼: 둘 다 간파 타이밍에 막아야 간파. 하나만 맞추면 그냥 막기 (10/31)
	var combos: Array = _pat()[2]
	var first_p := false
	if tut < 0 and _flag(combos[ci][mi]) == 1:
		perfect = perfect and tw_p
	elif tut < 0 and mi + 1 < combos[ci].size() and _flag(combos[ci][mi + 1]) == 1:
		tw_p = perfect
		first_p = perfect
		perfect = false
	# 연격이 오던 중: 그냥 막으면 연격 칼이 바로 들어오고, 간파하면 다 끊긴다
	var linked := link and not perfect
	_link_show(false)
	blade_m.material_override = mat(WHITE)
	# 칼이 막히면 폰 진동, 간파는 더 길고 세게
	_buzz(160 if perfect else 45, 1.0 if perfect else 0.5)
	# 진동과 같은 순간: 칼 부딪친 자리에 불꽃, 화면 잠깐 멈춤 (간파는 더 많이·더 길게)
	if fx:
		if perfect:
			fx.parry(blade_m.global_position)
		else:
			fx.block(blade_m.global_position)
	else:
		_burst(blade_m.global_position, 26 if perfect else 14, perfect)
		hitstop = 0.09 if perfect else 0.05
	shake_t = maxf(shake_t, 0.12 if perfect else 0.06)
	# 간파 = 패링 소리, 그냥 막기 = 이번 칼 모양의 막기 소리
	sfx(SND["parry"] if perfect else BLOCK_SND[sty])
	_tint(WHITE)
	flash_t = 0.1
	fl = Vector3(0, 0, -0.4)
	_eyes()
	mi += 1
	# 베기 검객의 두 번째 칼: 첫 칼을 간파해도 끊기지 않고 반드시 한 번 더 온다
	var twice: bool = tut < 0 and mi < combos[ci].size() and _flag(combos[ci][mi]) == 1
	if tut < 0:
		blocks += 1
		if perfect:
			perfects += 1
			# 능력 "숨 고르기": 간파하면 체력이 조금 찬다
			if _lv("leech") > 0 and life < max_life:
				life = mini(max_life, life + _lv("leech"))
		msg(_s("parry") if perfect else _s("block"), 0.6)
	if first_p:
		msg(_s("parry_twice"), 0.7)
	elif perfect:
		slow = 0.7
		_floor(B)
		if tut < 0:
			msg(_s("parry_go"), 0.8)
	# 간파하면 연속기 중간이라도 끊고 내가 벨 차례 (초록 상자)
	if linked and mi < combos[ci].size():
		_link_beat()
		return
	if twice or (tut < 0 and not perfect and mi < combos[ci].size()):
		# 그냥 막은 뒤 다음 칼은 숨 돌릴 틈을 두고 온다 (10/31: 0.12 → 0.6)
		_rest(0.03 if twice else 0.6)
		return
	ci = (ci + 1) % combos.size()
	mi = 0
	# 베기 검객: 두 칼 다 간파하지 않으면 빈틈이 거의 안 난다 (10/31: 그냥 막기는 20%만)
	if tut < 0 and ftype == 2 and not perfect and randf() >= 0.2:
		msg(_s("no_gap"), 0.7)
		_rest(0.5)
		return
	fs = 2
	fs_t = 0.0
	gp = perfect
	win = float(_pat()[1]) * (1.8 if perfect else 1.0) * (1.0 + 0.3 * _lv("gap") + 0.1 * _tl("t_gap"))
	odir = OPP[rdir]  # 빈틈은 늘 마지막 칼이 온 쪽의 반대 (간파든 막기든)
	_path(-1)
	_show(odir)


func _cut() -> void:
	sfx(SND["hit"])
	if fx:
		fx.swing(ind[odir].global_position, odir)
		fx.hit(ind[odir].global_position)
		shake_t = maxf(shake_t, 0.08)
	var x := 3 if _tl("t_x3") > 0 else 2
	var dmg := _pow() * (x if gp else 1)  # 간파로 연 빈틈에 벤 칼은 피해 두 배 (강화하면 세 배)
	_tint(GOOD)
	flash_t = 0.15
	if anim and foe_hp - dmg > 0:
		anim.play("Hit")
	fl = Vector3(0, 0, -1.2)
	fs = 4
	fs_t = 0.0
	_clear()
	_hold(false)
	if tut >= 0:
		return
	foe_hp -= dmg
	if gp:
		msg(_s("x3" if x == 3 else "x2"), 0.6)
	if ftype == 4:
		boss_dmg += dmg
		run_coin += 1  # 끝판왕은 벨 때마다 1냥
		foe_hp = maxi(foe_hp, 1)  # 끝판왕은 쓰러지지 않는다
	_hp_bar()
	if foe_hp <= 0:
		kills[ftype] += 1
		var got := 4 + 2 * n  # 냥: 뒤 상대일수록 많이
		run_coin += got
		life = mini(max_life, life + _tl("t_mend"))
		_save()
		mode = "fall"
		mode_t = 1.4
		msg(_f("win_coin", [got]), 1.2)
		hp_back.visible = false
		hp_fill.visible = false
		return
	var want := 0
	if ftype == 4:
		cuts += 1
		want = mini(2, cuts / 5)
	elif foe_hp * 3 <= foe_max:
		want = 2
	elif foe_hp * 3 <= foe_max * 2:
		want = 1
	if want > ph:
		ph = want
		ci = 0
		mi = 0
		mode = "shift"
		mode_t = 1.2
		msg(_f("rank", [ph + 1]), 1.0)
		_eyes()



## 검객을 쓰러뜨림: 능력 셋 중 하나를 고른다 (체력은 저절로 차지 않는다)
func _open_pick() -> void:
	n += 1
	best_n = maxi(best_n, n)
	_save()
	var pool: Array = []
	for i in PERKS.size():
		var k: String = PERKS[i][0]
		if _lv(k) >= int(PERKS[i][3]):
			continue
		if k == "mend" and life >= max_life:
			continue
		pool.append(i)
	pool.shuffle()
	pick = pool.slice(0, 3)
	mode = "pick"
	mode_t = 0.45  # 베기를 연타하다 카드를 잘못 누르지 않게 잠깐 막는다
	_btns.clear()
	pend.clear()
	pick_head.text = _f("pick_head", [life, max_life])
	for i in 3:
		pick_bg[i].visible = i < pick.size()
		if i < pick.size():
			var p: Array = PERKS[pick[i]]
			var lv := _lv(p[0])
			pick_l[i].text = "%s%s\n%s" % [_s("pk_" + p[0]), "" if lv == 0 else " (+%d)" % lv, _s("pkd_" + p[0])]
			pick_bg[i].scale = Vector2.ONE
	pick_box.visible = true


func _choose(i: int) -> void:
	var k: String = PERKS[pick[i]][0]
	perk[k] = _lv(k) + 1
	if k == "hp":
		max_life += 4
		life += 4
	elif k == "mend":
		life = mini(max_life, life + ceili(max_life / 2.0))
	msg(_s("pk_" + k), 0.8)
	_press(pick_bg[i]).tween_callback(_next_foe)
	mode = "picked"


func _next_foe() -> void:
	pick_box.visible = false
	_buttons()
	_spawn(n)
	fl = Vector3(0, 0, -10)
	_fade(0.0)
	mode = "enter"
	mode_t = 1.2


func _tut_done() -> void:
	tut_done = true
	_save()
	tut = 4
	hold = true
	mode = "ready"
	_clear()
	tut_l.text = _s("tut_end")


func _tap(p: Vector2) -> void:
	if mode == "lobby":
		_lobby_tap(p)
		return
	if mode == "pick":
		if mode_t <= 0.0:
			for i in pick.size():
				if _pick_r(i).has_point(p):
					_choose(i)
					return
		return
	if mode == "picked":
		return
	if tut >= 0 and skip_l.get_global_rect().grow(16).has_point(p):
		_start_run()
		return
	if mode == "ready":
		_start_run()
		return
	start = p
	armed = true


## 지난 판에 고른 능력 한 줄
func _perk_text() -> String:
	var s: Array = []
	for p: Array in PERKS:
		var lv := _lv(p[0])
		if lv > 0:
			s.append(_s("pk_" + p[0]) if lv == 1 else "%s+%d" % [_s("pk_" + p[0]), lv])
	return _s("no_perk") if s.is_empty() else _s("perks") + ", ".join(s)


func _lobby_tap(p: Vector2) -> void:
	if going:
		return
	if set_box.visible:
		for i in 2:
			for plus in [false, true]:
				if _set_r(i, plus).has_point(p):
					var dv := 1 if plus else -1
					if i == 0:
						vol = clampi(vol + dv, 0, 10)
						_apply_vol()
					else:
						vib = clampi(vib + dv, 0, 10)
						_buzz(160, 1.0)  # 바뀐 세기를 바로 느껴 본다
					_save()
					_set_refresh()
					return
		if SET_LANG.has_point(p):
			lang = "ko" if lang == "en" else "en"
			_set_lang()
			_save()
			_apply_text()
			_set_refresh()
			return
		if SET_CLOSE.has_point(p) or set_btn.get_global_rect().has_point(p) or p.y >= NAV_Y:
			set_box.visible = false
		return
	if lang_btn.get_global_rect().has_point(p):
		_press(lang_btn)
		lang = "ko" if lang == "en" else "en"
		_set_lang()
		_save()
		_apply_text()
		_set_refresh()
		return
	if set_btn.get_global_rect().has_point(p):
		_press(set_btn)
		_set_refresh()
		set_box.visible = true
		return
	for i in TABS.size():
		if _tab_r(i).has_point(p):
			_press(nav_bg[i])
			if i != tab:
				_set_tab(i)
			return
	match tab:
		0:
			# 눌린 버튼이 다시 튀어 오르는 걸 보여 주고 출발
			if play_edge.get_global_rect().has_point(p):
				going = true
				_press(play_edge).tween_callback(_start_run)
			elif tut_again.get_global_rect().has_point(p):
				going = true
				_press(tut_again).tween_callback(_begin_tut)
		1:
			for i in TREE.size():
				if _up_r(int(TREE[i][5]), int(TREE[i][6])).has_point(p):
					_press(up_bg[i].get_parent())
					up_pick = i
					_lobby_refresh()
					return
			if UP_BUY.has_point(p):
				_press(up_buy)
				var row: Array = TREE[up_pick]
				if _tl(row[0]) < int(row[3]) and _up_open(up_pick) and coin >= _cost(up_pick):
					coin -= _cost(up_pick)
					tree[row[0]] = _tl(row[0]) + 1
					_save()
					_buzz(60, 0.6)
					sfx(SND["parry"])
				_lobby_refresh()
		2:
			for i in 5:
				if _dex_r(i).has_point(p):
					_press(dex_bg[i])
					dex_pick = i
					_set_tab(2)
					return


## 버튼 누름 애니메이션: 쑥 들어갔다가 살짝 튀어 오르며 제자리
func _press(c: Control) -> Tween:
	c.pivot_offset = c.size * 0.5
	var s0: Vector2 = c.get_meta("s0", Vector2.ONE)  # UI 편집으로 바꾼 크기로 돌아온다
	var tw := create_tween()
	tw.tween_property(c, "scale", s0 * 0.86, 0.06)
	tw.tween_property(c, "scale", s0, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	return tw


## 불꽃: 노랗고 흰 작은 조각이 사방으로 튀고 떨어지며 줄어든다
func _burst(at: Vector3, count: int, big: bool) -> void:
	for i in count:
		var sm := StandardMaterial3D.new()
		sm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		sm.albedo_color = [Color("fff3bf"), Color("ffd43b"), Color("ffa94d")][i % 3]
		var m := box(at, Vector3.ONE * 0.1, WHITE)
		m.material_override = sm
		var v := Vector3(randf_range(-1, 1), randf_range(-0.6, 1.2), randf_range(0.2, 1.0)).normalized() * randf_range(3.0, 7.0 if big else 5.0)
		var lt := randf_range(0.22, 0.4)
		sparks.append([m, v, lt, lt])


func _sparks(dt: float) -> void:
	for i in range(sparks.size() - 1, -1, -1):
		var sp: Array = sparks[i]
		var m: MeshInstance3D = sp[0]
		sp[2] -= dt
		if sp[2] <= 0.0 or not is_instance_valid(m):
			if is_instance_valid(m):
				m.queue_free()
			sparks.remove_at(i)
			continue
		sp[1].y -= 12.0 * dt
		m.position += sp[1] * dt
		m.scale = Vector3.ONE * 0.1 * (sp[2] / sp[3])


## 밀면 칼 방향만 정한다 (막기·베기는 버튼). 손을 떼지 않고 계속 밀어 방향을 또 바꿀 수 있다.
func _drag(p: Vector2) -> void:
	if not armed:
		return
	var v := p - start
	if v.length() < SWIPE:
		return
	start = p
	if absf(v.x) > absf(v.y):
		_aim(0 if v.x < 0.0 else 1)
	else:
		_aim(2 if v.y < 0.0 else 3)


func _aim(d: int) -> void:
	if mode == "lobby" or mode == "dead" or d == stance:
		return
	stance = d


func _lift(_p: Vector2) -> void:
	armed = false


func _btn_down(k: String, _p: Vector2) -> void:
	if k == "guard" or k == "cut":
		pend[k] = 0.0


## 버튼을 누른 채 밀면: 민 쪽으로 방향을 잡고 그 자리에서 막기/베기
func _btn_drag(k: String, p: Vector2) -> void:
	if not pend.has(k):
		return
	var v: Vector2 = p - _btns[k].at
	if v.length() < BTN_SWIPE:
		return
	if absf(v.x) > absf(v.y):
		_aim(0 if v.x < 0.0 else 1)
	else:
		_aim(2 if v.y < 0.0 else 3)
	_btn_fire(k)


func _btn_up(k: String, _p: Vector2) -> void:
	if pend.has(k):
		_btn_fire(k)


func _btn_fire(k: String) -> void:
	pend.erase(k)
	_act(0 if k == "guard" else 1)


## PC: 방향키/WASD = 칼 방향, J = 막기, K = 베기
func _input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	match event.keycode:
		KEY_LEFT, KEY_A: _aim(0)
		KEY_RIGHT, KEY_D: _aim(1)
		KEY_UP, KEY_W: _aim(2)
		KEY_DOWN, KEY_S: _aim(3)
		KEY_J, KEY_Z: _act(0)
		KEY_K, KEY_X: _act(1)


## 효과음 한 번 (줄 넷을 돌려 써서 겹쳐도 안 끊긴다. 소리 크기 설정은 버스 0 에 걸려 있다). 소리는 파이가 보낸 sfx 뿐이다.
func sfx(st: AudioStream, pitch := 1.0) -> void:
	var p: AudioStreamPlayer = sfx_p[sfx_i]
	sfx_i = (sfx_i + 1) % sfx_p.size()
	p.stream = st
	p.pitch_scale = pitch
	p.play()


## 거합 칼: true = 뽑아 손에 든다, false = 다시 칼집에 넣는다 (쉬는 동안 _relax 가 칼을 그 자리로 옮긴다)
func _hold(on: bool) -> void:
	if ftype != 3:
		return
	drawn = on
	if on:
		blade_rr = Vector3(0, 0, 0.5)
		blade_rest = _grip_rest(hand_p, blade_rr)
	else:
		blade_rest = sheath_p
		blade_rr = sheath_rr
