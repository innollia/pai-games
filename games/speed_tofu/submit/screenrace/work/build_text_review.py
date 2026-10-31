import json, sys
rows = json.load(open(sys.argv[1], encoding='utf-8'))
BS = chr(92)
BACK = {
"Run with the left stick, hop over with [Jump]. / [Box] at a mailbox = deliver. [Box] anywhere else = throw and dash. / Pushed off the left edge, you lose a box. Whoever delivers the most wins!": "왼쪽 스틱으로 달리고 [점프]로 넘어. / 우체통에서 [짐] = 배달. 다른 곳에서 [짐] = 던지고 대시. / 왼쪽 끝에 밀리면 짐 하나를 잃어. 가장 많이 배달한 사람이 이겨!",
"PRESS ONCE MORE TO LEAVE": "한 번 더 누르면 나가",
"Most delivered: Basic %d / Lantern %d / Speeding %d": "최다 배달: 기본 %d / 등불 %d / 과속 %d",
"Night Lantern": "밤 등불", "Speeding": "과속", "Pick a perk": "특전 고르기", "Next road? My boxes %d": "다음 길? 내 짐 %d", "none yet": "아직 없음",
"Bronze": "동", "Silver": "은", "Gold": "금",
"Next time: the shortcut over the scale with 6 boxes!": "다음엔: 짐 6개로 저울 위 지름길!",
"Next time: Speeding Delivery, ceiling boost with 4 boxes!": "다음엔: 과속 배달, 짐 4개로 천장 가속!",
"Next time: Night Lantern, stay close to the leader's light!": "다음엔: 밤 등불, 선두의 빛 가까이 붙어!",
"%s · #%d / Boxes delivered %d · Run time %.1fs / Best course: %s / %s / Most delivered on this device %d%s / Best finish %s / %s / Gold: win within 2 rounds + %d delivered / Silver: within 3 rounds / Bronze: finish the course / Tap the empty space below the stars to deliver again": "%s · %d위 / 배달한 짐 %d개 · 달린 시간 %.1f초 / 최고 코스: %s / %s / 이 기기 최다 배달 %d개%s / 완주 최고 %s / %s / 금: 2판 안에 승리 + 배달 %d개 / 은: 3판 안 / 동: 코스 완주 / 별 아래 빈 곳을 탭하면 다시 배달",
"%.1fs": "%.1f초", "in progress": "진행 중", "All six towns delivered!": "여섯 동네 모두 배달!", "That's all the deliveries for today": "오늘 배달은 이게 다예요",
" · New record!": " · 새 기록!", " / Record not saved": " / 기록 저장 안 됨", "Jump": "점프", "Box": "짐",
"DELIVERED x%d": "배달됨 x%d", "DELIVERED": "배달됨", "%s DELIVERED": "%s 배달함",
"Put boxes in mailboxes! / Whoever puts in the most wins": "우체통에 짐을 넣어! / 가장 많이 넣은 사람이 이겨",
"Keyboard: ←→ run · ↑/Space jump · ↓/Shift [BOX] · Enter start": "키보드: ←→ 달리기 · ↑/Space 점프 · ↓/Shift [짐] · Enter 시작",
"%s · %s round %d · boxes %d": "%s · %s %d판 · 짐 %d", "Last Delivery": "마지막 배달", "Box %d": "짐 %d", "QUICK START!": "빠른 출발!",
"1ST TO FINISH +%d": "1등 도착 +%d", "RIVAL 1ST TO FINISH +%d": "상대가 1등 도착 +%d", "ALL DELIVERED · ON TO THE FINISH!": "모두 배달 · 결승으로!",
"WINNER DECIDED · ON TO THE FINISH!": "승자 결정 · 결승으로!", "CLOSING SOON": "곧 마감", "FIRST CLASS": "1등석", "HEADWIND": "맞바람", "HANDLE WITH CARE": "취급 주의",
"WINDBREAK": "바람막이", "BLACKOUT": "정전", "CROSSING": "건널목", "TRANSIT ACCIDENT": "운송 사고", "OVERWEIGHT": "중량 초과", "DAMAGED": "파손", "LAST PARCEL": "마지막 짐",
"RETURNED": "반송", "UNDELIVERED": "미배달", "MOST DELIVERED · %d": "최다 배달 · %d", "I WON!": "내가 이겼다!", "%s WINS": "%s 승리",
"%s  delivered %d  · wins %d/%d": "%s  배달 %d  · 승 %d/%d", "%s TOOK THE ROUTE": "%s 노선 차지", "Next road: %s / %s": "다음 길: %s / %s",
"Low door: only up to %d boxes get through / Push on and boxes catch and fall off": "낮은 문: 짐 %d개까지만 지나간다 / 밀고 가면 짐이 걸려 떨어진다",
"THROUGH!": "통과!", "OVERSIZE": "규격 초과", "AIR MAIL": "항공편", "ALMOST LATE": "지연 직전", "ME · BOXES %d": "나 · 짐 %d", "HIJACKED BY %s": "%s 가로챔",
"LOST": "분실", "NIGHT DELIVERY": "야간 배송", "HIJACKED": "가로챔", "Start delivery!": "배달 시작!", "SKIP": "건너뛰기", "NICE!": "좋아!", "Push right to run!": "오른쪽으로 밀어 달려!",
"Jump over the crate!": "점프로 상자를 넘어!", "Mailbox on screen = [BOX] turns green: tap to deliver!": "우체통이 화면에 보이면 = [짐]이 초록: 탭해서 배달!",
"[BOX] anywhere else = throw and dash!": "다른 곳에서 [짐] = 던지고 대시!", "Pushed off the left edge = you lose a box!": "왼쪽 끝에 밀리면 = 짐 하나를 잃어!",
"Whoever delivers the most wins!": "가장 많이 배달한 사람이 이겨!", "READY": "준비", "SET": "차렷", "GO!": "출발!", "DELIVER AGAIN": "다시 배달", "#%d · DELIVERED": "%d위 · 배달 완료",
"#%d · CLOSED": "%d위 · 마감", "How was this game?": "이 게임 어때요?", "Close": "닫기", "Rate": "평가", "Leave a comment": "한마디 남기기", "Comment": "한마디", "Tap to start": "탭해서 시작",
"Delivery style": "배달 방식", "< Home": "< 처음", "Next road?": "다음 길은?", "APPROVED": "승인", "Only %d boxes or fewer pass · now %d": "짐 %d개 이하만 통과 · 지금 %d개",
"Ice: heavier = faster": "얼음: 무거울수록 = 빠르다", "Stick right behind the runner ahead": "앞사람 바로 뒤에 붙어라", "Best ×%d": "최고 ×%d", "NEW RECORD!": "새 기록!",
"record not saved": "기록 저장 안 됨", "still going for a finish": "완주 도전 중", "%d boxes · %s": "%d개 · %s", "Give up?": "포기할래요?", "Market": "시장", "Get over the walls": "벽을 넘어라",
"Riverside": "강변", "The floor flows: heavy loads get pushed less": "바닥이 흐른다: 짐이 무거우면 덜 밀린다", "Crossing": "건널목",
"The tracks below are fast. Trains come from the front": "아래 선로는 빠르다. 기차는 앞에서 온다", "Night Market": "야시장",
"Blackout: when the lights go out, nobody sees ahead": "정전: 불이 꺼지면 아무도 앞을 못 본다", "Swaying Bridge": "흔들다리",
"6+ boxes and the boards you step on collapse": "짐 6개 이상이면 밟은 판이 무너진다", "Rooftops": "지붕", "No walls: to cross far gaps you must drop a box": "벽이 없다: 먼 틈을 넘으려면 짐을 버려야 한다",
"Low Door": "낮은 문", "only up to 4 boxes get through": "짐 4개까지만 지나간다", "Ice Downhill": "얼음 내리막", "can't stop, heavier is faster": "못 멈춘다, 무거울수록 빠르다",
"Headwind": "맞바람", "stay behind someone and there's no wind": "누군가 뒤에 붙으면 바람이 없다", "Basic": "기본", "put boxes in mailboxes · the leader can't see ahead": "우체통에 짐을 넣어라 · 1등은 앞이 안 보인다",
"only mailboxes inside the light show · stay close to the light": "빛 안의 우체통만 보인다 · 빛에 붙어라", "Speeding Delivery": "과속 배달", "4 boxes or fewer: ceiling boost / wall bounce": "짐 4개 이하: 천장 가속 / 벽 반동",
"Shoes": "신발", "faster": "더 빨리", "Strap": "끈", "1 more box": "짐 하나 더", "Spring": "용수철", "jump high": "높이 뛰기", "Wind": "바람", "double wind": "바람 두 배", "Light Box": "가벼운 상자",
"boxes weigh 40% less": "짐 무게 40% 덜", "Tough Body": "단단한 몸", "pushed less when hit": "치여도 덜 밀림", "Me": "나", "Red": "빨강", "Mint": "민트", "Yellow": "노랑", "< Menu": "< 메뉴",
"A word about this game (optional)": "이 게임에 한마디 (선택)", "Thanks!": "고마워요!", "Sending": "보내는 중", "Your comment was sent": "한마디를 보냈어요", "Not saved · tap a star again": "저장 안 됨 · 별을 다시 탭",
"%d / Best %d%s": "%d / 최고 %d%s", "Deliver to mailboxes": "우체통에 배달하기", "Find mailboxes in the light": "빛 안의 우체통 찾기", "4 boxes or less: ceiling boost": "짐 4개 이하: 천장 부스트", " / Tap to retry": " / 탭해서 다시",
}

BACK.update({
"PLAY": "[게임 관용어] 플레이(시작)", "PLAY AGAIN": "[게임 관용어] 다시 플레이", "YOU WIN!": "[게임 관용어] 네가 이겼다!", "HURRY UP!": "[게임 관용어] 서둘러!",
"GREAT START!": "[게임 관용어] 좋은 출발!", "TAP AGAIN TO QUIT": "[게임 관용어] 한 번 더 탭하면 나감", "1ST! +%d": "[게임 관용어] 1등! +%d", "RIVAL 1ST! +%d": "[게임 관용어] 상대 1등! +%d",
"READY": "[게임 관용어] 준비", "SET": "[게임 관용어] 차렷", "GO!": "[게임 관용어] 출발!", "SKIP": "[게임 관용어] 건너뛰기", "NICE!": "[게임 관용어] 좋아!", "NEW RECORD!": "[게임 관용어] 새 기록!",
"Only %d boxes get through": "짐 %d개만 지나간다", "Low door: only %d boxes get through / Any more catch on the door and fall off one by one": "낮은 문: 짐 %d개만 지나간다 / 더 많으면 문에 걸려 하나씩 떨어진다",
"%s round %d · boxes %d": "%s %d판 · 짐 %d", "BOXES %d → %d": "짐 %d → %d",
})
DROP = {'모드 카드', '모드 이름', '모드 설명', '하는 법(?) 카드'}
M = {'맨 위 표': '모드 카드', '_finish': '마지막 결과 영수증', '_best_line': '마지막 결과 영수증', '_draw_receipt': '마지막 결과 영수증', '_update_content_hud': '경주 중 위 안내줄', '_step': '경주 중 안내', '_setup': '경주 중 안내', '_draw_all': '경주 중 안내', '_process': '경주 중 안내',
     'restyle_rating': '별점 카드·공용 글', 'restyle_howto': '하는 법(?) 카드', '_apply_word_mode': '제목·연습 버튼', '_fill_modes': '모드 카드', '_draw_mode_over': '모드 카드', '_fill_choice': '특전 카드', '_on_choice': '특전 카드'}
rows = [[M.get(w, w), k.replace(BS + 'n', ' / '), e.replace(BS + 'n', ' / ')] for w, k, e in rows]
order = ['제목·연습 버튼', '연습 말풍선', '하는 법(?) 카드', '모드 카드', '모드 이름', '모드 설명', '출발 카운트다운', '출발 때 큰 안내', '다음 길 안내', '길 이름', '길 설명', '길 카드 설명', '동네 이름', '동네 설명', '배달부 이름', '경주 중 위 안내줄', '경주 중 안내', '낮은 문 안내', '도장(화면에 찍히는 글)', '판 끝 결과판', '특전 카드', '특전 이름', '특전 설명', '마지막 결과 영수증', '메달·기록', '별점 카드·공용 글']
rows = [r for r in rows if r[0] not in DROP]
rows.sort(key=lambda r: (order.index(r[0]) if r[0] in order else len(order), r[0]))
miss = [e for _, _, e in rows if e not in BACK]
out = ['# 화면 밖 경주 — 게임 글자 검수표', '',
       '게임에 나오는 글 %d개예요. 영어는 모두 한글 뜻 그대로 옮겼어요. **"영어 뜻(한글로)"** 칸은 영어를 다시 한글로 옮긴 것이라, 한글 칸과 뜻이 같은지 보시면 돼요.' % len(rows), '',
       '고칠 줄은 번호와 고친 한글만 보내 주세요. 예: `12: 짐을 우체통에 넣어!` 영어는 제가 맞춰 고쳐요.', '',
       '- `%d` 자리에는 숫자, `%s` 자리에는 이름·글이 들어가요.', '- `/` 는 줄바꿈이에요.', '',
       '| 번호 | 어디 | 한글 | 영어 뜻(한글로) | English |', '| --- | --- | --- | --- | --- |']
for i, (w, k, e) in enumerate(rows, 1):
    out.append('| %d | %s | %s | %s | %s |' % (i, w, k.replace('|', '/'), BACK.get(e, '(확인 필요)').replace('|', '/'), e.replace('|', '/')))
open(r'C:/projects/pai-games/games/speed_tofu/submit/screenrace/TEXT_REVIEW.md', 'w', encoding='utf-8', newline='\n').write('\n'.join(out) + '\n')
open(sys.argv[1].replace('.json', '_miss.txt'), 'w', encoding='utf-8').write('\n'.join(miss))
print(len(rows), 'missing back:', len(miss))
